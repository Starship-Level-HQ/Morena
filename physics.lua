local physics = {
    normals = {},
}

function physics.collisionOnEnter(fixture_a, fixture_b, contact) --выводит в консоль координаты столкновения. 
  --Понадобится для боёв, взаимодействия с предметами и тд
    local dx,dy = contact:getNormal()
    dx = dx * 30
    dy = dy * 30
    print("dx: ", dx, "dy: ", dy)
    local point = {contact:getPositions()}
    for i=1,#point,2 do
        local x,y = point[i], point[i+1]
        print("x: ", x, "y: ", y)
        -- Cache the values inside the contacts because they're not guaranteed
        -- to be valid later in the frame.
        table.insert(physics.normals, {x,y, x+dx, y+dy})
    end

    -- do not use contact after this function returns
end

function physics.makeBody(world, x, y, height, width, bodyType)
  local object = {}
  object.body = love.physics.newBody(world, x, y, bodyType)
  object.shape = love.physics.newRectangleShape(height, width)
  object.fixture = love.physics.newFixture(object.body, object.shape)
  return object
end

return physics