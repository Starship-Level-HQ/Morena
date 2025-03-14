PlayerCollisions = {
  new = function(self)

    function self:collisionWithShot(shot)
      self.health = self.health - shot.damage
      if shot.effect ~= nil then
        shot.effect(self)
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