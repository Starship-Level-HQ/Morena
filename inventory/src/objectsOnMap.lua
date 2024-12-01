local ItemModule = require("inventory.src.item")

MapStaff = {
    new = function(world)
        if not world then
            _log("Enemy requires parameters 'world', 'x', and 'y' to be specified")
            return false
        end
        local self = {}
        self.items = {}
        self.nextId = 0
        function self:addItem(x, y, id)
            local newItem = ItemModule.create_item(id)
            local angle = math.random() * math.pi  -- Случайный угол
            local itemBody = {x = x, y = y, item = newItem, angle = angle, collision = false, id = self.nextId}
            itemBody.body = love.physics.newBody(world, x, y, "static")
            itemBody.shape = love.physics.newRectangleShape(24, 24)
            itemBody.fixture = love.physics.newFixture(itemBody.body, itemBody.shape)
            itemBody.fixture:setCategory(cat.ITEM)
            itemBody.fixture:setUserData(itemBody)
            table.insert(self.items, itemBody)
            self.nextId = self.nextId + 1
        end

        function self:dropItem(x, y, item)
            local newItem = item
            local angle = math.random() * math.pi  -- Случайный угол
            local itemBody = {x = x, y = y, item = newItem, angle = angle, collision = false, id = self.nextId}
            itemBody.body = love.physics.newBody(world, x, y, "static")
            itemBody.shape = love.physics.newRectangleShape(24, 24)
            itemBody.fixture = love.physics.newFixture(itemBody.body, itemBody.shape)
            itemBody.fixture:setCategory(cat.ITEM)
            itemBody.fixture:setUserData(itemBody)
            table.insert(self.items, itemBody)
            self.nextId = self.nextId + 1
        end

        function self:takeItemByID(itemID)
            for i, itemData in ipairs(self.items) do
                if itemData.id == itemID then
                    itemData.body:destroy()
                    table.remove(self.items, i)
                    return itemData.item
                end
            end
            return nil
        end

        function self:draw(t, d1, d2, d3, d4)
            for _, itemData in ipairs(self.items) do
                if itemData.collision then
                    love.graphics.setColor(1, 1, 0, 1)  -- подсвечиваем предмет (жёлтый цвет)
                else
                    love.graphics.setColor(d1, d2, d3, d4)
                end
                love.graphics.draw(itemData.item.img, itemData.x, itemData.y, itemData.angle, 0.5, 0.5, 12, 19)
            end
        end
        
        function self:clearWorld()
            -- Удаляем все физические тела из мира
            for _, itemData in ipairs(self.items) do
                if itemData.body then
                    itemData.body:destroy()
                end
            end
            self.items = {}
            self.nextId = 0
        end
        return self
    end
}
