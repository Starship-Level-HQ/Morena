local physics = require("physics")
local player = require("player")
local enemy = require("enemy")
local enemies = {}
local cat = require("objectsCategories")

function love.load(arg)

  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  love.window.setTitle("Morena")

  camera = require 'libraries/camera' -- движение камеры
  cam = camera()

  anim8 = require 'libraries/anim8'                    -- анимация движения
  love.graphics.setDefaultFilter('nearest', 'nearest') -- увеличение резкости отображения персонажа

  sti = require 'libraries/sti'                        -- отрисовка карты из Tiled
  gameMap = sti('maps/testMap.lua')
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(collisionOnEnter)

  day = true

  player.init(world, 300, 450) -- new table for the hero
  
  for i = 1, 3 do
    local e = enemy.new()
    e.init(world, 600, i * 100)
    table.insert(enemies, e)
  end

  lake = physics.makeBody(world, 400, 550, 80, 80, "static")  
  lake.fixture:setCategory(cat.TEXTURE)

  shotSound = love.audio.newSource("sounds/shot.wav", "static")

end

function love.update(dt)

  player.update(dt)
  
  for i, e in ipairs(enemies) do
    e.update(dt, player.body:getX(), player.body:getY())
  end

  world:update(dt)

  -- Update camera position
  cam:lookAt(player.body:getX(), player.body:getY())

  -- This section prevents the camera from viewing outside the background
  -- First, get width/height of the game window
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()

  -- Left border
  if cam.x < w / 2 then
    cam.x = w / 2
  end

  -- Right border
  if cam.y < h / 2 then
    cam.y = h / 2
  end

  -- Get width/height of background
  local mapW = gameMap.width * gameMap.tilewidth
  local mapH = gameMap.height * gameMap.tileheight

  -- Right border
  if cam.x > (mapW - w / 2) then
    cam.x = (mapW - w / 2)
  end
  -- Bottom border
  if cam.y > (mapH - h / 2) then
    cam.y = (mapH - h / 2)
  end
end

function love.draw()
  cam:attach()
  -- let's draw a background
  gameMap:drawLayer(gameMap.layers["grass"])
  gameMap:drawLayer(gameMap.layers["road"])
  gameMap:drawLayer(gameMap.layers["trees"])
  
  local d1, d2, d3, d4 = 255, 255, 255, 255

  love.graphics.setColor(0.23, 0.25, 0.59, 1)
  love.graphics.polygon("fill", lake.body:getWorldPoints(lake.shape:getPoints()))

  if day then
    d1, d2, d3, d4 = 255, 255, 255, 255
  else
    d1, d2, d3, d4 = 0.23, 0.25, 0.59, 1
  end
  
  love.graphics.setColor(d1, d2, d3, d4)
  
  for i, e in ipairs(enemies) do
    e:draw(d1, d2, d3, d4)
  end

  -- let's draw our hero
  player:draw(d1, d2, d3, d4)
  cam:detach()

end

function love.keypressed(key)
  if (key == " " or key == "space") then
    player.shoot(shotSound)
  end
  if (key == "q") then
    day = not day
  end
end

--Понадобится для боёв, взаимодействия с предметами и тд
function collisionOnEnter(fixture_a, fixture_b, contact)
  
  player.collisionWithEnemy(fixture_a, fixture_b)

  if fixture_b:getCategory() == cat.P_SHOT and fixture_a:getCategory() == cat.ENEMY then
    for i, e in ipairs(enemies) do
      e.colisionWithShot(fixture_a)
    end
    fixture_b:getBody():destroy()
    fixture_b:destroy()
  end

end