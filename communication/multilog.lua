Multilog = {}

function Multilog:new(phrases, callback)
  local this = {}
  this.phrases = phrases
  this.callback = callback
  this.current = 0

  setmetatable(this,self)
  self.__index = self
  return this
end

function Multilog:update(dt)
  
  local currentPhrase = self.phrases[self.current]
  if self.dt == nil then
    self.dt = dt
    self.current = self.current + 1
    currentPhrase = self.phrases[self.current]
    if currentPhrase.dur == nil then
      currentPhrase.dur = 1
    end

  else
    self.dt = self.dt + dt
    if currentPhrase.dur == nil then
      currentPhrase.dur = 1
    end
    if self.dt >= currentPhrase.dur then
      self.dt = 0
      self.current = self.current + 1
      if self.current > #self.phrases then
        self.callback()
        return nil
      end
    end
  end
  return currentPhrase.body
end

function Multilog:draw(d1, d2, d3, d4)
  if self.current > 0 then
    local currentPhrase = self.phrases[self.current]
    love.graphics.setColor(1, 1, 1, 0.5)
    local _, strings = currentPhrase.text:gsub("\n","")
    strings = strings + 1
    love.graphics.rectangle("fill", currentPhrase.body:getX() - 23, currentPhrase.body:getY() - 90, 14/strings*#currentPhrase.text, 31*strings)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(currentPhrase.text, currentPhrase.body:getX() - 23, currentPhrase.body:getY() - 90, 0, 1.8, 1.6)
    love.graphics.setColor(d1, d2, d3, d4)
  end
end