require("shots/roots")

Leshiy = {}
setmetatable(Leshiy ,{__index = Enemy})

function Leshiy:new(world, eData)

  local this = Enemy.new(self, world, eData, 350, love.physics.newRectangleShape(66, 190))

  this.widthDivTwo = 60
  this.heightDivTwo = 118
  this.spriteSheet = love.graphics.newImage('res/sprites/leshiy-full.png')
  this.grid = anim8.newGrid(121, 236, this.spriteSheet:getWidth(), this.spriteSheet:getHeight())
  this.animations = {}
  this.animations.down = anim8.newAnimation(this.grid('1-4', 1), 0.3)
  this.animations.up = anim8.newAnimation(this.grid('1-4', 1), 0.3)
  this.animations.right = anim8.newAnimation(this.grid('1-4', 1), 0.3)
  this.animations.left = anim8.newAnimation(this.grid('1-4', 1), 0.3)
  this.anim = this.animations.down
  
  this.canShoot = true
  this.reload = 1.8

  this.deadSpriteSheet = love.graphics.newImage('res/sprites/leshiy-dead.png')
  this.deadGrid = anim8.newGrid(113, 100, this.deadSpriteSheet:getWidth(), this.deadSpriteSheet:getHeight())
  if not userConfig.blood then
    this.deadAnimations = anim8.newAnimation(this.deadGrid('1-1', 2), 1)
  else
    this.deadAnimations = anim8.newAnimation(this.deadGrid('1-1', 1), 1)
  end    

  function self:shoot()
    local shot = Roots:new(cat.E_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), angles.calculateAngle(self.body:getX(), self.body:getY(), self.playerPos[1]:getBody():getX(), self.playerPos[1]:getBody():getY()))
    table.insert(self.shots, shot)
  end

  setmetatable(this,self)
  self.__index = self
  return this
end
