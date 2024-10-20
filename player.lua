local player = {}

function player.init(world, x, y)
    player.speed = 150
    player.defaultSpeed = 150
    player.body = love.physics.newBody(world, x, y, "dynamic")             --тело для движения и отрисовки
    player.shape = love.physics.newRectangleShape(20, 28)                  --размер коллайдера
    player.fixture = love.physics.newFixture(player.body, player.shape, 1) --коллайдер
    player.shots = {}                                                      -- holds our fired shots

    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)

    player.anim = player.animations.left

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
        xv, yv = player.body:getLinearVelocity() -- повторяется в 6 местах, но если просто вынести перед ифами, то наискосок идёт только при отпускании первой нажатой клавиши (значения xv, xy не обновляются). Наверное можно сделать красиво, но надо думать.
        player.body:setLinearVelocity(-speed, yv)
        player.anim = player.animations.left
        isMoving = true
    elseif love.keyboard.isDown("right") then
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(speed, yv)
        player.anim = player.animations.right
        isMoving = true
    else
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(0, yv)
    end

    if love.keyboard.isDown("up") then
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(xv, -speed)
        player.anim = player.animations.up
        isMoving = true
    elseif love.keyboard.isDown("down") then
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(xv, speed)
        player.anim = player.animations.down
        isMoving = true
    else
        xv, yv = player.body:getLinearVelocity()
        player.body:setLinearVelocity(xv, 0)
    end

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    if love.keyboard.isDown("lshift") and not player.isDashing and player.dashCooldownLeft <= 0 then
        player.isDashing = true
        player.dashTimeLeft = player.dashDuration
    end
    player.updateDash(dt)
    player.anim:update(dt)
    player.updateShots(dt)
end

function player.updateShots(dt)
    local remShot = {}

    -- update the shots
    for i, v in ipairs(player.shots) do
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

    for i, v in ipairs(remShot) do
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
end

return player
