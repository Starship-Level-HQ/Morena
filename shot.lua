local shotFabric = {}
physics = require("physics")
anim8 = require 'libraries/anim8'

shotFabric.slashSprite = love.graphics.newImage('res/sprites/slash.png')
shotFabric.slashGrid = anim8.newGrid(12, 12, shotFabric.slashSprite:getWidth(), shotFabric.slashSprite:getHeight())
shotFabric.slashAnimations = {}
shotFabric.slashAnimations.up = anim8.newAnimation(shotFabric.slashGrid('1-4', 1), 0.05)
shotFabric.slashAnimations.down = anim8.newAnimation(shotFabric.slashGrid('1-4', 4), 0.05)
shotFabric.slashAnimations.right = anim8.newAnimation(shotFabric.slashGrid('1-4', 2), 0.05)
shotFabric.slashAnimations.left = anim8.newAnimation(shotFabric.slashGrid('1-4', 3), 0.05)

shotFabric.shotSprite = love.graphics.newImage('res/sprites/arrow.png')
shotFabric.shotGrid = anim8.newGrid(5, 13, shotFabric.shotSprite:getWidth(), shotFabric.shotSprite:getHeight())
shotFabric.shotAnimations = anim8.newAnimation(shotFabric.shotGrid('1-4', 1), 0.1)

function shotFabric.new(category, world, x, y, h, w, lifeTime, dir, damage, speed)
  if speed == nil then
    speed = 1
  end
  local shot = physics.makeBody(world, x, y, h, w, "dynamic")
  shot.fixture:setCategory(category)
  shot.fixture:setUserData(damage)
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
  shot.arrowAnim = {anim = shotFabric.shotAnimations, rotate = 0}

  if dir == "r" then
    shot.body:setLinearVelocity(100*speed, 0)
    shot.anim = shotFabric.slashAnimations.right
    shot.arrowAnim.rotate = 1
  elseif dir == "l" then
    shot.body:setLinearVelocity(-100*speed, 0)
    shot.anim = shotFabric.slashAnimations.left
    shot.arrowAnim.rotate = 3
  elseif dir == "u" then
    shot.body:setLinearVelocity(0, -100*speed)
    shot.anim = shotFabric.slashAnimations.up
    shot.arrowAnim.rotate = 0
  elseif dir == "d" then
    shot.body:setLinearVelocity(0, 100*speed)
    shot.anim = shotFabric.slashAnimations.down
    shot.arrowAnim.rotate = 2
  elseif dir == "ld" then
    shot.body:setLinearVelocity(-100*speed, 100*speed)
    shot.arrowAnim.rotate = 2.5
  elseif dir == "lu" then
    shot.body:setLinearVelocity(-100*speed, -100*speed)
    shot.arrowAnim.rotate = 3.5
  elseif dir == "ru" then
    shot.body:setLinearVelocity(100*speed, -100*speed)
    shot.arrowAnim.rotate = 0.5
  elseif dir == "rd" then
    shot.body:setLinearVelocity(100*speed, 100*speed)
    shot.arrowAnim.rotate = 1.5
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
    shot.arrowAnim.anim:update(dt)
  end
  
  function shot.drawSlash()
    shot.anim:draw(shotFabric.slashSprite, shot.body:getX(), shot.body:getY(), nil, 4, nil, 5, 5)
  end
  
  function shot.drawShot()
    shot.anim:draw(shotFabric.shotSprite, shot.body:getX(), shot.body:getY(), nil, 3, nil, 5, 5) --shot.arrowAnim.rotate
  end

  return shot
end

return shotFabric