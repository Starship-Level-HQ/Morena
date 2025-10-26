local RandomLootProvider = require("items/randomLootProvider")

NPC = {}

function NPC:new(world, eData, range, shape)
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
  this.bloodDrops = {}
  this.playerPos = {}
  this.direction = "d"
  this.isAlive = true
  this.isAlive1 = eData.isAlive
  this.tickWalk = math.random(0, 19) / 10

  this.isMoving = false
  this.dialog = {}

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

function NPC:update(dt)

  if self.isAlive then
    self.isMoving = false
    if #self.playerPos > 0 then
      local player = self.playerPos[1]

      self:moving(player)

      self.tickWalk = self.tickWalk + dt

      if self.tickWalk > 1.9 then
        self.tickWalk = 0
      end

    end

    if self.isMoving == false then
      self.anim:gotoFrame(2)
      self.body:setLinearVelocity(0, 0)
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
  if #self.dialog > 0 then
    self.dialog[1].time = self.dialog[1].time - dt
    if self.dialog[1].time <= 0 then
      table.remove(self.dialog, 1)
    end
  end
  self:updateBloodDrops(dt)
end

function NPC:moving(player)

  local speedX = 0
  local speedY = 0
  local playerX = player:getBody():getX()
  local playerY = player:getBody():getY()

  if self.tickWalk < 1.5 then

    if self.body:getX() < playerX and math.abs(self.body:getX() - playerX) > 8 then
      speedX = -self.defaultSpeed
      self.anim = self.animations.left
      self.direction = "l"
      self.isMoving = true
    elseif self.body:getX() > playerX and math.abs(self.body:getX() - playerX) > 8 then
      speedX = self.defaultSpeed
      self.anim = self.animations.right
      self.direction = "r"
      self.isMoving = true
    end

    if self.body:getY() < playerY and math.abs(self.body:getY() - playerY) > 8 then
      speedY = -self.defaultSpeed
      self.anim = self.animations.up
      self.direction = "u"
      self.isMoving = true

    elseif self.body:getY() > playerY and math.abs(self.body:getY() - playerY) > 8 then
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

function NPC:die(dt)

  self.body:setLinearVelocity(0, 0)
  self.spriteSheet = self.deadSpriteSheet
  self.anim = self.deadAnimations
  self.anim:update(dt)
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

function NPC:updateBloodDrops(dt)
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

function NPC:collisionAction(player)
  self.playerPos = {}
  self.collision = true
  player.nearestNpc = self
end

function NPC:communicate(player)
  table.insert(self.dialog, {time = 1.3, text = "Hello?"})
end

function NPC:draw(d1, d2, d3, d4)

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
    xx = self.body:getX()-self.widthDivTwo
    yy = self.body:getY()-self.heightDivTwo
    self.anim:draw(self.spriteSheet, xx, yy, nil, self.zoom)
  else
    xx = self.body:getX()-self.widthDivTwo
    yy = self.body:getY()-self.heightDivTwo
    self.anim:draw(self.spriteSheet, xx, yy)
  end
  --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints())) --Ne udalat
  
  if self.dialog[1] then
    love.graphics.setColor(1, 1, 1, 0.5)
    local text = self.dialog[1].text
    love.graphics.rectangle("fill", self.body:getX() - 25, self.body:getY() - 65, 14*#text, 31)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(text, self.body:getX() - 25, self.body:getY() - 65, 0, 1.6, 1.6)
  elseif self.health > 0 then
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print(self.health, xx, yy-22, 0, 1.6, 1.6)
  end

  love.graphics.setColor(d1, d2, d3, d4)

end

function NPC:colisionWithShot(shot)
  self.health = self.health - shot.damage
end

function NPC:seePlayer(playerBody)
  table.insert(self.playerPos, playerBody)
end

function NPC:dontSeePlayer(playerBody)
  self.playerPos = {}
  self.path = nil
end