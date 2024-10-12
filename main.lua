function love.load(arg)
    if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
    love.window.setTitle("Morena")

    camera = require 'libraries/camera' -- движение камеры
    cam = camera()

    anim8 = require 'libraries/anim8'                    -- анимация движения
    love.graphics.setDefaultFilter('nearest', 'nearest') -- увеличение резкости отображения персонажа

    sti = require 'libraries/sti'                        -- отрисовка карты из Tiled
    gameMap = sti('maps/testMap.lua')

    player = {}    -- new table for the hero
    player.x = 300 -- x,y coordinates of the hero
    player.y = 450
    player.speed = 150
    
    player.shots = {} -- holds our fired shots

    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.spriteSheetDash = love.graphics.newImage('sprites/player-sheet-dash.png')
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)

    player.anim = player.animations.left
    
    shotSound = love.audio.newSource("sounds/shot.wav", "static")
    
    player.isDashing = false
    player.dashSpeed = 450
    player.dashDuration = 0.2
    player.dashCooldown = 0.4
    player.dashTimeLeft = 0
    player.dashCooldownLeft = 0
    
    player.trail = {}      -- таблица для хранения следов
    player.trailDuration = 0.1 -- как долго следы остаются на экране (в секундах)
    player.trailFrequency = 0.05 -- как часто добавляются следы (в секундах)
    player.trailTimer = 0    -- таймер для добавления следов
end

function love.update(dt)
    local isMoving = false

    local moveSpeed = player.speed
    if player.isDashing then
        moveSpeed = player.dashSpeed
    end

    if love.keyboard.isDown("left") then
        player.x = player.x - moveSpeed * dt
        player.anim = player.animations.left
        isMoving = true
    elseif love.keyboard.isDown("right") then
        player.x = player.x + moveSpeed * dt
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        player.y = player.y - moveSpeed * dt
        player.anim = player.animations.up
        isMoving = true
    elseif love.keyboard.isDown("down") then
        player.y = player.y + moveSpeed * dt
        player.anim = player.animations.down
        isMoving = true
    end

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    player.anim:update(dt)
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

    -- Update camera position
    cam:lookAt(player.x, player.y)

    -- This section prevents the camera from viewing outside the background
    -- First, get width/height of the game window
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- Left border
    if cam.x < w / 2 then
        cam.x = w / 2
    end

    -- Right border
    if cam.y < h / 2 then
        cam.y = h / 2
    end

    -- Get width/height of background
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    -- Right border
    if cam.x > (mapW - w / 2) then
        cam.x = (mapW - w / 2)
    end
    -- Bottom border
    if cam.y > (mapH - h / 2) then
        cam.y = (mapH - h / 2)
    end
    
    
        -- Добавляем следы, если персонаж двигается
    if player.dashTimeLeft > 0 then
      player.trailTimer = player.trailTimer - dt
      if player.trailTimer <= 0 then
          -- Добавляем новую позицию в таблицу следов
          table.insert(player.trail, {x = player.x, y = player.y, anim = player.anim, alpha = 1, lifetime = player.trailDuration})
          player.trailTimer = player.trailFrequency
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
    -- Обновляем следы (уменьшаем прозрачность и время жизни)
    for i, t in ipairs(player.trail) do
      t.lifetime = t.lifetime - dt
      t.alpha = t.lifetime / player.trailDuration -- уменьшаем прозрачность пропорционально оставшемуся времени
      if t.lifetime <= 0 then
          table.remove(player.trail, i) -- удаляем след, когда его время жизни истекло
      end
    end
end

function love.draw()
    cam:attach()
    -- let's draw a background
    gameMap:drawLayer(gameMap.layers["grass"])
    gameMap:drawLayer(gameMap.layers["road"])
    gameMap:drawLayer(gameMap.layers["trees"])
    
    love.graphics.setColor(255,255,255,255)
    for i,v in ipairs(player.shots) do
      love.graphics.rectangle("fill", v.x, v.y, 2, 5)
    end

    for i, t in ipairs(player.trail) do
      local fade = t.lifetime / player.trailDuration -- 1 для новых следов, 0 для исчезающих

      -- Значительное изменение цвета: от темного к светлому
      local red = 255 * fade  -- начинаем с белого и уменьшаем до прозрачного
      local green = 255 * fade -- аналогично с зелёным
      local blue = 255 * fade -- аналогично с синим
      local alpha = 255 * fade  -- прозрачность уменьшается с временем жизни

      -- Устанавливаем цвет с рассчитанным эффектом
      love.graphics.setColor(red, green, blue, alpha) 
      t.anim:draw(player.spriteSheetDash, t.x, t.y, nil, 4, nil, 6, 9)
    end

    -- Сбрасываем цвет обратно к стандартному белому и непрозрачному для персонажа
    love.graphics.setColor(255, 255, 255, 255)
    -- Рисуем персонажа
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 4, nil, 6, 9)
    cam:detach()
end

function shoot()
  if #player.shots >= 5 then return end
  local shot = {}
  shot.x = player.x
  shot.y = player.y
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

function love.keypressed(key)
  -- in v0.9.2 and earlier space is represented by the actual space character ' ', so check for both
  if (key == " " or key == "space") then
    shoot()
  end
  
  if key == "lshift" and not player.isDashing and player.dashCooldownLeft <= 0 then
    player.isDashing = true
    player.dashTimeLeft = player.dashDuration
  end
    
end