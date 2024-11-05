local menu = require("menu")
local level = require("level")

-- Глобальная переменная для состояния игры
gameState = "menu"  -- Начальное состояние — меню

function love.load()
    menu.load()
    --Чтобы стартовать не с меню а с лвла
    --gameState = "level"
    --level.startLevel(1)
end

function love.update(dt)
    if gameState == "menu" then
        menu.update(dt)
    elseif gameState == "level" then
        level.update(dt)
    end
end

function love.draw()
    if gameState == "menu" then
        menu.draw()
    elseif gameState == "level" then
        level.draw()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if gameState == "menu" then
        menu.mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    if gameState == "level" and key == "escape" then
        gameState = "menu"
        menu.load()
    elseif gameState == "level" then
        level.keypressed(key)
    end
end

function startLevel(levelNumber)
    gameState = "level"
    print(levelNumber)
    level.startLevel(levelNumber)
end
