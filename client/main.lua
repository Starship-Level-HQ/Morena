require("noobhub")

hub = noobhub.new({ server = "127.0.0.1", port = 1337, });

local square = {
    x = 100,
    y = 100,
    size = 50,
    speed = 200 -- скорость перемещения (пиксели в секунду)
}

local clients = {}

function love.load()
    love.window.setTitle("Квадрат и управление клавишами") -- Устанавливаем заголовок окна
    love.window.setMode(800, 600) -- Размер окна: 800x600 пикселей
end

port = hub:subscribe({
    channel = "hello-world",
    callback = function(message)
        if message.client then
            -- Обновляем положение клиента в таблице
            clients[message.client] = { x = message.x, y = message.y }
        end
    end,
});


dtotal = 0            -- this keeps track of how much time has passed
function love.update(dt)
    hub:enterFrame(); -- making sure to give some CPU time to Noobhub

    if love.keyboard.isDown("right") then
        square.x = square.x + square.speed * dt
        hub:publish({
            message = {
                client    = port,
                action    = "right",
                timestamp = love.timer.getTime(),
                x         = square.x,
                y         = square.y
            }
        });
    end
    if love.keyboard.isDown("left") then
        square.x = square.x - square.speed * dt
        hub:publish({
            message = {
                client    = port,
                action    = "left",
                timestamp = love.timer.getTime(),
                x         = square.x,
                y         = square.y
            }
        });
    end
    if love.keyboard.isDown("down") then
        square.y = square.y + square.speed * dt
        hub:publish({
            message = {
                client    = port,
                action    = "down",
                timestamp = love.timer.getTime(),
                x         = square.x,
                y         = square.y
            }
        });
    end
    if love.keyboard.isDown("up") then
        square.y = square.y - square.speed * dt
        hub:publish({
            message = {
                client    = port,
                action    = "up",
                timestamp = love.timer.getTime(),
                x         = square.x,
                y         = square.y
            }
        });
    end
end

function love.draw()
    love.graphics.rectangle("fill", square.x, square.y, square.size, square.size)

    for clientPort, pos in pairs(clients) do
        if clientPort ~= port then -- Не рисуем себя дважды
            love.graphics.rectangle("line", pos.x, pos.y, square.size, square.size)
        end
    end
end
