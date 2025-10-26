Phrases = {}

function Phrases:new(body)
  local this = {}
  this.phrases = {}
  this.body = body

  setmetatable(this,self)
  self.__index = self
  return this
end

function Phrases:update(dt)
  if #self.phrases > 0 then
    self.phrases[1].time = self.phrases[1].time - dt
    if self.phrases[1].time <= 0 then
      table.remove(self.phrases, 1)
    end
  end
end

function Phrases:add(text, time)
  table.insert(self.phrases, {text=text, time=time})
end

function Phrases:draw(d1, d2, d3, d4)
  if self.phrases[1] then
    love.graphics.setColor(1, 1, 1, 0.5)
    local text = self.phrases[1].text
    love.graphics.rectangle("fill", self.body:getX() - 25, self.body:getY() - 65, 14*#text, 31)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(text, self.body:getX() - 25, self.body:getY() - 65, 0, 1.6, 1.6)
    return true
  end
  return false
end