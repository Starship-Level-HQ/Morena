Teleport = {}

function Teleport:new(world, x, y, h, w, levelNum, pX, pY) 
  local te = physics.makeBody(world, x, y, h, w, "static")
  te.fixture:setCategory(cat.TRIGGER)
  te.fixture:setSensor(true)
  te.fixture:setMask(cat.ENEMY, cat.P_SHOT, cat.E_SHOT)
  te.img = love.graphics.newImage("res/sprites/teleport.png")
  
  te.fixture:setUserData({levelNum, pX, pY})
  te.widthDivTwo = te.img:getWidth()/2
  te.heightDivTwo = te.img:getHeight()/2
  
  te.class = "Teleport"
  
  function Teleport:draw()
    local xx = self.body:getX()-self.widthDivTwo
    local yy = self.body:getY()-self.heightDivTwo
    love.graphics.draw(self.img, xx, yy)
  end
  
  setmetatable(te,self)
  self.__index = self
  return te
end