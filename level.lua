require("enemy")
require "angles"
require("player/player")
require("dialog")
require("inventory.src.mapStaff")
require("NPCs/zombee")
require("NPCs/smartZombee")
require("NPCs/kaban")
require("NPCs/leshiy")
require("shot")
require("objects/rock")
require("objects/teleport")

level = {}
local gameMap
local world
local day

local levels = {
  {
    map = "res/maps/testMap.lua",
    playerPosition = { 300, 450 },
    enemyPositions = { { 600, 100, Kaban}, { 600, 300, Zombee} },
    obstacles = {{ 400, 550, 80, 80}},
    objects = { {Rock, 555, 550, 37, 25, "dynamic"} },
    teleports = { {x=800, y=800, h=80, w=80, level=2, pX=100, pY=200} },
    loot = { { 350, 400, 2.1 },  {370, 400, 2.2}, {500, 500, 1.1}} -- x y id
  },
  {
    map = "res/maps/testMap.lua",
    playerPosition = { 100, 200 },
    enemyPositions = { { 550, 200, SmartZombee } , { 525, 225, SmartZombee }, { 575, 225, SmartZombee }, { 575, 200, SmartZombee } }, 
    objects = {{Rock, 500, 500, 37, 25, "dynamic"}},
    teleports = { {x=800, y=800, h=80, w=80, level=3, pX=100, pY=300} },
    obstacles = {{ 400, 200, 100, 150}, { 375, 150, 150, 100}},
    loot = { { 350, 400, 2.1 },  {370, 400, 2.2}, {500, 500, 1.1}}
  },
  {
    map = "res/maps/testMap.lua",
    playerPosition = { 100, 200 },
    enemyPositions = { { 700, 400, Leshiy } },
    obstacles = {{ 0, 0 , 10, 10}},
    objects = {{Rock, 300, 299, 37, 25, "dynamic"}},
    teleports = { {x=800, y=800, h=80, w=80, level=1, pX=100, pY=400} },
    loot = { { 350, 400, 2.1 },  {370, 400, 2.2}, {500, 500, 1.1}}
  }
  -- Добавляйте больше уровней с разными настройками
}

function level.continue()
  local playerData = globalReadPlayerSave()
  if playerData == nil then
    level.startLevel(1, {world = 1, x = 100, y = 100, health = 100, inventory={arr={}, activeEquip={}}})
  else
    level.startLevel(playerData["world"], playerData)
  end
end

function level.startLevel(levelNumber, playerData)
  
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
  
  local savedData = globalReadSave(levelNumber)
  
  player = Player.new(world, playerData)

  level.obstacles = {}

  for i, o in ipairs(levelData.obstacles) do
    local ob = physics.makeBody(world, o[1], o[2], o[3], o[4], "static")
    ob.fixture:setCategory(cat.TEXTURE)
    ob.x, ob.y = ob.body:getWorldPoints(ob.shape:getPoints())
    ob.w = o[3]
    ob.h = o[4]
    table.insert(level.obstacles, ob)
  end
  
  level.enemies = {}
  day = true

  --shotSound = love.audio.newSource("res/sounds/shot.wav", "static")

  level.mapStaff = MapStaff.new(world)
  
  if savedData ~= nil then
    for i, p in ipairs(levelData.enemyPositions) do
      local enemy = p[3]:new(world, savedData.enemies[i])
      table.insert(level.enemies, enemy)
    end
    for _, item in ipairs(savedData.loot) do
      level.mapStaff:addItem(item.x, item.y, item.id)
    end
    for i, o in ipairs(levelData.objects) do
      level.mapStaff:addNonActiveItem(o[1].new(world, savedData.objects[i]))
    end
  else
    for _, p in ipairs(levelData.enemyPositions) do
      local enemy = p[3]:new(world, {x=p[1], y=p[2], health=100, isAlive=true})
      table.insert(level.enemies, enemy)
    end
    for _, l in ipairs(levelData.loot) do
      level.mapStaff:addItem(l[1], l[2], l[3])
    end
    for _, o in ipairs(levelData.objects) do
      level.mapStaff:addNonActiveItem(o[1].new(world, {x=o[2], y=o[3], h=o[4], w=o[5], bodyType=o[6]}))
    end
  end
  
  for i, t in ipairs(levelData.teleports) do
    level.mapStaff:addNonActiveItem(Teleport.new(world, t.x, t.y, t.h, t.w, t.level, t.pX, t.pY))
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
  level.enemies = {}
  level.mapStaff:clearWorld()
  level.mapStaff = nil
  --world:destroy()
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
      player:update(dt, false)

      for _, enemy in ipairs(level.enemies) do
        enemy:update(dt)
      end

      world:update(dt)

      cam:lookAt(player.body:getX(), player.body:getY())

      level.cameraFocus()

      if player.health < 0 then
        level.continue()
      end
    end
  elseif player.inventoryIsOpen then
    player:update(dt, true)
  end
  local nextLevel = love.thread.getChannel('trans'):pop()
  if nextLevel then
    level.endLevel()
    local number, pX, pY = unpack(nextLevel)
    local pData = globalReadPlayerSave()
    pData.x = pX
    pData.y = pY
    pData.world = number
    level.startLevel(number, pData)
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

  level.mapStaff:draw(d1, d2, d3, d4)

  love.graphics.setColor(d1, d2, d3, d4)
  for _, enemy in ipairs(level.enemies) do
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
  elseif key == "escape" then
    globalSave(level, player)
    level.pause = not level.pause
    if player.inventoryIsOpen then
      player.inventoryIsOpen = false
    end
  elseif key == "q" then
    day = not day
  elseif key == "1" then
    player.attackType = 'slash'
  elseif key == "2" then
    player.attackType = 'shoot'
  elseif key == "u" then
    level.dialog = Dialog.new(
      { { text = "Rrrrrr...\nrrrrrr...", body = level.enemies[1].body }, { text = "Ah shit", body = player.body }, { text = "Here we go again", body = player.body, dur = 1.2 } },
      level.callback)
    level.isDialog = true
  elseif key == "p" then
    level.pause = not level.pause
  elseif key == "i" then
    level.pause = not level.pause
    player.inventoryIsOpen = not player.inventoryIsOpen
  elseif key == "e" then
    player:pickupItem(level.mapStaff)
  end
end

function level.mousepressed(x, y, b)
  dropedItem = player:mousepressed(x, y, b)
  if dropedItem then
    print(dropedItem)
    level.mapStaff:dropItem(player.body:getX(), player.body:getY(), dropedItem)
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

function level.transition(levelNumber_pX_pY)
  level.pause = true
  globalSave(level, player)

  local code = [[
    local min, max, levelNum, pX, pY = ...
    local timer = require 'love.timer'
    for i = min, max do
      love.thread.getChannel('color'):push(0.01)
      timer.sleep(0.01)
    end
    love.thread.getChannel('trans'):push({levelNum, pX, pY})
  ]]
  
  local thread = love.thread.newThread(code)
  local levelNumber, pX, pY = unpack(levelNumber_pX_pY)
  thread:start(1, 100, levelNumber, pX, pY)
  
end

return level
