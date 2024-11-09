local menu = {}
local buttonStart = { x = 100, y = 100, width = 200, height = 50 }
local buttonLevel2 = { x = 100, y = 170, width = 200, height = 50 }
local buttonMultiplayer = { x = 100, y = 240, width = 200, height = 50 }
local buttonExit = { x = 100, y = 310, width = 200, height = 50 }

local background
local character
local buttonStartBackground
local buttonLevel2Background
local buttonMultiplayerBackground
local buttonExitBackground

-- Цвета для фона кнопок
local buttonColor = { 0.65, 0.5, 0.3 }
local colors = {
    { 0.65, 0.5,  0.3 },
    { 0.67, 0.5,  0.3 },
    { 0.69, 0.54, 0.3 },
    { 0.63, 0.5,  0.3 },
    { 0.61, 0.5,  0.3 },
    { 0.65, 0.55, 0.3 },
    { 0.65, 0.52, 0.3 },
    { 0.65, 0.48, 0.3 },
    { 0.61, 0.46, 0.3 },
}
--[[local colors = {
    {0.5, 0.4, 0.3},   -- темно-коричневый, основа
    {0.6, 0.5, 0.4},   -- более светлый коричневый
    {0.4, 0.35, 0.3},  -- темный землистый коричневый
    {0.55, 0.45, 0.35}, -- серо-коричневый, приглушенный оттенок
    {0.4, 0.4, 0.4},   -- нейтрально-серый для каменного эффекта
    {0.5, 0.5, 0.45},  -- светло-серый с легким оттенком зелени
    {0.35, 0.3, 0.25}, -- темно-коричневый с примесью черного
    {0.45, 0.35, 0.3}, -- темный землистый с чуть теплым оттенком
    {0.55, 0.5, 0.45}, -- теплый серо-коричневый
    {0.48, 0.43, 0.38}, -- приглушенный серо-коричневый
    {0.6, 0.55, 0.5},   -- светло-коричневый для некоторого разнообразия
}]]
local function generateButtonBackhround(currButton)
    --Генерация фона для кнопки Start Level
    buttonBackground = love.graphics.newCanvas(currButton.width, currButton.height)
    love.graphics.setCanvas(buttonBackground)
    love.graphics.setColor(buttonColor)
    love.graphics.rectangle("fill", 0, 0, currButton.width, currButton.height)
    local pixSize = 3
    for i = 1, 1000 do
        local color = colors[math.random(#colors)]
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", math.random(0, currButton.width - pixSize),
            math.random(0, currButton.height - pixSize), pixSize, pixSize)
    end
    love.graphics.setLineWidth(5)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", 0, 0, currButton.width, currButton.height)
    love.graphics.setCanvas()
    return buttonBackground
end

function menu.load()
    love.window.setTitle("Morena - Main Menu")

    background = love.graphics.newImage('menu/backGround.png')
    character = love.graphics.newImage("menu/character.png")

    buttonStartBackground = generateButtonBackhround(buttonStart)
    buttonLevel2Background = generateButtonBackhround(buttonLevel2)
    buttonMultiplayerBackground = generateButtonBackhround(buttonMultiplayer)
    buttonExitBackground = generateButtonBackhround(buttonExit)
end

function menu.update(dt)
end

-- Функция для рисования кнопки с заданным Canvas фоном
local function drawButton(button, buttonBackground, text)
    love.graphics.draw(buttonBackground, button.x, button.y)
    love.graphics.setColor(1, 1, 1) -- белый цвет для текста
    love.graphics.print(text, button.x + 20, button.y + 15)
end

function menu.draw()
    love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth() / background:getWidth(),
        love.graphics.getHeight() / background:getHeight())
    love.graphics.draw(character, 600, 500, 0, 3, 3)
    drawButton(buttonStart, buttonStartBackground, "Start Level 1")
    drawButton(buttonLevel2, buttonLevel2Background, "Start Level 2")
    drawButton(buttonMultiplayer, buttonMultiplayerBackground, "Multiplayer")
    drawButton(buttonExit, buttonExitBackground, "Exit")
end

local function isMouseOverButton(x, y, button)
    return x >= button.x and x <= button.x + button.width and
        y >= button.y and y <= button.y + button.height
end
function menu.mousepressed(x, y, button)
    if button == 1 then -- Левый клик
        if isMouseOverButton(x, y, buttonStart) then
            startLevel(1)
        elseif isMouseOverButton(x, y, buttonLevel2) then
            startLevel(2)
        elseif isMouseOverButton(x, y, buttonMultiplayer) then
            startMultiplayer()
        elseif isMouseOverButton(x, y, buttonExit) then
            love.event.quit()
        end
    end
end

return menu
