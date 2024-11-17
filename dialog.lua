Dialog = {
  new = function(bodies, phrases, order, callback)
    local self = {}
    self.bodies = bodies
    self.phrases = phrases
    self.order = order
    self.callback = callback
    self.current = 0

    function self.draw(d1, d2, d3, d4)
      if self.current > 0 then
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", bodies[order[self.current]]:getX() - 23, bodies[order[self.current]]:getY() - 90, 220, 31)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(phrases[self.current], bodies[order[self.current]]:getX() - 23, 
          bodies[order[self.current]]:getY() - 90, 0, 2, 2)
        love.graphics.setColor(d1, d2, d3, d4)
      end
    end

    function self.update()
      self.current = self.current + 1
      if self.current > #self.phrases then
        self.callback()
        return bodies[1]
      end
      return bodies[order[self.current]]
    end

    return self
  end
}