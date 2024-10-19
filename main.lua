local physics = require("physics")

function love.load(arg)
  
    if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
    love.window.setTitle("Morena")

    camera = require 'libraries/camera' -- движение камеры
    cam = camera()

    anim8 = require 'libraries/anim8'                    -- анимация движения
    love.graphics.setDefaultFilter('nearest', 'nearest') -- увеличение резкости отображения персонажа

    sti = require 'libraries/sti'                        -- отрисовка карты из Tiled
    gameMap = sti('maps/testMap.lua')
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(physics.collisionOnEnter)
    
    day = true

    player = {}    -- new table for the hero
    player.speed = 150
    player.body = love.physics.newBody(world, 300, 450, "dynamic") --тело для движения и отрисовки
    player.shape = love.physics.newRectangleShape(20, 28) --размер коллайдера
    player.fixture = love.physics.newFixture(player.body, player.shape, 1) --коллайдер
    
    lake = {}
    lake.body = love.physics.newBody(world, 400, 550, "static")
    lake.shape = love.physics.newRectangleShape(80, 80)
    lake.fixture = love.physics.newFixture(lake.body, lake.shape)   
    
    player.shots = {} -- holds our fired shots

    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)

    player.anim = player.animations.left

    shotSound = love.audio.newSource("sounds/shot.wav", "static")
end

function love.update(dt)
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
    
    world:update(dt)

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
    cam:lookAt(player.body:getX(), player.body:getY())

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

    -- let's draw our hero
    --player.anim:draw(player.spriteSheet, player.x, player.y, nil, 4, nil, 6, 9)
    player.anim:draw(player.spriteSheet, player.body:getX(), player.body:getY(), nil, 4, nil, 6, 9)
    love.graphics.setColor(0.23, 0.25, 0.59, 1)
    love.graphics.polygon("fill", lake.body:getWorldPoints(lake.shape:getPoints()))
    if day then
      love.graphics.setColor(255,255,255,255)
    end
    cam:detach()
    
end

function shoot()
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

function love.keypressed(key)
  if (key == " " or key == "space") then
    shoot()
  end
  if (key == "q") then
    day = not day
  end
end