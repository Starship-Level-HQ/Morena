local shotFabric = {}
physics = require("physics")
anim8 = require 'libraries/anim8'

shotFabric.slashSprite = love.graphics.newImage('sprites/slash.png')
shotFabric.slashGrid = anim8.newGrid(12, 12, shotFabric.slashSprite:getWidth(), shotFabric.slashSprite:getHeight())
shotFabric.slashAnimations = {}
shotFabric.slashAnimations.up = anim8.newAnimation(shotFabric.slashGrid('1-4', 1), 0.1)
shotFabric.slashAnimations.down = anim8.newAnimation(shotFabric.slashGrid('1-4', 4), 0.1)
shotFabric.slashAnimations.right = anim8.newAnimation(shotFabric.slashGrid('1-4', 2), 0.1)
shotFabric.slashAnimations.left = anim8.newAnimation(shotFabric.slashGrid('1-4', 3), 0.1)

function shotFabric.new(category, world, x, y, h, w, lifeTime, dir, speed)
  if speed == nil then
    speed = 1
  end
  local shot = physics.makeBody(world, x, y, h, w, "dynamic")
  shot.fixture:setCategory(category)
  shot.h = h
  shot.w = w
  if category == cat.P_SHOT then
    shot.fixture:setMask(cat.TEXTURE, cat.E_SHOT)
  else
    shot.fixture:setMask(cat.TEXTURE, cat.P_SHOT, cat.E_SHOT, cat.VOID)
  end
  shot.lifeTime = lifeTime
  shot.time = 0
  shot.anim = shotFabric.slashAnimations.down

  if dir == "r" then
    shot.body:setLinearVelocity(100*speed, 0)
    shot.anim = shotFabric.slashAnimations.right
  elseif dir == "l" then
    shot.body:setLinearVelocity(-100*speed, 0)
    shot.anim = shotFabric.slashAnimations.left
  elseif dir == "u" then
    shot.body:setLinearVelocity(0, -100*speed)
    shot.anim = shotFabric.slashAnimations.up
  elseif dir == "d" then
    shot.body:setLinearVelocity(0, 100*speed)
    shot.anim = shotFabric.slashAnimations.down
  elseif dir == "ld" then
    shot.body:setLinearVelocity(-100*speed, 100*speed)
  elseif dir == "lu" then
    shot.body:setLinearVelocity(-100*speed, -100*speed)
  elseif dir == "ru" then
    shot.body:setLinearVelocity(100*speed, -100*speed)
  elseif dir == "rd" then
    shot.body:setLinearVelocity(100*speed, 100*speed)
  end

  function shot.update(remShot, i, dt)
    shot.time = shot.time + 1
    -- mark shots that are not visible for removal
    if shot.body:isDestroyed() or shot.time > shot.lifeTime then
      table.insert(remShot, i)
      if not shot.body:isDestroyed() then
        shot.fixture:destroy()
        shot.body:destroy()
      end
    end
    shot.anim:update(dt)
  end
  
  function shot.draw()
    shot.anim:draw(shotFabric.slashSprite, shot.body:getX(), shot.body:getY(), nil, 4, nil, 5, 5)
  end

  return shot
end

return shotFabric