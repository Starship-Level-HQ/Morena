local enemy = {}

function enemy.init(x, y)
  enemy.defaultSpeed = 40
  enemy.body = love.physics.newBody(world, x, y, "dynamic") --тело для движения и отрисовки
  enemy.body:setMass(50)
  enemy.shape = love.physics.newRectangleShape(20, 28) --размер коллайдера
  enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 10) --коллайдер
  enemy.shots = {} -- holds our fired shots

  enemy.spriteSheet = love.graphics.newImage('sprites/enemy-sheet.png')
  enemy.grid = anim8.newGrid(12, 18, enemy.spriteSheet:getWidth(), enemy.spriteSheet:getHeight())
  enemy.animations = {}
  enemy.animations.down = anim8.newAnimation(enemy.grid('1-4', 1), 0.2)
  enemy.animations.up = anim8.newAnimation(enemy.grid('1-4', 4), 0.2)
  enemy.animations.right = anim8.newAnimation(enemy.grid('1-4', 3), 0.2)
  enemy.animations.left = anim8.newAnimation(enemy.grid('1-4', 2), 0.2)

  enemy.anim = enemy.animations.left

  enemy.tick = 0

end

function enemy.update(dt, playerX, playerY)

  local isMoving = false

  if math.sqrt((enemy.body:getX() - playerX)^2 + (enemy.body:getY() - playerY)^2) < 200 then
    local speedX = 0
    local speedY = 0

    if enemy.tick < 100 then
      if enemy.body:getX() > playerX then
        speedX = -enemy.defaultSpeed
        enemy.anim = enemy.animations.left
        isMoving = true
      elseif enemy.body:getX() < playerX then
        speedX = enemy.defaultSpeed
        enemy.anim = enemy.animations.right
        isMoving = true
      end

      if enemy.body:getY() > playerY and math.abs(enemy.body:getY() - playerY) > 5 then
        speedY = -enemy.defaultSpeed
        enemy.anim = enemy.animations.up
        isMoving = true
      elseif enemy.body:getY() < playerY and math.abs(enemy.body:getY() - playerY) > 5 then
        speedY = enemy.defaultSpeed
        enemy.anim = enemy.animations.down
        isMoving = true
      end

      enemy.body:setLinearVelocity(speedX, speedY)

    else
      enemy.body:setLinearVelocity(0, 0)
      enemy.anim = enemy.animations.down
      isMoving = false
    end

    enemy.tick = enemy.tick + 1

    if enemy.tick > 200 then
      enemy.tick = 0
    end

  end

  if isMoving == false then
    enemy.anim:gotoFrame(2)
    enemy.body:setLinearVelocity(0, 0)
  end

  enemy.anim:update(dt)

end


function enemy.updateShots(dt)
  local remShot = {}

  -- update the shots
  for i,v in ipairs(enemy.shots) do
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
    table.remove(enemy.shots, v)
  end
end

function enemy.shoot(shotSound)
  if #enemy.shots >= 5 then return end
  local shot = {}
  shot.x = enemy.body:getX()
  shot.y = enemy.body:getY()
  if enemy.anim == enemy.animations.right then
    shot.dir = "r"
  elseif enemy.anim == enemy.animations.left then 
    shot.dir = "l"
  elseif enemy.anim == enemy.animations.up then 
    shot.dir = "u"
  else
    shot.dir = "d"
  end

  table.insert(enemy.shots, shot)
  love.audio.play(shotSound)
end

return enemy