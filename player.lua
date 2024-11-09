local player = {}
shots = require("shot")

function player.init(world, x, y)
  player.speed = 150
  player.defaultSpeed = 150
  player.body = love.physics.newBody(world, x, y, "dynamic")             --тело для движения и отрисовки
  player.shape = love.physics.newRectangleShape(33, 58)                  --размер коллайдера
  player.fixture = love.physics.newFixture(player.body, player.shape, 0) --коллайдер
  player.fixture:setCategory(cat.PLAYER) -- Категория объектов, к которой относится игрок
  player.fixture:setMask(cat.P_SHOT, cat.VOID) -- Категории, которые игрок игнорирует (свои выстрелы и пустоту)
  player.shots = {}                                                      -- holds our fired shots
  player.slashes = {}
  player.health = 100
  player.body:setGravityScale(0)
  player.attackType = true
  player.damage = 10

  player.spriteSheet = love.graphics.newImage('sprites/MC.png')
  player.grid = anim8.newGrid(24, 36, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
  player.animations = {}
  player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.17)
  player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.17)
  player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.17)
  player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.17)

    player.anim = player.animations.left
    player.direction = "l"

    --Рывок
    player.isDashing = false
    player.dashSpeed = 300
    player.dashDuration = 0.2
    player.dashCooldown = 0.4
    player.dashTimeLeft = 0
    player.dashCooldownLeft = 0

    --След рывка
    player.trail = {}            -- таблица для хранения следов
    player.trailDuration = 0.05  -- как долго следы остаются на экране (в секундах)
    player.trailFrequency = 0.01 -- как часто добавляются следы (в секундах)
    player.trailTimer = 0        -- таймер для добавления следов
end

function player.update(dt)
    local isMoving = false
    local speed = player.defaultSpeed
    if player.isDashing then
        speed = speed + player.dashSpeed
    end

    if love.keyboard.isDown("left") then
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(-speed, yv)
        player.anim = player.animations.left
        player.direction = "l"
        isMoving = true
    elseif love.keyboard.isDown("right") then
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(speed, yv)
        player.anim = player.animations.right
        player.direction = "r"
        isMoving = true
    else
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(0, yv)
    end

    if love.keyboard.isDown("up") then
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(xv, -speed)
        player.anim = player.animations.up
        player.direction = "u"
        isMoving = true
    elseif love.keyboard.isDown("down") then
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(xv, speed)
        player.anim = player.animations.down
        player.direction = "d"
        isMoving = true
    else
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(xv, 0)
    end

    xv, yv = player.body:getLinearVelocity()
    player.direction = physics.calculateDirection(xv, yv, player.direction) -- 45'

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    if love.keyboard.isDown("lshift") and not player.isDashing and player.dashCooldownLeft <= 0 then
        player.isDashing = true
        player.dashTimeLeft = player.dashDuration
        player.fixture:setCategory(cat.DASHING_PLAYER)
    end
    player.updateDash(dt)
    player.anim:update(dt)
    player.updateShots(dt)
    player.updateSlash(dt)
end

function player.updateShots(dt)
    local remShot = {}

    -- update the shots
    for i, s in ipairs(player.shots) do
        s.update(remShot, i, dt)
    end

    for i, s in ipairs(remShot) do
        table.remove(player.shots, i)
    end
end

function player.shoot(shotSound)
  --if #player.shots >= 5 then return end
  local shot = shots.new(cat.P_SHOT, player.body:getWorld(), player.body:getX(), player.body:getY(), 2, 5, 200, player.direction, player.damage)
  table.insert(player.shots, shot)
  love.audio.play(shotSound)
end

function player.slash(slashSound)
  if #player.slashes >= 1 then return end
  local shot = shots.new(cat.P_SHOT, player.body:getWorld(), player.body:getX(), player.body:getY(), 30, 30, 13, player.direction, player.damage, 3)
  table.insert(player.slashes, shot)
  love.audio.play(slashSound)
end

function player.updateSlash(dt)
    local remShot = {}

    -- update the shots
    for i, s in ipairs(player.slashes) do
        s.update(remShot, i, dt)
    end

    for i, s in ipairs(remShot) do
        table.remove(player.slashes, i)
    end
end

function player.updateDash(dt)
    --След
    if player.dashTimeLeft > 0 then
        player.trailTimer = player.trailTimer - dt
        if player.trailTimer <= 0 then
            table.insert(player.trail,
                {
                    x = player.body:getX(),
                    y = player.body:getY(),
                    anim = player.anim,
                    alpha = 0.3,
                    lifetime = player
                        .trailDuration
                })
            player.trailTimer = player.trailFrequency
        end
    end
    -- Обновление следов во время рывка
    for i, t in ipairs(player.trail) do
        t.lifetime = t.lifetime - dt
        if t.lifetime <= 0 then
            table.remove(player.trail, i)
        end
    end
    if player.isDashing then
        player.dashTimeLeft = player.dashTimeLeft - dt
        if player.dashTimeLeft <= 0 then
            player.isDashing = false
            player.dashCooldownLeft = player.dashCooldown
        end
    elseif player.dashCooldownLeft > 0 then
        player.dashCooldownLeft = player.dashCooldownLeft - dt
    end
    if not player.isDashing then
        player.fixture:setCategory(cat.PLAYER)
    end
end

function player.draw(t, d1, d2, d3, d4)
  for i, s in ipairs(player.shots) do
    if not s.body:isDestroyed() then
      love.graphics.rectangle("fill", s.body:getX(), s.body:getY(), s.h, s.w)
    end
  end
  
  for i, s in ipairs(player.slashes) do
    if not s.body:isDestroyed() then
      s:draw()
      --love.graphics.polygon("fill", s.body:getWorldPoints(s.shape:getPoints()))
    end
  end

  --love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))
  player.anim:draw(player.spriteSheet, player.body:getX(), player.body:getY(), nil, 2.1, nil, 12, 19)

  --След
  love.graphics.setColor(0.7,0.7,0.9,0.2)
  for i = #player.trail, 1, -1 do
    local t = player.trail[i]
    t.anim:draw(player.spriteSheet, t.x, t.y, nil, 2, nil, 12, 19)
  end

    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print(player.health, player.body:getX() - 23, player.body:getY() - 65, 0, 2, 2)

    love.graphics.setColor(d1, d2, d3, d4)
end

function player.collisionWithEnemy(fixture_b, damage)

  player.health = player.health - damage
  xi, yi = fixture_b:getBody():getLinearVelocity()
  player.body:applyLinearImpulse(xi*55, yi*55) --отскок игрока при получении урона, пока слишком резкий, если получится сделать плавным - оставим
end

function player.collisionWithShot(damage)

  player.health = player.health - damage

end

return player
