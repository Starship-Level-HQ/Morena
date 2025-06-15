Roots = {
  new = function(category, world, x, y, angle, damageModifier) 
    if damageModifier == nil then
      damageModifier = 1
    end
    local self = shots.new(category, world, x, y, 60, 80, 3, angle, 10, 140)
    self.body:setMass(400)
    
    self.effect = function(player)
      --table.insert(player.effects, {"Регенерация", -3, 20}) -- Эффект яда, другому врагу добавим
      player.stun = 0.5 
      player.stunTime = 0.5
    end
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