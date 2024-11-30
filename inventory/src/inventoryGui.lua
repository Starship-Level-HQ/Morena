local inventoryGui = {}

local inv
local invW
local invH
local itemDrawW
local itemDrawH

function inventoryGui:setInventory(inventory, iconW, iconH)
    inv = inventory
    invW = #inv.arr[1]
    invH = #inv.arr
    itemDrawW = iconW
    itemDrawH = iconH
end

local mx, my = love.mouse.getPosition()

local mouseOn = { is = false, x = 1, y = 1 }

local selected = { is = false, x = 1, y = 1 }

local infoBox = { w = 200, h = 200 }

function inventoryGui:update()
    local offsetX, offsetY = cam:position()
    
    mx, my = love.mouse.getPosition()
    mx = mx + offsetX - love.graphics.getWidth()/2
    my = my + offsetY - love.graphics.getHeight()/2
    
    offsetX = offsetX - 140
    offsetY = offsetY - 140
  
    mouseOn.is = false
    for y = 1, invH do
        for x = 1, invW do
            local drawX = (x - 1) * itemDrawW + offsetX
            local drawY = (y - 1) * itemDrawH + offsetY
            
            local mouseIsOn = mx > drawX and mx <= drawX + itemDrawW and my > drawY and my <= drawY + itemDrawH
            if mouseIsOn then
                mouseOn.is = true
                mouseOn.x, mouseOn.y = x, y
              
            end
        end
    end
    --_log("Mouse position: ", mx, my)
    --_log("Offset position: ", offsetX, offsetY)
    --_log("Mouse on cell: ", mouseOn.is, mouseOn.x, mouseOn.y)
end

function inventoryGui:mousepressed(x, y, b)
    if b == 1 then
        if mouseOn.is then
            if not selected.is then
                if inv.arr[mouseOn.y][mouseOn.x] ~= 0 then
                    selected.is = true
                    selected.x = mouseOn.x
                    selected.y = mouseOn.y
                end
            else
                inv:replace(selected.x, selected.y, mouseOn.x, mouseOn.y)
                selected.is = false
            end
        end
    end
    if b == 2 then
      if mouseOn.is then
            if inv.arr[mouseOn.y][mouseOn.x] ~= 0 and inv.arr[mouseOn.y][mouseOn.x].usage ~= nil then
                inv.arr[mouseOn.y][mouseOn.x].usage()
                inv:removeItem(mouseOn.y, mouseOn.x)
            end
        end
      end
end

love.graphics.setLineWidth(2)
love.graphics.setNewFont(15)
function inventoryGui:draw()
    local offsetX, offsetY = cam:position()
    
    offsetX = offsetX - 140
    offsetY = offsetY - 140
  
    love.graphics.setColor(255, 255, 255)

    for y = 1, invH do
        for x = 1, invW do
            local drawX = (x - 1) * itemDrawW + offsetX
            local drawY = (y - 1) * itemDrawH + offsetY
            local mouseOnThis = mouseOn.is and mouseOn.x == x and mouseOn.y == y
            if mouseOnThis then
                love.graphics.setColor(200, 200, 200)
            else
                love.graphics.setColor(170, 170, 170)
            end
            love.graphics.rectangle("fill", drawX, drawY, itemDrawW, itemDrawH)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", drawX, drawY, itemDrawW, itemDrawH)
            love.graphics.setColor(255, 255, 255)
            local item = inv.arr[y][x]
            if mouseOn.is and item ~= 0 and mouseOn.x == x and mouseOn.y == y then
                love.graphics.setColor(255, 255, 255) -- Белый цвет для фона
                love.graphics.rectangle("fill", itemDrawW * invW + 10 + offsetX, offsetY, infoBox.w, infoBox.h)
                love.graphics.setColor(0, 0, 0)       -- Черный цвет для текста
                love.graphics.printf(item.name .. "\n" .. item.desc, itemDrawW * invW + 15 + offsetX, offsetY,
                    infoBox.w - 5)
                love.graphics.setColor(255, 255, 255) -- Сбрасываем цвет для остальных элементов
            end
            
            if not selected.id and item ~= 0 then
                love.graphics.setColor(255, 255, 255)
                love.graphics.draw(item.img, drawX, drawY)
            end
        end
    end
  
    if selected.is then
      love.graphics.setColor(0, 0, 0, 30)
      love.graphics.draw(inv.arr[selected.y][selected.x].img, mx+10, my+10)
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(inv.arr[selected.y][selected.x].img, mx, my)
    end
end

return inventoryGui
