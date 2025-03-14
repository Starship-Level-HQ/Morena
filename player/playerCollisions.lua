PlayerCollisions = {
  new = function(self)

    function self:collisionWithShot(damageAndEffect)
      self.health = self.health - damageAndEffect[1]
      if damageAndEffect[2] ~= nil then
        damageAndEffect[2](self)
      end
    end

    function self:collisionWithEnemy(fixture_b, damage)
      self.health = self.health - damage
      self.stun = 0.2
      self.stunTime = 0.2
      xi, yi = fixture_b:getBody():getLinearVelocity()
      self.body:applyLinearImpulse(xi * 200, yi * 200) --отскок игрока при получении урона
    end

  end
}