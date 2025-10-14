Shot = {}

function Shot:new(category, world, x, y, h, w, lifeTime, angle, damage, speed)
  if speed == nil then
    speed = 100
  end
  local this = {}
  --physics.makeBody(world, x, y, h, w, "dynamic")
  this.body = love.physics.newBody(world, x, y, "dynamic")
  this.body:setGravityScale(0)
  this.shape = love.physics.newRectangleShape(h, w)
  this.fixture = love.physics.newFixture(this.body, this.shape, 0)
  this.body:setMass(10)
  this.fixture:setCategory(category)
  this.fixture:setUserData(this)
  this.damage = damage
  this.heightDivTwo = 2
  this.widthDivTwo = 2
  this.fixture:setMask(cat.TEXTURE, cat.P_SHOT, cat.E_SHOT, cat.VOID)
  this.lifeTime = lifeTime
  this.time = 0
  this.zoom = 1
  
  this.rotate = angle
  this.body:setLinearVelocity(math.cos(angle) * speed, math.sin(angle) * speed)
  this.body:setAngle(angle)

  function self:update(remShot, i, dt)
    self.time = self.time + dt
    -- mark shots that are not visible for removal
    if self.body:isDestroyed() or self.time > self.lifeTime then
      table.insert(remShot, i)
      if not self.body:isDestroyed() then
        self.fixture:destroy()
        self.body:destroy()
      end
    end
    self.animations:update(dt)
  end
  
  function self:draw()
    xx, yy = self.body:getWorldPoints(self.shape:getPoints())
    self.animations:draw(self.sprite, xx, yy, self.rotate, self.zoom, nil, self.widthDivTwo, self.heightDivTwo)
    --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
  end

  setmetatable(this,self)
  self.__index = self
  return this
end