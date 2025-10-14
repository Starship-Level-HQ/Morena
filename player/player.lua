local inventory = require("inventory.src.inventory")
local ItemModule = require("inventory.src.item")
local inventoryGuiSrc = require("inventory.src.inventoryGui")
require("shots/slash")
require("shots/arrow")
require("player/playerCollisions")
require("player/playerUpdate")
require("player/playerAnim")

Player = {
    new = function(world, playerData, isRemote)
        if not (world and playerData) then
            _log("Player requires parameters 'world', 'x', and 'y' to be specified")
            return false
        end
        isRemote = isRemote or false

        local self = {}

        self.speed = 150
        self.defaultSpeed = 150

        self.body = love.physics.newBody(world, playerData.x, playerData.y, "dynamic")         -- тело для движения и отрисовки
        self.body:setMass(50)
        self.shape = love.physics.newRectangleShape(33, 58)              -- размер коллайдера
        self.fixture = love.physics.newFixture(self.body, self.shape, 0) -- коллайдер
        self.fixture:setCategory(cat.PLAYER)                             -- Категория объектов, к которой относится игрок
        self.fixture:setMask(cat.P_SHOT, cat.VOID, cat.PLAYER)           -- Категории, которые игрок игнорирует (свои выстрелы, других игроков и пустоту)
        self.fixture:setUserData(self)
        self.body:setGravityScale(0)
        self.shots = {}                                                  -- holds our fired shots
        self.health = playerData.health
        self.damage = 10
        self.attackType = 'slash'
        self.stun = 0
        self.stunTime = 0
        self.zoom = 1

        PlayerAnim.new(self)

        self.anim = self.animations.left
        self.direction = "l"
        self.serverDirectionX = ""
        self.serverDirectionY = ""
        self.isRemote = isRemote

        self.nearestItem = nil
        self.inventory = inventory.new(6, 4)
        
        for i, o in ipairs(playerData.inventory.arr) do
          self.inventory:addItem(ItemModule.create_item(o))
        end
        
        for k, v in pairs(playerData.inventory.activeEquip) do
          local flag = false
          for _, s in ipairs(self.inventory.arr) do
            for _, item in ipairs(s) do
              if item == 0 then
                break
              end
              if item.id == v then
                item.isActive = true
                self.inventory.activeEquip[item.type] = item
                flag = true
                break
              end
            end
            if flag then
              break
            end
          end
        end

        self.inventoryGui = inventoryGuiSrc
        self.inventoryGui:setInventory(self.inventory, 50, 50)
        self.inventoryIsOpen = false

        self.effects = {}

        --Рывок
        self.isDashing = false
        self.dashSpeed = 300
        self.dashDuration = 0.2
        self.dashCooldown = 0.4
        self.dashTimeLeft = 0
        self.dashCooldownLeft = 0

        --След рывка
        self.trail = {}            -- таблица для хранения следов
        self.trailDuration = 0.05  -- как долго следы остаются на экране (в секундах)
        self.trailFrequency = 0.01 -- как часто добавляются следы (в секундах)
        self.trailTimer = 0        -- таймер для добавления следов
        
        PlayerUpdate.new(self)

        function self:mousepressed(xMousepressed, yMousepressed, b)
            if self.inventoryIsOpen then -- проверяем, открыт ли инвентарь
                local callback = self.inventoryGui:mousepressed(xMousepressed, yMousepressed, b)
                if not callback then 
                    return false
                elseif callback.target == "world" then
                    return callback.signature
                elseif callback.target == "Герой" then
                    for _, x in ipairs(callback.signature) do
                        table.insert(self.effects, x)
                    end
                end
            else
              width, height, _ = love.window.getMode( )
              self:attack(angles.calculateAngle(self.body:getX(), self.body:getY(), cam.x+xMousepressed-width/2, cam.y+yMousepressed-height/2))
            end
        end
        
        function self:attack(angle)
          if self.attackType == "slash" then
            if #self.shots >= 1 then return end
            local shot = Slash:new(cat.P_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), angle, 2)
            shot.body:setMass(90)
            if self.inventory.activeEquip["Оружие"] ~= nil then
              shot.damage = shot.damage + self.inventory.activeEquip["Оружие"].effects["Урон"]
            end
            table.insert(self.shots, shot)
          end
          if self.attackType == "shoot" then
            local shot = Arrow:new(cat.P_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), angle, 2)
            table.insert(self.shots, shot)
          end
        end

        function self:pickupItem(from, itemBody)
            itemBody = itemBody or self.nearestItem
            if itemBody then
                local item = from:takeItemByID(itemBody.id)
                if item then
                    self.inventory:addItem(itemBody.item)
                else
                    print("nil item Big Fail")
                end
            else
                print("no near item")
            end
        end

        function self:draw(t, d1, d2, d3, d4)
            -- Устанавливаем прозрачность для удалённых игроков
            if self.isRemote then
                love.graphics.setColor(d1, d2, d3, 0.5) -- 50% прозрачность
            else
                love.graphics.setColor(d1, d2, d3, d4)
            end

            for i, s in ipairs(self.shots) do
                if not s.body:isDestroyed() then
                  s:draw()
                    --love.graphics.rectangle("fill", s.body:getX(), s.body:getY(), s.h, s.w)
                end
            end

            local xx, yy = self.body:getWorldPoints(self.shape:getPoints()) 
             
            --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
            self.anim:draw(self.spriteSheet, xx-10, yy-10, nil, 2.1*self.zoom)

            --След
            love.graphics.setColor(0.7, 0.7, 0.9, 0.2)
            for i = #self.trail, 1, -1 do
                local t = self.trail[i]
                t.anim:draw(self.spriteSheet, t.x, t.y, nil, 2, nil, 12, 19)
            end

            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.print(math.ceil(self.health), xx - 8, yy - 44, 0, 1.8, 1.8)

            love.graphics.setColor(d1, d2, d3, d4)

            --Инвентарь
            if (self.inventoryIsOpen) then
                self.inventoryGui:draw()
            end
        end

        PlayerCollisions.new(self)

        return self
    end
}
