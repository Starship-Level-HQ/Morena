local RandomLootProvider = {}
local lootTable = {
  {1.1, 1.2},
  {2.1, 2.2},
  {}
  }

function RandomLootProvider:newLoot(lvl)
  local arr = {}
  for i = 1, lvl do
    table.insert(arr, lootTable[i][math.random(1, #lootTable[i])])
  end
  return arr
end

return RandomLootProvider