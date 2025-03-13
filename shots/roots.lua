Roots = {
  new = function(category, world, x, y, dir, damageModifier) 
    if damageModifier == nil then
      damageModifier = 1
    end
    local self = shots.new(category, world, x, y, 60, 80, 3, dir, 10*damageModifier, 1)
    self.body:setMass(100)
    self.sprite = love.graphics.newImage('res/sprites/roots.png')
    self.grid = anim8.newGrid(27, 36, self.sprite:getWidth(), self.sprite:getHeight())
    self.animations = anim8.newAnimation(self.grid('1-4', 1), 0.1)
    
    function self.draw()
      local xx, yy = self.body:getWorldPoints(self.shape:getPoints())
      self.animations:draw(self.sprite, xx, yy, self.rotate, 4, nil, 4, 4)
      --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    end
    
    return self
  end
}

return Roots