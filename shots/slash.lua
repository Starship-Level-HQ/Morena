Slash = {
  new = function(category, world, x, y, dir, damageModifier) 
    if damageModifier == nil then
      damageModifier = 1
    end
    local self = shots.new(category, world, x, y, 30, 30, 0.3, dir, 5*damageModifier, 3)
    self.sprite = love.graphics.newImage('res/sprites/slash.png')
    self.grid = anim8.newGrid(12, 12, self.sprite:getWidth(), self.sprite:getHeight())
    self.animations = anim8.newAnimation(self.grid('1-4', 1), 0.05)
    return self
  end
}