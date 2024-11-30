local shots = require("shot")

Enemy = {
    new = function(world, x, y, canShoot, range, health)
        if not (world and x and y) then
            _log("Enemy requires parameters 'world', 'x', and 'y' to be specified")
            return false
        end
        canShoot = canShoot or false

        local self = {}

        self.defaultSpeed = 40
        self.body = love.physics.newBody(world, x, y, "dynamic")         --тело для движения и отрисовки
        --self.body:setMass(49)
        self.shape = love.physics.newRectangleShape(23, 59)              --размер коллайдера
        self.fixture = love.physics.newFixture(self.body, self.shape, 0) --коллайдер
        self.fixture:setCategory(cat.ENEMY)
        self.fixture:setMask(cat.E_SHOT, cat.VOID, cat.DASHING_PLAYER)
        self.fixture:setUserData(self)
        self.rangeFixture = love.physics.newFixture(self.body, love.physics.newCircleShape(range), 0) --коллайдер
        self.rangeFixture:setCategory(cat.E_RANGE)
        self.rangeFixture:setMask(cat.E_SHOT, cat.VOID, cat.DASHING_PLAYER, cat.ENEMY, cat.P_SHOT, cat.TEXTURE)
        self.rangeFixture:setSensor(true)
        self.rangeFixture:setUserData(self)
        self.body:setGravityScale(0)
        self.health = health
        self.range = range
        self.shots = {} -- holds our fired shots
        self.bloodDrops = {}
        self.playerPos = {}

        self.spriteSheet = love.graphics.newImage('res/sprites/enemy-sheet.png')
        self.grid = anim8.newGrid(12, 18, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
        self.animations = {}
        self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2)
        self.animations.up = anim8.newAnimation(self.grid('1-4', 4), 0.2)
        self.animations.right = anim8.newAnimation(self.grid('1-4', 3), 0.2)
        self.animations.left = anim8.newAnimation(self.grid('1-4', 2), 0.2)

        self.anim = self.animations.left
        self.direction = "l"
        self.isAlive = true
        self.tick = x + y % 150
        self.canShoot = canShoot

        function self:update(dt)
            if self.isAlive then
                local isMoving = false

                if #self.playerPos > 0 then
                  local player = self.playerPos[1]
                  for i, p in ipairs(self.playerPos) do
                    d1, _, _, _, _ = love.physics.getDistance(self.fixture, p)
                    d2, _, _, _, _ = love.physics.getDistance(self.fixture, player)
                    if d1 < d2 then
                      player = p
                    end
                  end
                    local speedX = 0
                    local speedY = 0
                    local playerX = player:getBody():getX()
                    local playerY = player:getBody():getY()

                    if self.tick < 100 then
                        if self.body:getX() > playerX and math.abs(self.body:getX() - playerX) > 5 then
                            speedX = -self.defaultSpeed
                            self.anim = self.animations.left
                            self.direction = "l"
                            isMoving = true
                        elseif self.body:getX() < playerX and math.abs(self.body:getX() - playerX) > 5 then
                            speedX = self.defaultSpeed
                            self.anim = self.animations.right
                            self.direction = "r"
                            isMoving = true
                        end

                        if self.body:getY() > playerY and math.abs(self.body:getY() - playerY) > 5 then
                            speedY = -self.defaultSpeed
                            self.anim = self.animations.up
                            self.direction = "u"
                            isMoving = true
                        elseif self.body:getY() < playerY and math.abs(self.body:getY() - playerY) > 5 then
                            speedY = self.defaultSpeed
                            self.anim = self.animations.down
                            self.direction = "d"
                            isMoving = true
                        end

                        self.body:setLinearVelocity(speedX, speedY)
                    else
                        self.body:setLinearVelocity(0, 0)
                        self.anim = self.animations.down
                        isMoving = false
                    end

                    xv, yv = self.body:getLinearVelocity()
                    self.direction = physics.calculateDirection(xv, yv, self.direction) -- 45'

                    if self.canShoot then
                        if self.tick % 5 == 0 then
                            self:shoot()
                        end
                    end

                    self.tick = self.tick + 1

                    if self.tick > 150 then
                        self.tick = 0
                    end
                end

                if isMoving == false then
                    self.anim:gotoFrame(2)
                    self.body:setLinearVelocity(0, 0)
                end

                self.anim:update(dt)

                if self.health <= 0 then
                    self:die(dt)
                end
            end

            self:updateShots(dt)
            self:updateBloodDrops(dt)
        end

        function self:die(dt)
            self.body:setLinearVelocity(0, 0)
            self.spriteSheet = love.graphics.newImage('res/sprites/enemy-dead.png')
            self.grid = anim8.newGrid(12, 18, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
            if userConfig.blood then
                self.anim = anim8.newAnimation(self.grid('1-1', 1), 0.2)
            else
                self.anim = anim8.newAnimation(self.grid('2-2', 1), 0.2)
            end
            self.anim:update(dt)
            self.fixture:destroy()
            self.isAlive = false
            self.bloodDrops = physics.bloodDrops(self.body:getWorld(), self.body:getX(), self.body:getY())
        end

        function self:updateShots(dt)
            local remShot = {}

            -- update the shots
            for i, s in ipairs(self.shots) do
                s.update(remShot, i, dt)
            end

            for i, s in ipairs(remShot) do
                table.remove(self.shots, i)
            end
        end

        function self:updateBloodDrops(dt)
            local remShot = {}

            for i, d in ipairs(self.bloodDrops) do
                d.time = d.time + 1
                if not d.body:isDestroyed() then
                    d.body:setGravityScale(d.time)
                end
                if d.time > 100 then
                    table.insert(remShot, i)
                    if not d.body:isDestroyed() then
                        d.fixture:destroy()
                        d.body:destroy()
                    end
                end
            end

            for i, d in ipairs(remShot) do
                table.remove(self.bloodDrops, d)
            end
        end

        function self:shoot()
            local shot = shots.new(cat.E_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), 2, 5, 150,
                self.direction, 5)
            table.insert(self.shots, shot)
        end

        function self:draw(t, d1, d2, d3, d4)
            for i, s in ipairs(self.shots) do
                if not s.body:isDestroyed() then
                    love.graphics.rectangle("fill", s.body:getX(), s.body:getY(), s.h, s.w)
                end
            end

            love.graphics.setColor(1, 0, 0, 1)
            for i, d in ipairs(self.bloodDrops) do
                if not d.body:isDestroyed() then
                    love.graphics.rectangle("fill", d.body:getX(), d.body:getY(), 4, 5)
                end
            end
            love.graphics.setColor(d1, d2, d3, d4)
            --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
            self.anim:draw(self.spriteSheet, self.body:getX(), self.body:getY(), nil, 4, nil, 6, 9)
            if self.health > 0 then
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.print(self.health, self.body:getX() - 23, self.body:getY() - 65, 0, 2, 2)
            end
            love.graphics.setColor(d1, d2, d3, d4)
        end

        function self:colisionWithShot(damage)
          self.health = self.health - damage
        end
        
        function self:seePlayer(playerBody)
          table.insert(self.playerPos, playerBody)
        end
        
        function self:dontSeePlayer(playerBody)
          local remP = 0
          for i, p in ipairs(self.playerPos) do
            if p == playerBody then
              remP = i
              break
            end
          end
          table.remove(self.playerPos, remP)
        end

        return self
    end
}
