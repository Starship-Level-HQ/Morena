SmartZombee = {
  new = function(world, x, y, range, health) 
    local self = {}
    self.shape = love.physics.newRectangleShape(24, 60)              --размер коллайдера
    self.width = 12
    self.height = 4
    self.spriteSheet = love.graphics.newImage('res/sprites/enemy-sheet.png')
    self.grid = anim8.newGrid(12, 18, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2)
    self.animations.up = anim8.newAnimation(self.grid('1-4', 4), 0.2)
    self.animations.right = anim8.newAnimation(self.grid('1-4', 3), 0.2)
    self.animations.left = anim8.newAnimation(self.grid('1-4', 2), 0.2)
    self.canShoot = false
    self.zoom = 4

    self.deadSpriteSheet = love.graphics.newImage('res/sprites/enemy-dead.png')
    self.deadGrid = anim8.newGrid(12, 18, self.deadSpriteSheet:getWidth(), self.deadSpriteSheet:getHeight())
    if userConfig.blood then
      self.deadAnimations = anim8.newAnimation(self.deadGrid('1-1', 1), 1)
    else
      self.deadAnimations = anim8.newAnimation(self.deadGrid('2-2', 1), 1)
    end
    
    self = Enemy.new(world, x, y, range, health, self)
    
    self.dodgeFixture = love.physics.newFixture(self.body, love.physics.newCircleShape(80), 0) --коллайдер
    self.dodgeFixture:setCategory(cat.E_RANGE)
    self.dodgeFixture:setMask(cat.E_SHOT, cat.VOID, cat.DASHING_PLAYER, cat.ENEMY, cat.TEXTURE)
    self.dodgeFixture:setSensor(true)
    self.dodgeFixture:setUserData(self)

    self.dodge = function(shot)
      local dir = shot["dir"]
      if dir == "r" or dir == "l" then
        self.jump(0, 120*math.random(-1, 1))
      elseif dir == "u" or dir == "d" then
        self.jump(120*math.random(-1, 1), 0)
      elseif dir == "ld" or dir == "rd" or dir == "lu" or dir == "ru" then
        self.jump(60*math.random(-1, 1), 60*math.random(-1, 1))
      end
    end
    
    self.jump = function(xv, yv)
      self.jumpTime = 0.3
      self.body:setLinearVelocity(xv, yv)
    end
    return self
  end
}