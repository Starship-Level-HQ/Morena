Zombee = {}

function Zombee:new(world, eData) 
  
  self = Enemy:new(world, eData, 350, love.physics.newRectangleShape(24, 60))

  self.width = 12
  self.height = 4
  self.spriteSheet = love.graphics.newImage('res/sprites/enemy-sheet.png')
  self.grid = anim8.newGrid(12, 18, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2)
  self.animations.up = anim8.newAnimation(self.grid('1-4', 4), 0.2)
  self.animations.right = anim8.newAnimation(self.grid('1-4', 3), 0.2)
  self.animations.left = anim8.newAnimation(self.grid('1-4', 2), 0.2)
  self.anim = self.animations.down
  self.canShoot = true
  self.zoom = 4

  self.deadSpriteSheet = love.graphics.newImage('res/sprites/enemy-dead.png')
  self.deadGrid = anim8.newGrid(12, 18, self.deadSpriteSheet:getWidth(), self.deadSpriteSheet:getHeight())
  if userConfig.blood then
    self.deadAnimations = anim8.newAnimation(self.deadGrid('1-1', 1), 1)
  else
    self.deadAnimations = anim8.newAnimation(self.deadGrid('2-2', 1), 1)
  end
  
  return self
end