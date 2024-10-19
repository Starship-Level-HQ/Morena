local player = {}

function player.init(world, x, y)
  player.speed = 150
  player.body = love.physics.newBody(world, x, y, "dynamic") --тело для движения и отрисовки
  player.shape = love.physics.newRectangleShape(20, 28) --размер коллайдера
  player.fixture = love.physics.newFixture(player.body, player.shape, 1) --коллайдер
  player.shots = {} -- holds our fired shots

  player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
  player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
  player.animations = {}
  player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
  player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)
  player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
  player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)

  player.anim = player.animations.left
end

function player.update(dt)
  local isMoving = false

  if love.keyboard.isDown("left") then
    xv, yv = player.body:getLinearVelocity() -- повторяется в 6 местах, но если просто вынести перед ифами, то наискосок идёт только при отпускании первой нажатой клавиши (значения xv, xy не обновляются). Наверное можно сделать красиво, но надо думать.
    player.body:setLinearVelocity(-player.speed, yv)
    player.anim = player.animations.left
    isMoving = true
  elseif love.keyboard.isDown("right") then
    xv, yv = player.body:getLinearVelocity()
    player.body:setLinearVelocity(player.speed, yv)
    player.anim = player.animations.right
    isMoving = true
  else
    xv, yv = player.body:getLinearVelocity()
    player.body:setLinearVelocity(0, yv)
  end

  if love.keyboard.isDown("up") then
    xv, yv = player.body:getLinearVelocity()
    player.body:setLinearVelocity(xv, -player.speed)
    player.anim = player.animations.up
    isMoving = true
  elseif love.keyboard.isDown("down") then
    xv, yv = player.body:getLinearVelocity()
    player.body:setLinearVelocity(xv, player.speed)
    player.anim = player.animations.down
    isMoving = true
  else
    xv, yv = player.body:getLinearVelocity()
    player.body:setLinearVelocity(xv, 0)
  end
  
  if isMoving == false then
    player.anim:gotoFrame(2)
  end

  player.anim:update(dt)
  
  player.updateShots(dt)
end

function player.updateShots(dt)
  local remShot = {}

  -- update the shots
  for i,v in ipairs(player.shots) do
    if v.dir == "r" then
      v.x = v.x + dt * 100
    elseif v.dir == "l" then
      v.x = v.x - dt * 100
    elseif v.dir == "u" then
      v.y = v.y - dt * 100
    else
      v.y = v.y + dt * 100
    end

    -- mark shots that are not visible for removal
    if v.y < 0 or v.x < 0 or v.y > 700 or v.x > 700 then
      table.insert(remShot, i)
    end
  end

  for i,v in ipairs(remShot) do
    table.remove(player.shots, v)
  end
end

function player.shoot(shotSound)
  if #player.shots >= 5 then return end
  local shot = {}
  shot.x = player.body:getX()
  shot.y = player.body:getY()
  if player.anim == player.animations.right then
    shot.dir = "r"
  elseif player.anim == player.animations.left then 
    shot.dir = "l"
  elseif player.anim == player.animations.up then 
    shot.dir = "u"
  else
    shot.dir = "d"
  end

  table.insert(player.shots, shot)
  love.audio.play(shotSound)
end

return player