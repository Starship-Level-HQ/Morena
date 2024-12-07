Arrow = {
  new = function() 
    local self = {}
    self.sprite = love.graphics.newImage('res/sprites/arrow.png')
    self.grid = anim8.newGrid(5, 13, self.sprite:getWidth(), self.sprite:getHeight())
    self.animations = anim8.newAnimation(self.grid('1-4', 1), 0.1)
    self.rotate = 0
    return self
  end
}