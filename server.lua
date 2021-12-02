net = require("net")

function love.load()
  print("SERVER")
  
  local address = "127.0.0.1:27015" --run the server on port 27015
  local max_connections = 8 --maximum connections allowed
  local max_channels = 1
  local in_bandwidth = 0 --unlimited bandwidth
  local out_bandwidth = 0 --unlimited bandwidth

  net.init(address, max_connections, max_channels, in_bandwidth, out_bandwidth)
end

function love.update()
  net.update() --calls all callbacks which have been queued up by thread
end

--callback will be called any time a state changes for address
--list of states here: https://leafo.net/lua-enet/#peerstate
net.state(function(address, state)
  print("state changed for '" .. address .. "' to " .. state)

  if state == "connected" then
    print("connection established with " .. address)
    
    net.start("ping")
    net.writeByte(8)
    net.writeBool(true)
    net.writeInt(32)
    net.writeFloat(math.pi)
    net.writeDouble(math.pi * 2)
    net.writeString("Hello world")
    net.writeColour(1.0, 0.0, 0.0, 1.0)
    net.writeFormat("Bifds", 1, 32, 64.123, 124.123, "Hello world") --write a custom format based on: https://www.lua.org/manual/5.3/manual.html#6.4.2
    
    net.send(address) --send message to address only
    --net.send(address, flag, channel)
    
    --net.broadcast() --send message to all connections
    --net.broadcast(flag, channel)
    
    -- flag: 0 = reliable, 1 = unreliable, 2 = unsequenced, defaults to reliable
    --    "reliable" packets are guaranteed to arrive, and arrive in the order in which they are sent
    --    "unreliable" packets arrive in the order in which they are sent, but they aren't guaranteed to arrive
    --    "unsequenced" packets are neither guaranteed to arrive, nor do they have any guarantee on the order they arrive.
    
    -- channel: defaults to 0
    --    The channel to send the packet on
  end
end)

--callback will be called any time we receive a message with "pong"
net.receive("pong", function(address)
  print("client recieved our 'ping' response and sent 'pong' back")
end)