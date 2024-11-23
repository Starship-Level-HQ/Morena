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

    -- mx, my = mx - offsetX + 130 + itemDrawW, my - offsetY + 180 + itemDrawH * 2
    mouseOn.is = false
    for y = 1, invH do
        for x = 1, invW do
            local drawX = (x - 1) * itemDrawW
            local drawY = (y - 1) * itemDrawH
            local mouseIsOn = mx > drawX and mx <= drawX + itemDrawW and my > drawY and my <= drawY + itemDrawH
            if mouseIsOn then
                mouseOn.is = true
                mouseOn.x, mouseOn.y = x, y
            end
        end
    end
    _log("Mouse position: ", mx, my)
    _log("Offset position: ", offsetX, offsetY)
    _log("Mouse on cell: ", mouseOn.is, mouseOn.x, mouseOn.y)
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
end

love.graphics.setLineWidth(2)
love.graphics.setNewFont(15)
function inventoryGui:draw()
    local offsetX, offsetY = cam:position()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", offsetX, offsetX, 50, 50)
    love.graphics.setColor(255, 255, 255)
    offsetX = offsetX - 180
    offsetY = offsetY - 130

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
        end
    end
    for y = 1, invH do
        for x = 1, invW do
            local drawX = (x - 1) * itemDrawW + offsetX
            local drawY = (y - 1) * itemDrawH + offsetY
            local item = inv.arr[y][x]
            if selected.is and selected.x == x and selected.y == y then
                love.graphics.setColor(255, 255, 255, 100)
                love.graphics.draw(item.img, drawX, drawY)
                love.graphics.setColor(0, 0, 0, 30)
                love.graphics.draw(item.img, mx + 10 + offsetX, my + 10 + offsetY)
            elseif item ~= 0 then
                love.graphics.setColor(255, 255, 255)
                love.graphics.draw(item.img, drawX, drawY)
            end
            if mouseOn.is and item ~= 0 and mouseOn.x == x and mouseOn.y == y then
                love.graphics.setColor(255, 255, 255) -- Белый цвет для фона
                love.graphics.rectangle("fill", itemDrawW * invW + 10 + offsetX, offsetY, infoBox.w, infoBox.h)
                love.graphics.setColor(0, 0, 0)       -- Черный цвет для текста
                love.graphics.printf(item.name .. "\n" .. item.desc, itemDrawW * invW + 15 + offsetX, offsetY,
                    infoBox.w - 5)
                love.graphics.setColor(255, 255, 255) -- Сбрасываем цвет для остальных элементов
            end
        end
    end
    if selected.is then
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(inv.arr[selected.y][selected.x].img, mx + offsetX, my + offsetY)
    end
end

return inventoryGui
