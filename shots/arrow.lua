Arrow = {}
setmetatable(Arrow ,{__index = Shot})

function Arrow:new(category, world, x, y, angle, damageModifier)
  if damageModifier == nil then
    damageModifier = 1
  end

  local this = Shot.new(self, category, world, x, y, 6, 10, 1.6, angle, 5*damageModifier, 200)

  this.sprite = love.graphics.newImage('res/sprites/arrow.png')
  this.grid = anim8.newGrid(13, 5, this.sprite:getWidth(), this.sprite:getHeight())
  this.animations = anim8.newAnimation(this.grid('1-4', 1), 0.1)
  this.zoom = 4
  
--  function Arrow:update(remShot, i, dt)
--    Shot.update(self, remShot, i, dt)
--  end
  
--  function Arrow:draw()
--    Shot.draw(self)
--  end

  setmetatable(this,self)
  self.__index = self
  return this
end
