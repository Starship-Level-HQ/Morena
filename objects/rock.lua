Rock = {

new = function(world, x, y, h, w, t) 
  local rock = physics.makeBody(world, x, y, h, w, t)
  rock.body:setMass(55)
  rock.body:setLinearDamping(9)
  rock.fixture:setCategory(cat.BARRIER)
  rock.fixture:setMask(cat.VOID)
  rock.img = love.graphics.newImage("res/sprites/rock.png")
  return rock
end

}