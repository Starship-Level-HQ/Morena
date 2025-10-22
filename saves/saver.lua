local restartCode = [[
  require("libraries/json")
  
  for i = 1, 3 do
    local f = io.open("saves/level"..tostring(i)..".json", "w")
    f:write("null")
    f:close()
  end
  local f = io.open("saves/player.json", "w")
  local pSave = {world = 1, x = 100, y = 100, health = 100, inventory={arr={}, activeEquip={}}}
  f:write(json.encode(pSave))
  f:close()
]]

function globalSave(level, player)

  local levelSave = {enemies = {}, objects = {}, loot = {}}
  for _, e in ipairs(level.enemies) do
    local arr = {}
    pcall(
    function() 
      for _, s in ipairs(e.inventory.arr) do
        for _, o in ipairs(s) do
          if o ~= 0 then
            table.insert(arr, o.id)
          end
        end
      end
    end)
    table.insert(levelSave.enemies, {x = e.body:getX(), y = e.body:getY(), health = e.health, isAlive=e.isAlive, loot=arr})
  end
  for _, o in ipairs(level.mapStaff.nonActiveItems) do
    if o.inventory == nil then
      table.insert(levelSave.objects, {class = o.class, x = o.body:getX(), y = o.body:getY(), h = o.height, w = o.width, bodyType = o.body:getType()})
    else
      local arr = {}
      for _, s in ipairs(o.inventory.arr) do
        for _, o1 in ipairs(s) do
          if o1 ~= 0 then
            table.insert(arr, o1.id)
          end
        end
      end
      table.insert(levelSave.objects, {class = o.class, x = o.body:getX(), y = o.body:getY(), h = o.height, w = o.width, bodyType = o.body:getType(), loot = arr})
    end
  end
  for _, o in ipairs(level.mapStaff.items) do
    table.insert(levelSave.loot, {x = o.body:getX(), y = o.body:getY(), id = o.item.id})
  end

  local pSave = {world = level.number, x = player.body:getX(), y = player.body:getY(), health = player.health, inventory={arr={}, activeEquip={}}}
  for _, s in ipairs(player.inventory.arr) do
    for _, o in ipairs(s) do
      if o ~= 0 then
        table.insert(pSave.inventory.arr, o.id)
      end
    end
  end

  for k, v in pairs(player.inventory.activeEquip) do
    table.insert(pSave.inventory.activeEquip, v.id)
  end

  local code = [[
    local levelNumber, levelSave, playerSave = ...
    package.path = "./libraries/?.lua;" .. package.path
    local json = require("json")
    local f = io.open("saves/level"..tostring(levelNumber)..".json", "w")
    f:write(json.encode(levelSave))
    f:close()
    f = io.open("saves/player.json", "w")
    f:write(json.encode(playerSave))
    f:close()
  ]]

  local thread = love.thread.newThread(code)
  thread:start(level.number, levelSave, pSave)
  levelSave = nil
  pSave = nil
end

function globalReadSave(levelNumber)
  local status, data = pcall( function()
      local f = io.open("saves/level"..tostring(levelNumber)..".json", "r")
      local data = json.decode(f:read("*all"))
      f:close()

      return data
    end )

  if status then
    return data
  else
    return nil
  end
end

function globalReadPlayerSave()
  local f = io.open("saves/player.json", "r")
  local data = json.decode(f:read("*all"))
  f:close()
  return data
end

function globalRemoveAllSaves()
  local thread = love.thread.newThread(restartCode)
  thread:start()
  thread:wait()
end