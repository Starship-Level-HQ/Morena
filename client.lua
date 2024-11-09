package.path = "./libraries/?.lua;" .. package.path -- как сделать лучше?
socket = require("socket")
json = require("json")

local otherClients = {}

client = {
    new = function(params) -- constructor method
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

        function self:subscribe(params)
            self.channel = params.channel
            self.sock, err_msg = socket.connect(self.server, self.port)
            if (self.sock == nil) then
                _log("Client connection error: ", err_msg)
                return false
            end
            self.sock:setoption('tcp-nodelay', true) -- disable Nagle's algorithm for the connection
            self.sock:settimeout(0)

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
            -- TODO: add retries
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

                while true do -- now, checking if a message is present in buffer
                    local start = string.find(self.buffer, '__JSON__START__')
                    local finish = string.find(self.buffer, '__JSON__END__')
                    if (start and finish) then
                        local jsonData = string.sub(self.buffer, start + 15, finish - 1)            -- взяли сообщение
                        self.buffer = self.buffer:sub(1, start - 1) .. self.buffer:sub(finish + 13) -- вырезали из буфера
                        local data = json.decode(jsonData)

                        local _, port = self.sock:getsockname()
                        _log('MSG FROM SERVER: ', jsonData)
                        if (data.alive) then
                            if port == data.port then
                                if data.anim == "l" then
                                    self.gameState.body:setLinearVelocity(data.yv, self.gameState.defaultSpeed)
                                    self.gameState.anim = self.gameState.animations
                                        ["left"]
                                elseif data.anim == "r" then
                                    self.gameState.body:setLinearVelocity(self.gameState.defaultSpeed, data.yv)
                                    self.gameState.anim = self.gameState.animations
                                        ["right"]
                                elseif data.anim == "u" then
                                    self.gameState.body:setLinearVelocity(data.xv, -self.gameState.defaultSpeed)
                                    self.gameState.anim = self.gameState.animations
                                        ["up"]
                                elseif data.anim == "d" then
                                    self.gameState.body:setLinearVelocity(data.xv, self.gameState.defaultSpeed)
                                    self.gameState.anim = self.gameState.animations
                                        ["down"]
                                end
                            else
                                otherClients[data.port] = {
                                    x = data.x,
                                    y = data.y,
                                    xv = data.xv,
                                    yv = data.yv,
                                    anim = data.anim,
                                    health = data.health,
                                }
                            end
                        else
                            otherClients[data.port] = nil
                        end
                    else
                        break
                    end
                end
            end
        end

        function self:getOtherClients()
            return otherClients
        end

        return self
    end
}
