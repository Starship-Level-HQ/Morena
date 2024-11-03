local enemyFabric = {}

function enemyFabric.new()

  local enemy = {}

  function enemy.init(world, x, y)
    enemy.defaultSpeed = 40
    enemy.body = love.physics.newBody(world, x, y, "dynamic") --тело для движения и отрисовки
    --enemy.body:setMass(49)
    enemy.shape = love.physics.newRectangleShape(22, 29) --размер коллайдера
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 1) --коллайдер
    enemy.fixture:setCategory(cat.ENEMY) 
    enemy.fixture:setMask(cat.E_SHOT, cat.VOID, cat.DASHING_PLAYER) 
    enemy.body:setGravityScale(0)
    enemy.health = 100
    enemy.shots = {} -- holds our fired shots
    enemy.bloodDrops = {}

    enemy.spriteSheet = love.graphics.newImage('sprites/enemy-sheet.png')
    enemy.grid = anim8.newGrid(12, 18, enemy.spriteSheet:getWidth(), enemy.spriteSheet:getHeight())
    enemy.animations = {}
    enemy.animations.down = anim8.newAnimation(enemy.grid('1-4', 1), 0.2)
    enemy.animations.up = anim8.newAnimation(enemy.grid('1-4', 4), 0.2)
    enemy.animations.right = anim8.newAnimation(enemy.grid('1-4', 3), 0.2)
    enemy.animations.left = anim8.newAnimation(enemy.grid('1-4', 2), 0.2)

    enemy.anim = enemy.animations.left
    enemy.direction = "l"
    enemy.isAlive = true
    enemy.tick = x+y % 150

  end

  function enemy.update(dt, playerX, playerY)

    if enemy.isAlive then

      local isMoving = false

      if math.sqrt((enemy.body:getX() - playerX)^2 + (enemy.body:getY() - playerY)^2) < 200 then
        local speedX = 0
        local speedY = 0

        if enemy.tick < 100 then
          if enemy.body:getX() > playerX then
            speedX = -enemy.defaultSpeed
            enemy.anim = enemy.animations.left
            enemy.direction = "l"
            isMoving = true
          elseif enemy.body:getX() < playerX then
            speedX = enemy.defaultSpeed
            enemy.anim = enemy.animations.right
            enemy.direction = "r"
            isMoving = true
          end

          if enemy.body:getY() > playerY and math.abs(enemy.body:getY() - playerY) > 5 then
            speedY = -enemy.defaultSpeed
            enemy.anim = enemy.animations.up
            enemy.direction = "u"
            isMoving = true
          elseif enemy.body:getY() < playerY and math.abs(enemy.body:getY() - playerY) > 5 then
            speedY = enemy.defaultSpeed
            enemy.anim = enemy.animations.down
            enemy.direction = "d"
            isMoving = true
          end

          enemy.body:setLinearVelocity(speedX, speedY)

        else
          enemy.body:setLinearVelocity(0, 0)
          enemy.anim = enemy.animations.down
          isMoving = false
        end

        if enemy.tick % 5 == 0 then
          enemy.shoot()
        end

        enemy.tick = enemy.tick + 1

        if enemy.tick > 150 then
          enemy.tick = 0
        end

      end

      if isMoving == false then
        enemy.anim:gotoFrame(2)
        enemy.body:setLinearVelocity(0, 0)
      end

      enemy.anim:update(dt)

      if enemy.health <= 0 then
        enemy.body:setLinearVelocity(0, 0)
        enemy.spriteSheet = love.graphics.newImage('sprites/enemy-dead.png')
        enemy.grid = anim8.newGrid(12, 18, enemy.spriteSheet:getWidth(), enemy.spriteSheet:getHeight())
        enemy.anim = anim8.newAnimation(enemy.grid('1-1', 1), 0.2)
        enemy.anim:update(dt)
        enemy.fixture:destroy()
        enemy.isAlive = false
        enemy.bloodDrops = physics.bloodDrops(enemy.body:getWorld(), enemy.body:getX(), enemy.body:getY())
      end

  end
  
    enemy.updateShots(dt)
    enemy.updateBloodDrops(dt)

  end

  function enemy.updateShots(dt)
    local remShot = {}

    -- update the shots
    for i, s in ipairs(enemy.shots) do
      s.update(remShot, i)
    end

    for i, s in ipairs(remShot) do
      table.remove(enemy.shots, i)
    end
  end
  
  function enemy.updateBloodDrops(dt)
    local remShot = {}

    for i, d in ipairs(enemy.bloodDrops) do
      d.time = d.time + 1
      if not d.body:isDestroyed() then
        d.body:setGravityScale(d.time)
      end
      if d.time > 100 then
        table.insert(remShot, i)
        if not d.body:isDestroyed() then
          d.fixture:destroy()
          d.body:destroy()
        end
      end
    end

    for i, d in ipairs(remShot) do
      table.remove(enemy.bloodDrops, d)
    end
  end

  function enemy.shoot()
    local shot = shots.new(cat.E_SHOT, enemy.body:getWorld(), enemy.body:getX(), enemy.body:getY(), 2, 5, 150, enemy.direction)
  table.insert(enemy.shots, shot)
  end

  function enemy.draw(t, d1, d2, d3, d4)

    for i, s in ipairs(enemy.shots) do
      if not s.body:isDestroyed() then
        love.graphics.rectangle("fill", s.body:getX(), s.body:getY(), s.h, s.w)
      end
    end
    
    love.graphics.setColor(1, 0, 0, 1)
    for i, d in ipairs(enemy.bloodDrops) do
      if not d.body:isDestroyed() then
        love.graphics.rectangle("fill", d.body:getX(), d.body:getY(), 4, 5)
      end
    end
    love.graphics.setColor(d1, d2, d3, d4)
    enemy.anim:draw(enemy.spriteSheet, enemy.body:getX(), enemy.body:getY(), nil, 4, nil, 6, 9)
    if enemy.health > 0 then
      love.graphics.setColor(1, 0, 0, 1)
      love.graphics.print(enemy.health, enemy.body:getX()-23, enemy.body:getY()-65, 0, 2, 2)
    end
    love.graphics.setColor(d1, d2, d3, d4)
  end

  function enemy.colisionWithShot(f)
    if f == enemy.fixture then
      enemy.health = enemy.health - 100
    end
  end

  return enemy

end

return enemyFabric