require("shots/arrow")
shots = require("shot")

Enemy = {
  new = function(world, x, y, range, health, self)
    if not (world and x and y) then
      _log("Enemy requires parameters 'world', 'x', and 'y' to be specified")
      return false
    end

    self.defaultSpeed = 40
    self.body = love.physics.newBody(world, x, y, "dynamic")         --тело для движения и отрисовки
    self.body:setMass(49)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0) --коллайдер
    self.fixture:setCategory(cat.ENEMY)
    self.fixture:setMask(cat.E_SHOT, cat.VOID, cat.DASHING_PLAYER)
    self.fixture:setUserData(self)
    self.rangeFixture = love.physics.newFixture(self.body, love.physics.newCircleShape(range), 0) --коллайдер
    self.rangeFixture:setCategory(cat.E_RANGE)
    self.rangeFixture:setMask(cat.E_SHOT, cat.VOID, cat.DASHING_PLAYER, cat.P_SHOT, cat.ENEMY, cat.TEXTURE)
    self.rangeFixture:setSensor(true)
    self.rangeFixture:setUserData(self)
    self.body:setGravityScale(0)
    self.health = health
    self.range = range
    self.shots = {} -- holds our fired shots
    self.bloodDrops = {}
    self.playerPos = {}

    self.anim = self.animations.left
    self.direction = "l"
    self.isAlive = true
    self.tickWalk = math.random(0, 19) / 10
    self.tickShot = math.random(0, 20) / 100

    self.isMoving = false
    
    self.jumpTime = 0

    function self:update(dt)

      if self.isAlive then
        self.isMoving = false
        if #self.playerPos > 0 then
          local player = self.playerPos[1]

          for i, p in ipairs(self.playerPos) do
            d1, _, _, _, _ = love.physics.getDistance(self.fixture, p)
            d2, _, _, _, _ = love.physics.getDistance(self.fixture, player)
            if d1 < d2 then
              player = p
            end
          end
          
          if self.jumpTime <= 0 then
            self:moving(player)
          end
            
          if self.canShoot then
            if self.tickShot > 0.4 then
              self:shoot()
              self.tickShot = 0
            end
          end

          self.tickWalk = self.tickWalk + dt
          self.tickShot = self.tickShot + dt

          if self.tickWalk > 1.9 then
            self.tickWalk = 0
          end
          
        end

      if self.jumpTime <= 0 then
        if self.isMoving == false then
          self.anim:gotoFrame(2)
          self.body:setLinearVelocity(0, 0)
        end
      else
        self.jumpTime = self.jumpTime - dt
      end
        self.anim:update(dt)

        if self.health <= 0 then
          self:die(dt)
        end
      end

      self:updateShots(dt)
      self:updateBloodDrops(dt)
    end
    
    function self:moving(player)
      local speedX = 0
      local speedY = 0
      local playerX = player:getBody():getX()
      local playerY = player:getBody():getY()

      if self.tickWalk < 1.5 then
      
      if self.body:getX() > playerX and math.abs(self.body:getX() - playerX) > 5 then
              speedX = -self.defaultSpeed
              self.anim = self.animations.left
              self.direction = "l"
              self.isMoving = true
            elseif self.body:getX() < playerX and math.abs(self.body:getX() - playerX) > 5 then
              speedX = self.defaultSpeed
              self.anim = self.animations.right
              self.direction = "r"
              self.isMoving = true
            end

            if self.body:getY() > playerY and math.abs(self.body:getY() - playerY) > 8 then
              speedY = -self.defaultSpeed
              self.anim = self.animations.up
              self.direction = "u"

              self.isMoving = true
            elseif self.body:getY() < playerY and math.abs(self.body:getY() - playerY) > 5 then

              speedY = self.defaultSpeed
              self.anim = self.animations.down
              self.direction = "d"
              self.isMoving = true
            end

            self.body:setLinearVelocity(speedX, speedY)
          else
            self.isMoving = false
          end

          xv, yv = self.body:getLinearVelocity()
          self.direction = physics.calculateDirection(xv, yv, self.direction) -- 45'
      
    end

    function self:die(dt)
      self.body:setLinearVelocity(0, 0)
      self.spriteSheet = self.deadSpriteSheet
      self.anim = self.deadAnimations
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
      local shot = Arrow.new(cat.E_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), self.direction, 2)
      table.insert(self.shots, shot)
    end

    function self:draw(t, d1, d2, d3, d4)
      for i, s in ipairs(self.shots) do
        if not s.body:isDestroyed() then
          s.draw()
        end
      end

      love.graphics.setColor(1, 0.2, 0.2, 1)
      for i, d in ipairs(self.bloodDrops) do
        if not d.body:isDestroyed() then
          love.graphics.rectangle("fill", d.body:getX(), d.body:getY(), 6, 6)
        end
      end
      love.graphics.setColor(d1, d2, d3, d4)
      --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints())) --Ne udalat
      local xx, yy = self.body:getWorldPoints(self.shape:getPoints()) 
      xx = xx - self.width
      yy = yy - self.height
      if self.zoom ~= nil then
        self.anim:draw(self.spriteSheet, xx, yy, nil, self.zoom)
      else
        self.anim:draw(self.spriteSheet, xx, yy)
      end
      --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints())) --Ne udalat
      if self.health > 0 then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print(self.health, xx, yy+self.height-36, 0, 1.8, 1.8)
      end
      love.graphics.setColor(d1, d2, d3, d4)
    end

    function self:colisionWithShot(shot)
      self.health = self.health - shot.damage
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
