local item = {}
item.__index = item

function item.new(name,img,desc)
  local itm = {}
  setmetatable(itm,item)
  itm.name = name
  itm.img = love.graphics.newImage(img)
  itm.desc = desc
  return itm
end

return item