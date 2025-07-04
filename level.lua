require("enemy")
require "angles"
require("player/player")
require("dialog")
require("inventory.src.objectsOnMap")
require("NPCs/zombee")
require("NPCs/smartZombee")
require("NPCs/kaban")
require("NPCs/leshiy")
require("shot")
require("objects/rock")
require("objects/teleport")

level = {}
local enemies
local gameMap
local world
local lake
local day

local levels = {
  {
    map = "res/maps/testMap.lua",
    playerPosition = { 300, 450 },
    enemyPositions = { { 600, 100, Kaban}, { 600, 200, Zombee}, { 600, 300, Kaban} },
    obstacles = {{ 400, 550, 80, 80}},
    objects = { {Rock, 555, 550, 37, 25, "dynamic"} },
    teleports = { {800, 800, 80, 80, 2} },
    loot = { { 350, 400, 1 } } -- x y id
  },
  {
    map = "res/maps/testMap.lua",
    playerPosition = { 100, 200 },
    enemyPositions = { { 550, 200, SmartZombee }, { 525, 225, SmartZombee }, { 575, 225, SmartZombee }, { 575, 200, SmartZombee } }, 
    --obstacles = {{ 400, 200, 100, 100}},
    objects = {{Rock, 500, 500, 37, 25, "dynamic"}},
    teleports = { {800, 800, 80, 80, 3} },
    obstacles = {{ 400, 200, 100, 150}, { 375, 150, 150, 100}}
  },
  {
    map = "res/maps/testMap.lua",
    playerPosition = { 100, 200 },
    enemyPositions = { { 700, 400, Leshiy } },
    obstacles = {{ 0, 0 , 10, 10}},
    objects = {{Rock, 300, 299, 37, 25, "dynamic"}},
    teleports = { {800, 800, 80, 80, 1} }
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
  love.mouse.setCursor(love.mouse.newCursor('res/sprites/curs.png', 272 , 272))
  
  level.defaultColor1 = 0
  level.defaultColor2 = 0
  level.defaultColor3 = 0
  level.defaultColor4 = 0

  level.obstacles = {}

  for i, o in ipairs(levelData.obstacles) do
    local ob = physics.makeBody(world, o[1], o[2], o[3], o[4], "static")
    ob.fixture:setCategory(cat.TEXTURE)
    ob.x, ob.y = ob.body:getWorldPoints(ob.shape:getPoints())
    ob.w = o[3]
    ob.h = o[4]
    table.insert(level.obstacles, ob)
  end

  player = Player.new(world, levelData.playerPosition[1], levelData.playerPosition[2])
  enemies = {}
  day = true

  for i, p in ipairs(levelData.enemyPositions) do
    local enemy
    enemy = p[3].new(world, p[1], p[2], 250, 100)
    table.insert(enemies, enemy)
  end

  --shotSound = love.audio.newSource("res/sounds/shot.wav", "static")

  mapStaff = MapStaff.new(world)
  mapStaff:addItem(350, 400, 1)
  mapStaff:addItem(370, 400, 2)
  mapStaff:addItem(800, 800, 1)
  
  for i, o in ipairs(levelData.objects) do
    mapStaff:addNonActiveItem(o[1].new(world, o[2], o[3], o[4], o[5], o[6]))
  end
  
  for i, t in ipairs(levelData.teleports) do
    mapStaff:addNonActiveItem(Teleport.new(world, t[1], t[2], t[3], t[4], t[5]))
  end
  
  local code = [[
    local min, max, levelNum = ...
    local timer = require 'love.timer'
    for i = min, max do
      love.thread.getChannel('color'):push(-0.01)
      timer.sleep(0.01)
    end
  ]]
  
  local thread = love.thread.newThread(code)
  thread:start(1, 100, levelNumber)
  
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
        enemy:update(dt)
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
  local newLevelNumber = love.thread.getChannel('trans'):pop()
  if newLevelNumber then
    level.startLevel(newLevelNumber)
  end
end

function level.draw()
  cam:attach()
  gameMap:drawLayer(gameMap.layers["grass"])
  gameMap:drawLayer(gameMap.layers["road"])
  gameMap:drawLayer(gameMap.layers["trees"])

  local newColor = love.thread.getChannel('color'):pop()
  if newColor then
    level.defaultColor1 = level.defaultColor1 - newColor
    level.defaultColor2 = level.defaultColor2 - newColor
    level.defaultColor3 = level.defaultColor3 - newColor
    level.defaultColor4 = level.defaultColor4 - newColor
  end
  local d1, d2, d3, d4 = level.defaultColor1, level.defaultColor2, level.defaultColor3, level.defaultColor4
  
  love.graphics.setColor(0.23, 0.25, 0.59, 1)
  for i, ob in ipairs(level.obstacles) do
    love.graphics.setColor(0.23, 0.25, 0.59, 1)
    love.graphics.polygon("fill", ob.body:getWorldPoints(ob.shape:getPoints()))
  end

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
    --fek
  elseif key == "q" then
    day = not day
  elseif key == "1" then
    player.attackType = 'slash'
  elseif key == "2" then
    player.attackType = 'shoot'
  elseif key == "i" then
    level.dialog = Dialog.new(
      { { text = "Rrrrrr...\nrrrrrr...", body = enemies[3].body }, { text = "Ah shit", body = player.body }, { text = "Here we go again", body = player.body, dur = 1.2 } },
      level.callback)
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

  if fixture_a:getCategory() == cat.P_SHOT and fixture_b:getCategory() == cat.E_RANGE then
    if fixture_b:getUserData().dodge ~= nil then
      fixture_b:getUserData().dodge(fixture_a:getUserData())
    end
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
  
  if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.TRIGGER then
    level.transition(fixture_b:getUserData())
  end
end

function level.collisionOnEnd(fixture_a, fixture_b, contact)
  if (fixture_a:getCategory() == cat.PLAYER or fixture_a:getCategory() == cat.DASHING_PLAYER)
  and fixture_b:getCategory() == cat.E_RANGE then
    fixture_b:getUserData():dontSeePlayer(fixture_a)
  end

  if (fixture_a:getCategory() == cat.PLAYER or fixture_a:getCategory() == cat.DASHING_PLAYER) and fixture_b:getCategory() == cat.ITEM then
    local item = fixture_b:getUserData()
    item.collision = false
    local player = fixture_a:getUserData()
    if (player.nearestItem == item) then
      fixture_a:getUserData().nearestItem = nil
    end
  end
end

function level.transition(levelNumber)
  level.pause = true

  local code = [[
    local min, max, levelNum = ...
    local timer = require 'love.timer'
    for i = min, max do
      love.thread.getChannel('color'):push(0.01)
      timer.sleep(0.01)
    end
    love.thread.getChannel('trans'):push(levelNum)
  ]]
  
  local thread = love.thread.newThread(code)
  thread:start(1, 100, levelNumber)
  
end

return level
