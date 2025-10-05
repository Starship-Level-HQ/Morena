Rock = {

new = function(world, oData) 
  local rock = physics.makeBody(world, oData.x, oData.y, oData.h, oData.w, oData.bodyType)
  rock.body:setMass(55)
  rock.body:setLinearDamping(9)
  rock.fixture:setCategory(cat.BARRIER)
  rock.fixture:setMask(cat.VOID)
  rock.img = love.graphics.newImage("res/sprites/rock.png")
  return rock
end

}