Roots = {}
setmetatable(Roots ,{__index = Shot})

function Roots:new(category, world, x, y, angle, damageModifier) 

  local this = Shot.new(self, category, world, x, y, 80, 60, 3, angle, 10, 140)
  this.body:setMass(400)

  this.effect = function(player)
    --table.insert(player.effects, {"Регенерация", -3, 10}) -- Эффект яда, другому врагу добавим
    player.stun = 0.5 
    player.stunTime = 0.5
  end
  this.sprite = love.graphics.newImage('res/sprites/roots.png')
  this.grid = anim8.newGrid(35, 27, this.sprite:getWidth(), this.sprite:getHeight())
  this.animations = anim8.newAnimation(this.grid('1-4', 1), 0.1)
  this.zoom = 4
  this.heightDivTwo = 5
  this.widthDivTwo = 5

  setmetatable(this,self)
  self.__index = self
  return this
end