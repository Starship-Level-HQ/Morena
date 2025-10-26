local RandomLootProvider = require("items/randomLootProvider")

Enemy = {}

function Enemy:new(world, eData, range, shape)
  local this = {}
  this.defaultSpeed = 42
  this.shape = shape
  this.body = love.physics.newBody(world, eData.x, eData.y, "dynamic")         --тело для движения и отрисовки
  this.body:setMass(49)
  this.fixture = love.physics.newFixture(this.body, this.shape, 0) --коллайдер
  this.fixture:setCategory(cat.ENEMY)
  this.fixture:setMask(cat.E_SHOT, cat.VOID, cat.DASHING_PLAYER, cat.TEXTURE, cat.ENEMY)
  this.fixture:setUserData(this)
  this.rangeFixture = love.physics.newFixture(this.body, love.physics.newCircleShape(range), 0) --коллайдер
  this.rangeFixture:setCategory(cat.E_RANGE)
  this.rangeFixture:setMask(cat.E_SHOT, cat.VOID, cat.P_SHOT, cat.ENEMY, cat.TEXTURE)
  this.rangeFixture:setSensor(true)
  this.rangeFixture:setUserData(this)
  this.body:setGravityScale(0)
  this.health = eData.health
  this.range = range
  this.shots = {} -- holds our fired shots
  this.bloodDrops = {}
  this.playerPos = {}
  this.direction = "d"
  this.isAlive = true
  this.isAlive1 = eData.isAlive
  this.tickWalk = math.random(0, 19) / 10
  this.tickShot = math.random(0, 20) / 100
  this.damage = 10

  this.isMoving = false

  this.jumpTime = 0

  this.inventory = Box:new(3, 2)

  if eData.loot == "rnd" then
    eData.loot = RandomLootProvider:newLoot(eData.lootLvl or 1)
  end

  for i, id in ipairs(eData.loot) do
    this.inventory:addItem(ItemModule.create_item(id))
  end

  this.inventoryGui = BoxGui:new(this.inventory)
  this.inventoryIsOpen = false

  setmetatable(this,self)
  self.__index = self
  return this
end

function Enemy:update(dt)

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
        if self.tickShot > self.reload then
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
  else
    if self.inventory then
      if self.inventory:isEmpty() then
        self.inventory = nil
        self.fixture:destroy()
      end
      self.anim:update(dt)
    end
  end

  self:updateShots(dt)
  self:updateBloodDrops(dt)
end

function Enemy:moving(player)
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

end

function Enemy:die(dt)

  self.body:setLinearVelocity(0, 0)
  self.spriteSheet = self.deadSpriteSheet
  self.anim = self.deadAnimations
  self.anim:update(dt)
  --self.fixture:destroy()
  self.fixture:setCategory(cat.ITEM)
  self.fixture:setSensor(true)
  self.rangeFixture:destroy()
  if self.dodgeFixture ~= nil then
    self.dodgeFixture:destroy()
  end
  self.isAlive = false
  if self.isAlive1 then
    self.isAlive1 = false
    self.bloodDrops = physics.bloodDrops(self.body:getWorld(), self.body:getX(), self.body:getY())
  end

end

function Enemy:updateShots(dt)
  local remShot = {}

  -- update the shots
  for i, s in ipairs(self.shots) do
    s:update(remShot, i, dt)
  end

  for i, s in ipairs(remShot) do
    table.remove(self.shots, i)
  end
end

function Enemy:updateBloodDrops(dt)
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

function Enemy:shoot()
  local shot = Arrow:new(cat.E_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), angles.calculateAngle(self.body:getX(), self.body:getY(), self.playerPos[1]:getBody():getX(), self.playerPos[1]:getBody():getY()), 2)
  table.insert(self.shots, shot)
end

function Enemy:collisionAction(player) 
  player.health = player.health - self.damage
  player.stun = 0.2 ; player.stunTime = 0.2
  xi, yi = self.body:getLinearVelocity()
  player.body:applyLinearImpulse(xi * 200, yi * 200) --отскок игрока при получении урона
end

function Enemy:draw(d1, d2, d3, d4)
  for i, s in ipairs(self.shots) do
    if not s.body:isDestroyed() then
      s:draw()
    end
  end

  love.graphics.setColor(1, 0.2, 0.2, 1)
  for i, d in ipairs(self.bloodDrops) do
    if not d.body:isDestroyed() then
      love.graphics.rectangle("fill", d.body:getX(), d.body:getY(), 6, 6)
    end
  end

  if self.collision then
    love.graphics.setColor(1, 1, 0, 1)  -- подсвечиваем предмет (жёлтый цвет)
  else
    love.graphics.setColor(d1, d2, d3, d4)
  end

  local xx
  local yy

  if self.zoom ~= nil then
    xx = self.body:getX()-self.widthDivTwo*self.zoom
    yy = self.body:getY()-self.heightDivTwo*self.zoom
    self.anim:draw(self.spriteSheet, xx, yy, nil, self.zoom)
  else
    xx = self.body:getX()-self.widthDivTwo
    yy = self.body:getY()-self.heightDivTwo
    self.anim:draw(self.spriteSheet, xx, yy)
  end
  --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints())) --Ne udalat
  if self.health > 0 then
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print(self.health, xx, yy-10, 0, 1.8, 1.8)
  end

  love.graphics.setColor(d1, d2, d3, d4)

end

function Enemy:colisionWithShot(shot)
  self.health = self.health - shot.damage
end

function Enemy:seePlayer(playerBody)
  table.insert(self.playerPos, playerBody)
end

function Enemy:dontSeePlayer(playerBody)
  local remP = 0
  for i, p in ipairs(self.playerPos) do
    if p == playerBody then
      remP = i
      break
    end
  end
  table.remove(self.playerPos, remP)
  self.path = nil
end