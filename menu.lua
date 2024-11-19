local menu = {}

local menuRouter = { "main" } -- solo, multiplayer, settings, список если вдруг понадобится более сложная вложеная менюшка
local activeInputButton = nil

local cursorBlink = true -- Для мигания курсора
local cursorBlinkTimer = 0
local cursorBlinkInterval = 0.5

-- Таблица для хранения данных о кнопках
local buttons = {
    main = {
        { text = "Camping",     action = function() table.insert(menuRouter, "solo") end },
        { text = "Multiplayer", action = function() table.insert(menuRouter, "multiplayer") end },
        { text = "Settings",    action = function() userConfig.blood = not userConfig.blood end },
        { text = "Exit",        action = function() love.event.quit() end }
    },
    solo = {
        { text = "Start Level 1", action = function() startLevel(1) end },
        { text = "Start Level 2", action = function() startLevel(2) end },
        --{ text = "Load", action = function()  end },
        { text = "Back",          action = function() table.remove(menuRouter) end }
    },
    multiplayer = {
        {
            text = "Port",
            action = function(self)
                self.text = ""
                activeInputButton = self
            end
        }, -- поле для ввода. Пока что ни на что не влияет.
        {
            text = "Join",
            action = function()
                local channel = activeInputButton ~= nil and activeInputButton.text or "Morena"
                startMultiplayer(channel)
            end
        },
        { text = "Back", action = function() table.remove(menuRouter) end }
    }
}

local buttonBackgrounds = {} -- Таблица для хранения фонов кнопок

local background
local character

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
-- Генерация фона для кнопки
local function generateButtonBackground(width, height)
    local buttonBackground = love.graphics.newCanvas(width, height)
    love.graphics.setCanvas(buttonBackground)

    love.graphics.setColor(0.65, 0.5, 0.3) -- основной цвет кнопки
    love.graphics.rectangle("fill", 0, 0, width, height)

    local pixSize = 3
    for i = 1, 1000 do
        local color = colors[math.random(#colors)]
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", math.random(0, width - pixSize),
            math.random(0, height - pixSize), pixSize, pixSize)
    end

    love.graphics.setLineWidth(5)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", 0, 0, width, height)
    love.graphics.setCanvas()
    return buttonBackground
end

function menu.load()
    love.window.setTitle("Morena - Main Menu")

    background = love.graphics.newImage('res/menu/backGround.png')
    character = love.graphics.newImage("res/menu/MC.png")

    -- Генерация фонов и размещение кнопок
    local buttonWidth, buttonHeight = 200, 50
    local startX, startY, spacing = 100, 100, 70

    for state, btnList in pairs(buttons) do
        for i, button in ipairs(btnList) do
            button.x = startX
            button.y = startY + (i - 1) * spacing
            button.width = buttonWidth
            button.height = buttonHeight
            button.background = generateButtonBackground(buttonWidth, buttonHeight)
        end
    end
end

function menu.update(dt)
    -- Обновление таймера для мигания курсора
    cursorBlinkTimer = cursorBlinkTimer + dt
    if cursorBlinkTimer >= cursorBlinkInterval then
        cursorBlink = not cursorBlink -- Переключение состояния курсора
        cursorBlinkTimer = 0
    end
end

-- Функция для рисования кнопки
local function drawButton(button)
    love.graphics.draw(button.background, button.x, button.y)
    love.graphics.setColor(1, 1, 1) -- белый цвет для текста
    local text = button.text
    if activeInputButton == button and cursorBlink then
        text = text .. "|" -- Добавляем мигающую палочку
    end
    love.graphics.print(text, button.x + 20, button.y + 15)
end

function menu.draw()
    love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth() / background:getWidth(),
        love.graphics.getHeight() / background:getHeight())
    love.graphics.draw(character, 560, 480, 0, 2, 2)


    local currentState = menuRouter[#menuRouter]
    local currentButtons = buttons[currentState]

    for i, button in ipairs(currentButtons) do
        drawButton(button)
    end
end

local function isMouseOverButton(x, y, button)
    return x >= button.x and x <= button.x + button.width and
        y >= button.y and y <= button.y + button.height
end

function menu.mousepressed(x, y, button)
    if button == 1 then -- Левый клик
        local currentState = menuRouter[#menuRouter]
        local currentButtons = buttons[currentState]
        -- Проверяем кнопки текущего состояния
        for _, btn in ipairs(currentButtons) do
            if isMouseOverButton(x, y, btn) then
                btn.action(btn)
                break
            end
        end
    end
end

function menu.textinput(text)
    _log(text)
    if activeInputButton then
        activeInputButton.text = activeInputButton.text .. text
    end
end

function menu.keypressed(key)
    if activeInputButton and key == "backspace" then
        activeInputButton.text = activeInputButton.text:sub(1, -2)
    end
end

return menu
