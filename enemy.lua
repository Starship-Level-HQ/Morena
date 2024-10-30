local enemyFabric = {}
local cat = require("objectsCategories")

function enemyFabric.new()
  
  local enemy = {}

  function enemy.init(world, x, y)
    enemy.defaultSpeed = 40
    enemy.body = love.physics.newBody(world, x, y, "dynamic") --тело для движения и отрисовки
    --enemy.body:setMass(49)
    enemy.shape = love.physics.newRectangleShape(22, 29) --размер коллайдера
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 1) --коллайдер
    enemy.fixture:setCategory(cat.ENEMY) 
    enemy.fixture:setMask(cat.E_SHOT, cat.VOID) 
    enemy.health = 100
    enemy.shots = {} -- holds our fired shots

    enemy.spriteSheet = love.graphics.newImage('sprites/enemy-sheet.png')
    enemy.grid = anim8.newGrid(12, 18, enemy.spriteSheet:getWidth(), enemy.spriteSheet:getHeight())
    enemy.animations = {}
    enemy.animations.down = anim8.newAnimation(enemy.grid('1-4', 1), 0.2)
    enemy.animations.up = anim8.newAnimation(enemy.grid('1-4', 4), 0.2)
    enemy.animations.right = anim8.newAnimation(enemy.grid('1-4', 3), 0.2)
    enemy.animations.left = anim8.newAnimation(enemy.grid('1-4', 2), 0.2)

    enemy.anim = enemy.animations.left
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
      end

    end

  end

  function enemy.draw(t, d1, d2, d3, d4)
    enemy.anim:draw(enemy.spriteSheet, enemy.body:getX(), enemy.body:getY(), nil, 4, nil, 6, 9)
    if enemy.health > 0 then
      love.graphics.setColor(1, 0, 0, 1)
      love.graphics.print(enemy.health, enemy.body:getX()-23, enemy.body:getY()-65, 0, 2, 2)
    end
    love.graphics.setColor(d1, d2, d3, d4)
  end
  
  function enemy.colisionWithShot(f)
    if f == enemy.fixture then
      enemy.health = enemy.health - 10
    end
  end
  
  return enemy
  
end

return enemyFabric