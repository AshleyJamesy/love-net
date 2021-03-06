# love2d-net
A single file module for threaded networking in Love2d

# Quick start Guide

Server:
```lua
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
    net.writeLong(100000)
    net.writeNumber(10000000) --lua number
    net.writeString("Hello world")
    net.writeColour(1.0, 0.0, 0.0, 1.0)
    net.writeFormat("Bifds", 0, 32, math.pi, math.pi * 2, "Hello world") --write a custom format based on: https://www.lua.org/manual/5.3/manual.html#6.4.2
    
    net.send(address) --send message to address only
    
    --ALTERNATIVES:
    --[[
        -- flag: 0 = reliable, 1 = unreliable, 2 = unsequenced, defaults to reliable
        --    "reliable" packets are guaranteed to arrive, and arrive in the order in which they are sent
        --    "unreliable" packets arrive in the order in which they are sent, but they aren't guaranteed to arrive
        --    "unsequenced" packets are neither guaranteed to arrive, nor do they have any guarantee on the order they arrive.
        
        -- channel: defaults to 0
        --    The channel to send the packet on
    
        net.send(address, flag, channel)

        --send message to all connections
        net.broadcast() 
        net.broadcast(flag, channel)
    ]]
  end
end)

--callback will be called any time we receive a message with "pong"
net.receive("pong", function(address, roundTripTime)
  --you'll need to send a lot more messages to average down the round trip time as it starts high and then lowers
  print("client recieved our 'ping' response and sent 'pong' back", roundTripTime)
end)
```

Client:
```lua
net = require("net")
  
function love.load()
  print("CLIENT")
  
  local address = "127.0.0.1:*" --just use a random port to connect
  local max_connections = 1 --only connecting to server, so only 1 connection needed
  local max_channels = 1
  local in_bandwidth = 0 --unlimited bandwidth
  local out_bandwidth = 0 --unlimited bandwidth

  net.init(address, max_connections, max_channels, in_bandwidth, out_bandwidth)
  net.connect("127.0.0.1:27015") --connect to the server
end

function love.update()
  net.update() --calls all callbacks which have been queued up by thread
end

--will be called any time a state changes for address
--list of states here: https://leafo.net/lua-enet/#peerstate
net.state(function(address, state)
  print("state changed for '" .. address .. "' to " .. state)

  if state == "connected" then
    print("connection established with " .. address)
  end
end)

--callback will be called any time we receive a message with "ping"
net.receive("ping", function(address, roundTripTime)
  --you'll need to send a lot more messages to average down the round trip time as it starts high and then lowers
  print("received message: 'ping' from '" .. address .. "'", roundTripTime)

  --the packet must be read in the order it was written in
  local byte = net.readByte()
  local bool = net.readBool()
  local int = net.readInt()
  local float = net.readFloat()
  local double = net.readDouble()
  local long = net.readLong()
  local number = net.readNumber() --lua number
  local str = net.readString()
  local r, g, b, a = net.readColour()
  
  --read custom format, quicker but more complicated
  --see https://www.lua.org/manual/5.3/manual.html#6.4.2
  local fByte, fInt, fFloat, fDouble, fString, index = net.readFormat("Bifds") --last returned value is index in stream
  net.seek(index) --must seek to index after reading custom format, otherwise wont be able to read other values after custom format
  
  print("\tbyte:", byte)
  print("\tbool:", bool)
  print("\tint:", int)
  print("\tfloat:", float)
  print("\tdouble:", double)
  print("\tlong:", long)
  print("\tnumber:", number)
  print("\tstring:", str)
  print("\tcolour:", r, g, b, a)
  print("\tcustom:", fByte, fInt, fFloat, fDouble, fString)

  net.start("pong")
  net.send(address) --send message to address only

  --ALTERNATIVES:
  --[[
      -- flag: 0 = reliable, 1 = unreliable, 2 = unsequenced, defaults to reliable
      --    "reliable" packets are guaranteed to arrive, and arrive in the order in which they are sent
      --    "unreliable" packets arrive in the order in which they are sent, but they aren't guaranteed to arrive
      --    "unsequenced" packets are neither guaranteed to arrive, nor do they have any guarantee on the order they arrive.
      
      -- channel: defaults to 0
      --    The channel to send the packet on
  
      net.send(address, flag, channel)

      --send message to all connections
      net.broadcast() 
      net.broadcast(flag, channel)
  ]]
end)
```
