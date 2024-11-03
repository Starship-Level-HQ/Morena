local shotFabric = {}
local physics = require("physics")

function shotFabric.new(category, world, x, y, h, w, lifeTime, dir)
  local shot = physics.makeBody(world, x, y, h, w, "dynamic")
  shot.fixture:setCategory(category)
  shot.h = h
  shot.w = w
  if category == cat.P_SHOT then
    shot.fixture:setMask(cat.TEXTURE, cat.E_SHOT)
  else
    shot.fixture:setMask(cat.TEXTURE, cat.P_SHOT, cat.E_SHOT, cat.VOID)
  end
  shot.lifeTime = lifeTime;
  shot.time = 0;
  
  if dir == "r" then
    shot.body:setLinearVelocity(100, 0)
  elseif dir == "l" then
    shot.body:setLinearVelocity(-100, 0)
  elseif dir == "u" then
    shot.body:setLinearVelocity(0, -100)
  else
    shot.body:setLinearVelocity(0, 100)
  end
  
  function shot.update(remShot, i)
    shot.time = shot.time + 1
    -- mark shots that are not visible for removal
    if shot.body:isDestroyed() or shot.time > shot.lifeTime then
      table.insert(remShot, i)
      if not shot.body:isDestroyed() then
        shot.fixture:destroy()
        shot.body:destroy()
      end
    end
    
  end
  
  return shot
end

return shotFabric