Teleport = {

new = function(world, x, y, h, w, levelNum, pX, pY) 
  local te = physics.makeBody(world, x, y, h, w, "static")
  te.fixture:setCategory(cat.TRIGGER)
  te.fixture:setSensor(true)
  te.fixture:setMask(cat.ENEMY, cat.P_SHOT, cat.E_SHOT)
  te.img = love.graphics.newImage("res/sprites/teleport.png")
  
  te.fixture:setUserData({levelNum, pX, pY})
  return te
end

}