require("player")
require("enemy")
require("client")

Multiplayer = {
    new = function(map, playerPosition, enemyPosition, lakePosition)
        -- Если параметры не были переданы, задаем значения по умолчанию
        map = map or "maps/testMap.lua"
        playerPosition = playerPosition or { 300, 300 }
        enemyPosition = enemyPosition or { 600, 100 }
        lakePosition = lakePosition or { 400, 550 }

        -- Создаем новый объект
        local self = {}

        self.multiplayer = {}
        self.remotePlayers = {}

        love.window.setTitle("Morena - Multiplayer")
        love.graphics.setDefaultFilter('nearest', 'nearest')
        self.cam = camera()
        self.gameMap = sti(map)
        self.world = love.physics.newWorld(0, 0, true)
        self.world:setGravity(0, 40)
        self.world:setCallbacks(self.multiplayer.collisionOnEnter)

        self.player = Player.new(self.world, playerPosition[1], playerPosition[2])
        self.enemy = Enemy.new(self.world, enemyPosition[1], enemyPosition[2])
        self.lake = physics.makeBody(self.world, lakePosition[1], lakePosition[2], 80, 80, "static")
        self.day = true
        self.lake.fixture:setCategory(cat.TEXTURE)
        self.shotSound = love.audio.newSource("sounds/shot.wav", "static")

        self.hub = Client.new({ server = "127.0.0.1", port = 1337, gameState = self.player })
        self.port = self.hub:subscribe({ channel = "MORENA" })

        function self:update(dt)
            self.player:update(dt)
            self.world:update(dt)
            self.enemy:update(dt, self.player.body:getX(), self.player.body:getY())

            self.hub:getMessage()
            -- создать игроков или обновить их состояние
            for remotePlayerPort, remotePlayerData in pairs(self.hub.remotePlayersData) do
                local remotePlayer = self.remotePlayers[remotePlayerPort]
                if remotePlayer then
                    remotePlayer:updateRemotePlayer(dt, remotePlayerData)
                else
                    local tempPlayer = Player.new(self.world, remotePlayerData.x, remotePlayerData.y)
                    tempPlayer.health = remotePlayerData.health
                    self.remotePlayers[remotePlayerPort] = tempPlayer
                end
            end

            for remotePlayerPort, _ in pairs(self.remotePlayers) do
                if not self.hub.remotePlayersData[remotePlayerPort] then
                    self.remotePlayers[remotePlayerPort] = nil
                end
            end

            self.hub:sendMessage({
                port       = self.port,
                x          = self.player.body:getX(),
                y          = self.player.body:getY(),
                xv         = self.xv,
                yv         = self.yv,
                directionX = self.player.serverDirectionX,
                directionY = self.player.serverDirectionY,
                health     = self.player.health,
            })

            self.cam:lookAt(self.player.body:getX(), self.player.body:getY())

            -- Ограничиваем камеру в границах карты
            local w = love.graphics.getWidth()
            local h = love.graphics.getHeight()

            if self.cam.x < w / 2 then self.cam.x = w / 2 end
            if self.cam.y < h / 2 then self.cam.y = h / 2 end

            local mapW = self.gameMap.width * self.gameMap.tilewidth
            local mapH = self.gameMap.height * self.gameMap.tileheight

            if self.cam.x > (mapW - w / 2) then self.cam.x = (mapW - w / 2) end
            if self.cam.y > (mapH - h / 2) then self.cam.y = (mapH - h / 2) end
        end

        function self:draw()
            self.cam:attach()
            self.gameMap:drawLayer(self.gameMap.layers["grass"])
            self.gameMap:drawLayer(self.gameMap.layers["road"])
            self.gameMap:drawLayer(self.gameMap.layers["trees"])

            local d1, d2, d3, d4 = self.day and 255 or 0.23, self.day and 255 or 0.25, self.day and 255 or 0.59, 1
            love.graphics.setColor(0.23, 0.25, 0.59, 1)
            love.graphics.polygon("fill", self.lake.body:getWorldPoints(self.lake.shape:getPoints()))

            love.graphics.setColor(d1, d2, d3, d4)

            -- Отрисовка себя
            self.player:draw(d1, d2, d3, d4)
            self.enemy:draw(d1, d2, d3, d4)

            -- Отрисовка других игроков
            for _, remotePlayer in pairs(self.remotePlayers) do
                remotePlayer:draw(d1, d2, d3, d4)
            end

            self.cam:detach()
        end

        function self:keypressed(key)
            if key == " " or key == "space" then
                if self.player.attackType then
                    self.player:slash(self.shotSound)
                else
                    self.player:shoot(self.shotSound)
                end
            elseif key == "q" then
                self.day = not self.day
            elseif key == "1" then
                self.player.attackType = not self.player.attackType
            end
        end

        function self:collisionOnEnter(fixture_a, fixture_b, contact)
            if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.ENEMY then
                self.player:collisionWithEnemy(fixture_b)
            end

            if fixture_a:getCategory() == cat.PLAYER and fixture_b:getCategory() == cat.E_SHOT then
                self.player:collisionWithShot()
                fixture_b:getBody():destroy()
                fixture_b:destroy()
            end

            if fixture_a:getCategory() == cat.DASHING_PLAYER and fixture_b:getCategory() == cat.E_SHOT then
                fixture_b:setCategory(cat.P_SHOT)
            end

            if fixture_b:getCategory() == cat.P_SHOT and fixture_a:getCategory() == cat.ENEMY then
                self.enemy:colisionWithShot(fixture_a, self.player.damage)
                fixture_b:getBody():destroy()
                fixture_b:destroy()
            end
        end

        return self
    end
}
