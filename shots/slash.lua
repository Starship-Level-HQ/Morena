Slash = {
  new = function() 
    local self = {}
    self.sprite = love.graphics.newImage('res/sprites/slash.png')
    self.grid = anim8.newGrid(12, 12, self.sprite:getWidth(), self.sprite:getHeight())
    self.animations = anim8.newAnimation(self.grid('1-4', 1), 0.05)
    return self
  end
}