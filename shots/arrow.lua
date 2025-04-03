Arrow = {
  new = function(category, world, x, y, angle, damageModifier) 
    if damageModifier == nil then
      damageModifier = 1
    end
    local self = shots.new(category, world, x, y, 6, 10, 1.6, angle, 5*damageModifier, 200)
    self.sprite = love.graphics.newImage('res/sprites/arrow.png')
    self.grid = anim8.newGrid(5, 13, self.sprite:getWidth(), self.sprite:getHeight())
    self.animations = anim8.newAnimation(self.grid('1-4', 1), 0.1)
    return self
  end
}