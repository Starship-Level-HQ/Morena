DEBUG = true
GRID_SIZE = 25

function love.conf(t)
    t.console = DEBUG
    t.window.icon = "res/Ikonka.png"
    t.externalstorage = true
    t.window.resizable = true
end
