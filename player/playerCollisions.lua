PlayerCollisions = {
  new = function(self)

    function self:collisionWithShot(shot)
      local damage = shot.damage
      if self.inventory.activeEquip["Броня"] ~= nil then
        damage = damage - self.inventory.activeEquip["Броня"].effects["Защита"]
        if damage < 0 then
          damage = 0
        end
      end
      self.health = self.health - damage
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