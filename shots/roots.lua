Roots = {
  new = function(category, world, x, y, dir, damageModifier) 
    if damageModifier == nil then
      damageModifier = 1
    end
    local self = shots.new(category, world, x, y, 40, 40, 1.5, dir, 10*damageModifier, 1)
    self.body:setMass(100)
    self.sprite = love.graphics.newImage('res/sprites/roots.png')
    self.grid = anim8.newGrid(83, 44, self.sprite:getWidth(), self.sprite:getHeight())
    self.animations = anim8.newAnimation(self.grid('1-3', 1), 0.1)
    return self
  end
}

return Roots