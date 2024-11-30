Dialog = {
  new = function(phrases, callback)
    local self = {}
    self.bodies = bodies
    self.phrases = phrases
    self.callback = callback
    self.current = 0

    function self.draw(d1, d2, d3, d4)
      if self.current > 0 then
        love.graphics.setColor(1, 1, 1, 0.5)
        local _, strings = phrases[self.current].text:gsub("\n","")
        strings = strings + 1
        love.graphics.rectangle("fill", phrases[self.current].body:getX() - 23, phrases[self.current].body:getY() - 90, 14/strings*#phrases[self.current].text, 31*strings)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(phrases[self.current].text, phrases[self.current].body:getX() - 23, 
          phrases[self.current].body:getY() - 90, 0, 1.7, 1.8)
        love.graphics.setColor(d1, d2, d3, d4)
      end
    end

    function self.update(dt)
      if self.dt == nil then
        self.dt = dt
        self.current = self.current + 1
        if phrases[self.current].dur == nil then
          phrases[self.current].dur = 1
        end
        
      else 
        self.dt = self.dt + dt
        if phrases[self.current].dur == nil then
          phrases[self.current].dur = 1
        end
        if self.dt >= phrases[self.current].dur then
          self.dt = 0
          self.current = self.current + 1
          if self.current > #self.phrases then
            self.callback()
            return nil
          end
        end
      end
      return phrases[self.current].body
    end

    return self
  end
}