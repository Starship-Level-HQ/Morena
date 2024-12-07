PlayerAnim = {
  new = function(self)

    self.spriteSheet = love.graphics.newImage('res/sprites/MC1.png')
    self.grid = anim8.newGrid(24, 36, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.17)
    self.animations.up = anim8.newAnimation(self.grid('1-4', 4), 0.17)
    self.animations.right = anim8.newAnimation(self.grid('1-4', 3), 0.17)
    self.animations.left = anim8.newAnimation(self.grid('1-4', 2), 0.17)
    self.animations.sDown = anim8.newAnimation(self.grid('4-5', 1), 1.1)
    self.animations.sUp = anim8.newAnimation(self.grid('4-5', 4), 1.1)
    self.animations.sRight = anim8.newAnimation(self.grid('4-5', 3), 1.1)
    self.animations.sLeft = anim8.newAnimation(self.grid('4-5', 2), 1.1)

  end
}