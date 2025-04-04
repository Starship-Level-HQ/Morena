local shotFabric = {}
physics = require("physics")
anim8 = require 'libraries/anim8'

function shotFabric.new(category, world, x, y, h, w, lifeTime, angle, damage, speed)
  if speed == nil then
    speed = 100
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
  
  shot.rotate = angle +  math.pi/2 ----------------------- развернуть спрйт и убрать вычисления лишние
  shot.body:setLinearVelocity(math.cos(angle) * speed, math.sin(angle) * speed)
  shot.body:setAngle(angle +  math.pi/2) ------------ тоже самое

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