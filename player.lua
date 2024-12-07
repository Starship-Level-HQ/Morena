local shots = require("shot")
local inventory = require("inventory.src.inventory")
local ItemModule = require("inventory.src.item")
local inventoryGuiSrc = require("inventory.src.inventoryGui")

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
        self.shape = love.physics.newRectangleShape(33, 58)              -- размер коллайдера
        self.fixture = love.physics.newFixture(self.body, self.shape, 0) -- коллайдер
        self.fixture:setCategory(cat.PLAYER)                             -- Категория объектов, к которой относится игрок
        self.fixture:setMask(cat.P_SHOT, cat.VOID, cat.PLAYER)           -- Категории, которые игрок игнорирует (свои выстрелы, других игроков и пустоту)
        self.fixture:setUserData(self)
        self.body:setGravityScale(0)
        self.shots = {}                                                  -- holds our fired shots
        self.slashes = {}
        self.health = 100
        self.attackType = true
        self.damage = 10

        self.spriteSheet = love.graphics.newImage('res/sprites/MC1.png')
        self.grid = anim8.newGrid(24, 36, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
        self.animations = {}
        self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.17)
        self.animations.up = anim8.newAnimation(self.grid('1-4', 4), 0.17)
        self.animations.right = anim8.newAnimation(self.grid('1-4', 3), 0.17)
        self.animations.left = anim8.newAnimation(self.grid('1-4', 2), 0.17)
        self.animations.sDown = anim8.newAnimation(self.grid('4-5', 1), 1.1)
        self.animations.sUp = anim8.newAnimation(self.grid('4-5', 4), 1.1)
        self.animations.sRight = anim8.newAnimation(self.grid('4-5', 3), 1.1)
        self.animations.sLeft = anim8.newAnimation(self.grid('4-5', 2), 1.1)

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

        function self:update(dt)
            local isMoving = false
            local speed = self.defaultSpeed
            if self.isDashing then
                speed = speed + self.dashSpeed
            end

            if love.keyboard.isDown("left") then
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(-speed, yv)
                self.anim = self.animations.left
                self.direction = "l"
                self.serverDirectionX = "l"
                isMoving = true
            elseif love.keyboard.isDown("right") then
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(speed, yv)
                self.anim = self.animations.right
                self.direction = "r"
                self.serverDirectionX = "r"
                isMoving = true
            else
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(0, yv)
                self.serverDirectionX = ""
            end

            if love.keyboard.isDown("up") then
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(xv, -speed)
                self.anim = self.animations.up
                self.direction = "u"
                self.serverDirectionY = "u"
                isMoving = true
            elseif love.keyboard.isDown("down") then
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(xv, speed)
                self.anim = self.animations.down
                self.direction = "d"
                self.serverDirectionY = "d"
                isMoving = true
            else
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(xv, 0)
                self.serverDirectionY = ""
            end

            xv, yv = self.body:getLinearVelocity()
            self.direction = physics.calculateDirection(xv, yv, self.direction) -- 45'

            if isMoving == false then
                if self.direction == "d" then
                    self.anim = self.animations.sDown
                elseif self.direction == "u" then
                    self.anim = self.animations.sUp
                elseif self.direction == "r" then
                    self.anim = self.animations.sRight
                else
                    self.anim = self.animations.sLeft
                end
            end

            if love.keyboard.isDown("lshift") and not self.isDashing and self.dashCooldownLeft <= 0 then
                self.isDashing = true
                self.dashTimeLeft = self.dashDuration
                self.fixture:setCategory(cat.DASHING_PLAYER)
                print(self.nearestItem)
            end

            if self.health == 0 then
                self.health = 1
            end
            self.updateEffects(dt)
            self:updateDash(dt)
            self.anim:update(dt)
            self:updateShots(dt)
            self:updateSlash(dt)
            self:updateInventary()
        end

        function self:updateRemotePlayer(dt, remotePlayerData)
            self.health = remotePlayerData.health
            local speed = self.defaultSpeed

            -- Проверяем состояние dash на основе данных от сервера
            if remotePlayerData.isDashing then
                speed = speed + self.dashSpeed
                self.isDashing = true
            else
                self.isDashing = false
            end

            if remotePlayerData.directionX == "l" then
                self.body:setLinearVelocity(-speed, remotePlayerData.yv)
                self.anim = self.animations.left
                self.direction = "l"
            elseif remotePlayerData.directionX == "r" then
                self.body:setLinearVelocity(speed, remotePlayerData.yv)
                self.anim = self.animations.right
                self.direction = "r"
            else
                self.body:setLinearVelocity(0, remotePlayerData.yv)
            end

            if remotePlayerData.directionY == "u" then
                self.body:setLinearVelocity(remotePlayerData.xv, -speed)
                self.anim = self.animations.up
                self.direction = "u"
            elseif remotePlayerData.directionY == "d" then
                self.body:setLinearVelocity(remotePlayerData.xv, speed)
                self.anim = self.animations.down
                self.direction = "d"
            else
                self.body:setLinearVelocity(remotePlayerData.xv, 0)
            end

            if (remotePlayerData.directionX == "" and remotePlayerData.directionY == "") then
                self.anim:gotoFrame(2) -- не движется
            end

            self.direction = physics.calculateDirection(remotePlayerData.xv, remotePlayerData.yv, self.direction)

            -- Обновляем dash-статус и анимацию
            if self.isDashing then
                self.dashTimeLeft = self.dashDuration
                self.fixture:setCategory(cat.DASHING_PLAYER)
            else
                self.fixture:setCategory(cat.PLAYER)
            end

            self:updateDash(dt)
            self.anim:update(dt)
            self:updateShots(dt)
            self:updateSlash(dt)
        end

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

        function self.updateEffects(dt) -- {name, ..param}
            local effectHandlers = {
                Здоровье = function(param) 
                    self.health = self.health + param[2]
                    return nil
                end,
                
                Регенерация = function(param) 
                    if param[3] > 0 then
                        self.health = self.health + param[2] * dt
                        return {param[1], param[2], param[3] - dt}
                    else
                        return nil
                    end
                end,
        
                default = function() 
                    print("Неизвестный эффект")
                    return nil
                end
            }

            for i, effect in ipairs(self.effects) do
                local effectName = effect[1]
                       
                local handler = effectHandlers[effectName] or effectHandlers.default
                local updatedParams = handler(effect)

                if updatedParams then
                    self.effects[i] = updatedParams
                else
                    table.remove(self.effects, i)
                    i = i - 1
                end
            end
        end

        function self:updateInventary()
            if (self.inventoryIsOpen) then self.inventoryGui:update() end
        end

        function self:updateShots(dt)
            local remShot = {}

            -- update the shots
            for i, s in ipairs(self.shots) do
                s.update(remShot, i, dt)
            end

            for i, _ in ipairs(remShot) do
                table.remove(self.shots, i)
            end
        end

        function self:shoot(shotSound)
            --if #self.shots >= 5 then return end
            local shot = shots.new(cat.P_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), 2, 5, 200,
                self.direction, self.damage)
            table.insert(self.shots, shot)
            love.audio.play(shotSound)
        end

        function self:slash(slashSound)
            if #self.slashes >= 1 then return end
            local shot = shots.new(cat.P_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), 30, 30, 13,
                self.direction, self.damage, 3)
            table.insert(self.slashes, shot)
            love.audio.play(slashSound)
        end

        function self:updateSlash(dt)
            local remShot = {}

            -- update the shots
            for i, s in ipairs(self.slashes) do
                s.update(remShot, i, dt)
            end

            for i, _ in ipairs(remShot) do
                table.remove(self.slashes, i)
            end
        end

        function self:updateDash(dt)
            --След
            if self.dashTimeLeft > 0 then
                self.trailTimer = self.trailTimer - dt
                if self.trailTimer <= 0 then
                    table.insert(self.trail,
                        {
                            x = self.body:getX(),
                            y = self.body:getY(),
                            anim = self.anim,
                            alpha = 0.3,
                            lifetime = self
                                .trailDuration
                        })
                    self.trailTimer = self.trailFrequency
                end
            end
            -- Обновление следов во время рывка
            for i, t in ipairs(self.trail) do
                t.lifetime = t.lifetime - dt
                if t.lifetime <= 0 then
                    table.remove(self.trail, i)
                end
            end
            if self.isDashing then
                self.dashTimeLeft = self.dashTimeLeft - dt
                if self.dashTimeLeft <= 0 then
                    self.isDashing = false
                    self.dashCooldownLeft = self.dashCooldown
                end
            elseif self.dashCooldownLeft > 0 then
                self.dashCooldownLeft = self.dashCooldownLeft - dt
            end
            if not self.isDashing then
                self.fixture:setCategory(cat.PLAYER)
            end
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
                  s:drawShot()
                    --love.graphics.rectangle("fill", s.body:getX(), s.body:getY(), s.h, s.w)
                end
            end

            for i, s in ipairs(self.slashes) do
                if not s.body:isDestroyed() then
                    s:drawSlash()
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

        function self:collisionWithEnemy(fixture_b, damage)
            self.health = self.health - damage
            xi, yi = fixture_b:getBody():getLinearVelocity()
            self.body:applyLinearImpulse(xi * 55, yi * 55) --отскок игрока при получении урона, пока слишком резкий, если получится сделать плавным - оставим
        end

        function self:collisionWithShot(damage)
            self.health = self.health - damage
        end

        return self
    end
}
