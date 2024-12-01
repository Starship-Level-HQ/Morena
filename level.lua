require("enemy")
require("player")
require("dialog")
require("inventory.src.objectsOnMap")

local level = {}
local enemies
local gameMap
local world
local lake
local day

local levels = {
    {
        map = "res/maps/testMap.lua",
        playerPosition = { 300, 450 },
        enemyPositions = { { 600, 100 }, { 600, 200 }, { 600, 300 } },
        lakePosition = { 400, 550 },
        loot = {{350, 400, 1}} -- x y id
    },
    {
        map = "res/maps/testMap.lua",
        playerPosition = { 100, 200 },
        enemyPositions = { { 400, 100 }, { 500, 200 }, { 600, 300 }, { 700, 400 } },
        lakePosition = { 300, 400 }
    }
    -- Добавляйте больше уровней с разными настройками
}

function level.startLevel(levelNumber)

  local levelData = levels[levelNumber]
  level.number = levelNumber
  level.pause = false
  level.isDialog = false
  love.window.setTitle("Morena - Level")
  cam = camera()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  gameMap = sti(levelData.map)
  world = love.physics.newWorld(0, 0, true)
  world:setGravity(0, 40)
  world:setCallbacks(level.collisionOnEnter, level.collisionOnEnd)

  player = Player.new(world, levelData.playerPosition[1], levelData.playerPosition[2])
  enemies = {}
  day = true

  for i, p in ipairs(levelData.enemyPositions) do
    local enemy = Enemy.new(world, p[1], p[2], i % 2 == 0, 250, 100)
    table.insert(enemies, enemy)
  end

  lake = physics.makeBody(world, levelData.lakePosition[1], levelData.lakePosition[2], 80, 80, "static")
  lake.fixture:setCategory(cat.TEXTURE)
  shotSound = love.audio.newSource("res/sounds/shot.wav", "static")
  
  mapStaff = MapStaff.new(world)
  mapStaff:addItem(350, 400, 1)
  mapStaff:addItem(353, 400, 1)
  mapStaff:addItem(355, 400, 1)
end

function level.endLevel()
    enemies = {}
    mapStaff:clearWorld()
    mapStaff = nil
end

function level.cameraFocus()
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

function level.update(dt)

  if not level.pause then
    if level.isDialog then
      local b = level.dialog.update(dt)
      if b ~= nil then
        cam:lookAt(b:getX(), b:getY())
        level.cameraFocus()
      end
    else
       player:update(dt)

            for _, enemy in ipairs(enemies) do
                enemy:update(dt, player.body:getX(), player.body:getY())
            end

            world:update(dt)

            cam:lookAt(player.body:getX(), player.body:getY())

            level.cameraFocus()

            if player.health < 0 then
                level.startLevel(level.number)
            end
        end
  elseif player.inventoryIsOpen then
      player:update(dt)
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

    mapStaff:draw(d1, d2, d3, d4)

    love.graphics.setColor(d1, d2, d3, d4)
    for _, enemy in ipairs(enemies) do
        enemy:draw(d1, d2, d3, d4)
    end

    player:draw(d1, d2, d3, d4)

    if level.isDialog then
        level.dialog.draw(d1, d2, d3, d4)
    end
    cam:detach()
end

function level.callback()
    level.isDialog = false
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
    elseif key == "i" then
      level.dialog = Dialog.new({{text="Rrrrrr...\nrrrrrr...", body = enemies[3].body}, {text = "Ah shit", body = player.body}, {text = "Here we go again", body = player.body, dur = 1.2}}, level.callback)
      level.isDialog = true
    elseif key == "p" then
        level.pause = not level.pause
    elseif key == "e" then
        level.pause = not level.pause
        player.inventoryIsOpen = not player.inventoryIsOpen
    elseif key == "f" then
        player:pickupItem(mapStaff)
    end
end

function level.mousepressed(x, y, b)
    dropedItem = player:mousepressed(x, y, b) 
    if dropedItem then
        print(dropedItem)
        mapStaff:dropItem(player.body:getX(), player.body:getY(), dropedItem)
    end
end

function level.collisionOnEnter(fixture_a, fixture_b, contact)
  if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.ENEMY then
    player:collisionWithEnemy(fixture_b, 10)
  end
  
  if (fixture_a:getCategory() == cat.PLAYER or fixture_a:getCategory() == cat.DASHING_PLAYER) 
  and fixture_b:getCategory() == cat.E_RANGE then
    fixture_b:getUserData():seePlayer(fixture_a)
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
    fixture_a:getUserData():colisionWithShot(fixture_b:getUserData())
    fixture_b:getBody():destroy()
    fixture_b:destroy()
  end

  if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.ITEM then
    local item = fixture_b:getUserData()
    item.collision = true 
    fixture_a:getUserData().nearestItem = item
  end 
end

function level.collisionOnEnd(fixture_a, fixture_b, contact)
  if (fixture_a:getCategory() == cat.PLAYER or fixture_a:getCategory() == cat.DASHING_PLAYER) 
  and fixture_b:getCategory() == cat.E_RANGE then
    fixture_b:getUserData():dontSeePlayer(fixture_a)
  end

  if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.ITEM then
    local item = fixture_b:getUserData()
    item.collision = false 
    local player = fixture_a:getUserData()
    if ( player.nearestItem == item) then
        fixture_a:getUserData().nearestItem = nil
    end
  end

end

return level
