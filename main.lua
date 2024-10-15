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
        player.x = player.x - player.speed * dt
        player.anim = player.animations.left
        isMoving = true
    elseif love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
        player.anim = player.animations.up
        isMoving = true
    elseif love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
        player.anim = player.animations.down
        isMoving = true
    end

    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    player.anim:update(dt)

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
end

function love.draw()
    cam:attach()
    -- let's draw a background
    gameMap:drawLayer(gameMap.layers["grass"])
    gameMap:drawLayer(gameMap.layers["road"])
    gameMap:drawLayer(gameMap.layers["trees"])

    -- let's draw our hero
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 4, nil, 6, 9)
    cam:detach()
end
