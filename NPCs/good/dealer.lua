Dealer = {}
setmetatable(Dealer ,{__index = NPC})

function Dealer:new(world, eData)

  local this = NPC.new(self, world, eData, 150, love.physics.newRectangleShape(30, 40))

  this.widthDivTwo = 15
  this.heightDivTwo = 34
  this.spriteSheet = love.graphics.newImage('res/sprites/man.png')
  this.grid = anim8.newGrid(33, 68, this.spriteSheet:getWidth(), this.spriteSheet:getHeight())
  this.health = 50
  this.animations = {}
  this.animations.down = anim8.newAnimation(this.grid('1-1', 1), 0.3)
  this.animations.up = anim8.newAnimation(this.grid('1-1', 1), 0.3)
  this.animations.right = anim8.newAnimation(this.grid('1-1', 1), 0.3)
  this.animations.left = anim8.newAnimation(this.grid('1-1', 1), 0.3)
  this.anim = this.animations.down

  this.deadSpriteSheet = love.graphics.newImage('res/sprites/enemy-dead.png')
  this.deadGrid = anim8.newGrid(12, 18, this.deadSpriteSheet:getWidth(), this.deadSpriteSheet:getHeight())
  this.deadAnimations = anim8.newAnimation(this.deadGrid('1-2', 1), 0.7)

  setmetatable(this,self)
  self.__index = self
  return this
end

function Dealer:die(dt)
  NPC.die(self, dt)
  self.zoom=4
end

function Dealer:communicate(player)
  self.dialog:add("Darova!", 1.3)
end