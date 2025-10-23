Kaban = {}
setmetatable(Kaban ,{__index = Enemy})

function Kaban:new(world, eData)
  local this = Enemy.new(self, world, eData, 300, love.physics.newRectangleShape(60, 54))
  
  this.spriteSheet = love.graphics.newImage('res/sprites/kaban.png')
  this.grid = anim8.newGrid(24, 24, this.spriteSheet:getWidth(), this.spriteSheet:getHeight())
  this.animations = {}
  this.animations.down = anim8.newAnimation(this.grid('1-4', 1), 0.2)
  this.animations.up = anim8.newAnimation(this.grid('1-4', 4), 0.2)
  this.animations.right = anim8.newAnimation(this.grid('1-4', 3), 0.2)
  this.animations.left = anim8.newAnimation(this.grid('1-4', 2), 0.2)
  this.anim = this.animations.left
  this.zoom = 4
  this.widthDivTwo = 12
  this.heightDivTwo = 12

  this.deadSpriteSheet = love.graphics.newImage('res/sprites/kaban-dead.png')
  this.deadGrid = anim8.newGrid(21, 21, this.deadSpriteSheet:getWidth(), this.deadSpriteSheet:getHeight())
  if not userConfig.blood then
    this.deadAnimations = anim8.newAnimation(this.deadGrid('1-1', 1), 1)
  else
    this.deadAnimations = anim8.newAnimation(this.deadGrid('2-2', 1), 1)
  end 

  setmetatable(this,self)
  self.__index = self
  return this
end

