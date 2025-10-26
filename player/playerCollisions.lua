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

  end
}