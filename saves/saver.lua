local restartCode = [[
  require("libraries/json")
  
  for i = 1, 3 do
    local f = io.open("saves/level"..tostring(i)..".json", "w")
    f:write("null")
    f:close()
  end
  local f = io.open("saves/player.json", "w")
  local pSave = {["world"] = 1, ["x"] = 100, ["y"] = 100, ["health"] = 100}
  f:write(json.encode(pSave))
  f:close()
]]

function globalSave(level, player)
  local f = io.open("saves/level"..tostring(level.number)..".json", "w")
  local levelSave = {enemies = {}, obstacles = {}, loot = {}}
  for i, e in ipairs(level.enemies) do
    table.insert(levelSave.enemies, {x = e.body:getX(), y = e.body:getY(), health = e.health})
  end
  f:write(json.encode(levelSave))
  f:close()
  levelSave = nil
  
  f = io.open("saves/player.json", "w")
  local pSave = {["world"] = level.number, ["x"] = player.body:getX(), ["y"] = player.body:getY(), ["health"] = player.health}
  f:write(json.encode(pSave))
  f:close()
  pSave = nil
end

function globalReadSave(levelNumber)
  local f = io.open("saves/level"..tostring(levelNumber)..".json", "r")
  local data = json.decode(f:read("*all"))
  f:close()
  return data
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
end