local item = {}
item.__index = item

function item.new(name,img,desc,usage)
  local itm = {}
  setmetatable(itm,item)
  itm.name = name
  itm.img = love.graphics.newImage(img)
  itm.desc = desc
  itm.usage = usage
  return itm
end

return item