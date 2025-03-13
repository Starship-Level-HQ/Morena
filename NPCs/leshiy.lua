local Roots = require("shots/roots")

Leshiy = {
  new = function(world, x, y, range, health) 
    local self = {}
    self.shape = love.physics.newRectangleShape(66, 175)              --размер коллайдера
    self.width = 68
    self.height = 130
    self.spriteSheet = love.graphics.newImage('res/sprites/leshiy2.png')
    self.grid = anim8.newGrid(43, 82, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.3)
    self.animations.up = anim8.newAnimation(self.grid('1-4', 2), 0.3)
    self.animations.right = anim8.newAnimation(self.grid('1-4', 1), 0.3)
    self.animations.left = anim8.newAnimation(self.grid('1-4', 1), 0.3)
    --self.zoom = 3
    
    self.deadSpriteSheet = love.graphics.newImage('res/sprites/leshiy-dead.png')
    self.deadGrid = anim8.newGrid(28, 30, self.deadSpriteSheet:getWidth(), self.deadSpriteSheet:getHeight())
    if not userConfig.blood then
      self.deadAnimations = anim8.newAnimation(self.deadGrid('1-1', 2), 1)
    else
      self.deadAnimations = anim8.newAnimation(self.deadGrid('1-1', 1), 1)
    end
    
    self = Enemy.new(world, x, y, range, health, self)
    
    
    function self:update(dt)

      if self.isAlive then
        self.isMoving = false
        if #self.playerPos > 0 then
          local player = self.playerPos[1]

          for i, p in ipairs(self.playerPos) do
            d1, _, _, _, _ = love.physics.getDistance(self.fixture, p)
            d2, _, _, _, _ = love.physics.getDistance(self.fixture, player)
            if d1 < d2 then
              player = p
            end
          end
          
          self:moving(player)

          self.tickWalk = self.tickWalk + dt

          if self.tickWalk > 1.9 then
            self.tickWalk = 0
            self:shoot()
          end
          
        end

        if self.isMoving == false then
          self.anim:gotoFrame(2)
          self.body:setLinearVelocity(0, 0)
        end

        self.anim:update(dt)

        if self.health <= 0 then
          self:die(dt)
        end
      end

      self:updateShots(dt)
      self:updateBloodDrops(dt)
    end
    
    function self:shoot()
      local shot = Roots.new(cat.E_SHOT, self.body:getWorld(), self.body:getX(), self.body:getY(), self.direction)
      table.insert(self.shots, shot)
    end
    
    return self
  end
}