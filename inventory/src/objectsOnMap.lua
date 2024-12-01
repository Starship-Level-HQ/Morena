local ItemModule = require("inventory.src.item")

mapStaff = {
    new = function(world)
        if not world then
            _log("Enemy requires parameters 'world', 'x', and 'y' to be specified")
            return false
        end
        local self = {}
        self.items = {}

        function self:update(dt)
        end

        function self:addItem(x, y, id)
            local newItem = ItemModule.create_item(id)
            local angle = math.random() * 2 * math.pi  -- Случайный угол
            table.insert(self.items, {x = x, y = y, item = newItem, angle = angle})
        end

        function self:draw(t, d1, d2, d3, d4)
            love.graphics.setColor(d1, d2, d3, d4)
            for _, itemData in ipairs(self.items) do
                love.graphics.draw(itemData.item.img, itemData.x, itemData.y, itemData.angle, 0.5, 0.5, 12, 19)
           
            end
        end

        return self
    end
}
