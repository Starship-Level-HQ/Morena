module ( "angles", package.seeall )

function calculateAngle(playerX, playerY, mouseX, mouseY)
  
  local acos = math.atan2(mouseY - playerY, mouseX - playerX)
  
  return acos
end
  