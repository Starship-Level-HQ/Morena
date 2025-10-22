Rock = {}

function Rock:new(world, oData) 
  local rock = physics.makeBody(world, oData.x, oData.y, oData.h, oData.w, oData.bodyType)
  rock.body:setMass(55)
  rock.body:setLinearDamping(9)
  rock.fixture:setCategory(cat.BARRIER)
  rock.fixture:setMask(cat.VOID)
  rock.img = love.graphics.newImage("res/sprites/rock.png")

  rock.widthDivTwo = rock.img:getWidth()/2
  rock.heightDivTwo = rock.img:getHeight()/2
  
  rock.class = "Rock"

  function Rock:draw()
    local xx = self.body:getX()-self.widthDivTwo
    local yy = self.body:getY()-self.heightDivTwo
    love.graphics.draw(self.img, xx, yy)
  end

  setmetatable(rock,self)
  self.__index = self

  return rock
end

