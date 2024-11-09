local multiplayer = {}

cat = require("objectsCategories")
require("client")
local physics = require("physics")
local player = require("player")
local enemyFabric = require("enemy")
local camera = require 'libraries/camera'
anim8 = require 'libraries/anim8'
local sti = require 'libraries/sti'

local cam
local gameMap
local world
local lake
local day
local enemy

local multiplayerInit = {
    map = "maps/testMap.lua",
    playerPosition = { 300, 450 },
    enemyPosition = { 600, 100 },
    lakePosition = { 400, 550 }
}

function multiplayer.startMultiplayer()
    hub = client.new({ server = "127.0.0.1", port = 1337, gameState = player })
    port = hub:subscribe({ channel = "MORENA" })
    otherClients = hub:getOtherClients()

    love.window.setTitle("Morena - Multiplayer")
    cam = camera()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    gameMap = sti(multiplayerInit.map)
    world = love.physics.newWorld(0, 0, true)
    world:setGravity(0, 40)
    world:setCallbacks(multiplayerInit.collisionOnEnter)

    player.init(world, multiplayerInit.playerPosition[1], multiplayerInit.playerPosition[2])
    enemy = enemyFabric.new()
    enemy.init(world, multiplayerInit.enemyPosition[1], multiplayerInit.enemyPosition[2])
    day = true

    lake = physics.makeBody(world, multiplayerInit.lakePosition[1], multiplayerInit.lakePosition[2], 80, 80, "static")
    lake.fixture:setCategory(cat.TEXTURE)
    shotSound = love.audio.newSource("sounds/shot.wav", "static")
end

function multiplayer.update(dt)
    player.update(dt)
    world:update(dt)
    enemy.update(dt, player.body:getX(), player.body:getY())

    hub:getMessage()
    hub:sendMessage({
        port = port,
        x    = player.body:getX(),
        y    = player.body:getY(),
        xv   = xv,
        yv   = yv,
        anim = player.direction
    })

    cam:lookAt(player.body:getX(), player.body:getY())

    -- Ограничиваем камеру в границах карты
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w / 2 then cam.x = w / 2 end
    if cam.y < h / 2 then cam.y = h / 2 end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x > (mapW - w / 2) then cam.x = (mapW - w / 2) end
    if cam.y > (mapH - h / 2) then cam.y = (mapH - h / 2) end
end

function multiplayer.draw()
    cam:attach()
    gameMap:drawLayer(gameMap.layers["grass"])
    gameMap:drawLayer(gameMap.layers["road"])
    gameMap:drawLayer(gameMap.layers["trees"])

    local d1, d2, d3, d4 = day and 255 or 0.23, day and 255 or 0.25, day and 255 or 0.59, 1
    love.graphics.setColor(0.23, 0.25, 0.59, 1)
    love.graphics.polygon("fill", lake.body:getWorldPoints(lake.shape:getPoints()))

    love.graphics.setColor(d1, d2, d3, d4)

    -- Отрисовка себя
    player:draw(d1, d2, d3, d4)
    enemy:draw(d1, d2, d3, d4)

    -- Отрисовка других игроков
    for _, client in pairs(otherClients) do
        local clientAnim = player.animations[client.anim] or player.animations.left
        clientAnim:draw(player.spriteSheet, client.x, client.y, nil, 4, nil, 6, 9)
    end

    cam:detach()
end

function multiplayer.keypressed(key)
    if key == " " or key == "space" then
        if player.attackType then
            player.slash(shotSound)
        else
            player.shoot(shotSound)
        end
    elseif key == "q" then
        day = not day
    elseif key == "1" then
        player.attackType = not player.attackType
    end
end

function multiplayer.collisionOnEnter(fixture_a, fixture_b, contact)
    if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.ENEMY then
        player.collisionWithEnemy(fixture_b)
    end

    if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.E_SHOT then
        player.collisionWithShot()
        fixture_b:getBody():destroy()
        fixture_b:destroy()
    end

    if fixture_a:getCategory() == cat.DASHING_PLAYER and fixture_b:getCategory() == cat.E_SHOT then
        fixture_b:setCategory(cat.P_SHOT)
    end

    if fixture_b:getCategory() == cat.P_SHOT and fixture_a:getCategory() == cat.ENEMY then
        enemy.colisionWithShot(fixture_a, player.damage)
        fixture_b:getBody():destroy()
        fixture_b:destroy()
    end
end

return multiplayer
