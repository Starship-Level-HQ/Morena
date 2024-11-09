require("enemy")
require("player")
local physics = require("physics")

local level = {}
local enemies
local cam
local gameMap
local world
local lake
local day

local levels = {
    {
        map = "maps/testMap.lua",
        playerPosition = { 300, 450 },
        enemyPositions = { { 600, 100 }, { 600, 200 }, { 600, 300 } },
        lakePosition = { 400, 550 }
    },
    {
        map = "maps/testMap.lua",
        playerPosition = { 100, 200 },
        enemyPositions = { { 400, 100 }, { 500, 200 }, { 600, 300 }, { 700, 400 } },
        lakePosition = { 300, 400 }
    }
    -- Добавляйте больше уровней с разными настройками
}

function level.startLevel(levelNumber)
    local levelData = levels[levelNumber]
    love.window.setTitle("Morena - Level")
    cam = camera()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    gameMap = sti(levelData.map)
    world = love.physics.newWorld(0, 0, true)
    world:setGravity(0, 40)
    world:setCallbacks(level.collisionOnEnter)

    player = Player.new(world, levelData.playerPosition[1], levelData.playerPosition[2])
    enemies = {}
    day = true

    for i = 1, 3 do
        local enemy = Enemy.new(world, levelData.enemyPositions[i][1], levelData.enemyPositions[i][2], i % 2 == 0)
        table.insert(enemies, enemy)
    end

    lake = physics.makeBody(world, levelData.lakePosition[1], levelData.lakePosition[2], 80, 80, "static")
    lake.fixture:setCategory(cat.TEXTURE)
    shotSound = love.audio.newSource("sounds/shot.wav", "static")
end

function level.endLevel()
    enemies = {}
end

function level.update(dt)
    player:update(dt)

    for _, enemy in ipairs(enemies) do
        enemy:update(dt, player.body:getX(), player.body:getY())
    end

    world:update(dt)
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

    if player.health < 0 then
        level.startLevel(1)
    end
end

function level.draw()
    cam:attach()
    gameMap:drawLayer(gameMap.layers["grass"])
    gameMap:drawLayer(gameMap.layers["road"])
    gameMap:drawLayer(gameMap.layers["trees"])

    local d1, d2, d3, d4 = day and 255 or 0.23, day and 255 or 0.25, day and 255 or 0.59, 1
    love.graphics.setColor(0.23, 0.25, 0.59, 1)
    love.graphics.polygon("fill", lake.body:getWorldPoints(lake.shape:getPoints()))

    love.graphics.setColor(d1, d2, d3, d4)
    for _, enemy in ipairs(enemies) do
        enemy:draw(d1, d2, d3, d4)
    end

    player:draw(d1, d2, d3, d4)
    cam:detach()
end

function level.keypressed(key)
    if key == " " or key == "space" then
        if player.attackType then
            player:slash(shotSound)
        else
            player:shoot(shotSound)
        end
    elseif key == "q" then
        day = not day
    elseif key == "1" then
        player.attackType = not player.attackType
    end
end

function level.collisionOnEnter(fixture_a, fixture_b, contact)
    if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.ENEMY then
        player:collisionWithEnemy(fixture_b, 10)
    end

    if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.E_SHOT then
        player:collisionWithShot(fixture_b:getUserData())
        fixture_b:getBody():destroy()
        fixture_b:destroy()
    end

    if fixture_a:getCategory() == cat.DASHING_PLAYER and fixture_b:getCategory() == cat.E_SHOT then
        fixture_b:setCategory(cat.P_SHOT)
    end

    if fixture_b:getCategory() == cat.P_SHOT and fixture_a:getCategory() == cat.ENEMY then
        for _, enemy in ipairs(enemies) do
            enemy:colisionWithShot(fixture_a, fixture_b:getUserData())
            fixture_b:getBody():destroy()
            fixture_b:destroy()
        end
    end
end

return level
