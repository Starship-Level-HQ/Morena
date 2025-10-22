BoxGui = {}
local drawSize = 50

function BoxGui:new(inventory)
  local this = {}
  this.inv = inventory
  this.invW = #inventory.arr[1]
  this.invH = #inventory.arr
  
  setmetatable(this,self)
  self.__index = self
  return this
end

local mx, my = 0, 0

local mouseOn = { is = false, x = 1, y = 1 }

local selected = { is = false, x = 1, y = 1 }

local infoBox = { w = 200, h = 200 }

function BoxGui:update()
  local offsetX, offsetY = cam:position()

  mx, my = love.mouse.getPosition()
  mx = mx + offsetX - love.graphics.getWidth()/2
  my = my + offsetY - love.graphics.getHeight()/2

  offsetX = offsetX - 140
  offsetY = offsetY + 100

  mouseOn.is = false
  for y = 1, self.invH do
    for x = 1, self.invW do
      local drawX = (x - 1) * drawSize + offsetX
      local drawY = (y - 1) * drawSize + offsetY

      local mouseIsOn = mx > drawX and mx <= drawX + drawSize and my > drawY and my <= drawY + drawSize
      if mouseIsOn then
        mouseOn.is = true
        mouseOn.x, mouseOn.y = x, y

      end
    end
  end

end

function BoxGui:mousepressed(x, y, b, secondInv)
  if b == 1 then --левая кнопка мыши
    if mouseOn.is then

      if self.inv.arr[mouseOn.y][mouseOn.x] ~= 0 then
        selected.is = true
        selected.x = mouseOn.x
        selected.y = mouseOn.y
      end

      if selected.is then
        secondInv:addItem(self.inv:removeItem(selected.x, selected.y))
      end

    end
  end
  if b == 2 then --правая кнопка мыши
    if mouseOn.is then
      local item = self.inv.arr[mouseOn.y][mouseOn.x]
      if item ~= 0 then
        if item.type == "Зелье" then
          self.inv:removeItem(mouseOn.x, mouseOn.y)
          return {target = item.target, signature = item.effects}
        end 
      end
    end
  end
end

--love.graphics.setLineWidth(2)
--love.graphics.setNewFont(15)
function BoxGui:draw()
  local offsetX, offsetY = cam:position()

  offsetX = offsetX - 140
  offsetY = offsetY + 100

  love.graphics.setColor(255, 255, 255)

  for y = 1, self.invH do
    for x = 1, self.invW do
      local drawX = (x - 1) * drawSize + offsetX
      local drawY = (y - 1) * drawSize + offsetY
      local mouseOnThis = mouseOn.is and mouseOn.x == x and mouseOn.y == y
      if mouseOnThis then
        love.graphics.setColor(200, 200, 200)
      else
        love.graphics.setColor(170, 170, 170)
      end
      love.graphics.rectangle("fill", drawX, drawY, drawSize, drawSize)
      love.graphics.setColor(0, 0, 0)
      love.graphics.rectangle("line", drawX, drawY, drawSize, drawSize)
      love.graphics.setColor(255, 255, 255)
      local item = self.inv.arr[y][x]
      if mouseOn.is and item ~= 0 and mouseOn.x == x and mouseOn.y == y then
        love.graphics.setColor(255, 255, 255) -- Белый цвет для фона
        love.graphics.rectangle("fill", drawSize * self.invW + 10 + offsetX, offsetY, infoBox.w, infoBox.h)
        love.graphics.setColor(0, 0, 0)       -- Черный цвет для текста
        love.graphics.printf(item.name .. "\n" .. item.desc .. "\n" .. string.gsub(json.encode(item.effects), "\"", " "), drawSize * self.invW + 15 + offsetX, offsetY, infoBox.w - 5)
        love.graphics.setColor(255, 255, 255) -- Сбрасываем цвет для остальных элементов
      end

      if not selected.id and item ~= 0 then
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(item.img, drawX, drawY)
      end
    end
  end

  if selected.is then
    --Smooth animation
  end
end
