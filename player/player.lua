local shots = require("shot")
local inventory = require("inventory.src.inventory")
local ItemModule = require("inventory.src.item")
local inventoryGuiSrc = require("inventory.src.inventoryGui")
require("shots/slash")
require("shots/arrow")
require("player/playerCollisions")
require("player/playerUpdate")
require("player/playerAnim")

Player = {
    new = function(world, x, y, isRemote)
        if not (world and x and y) then
            _log("Player requires parameters 'world', 'x', and 'y' to be specified")
            return false
        end
        isRemote = isRemote or false

        local self = {}

        self.speed = 150
        self.defaultSpeed = 150

        self.body = love.physics.newBody(world, x, y, "dynamic")         -- тело для движения и отрисовки
        self.body:setMass(50)
        self.shape = love.physics.newRectangleShape(33, 58)              -- размер коллайдера
        self.fixture = love.physics.newFixture(self.body, self.shape, 0) -- коллайдер
        self.fixture:setCategory(cat.PLAYER)                             -- Категория объектов, к которой относится игрок
        self.fixture:setMask(cat.P_SHOT, cat.VOID, cat.PLAYER)           -- Категории, которые игрок игнорирует (свои выстрелы, других игроков и пустоту)
        self.fixture:setUserData(self)
        self.body:setGravityScale(0)
        self.shots = {}                                                  -- holds our fired shots
        self.slashes = {}
        self.health = 100
        self.damage = 10
        self.attackType = 'slash'

        PlayerAnim.new(self)

        self.anim = self.animations.left
        self.direction = "l"
        self.serverDirectionX = ""
        self.serverDirectionY = ""
        self.isRemote = isRemote

        self.nearestItem = nil
        self.inventory = inventory.new(6, 4)
        self.inventory:addItem(ItemModule.create_item(1))
        self.inventory:addItem(ItemModule.create_item(2))
        self.inventory:addItem(ItemModule.create_item(1))
        -- self.inventory:addItem(item.new("Another Thing", "inventory/assets/thing2.png",
        --     "It's another thing. It has colors.", nil))
        -- self.inventory:addItem(item.new("Gold Nugget", "inventory/assets/gold nugget.png",
        --     "I found it lying on the ground. I must be lucky - you can sell one of these for 50 coins...", function() self.health = self.health + 30 end))

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
                callback = self.inventoryGui:mousepressed(xMousepressed, yMousepressed, b)
                if not callback then 
                    return false
                elseif callback.target == "world" then
                    return callback.signature
                elseif callback.target == "Герой" then
                    for _, x in ipairs(callback.signature) do
                        table.insert(self.effects, x)
                    end
                end
            end
        end

        function self:shoot(shotSound)
            --if #self.shots >= 5 then return end
            local shot = shots.new(cat.P_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), 6, 20, 1.4,
                self.direction, self.damage, 2, Arrow.new())
            table.insert(self.shots, shot)
            --love.audio.play(shotSound)
        end

        function self:slash(slashSound)
            if #self.slashes >= 1 then return end
            local shot = shots.new(cat.P_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), 30, 30, 0.3,
                self.direction, self.damage, 3, Slash.new())
            shot.body:setMass(30)
            table.insert(self.slashes, shot)
            --love.audio.play(slashSound)
        end

        function self:pickupItem(from, itemBody)
            itemBody = itemBody or self.nearestItem
            if itemBody then
                item = from:takeItemByID(itemBody.id)
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

            for i, s in ipairs(self.slashes) do
                if not s.body:isDestroyed() then
                    s:draw()
                end
            end

            --love.graphics.polygon("fill", self.player.body:getWorldPoints(player.shape:getPoints()))
            self.anim:draw(self.spriteSheet, self.body:getX(), self.body:getY(), nil, 2.1, nil, 12, 19)

            --След
            love.graphics.setColor(0.7, 0.7, 0.9, 0.2)
            for i = #self.trail, 1, -1 do
                local t = self.trail[i]
                t.anim:draw(self.spriteSheet, t.x, t.y, nil, 2, nil, 12, 19)
            end

            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.print(math.ceil(self.health), self.body:getX() - 24, self.body:getY() - 67, 0, 1.8, 1.8)

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
