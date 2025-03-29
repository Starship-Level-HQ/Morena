local shotFabric = {}
physics = require("physics")
anim8 = require 'libraries/anim8'

function shotFabric.new(category, world, x, y, h, w, lifeTime, dir, damage, speed)
  if speed == nil then
    speed = 1
  end
  local shot = physics.makeBody(world, x, y, h, w, "dynamic")
  shot.fixture:setCategory(category)
  shot.fixture:setUserData(shot)
  shot.damage = damage
  shot.h = h
  shot.w = w
  shot.fixture:setMask(cat.TEXTURE, cat.P_SHOT, cat.E_SHOT, cat.VOID)
  shot.lifeTime = lifeTime
  shot.time = 0
  shot.rotate = 0
  shot.dir = dir

  if dir == "r" then
    shot.body:setLinearVelocity(100*speed, 0)
    shot.rotate = 1.6
  elseif dir == "l" then
    shot.body:setLinearVelocity(-100*speed, 0)
    shot.rotate = 4.7
  elseif dir == "u" then
    shot.body:setLinearVelocity(0, -100*speed)
    shot.rotate = 0
  elseif dir == "d" then
    shot.body:setLinearVelocity(0, 100*speed)
    shot.rotate = 3.1
  elseif dir == "ld" then
    shot.body:setLinearVelocity(-100*speed, 100*speed)
    shot.rotate = 3.7
  elseif dir == "lu" then
    shot.body:setLinearVelocity(-100*speed, -100*speed)
    shot.rotate = 5.3
  elseif dir == "ru" then
    shot.body:setLinearVelocity(100*speed, -100*speed)
    shot.rotate = 0.5
  elseif dir == "rd" then
    shot.body:setLinearVelocity(100*speed, 100*speed)
    shot.rotate = 2.1
  end
  shot.body:setAngle(shot.rotate)

  function shot.update(remShot, i, dt)
    shot.time = shot.time + dt
    -- mark shots that are not visible for removal
    if shot.body:isDestroyed() or shot.time > shot.lifeTime then
      table.insert(remShot, i)
      if not shot.body:isDestroyed() then
        shot.fixture:destroy()
        shot.body:destroy()
      end
    end
    shot.animations:update(dt)
  end
  
  function shot.draw()
    shot.animations:draw(shot.sprite, shot.body:getX(), shot.body:getY(), shot.rotate, 4, nil, 4, 4)
    --love.graphics.polygon("fill", shot.body:getWorldPoints(shot.shape:getPoints()))
  end

  return shot
end

return shotFabric