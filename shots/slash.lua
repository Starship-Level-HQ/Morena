Slash = {}
setmetatable(Slash ,{__index = Shot})

function Slash:new(category, world, x, y, angle, damageModifier) 
  if damageModifier == nil then
    damageModifier = 1
  end
  local this = Shot.new(self, category, world, x, y, 30, 30, 0.3, angle, 5*damageModifier, 300)
  this.sprite = love.graphics.newImage('res/sprites/slash.png')
  this.grid = anim8.newGrid(12, 12, this.sprite:getWidth(), this.sprite:getHeight())
  this.animations = anim8.newAnimation(this.grid('1-4', 1), 0.05)
  this.zoom = 4
  
  setmetatable(this,self)
  self.__index = self
  return this
end
