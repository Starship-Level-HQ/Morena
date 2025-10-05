local physics = {
    normals = {},
}

function physics.collisionOnEnter(fixture_a, fixture_b, contact) --выводит в консоль координаты столкновения.
    local dx, dy = contact:getNormal()
    dx = dx * 30
    dy = dy * 30
    -- _log("dx: ", dx, "dy: ", dy)
    local point = { contact:getPositions() }
    for i = 1, #point, 2 do
        local x, y = point[i], point[i + 1]
        -- _log("x: ", x, "y: ", y)
        table.insert(physics.normals, { x, y, x + dx, y + dy })
    end

    -- do not use contact after this function returns
end

function physics.makeBody(world, x, y, height, width, bodyType)
    local object = {}
    object.body = love.physics.newBody(world, x, y, bodyType)
    object.body:setGravityScale(0)
    object.shape = love.physics.newRectangleShape(height, width)
    object.fixture = love.physics.newFixture(object.body, object.shape, 0)
    object.body:setMass(10)
    object.height = height
    object.width = width
    return object
end

function physics.bloodDrops(world, x, y)
    drops = {}
    if userConfig.blood then
        for i = 1, 10 do
            local drop = physics.makeBody(world, x, y, 2, 2, "dynamic")
            drop.body:setLinearVelocity(50 * (5 - i), -182 * (i % 3))
            drop.time = 0
            drop.fixture:setCategory(cat.VOID)
            drop.fixture:setMask(cat.VOID)
            table.insert(drops, drop)
        end
    end
    return drops
end

return physics
