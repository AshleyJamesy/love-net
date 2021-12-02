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
net.receive("ping", function(address)
  print("received message: 'ping' from '" .. address .. "'")

  local byte = net.readByte()
  local bool = net.readBool()
  local int = net.readInt()
  local float = net.readFloat()
  local double = net.readDouble()
  local str = net.readString()
  local r, g, b, a = net.readColour()
  
  --custom format, quicker but more complicated
  local fByte, fInt, fFloat, fDouble, fString, index = net.readFormat("Bifds") --last returned value is index in stream
  net.seek(index) --must seek to index after reading custom format, otherwise wont be able to read other values after custom format
  
  print("\tbyte:", byte)
  print("\tbool:", bool)
  print("\tint:", int)
  print("\tfloat:", float)
  print("\tdouble:", double)
  print("\tstring:", str)
  print("\tcolour:", r, g, b, a)
  print("\tcustom:", fByte, fInt, fFloat, fDouble, fString)

  net.start("pong")
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
end)