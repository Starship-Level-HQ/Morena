package.path = "./libraries/?.lua;" .. package.path
json = require("json")
socket = require("socket")

Client = {
    new = function(params)
        params = params
        if (not params.server or not params.port) then
            _log("Client requires server and port to be specified")
            return false
        end
        local self = {}

        self.buffer = ''
        self.server = params.server
        self.port = params.port
        self.gameState = params.gameState
        self.remotePlayersData = {}
        self.enemiesData = {}
        self.shootsData = {}
        self.clientPort = 0
        self.killedScore = 0

        function self:subscribe(params)
            self.channel = params.channel
            self.sock, err_msg = socket.connect(self.server, self.port)
            if (self.sock == nil) then
                _log("Client connection error: ", err_msg)
                return false
            end
            self.sock:setoption('tcp-nodelay', true) -- disable Nagle's algorithm for the connection
            self.sock:settimeout(0)

            _, self.clientPort = self.sock:getsockname()

            local _, output = socket.select(nil, { self.sock }, 3)
            for _, sock in ipairs(output) do sock:send("__SUBSCRIBE__" .. self.channel .. "__ENDSUBSCRIBE__") end

            return true
        end

        function self:unsubscribe()
            if (self.sock) then
                self.sock:close()
                self.sock = nil
            end
            self.buffer = ''
        end

        function self:reconnect()
            if (not self.channel) then return false end
            _log("Client attempts to reconnect...")
            return self:subscribe({ channel = self.channel })
        end

        function self:sendMessage(message)
            if (self.sock == nil) then
                _log("Client attempts to publish without valid subscription (bad socket)")
                self:reconnect()
                return false
            end
            local err, err_msg, num_bytes = self.sock:send("__JSON__START__" ..
                json.encode(message) .. "__JSON__END__")
            if (err == nil) then
                _log("Client publish error: ", err_msg, '  sent ', num_bytes, ' bytes')
                if (err_msg == 'closed') then self:reconnect() end
                return false
            end
            return true
        end

        function self:sendEnemyData(enemyData)
            if (self.sock == nil) then
                _log("Client attempts to send enemy data without valid subscription (bad socket)")
                self:reconnect()
                return false
            end
            local err, err_msg, num_bytes = self.sock:send("__JSON__ENEMY__START__" ..
                json.encode(enemyData) .. "__JSON__ENEMY__END__")
            if (err == nil) then
                _log("Client publish error (enemy data): ", err_msg, '  sent ', num_bytes, ' bytes')
                if (err_msg == 'closed') then self:reconnect() end
                return false
            end
            return true
        end

        function self:sendShootsData(shootsData)
            if (self.sock == nil) then
                _log("Client attempts to send enemy data without valid subscription (bad socket)")
                self:reconnect()
                return false
            end
            local err, err_msg, num_bytes = self.sock:send("__SHOOT__START__" ..
                json.encode(shootsData) .. "__SHOOT__END__")
            if (err == nil) then
                _log("Client publish error (shoots data): ", err_msg, '  sent ', num_bytes, ' bytes')
                if (err_msg == 'closed') then self:reconnect() end
                return false
            end
            return true
        end

        function self:getMessage()
            local input, _ = socket.select({ self.sock }, nil, 0) -- zero timeout not to block runtime while reading socket

            for _, sock in ipairs(input) do
                while true do
                    local input_data, err, additional_input_data = sock:receive()
                    if (input_data) then
                        self.buffer = self.buffer .. input_data
                    end
                    if (additional_input_data) then
                        self.buffer = self.buffer .. additional_input_data
                    end
                    if (not input_data or err) then break end
                end

                while true do
                    local startJSON = string.find(self.buffer, '__JSON__START__')
                    local finishJSON = string.find(self.buffer, '__JSON__END__')
                    local startEnemy = string.find(self.buffer, '__JSON__ENEMY__START__')
                    local finishEnemy = string.find(self.buffer, '__JSON__ENEMY__END__')
                    local startAddEnemy = string.find(self.buffer, '__ADDENEMY__START__')
                    local finishAddEnemy = string.find(self.buffer, '__ADDENEMY__END__')
                    local startShoot = string.find(self.buffer, '__SHOOT__START__')
                    local finishShoot = string.find(self.buffer, '__SHOOT__END__')

                    if startJSON and finishJSON then
                        -- Обработка обычного JSON сообщения
                        local jsonData = string.sub(self.buffer, startJSON + 15, finishJSON - 1)
                        self.buffer = self.buffer:sub(1, startJSON - 1) .. self.buffer:sub(finishJSON + 13)
                        local data = json.decode(jsonData)
                        _log('__JSON__START__: ', jsonData)

                        if data.host then self.killedScore = data.killedScore end

                        if data.alive then
                            if self.clientPort ~= data.port then
                                self.remotePlayersData[data.port] = {
                                    x = data.x,
                                    y = data.y,
                                    xv = data.xv,
                                    yv = data.yv,
                                    directionX = data.directionX,
                                    directionY = data.directionY,
                                    health = data.health,
                                }
                            else
                                self.gameState.host = data.host
                            end
                        else
                            self.remotePlayersData[data.port] = nil
                        end
                    elseif startEnemy and finishEnemy then
                        -- Обработка сообщения о состоянии врагов
                        local enemyData = string.sub(self.buffer, startEnemy + 22, finishEnemy - 1)
                        self.buffer = self.buffer:sub(1, startEnemy - 1) .. self.buffer:sub(finishEnemy + 20)
                        local enemies = json.decode(enemyData)
                        -- _log('__JSON__ENEMY__START__: ', enemyData)

                        if enemies == nil then return end

                        -- Сохраняем состояние врагов
                        for _, enemy in ipairs(enemies) do
                            self.enemiesData[enemy.id] = {
                                x = enemy.x,
                                y = enemy.y,
                                xv = enemy.xv,
                                yv = enemy.yv,
                                direction = enemy.direction,
                                health = enemy.health,
                                isMoving = enemy.isMoving,
                            }
                        end
                    elseif startAddEnemy and finishAddEnemy then
                        -- Обработка добавления нового врага
                        local addEnemyData = string.sub(self.buffer, startAddEnemy + 19, finishAddEnemy - 1)
                        self.buffer = self.buffer:sub(1, startAddEnemy - 1) .. self.buffer:sub(finishAddEnemy + 17)
                        local newEnemy = json.decode(addEnemyData)
                        -- _log('__ADDENEMY__START__: ', addEnemyData)

                        -- Добавляем нового врага
                        self.enemiesData[newEnemy.id] = {
                            x = newEnemy.x,
                            y = newEnemy.y,
                            xv = newEnemy.xv,
                            yv = newEnemy.yv,
                            direction = newEnemy.direction,
                            health = newEnemy.health,
                            isMoving = newEnemy.isMoving
                        }
                    elseif startShoot and finishShoot then
                        -- Обработка выстрелов
                        local shootData = string.sub(self.buffer, startShoot + 16, finishShoot - 1)
                        self.buffer = self.buffer:sub(1, startShoot - 1) .. self.buffer:sub(finishShoot + 14)
                        local newShoot = json.decode(shootData)
                        -- _log('__SHOOT__START__: ', shootData)

                        if self.clientPort ~= newShoot.port then
                            self.shootsData[newShoot.port] = {
                                attackType = newShoot.attackType,
                                shotButtonPressed = newShoot.shotButtonPressed,
                            }
                        end
                    else
                        break
                    end
                end
            end
        end

        return self
    end
}
