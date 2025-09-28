Kaban = {}

function Kaban:new(world, eData) 
  self = Enemy:new(world, eData, 300, love.physics.newRectangleShape(60, 54))
  
  self.width = 20
  self.height = 24
  self.spriteSheet = love.graphics.newImage('res/sprites/kaban.png')
  self.grid = anim8.newGrid(24, 24, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2)
  self.animations.up = anim8.newAnimation(self.grid('1-4', 4), 0.2)
  self.animations.right = anim8.newAnimation(self.grid('1-4', 3), 0.2)
  self.animations.left = anim8.newAnimation(self.grid('1-4', 2), 0.2)
  self.anim = self.animations.left
  self.zoom = 4

  self.deadSpriteSheet = love.graphics.newImage('res/sprites/kaban-dead.png')
  self.deadGrid = anim8.newGrid(21, 21, self.deadSpriteSheet:getWidth(), self.deadSpriteSheet:getHeight())
  if not userConfig.blood then
    self.deadAnimations = anim8.newAnimation(self.deadGrid('1-1', 1), 1)
  else
    self.deadAnimations = anim8.newAnimation(self.deadGrid('2-2', 1), 1)
  end 

  return self
end