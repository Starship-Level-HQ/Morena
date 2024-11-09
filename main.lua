require("logger")
local menu = require("menu")
local level = require("level")
local multiplayer = require("multiplayer")
sti = require("libraries/sti")
camera = require("libraries/camera")
cat = require("objectsCategories")
require("libraries/anim8")

-- Глобальная переменная для состояния игры
gameState = "menu" -- Начальное состояние — меню
userConfig = require("userConfig")

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
    elseif gameState == "multiplayer" then
        multiplayer.update(dt)
    end
end

function love.draw()
    if gameState == "menu" then
        menu.draw()
    elseif gameState == "level" then
        level.draw()
    elseif gameState == "multiplayer" then
        multiplayer.draw()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if gameState == "menu" then
        menu.mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    if gameState ~= "menu" and key == "escape" then
        gameState = "menu"
        menu.load()
    elseif gameState == "level" then
        level.keypressed(key)
    elseif gameState == "multiplayer" then
        multiplayer.keypressed(key)
    end
end

function startLevel(levelNumber)
    gameState = "level"
    _log(levelNumber)
    level.startLevel(levelNumber)
end

function startMultiplayer()
    gameState = "multiplayer"
    _log(gameState)
    multiplayer.startMultiplayer()
end
