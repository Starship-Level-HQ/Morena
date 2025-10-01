require "astar"

SmartZombee = {}
setmetatable(SmartZombee ,{__index = Enemy})

function SmartZombee:new(world, eData)

  local this = Enemy.new(self, world, eData, 400, love.physics.newRectangleShape(24, 60))
  this.width = 12
  this.height = 4
  this.spriteSheet = love.graphics.newImage('res/sprites/enemy-sheet.png')
  this.grid = anim8.newGrid(12, 18, this.spriteSheet:getWidth(), this.spriteSheet:getHeight())
  this.animations = {}
  this.animations.down = anim8.newAnimation(this.grid('1-4', 1), 0.2)
  this.animations.up = anim8.newAnimation(this.grid('1-4', 4), 0.2)
  this.animations.right = anim8.newAnimation(this.grid('1-4', 3), 0.2)
  this.animations.left = anim8.newAnimation(this.grid('1-4', 2), 0.2)
  this.anim = this.animations.down
  this.zoom = 4

  this.deadSpriteSheet = love.graphics.newImage('res/sprites/enemy-dead.png')
  this.deadGrid = anim8.newGrid(12, 18, this.deadSpriteSheet:getWidth(), this.deadSpriteSheet:getHeight())
  if userConfig.blood then
    this.deadAnimations = anim8.newAnimation(this.deadGrid('1-1', 1), 1)
  else
    this.deadAnimations = anim8.newAnimation(this.deadGrid('2-2', 1), 1)
  end

  this.defaultSpeed = 70

  this.dodgeFixture = love.physics.newFixture(this.body, love.physics.newCircleShape(80), 0) --коллайдер
  this.dodgeFixture:setCategory(cat.E_RANGE)
  this.dodgeFixture:setMask(cat.E_SHOT, cat.VOID, cat.PLAYER, cat.DASHING_PLAYER, cat.ENEMY, cat.TEXTURE)
  this.dodgeFixture:setSensor(true)
  this.dodgeFixture:setUserData(this)

  this.path = nil

  function SmartZombee:dodge(shot)
    local xv, yv = shot.body:getLinearVelocity()
    if math.abs(xv) > math.abs(yv) then 
      self.jump(0, 150*math.random(-1, 1))
    else 
      self.jump(150*math.random(-1, 1), 0)
    end
  end

  function SmartZombee:jump(xv, yv)
    self.jumpTime = 0.3
    self.body:setLinearVelocity(xv, yv)
  end

  function SmartZombee:getPath(pX, pY, isFull)
    if self.path == nil or self.path == {} then
      local nodes = self:getNodes(pX, pY)
      local playerNode = {x = pX, y = pY}
      local selfNode = {x = self.body:getX(), y = self.body:getY()}
      table.insert(nodes, selfNode)
      table.insert(nodes, playerNode)
      self.path = astar.path(selfNode, playerNode, nodes, false)
      if self.path ~= nil then
        self.path = {unpack(self.path, 2, 5)}
      end
    end
  end

  function SmartZombee:getNodes(pX, pY)
    local x1 = pX
    local y1 = pY
    local x2 = self.body:getX()
    local y2 = self.body:getY()
    local doDep = self.range
    local xx = math.min(x1, x2)-doDep 
    local yy = math.min(y1, y2)-doDep

    if xx < 0 then
      xx = 0
    end
    if yy < 0 then
      yy = 0
    end
    local nodes = {}
    local dGrid = GRID_SIZE * 2
    while yy < math.max(y1, y2)+doDep do
      while xx < math.max(x1, x2)+doDep do
        local flag = true
        for i, ob in ipairs(level.obstacles) do
          if xx >= ob.x - dGrid and xx <= ob.x + ob.w + dGrid and yy >= ob.y - dGrid and yy <= ob.y + ob.h + dGrid then
            flag = false
          end
        end
        if flag then
          table.insert(nodes, {x = xx, y = yy})
        end
        xx = xx + GRID_SIZE
      end
      xx = math.min(x1, x2)-doDep
      if xx < 0 then
        xx = 0
      end
      yy = yy + GRID_SIZE
    end
    return nodes
  end

  function SmartZombee:checkPath(pX, pY)
    local sX = math.floor(self.body:getX())
    local sY = math.floor(self.body:getY())
    local maxX = math.max(pX, sX)
    local maxY = math.max(pY, sY)
    local minX = math.min(pX, sX)
    local minY = math.min(pY, sY)

    for i, ob in ipairs(level.obstacles) do
      if ob.x >= minX and ob.x <= maxX and ob.y >= minY and ob.y <= maxY then
        return false
      end
      if ob.x+ob.w >= minX and ob.x+ob.w <= maxX and ob.y+ob.h >= minY and ob.y+ob.h <= maxY then
        return false
      end
      if ob.x >= minX and ob.x <= maxX and ob.y+ob.h >= minY and ob.y+ob.h <= maxY then
        return false
      end
      if ob.x+ob.w >= minX and ob.x+ob.w <= maxX and ob.y >= minY and ob.y <= maxY then
        return false
      end
      if ob.x <= maxX and ob.x+ob.w >= minX and ob.y <= minY and ob.y+ob.h >= maxY then
        return false
      end
      if ob.x <= minX and ob.x+ob.w >= maxX and ob.y <= maxY and ob.y+ob.h >= minY then
        return false
      end
    end
    return true
  end

  function SmartZombee:moving(player)
    local speedX = 0
    local speedY = 0
    local pX = math.floor(player:getBody():getX())
    local pY = math.floor(player:getBody():getY())

    if self:checkPath(pX, pY) then
      self.path = {{x=pX, y=pY}}
    else
      self.coroutine = coroutine.create(function(px, py, isFull)  self:getPath(px, py, isFull) end)
      coroutine.resume(self.coroutine, pX, pY, false)
    end

    if self.path ~= nil then
      local nextMove = self.path[1]
      if nextMove ~= nil then
        local playerX = nextMove.x
        local playerY = nextMove.y
        local selfX = self.body:getX()
        local selfY = self.body:getY()

        if selfX > playerX and math.abs(selfX - playerX) > 2 then
          speedX = -self.defaultSpeed
          self.anim = self.animations.left
          self.direction = "l"
          self.isMoving = true
        elseif selfX < playerX and math.abs(selfX - playerX) > 2 then
          speedX = self.defaultSpeed
          self.anim = self.animations.right
          self.direction = "r"
          self.isMoving = true
        end

        if selfY > playerY and math.abs(selfY - playerY) > 2 then
          speedY = -self.defaultSpeed
          self.anim = self.animations.up
          self.direction = "u"

          self.isMoving = true
        elseif selfY < playerY and math.abs(selfY - playerY) > 2 then

          speedY = self.defaultSpeed
          self.anim = self.animations.down
          self.direction = "d"
          self.isMoving = true
        end

        self.body:setLinearVelocity(speedX, speedY)

        local dist = astar.dist(selfX, selfY, nextMove.x, nextMove.y)
        if dist < 4 then
          table.remove(self.path, 1)
        end
      else
        self.path = nil
      end
    end
  end

  setmetatable(this,self)
  self.__index = self
  return this
end