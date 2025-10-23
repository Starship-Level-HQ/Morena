Zombee = {}
setmetatable(Zombee ,{__index = Enemy})

function Zombee:new(world, eData) 
  eData.lootLvl = 2
  local this = Enemy.new(self, world, eData, 350, love.physics.newRectangleShape(24, 60))

  this.widthDivTwo = 6
  this.heightDivTwo = 9
  this.spriteSheet = love.graphics.newImage('res/sprites/enemy-sheet.png')
  this.grid = anim8.newGrid(12, 18, this.spriteSheet:getWidth(), this.spriteSheet:getHeight())
  this.animations = {}
  this.animations.down = anim8.newAnimation(this.grid('1-4', 1), 0.2)
  this.animations.up = anim8.newAnimation(this.grid('1-4', 4), 0.2)
  this.animations.right = anim8.newAnimation(this.grid('1-4', 3), 0.2)
  this.animations.left = anim8.newAnimation(this.grid('1-4', 2), 0.2)
  this.anim = this.animations.down
  this.canShoot = true
  this.reload = 0.5
  this.zoom = 4

  this.deadSpriteSheet = love.graphics.newImage('res/sprites/enemy-dead.png')
  this.deadGrid = anim8.newGrid(12, 18, this.deadSpriteSheet:getWidth(), this.deadSpriteSheet:getHeight())
  if userConfig.blood then
    this.deadAnimations = anim8.newAnimation(this.deadGrid('1-1', 1), 1)
  else
    this.deadAnimations = anim8.newAnimation(this.deadGrid('2-2', 1), 1)
  end
  
  setmetatable(this,self)
  self.__index = self
  return this
end