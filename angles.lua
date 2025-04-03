module ( "angles", package.seeall )

function calculateAngle(playerX, playerY, mouseX, mouseY)
  --print(width, height)
  --print(mouseX, mouseY)
  local acos = math.atan2(mouseY - playerY, mouseX - playerX)
  --print(math.deg(acos))
  return acos
end
  