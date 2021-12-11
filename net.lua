local data, thread = require("love.data"), require("love.thread")
local pack, unpack = data.pack, data.unpack

local mt_stream = {
	bytes = "", index = 1,

	__len = function(stream)
		return #stream.bytes
	end,
	writeByte = function(stream, byte)
		stream.bytes = stream.bytes .. pack("string", "B", byte)
	end,
	readByte = function(stream)
		local n, bytes = unpack("B", stream.bytes, stream.index)
		stream.index = bytes

		return n, bytes
	end,
	writeBytes = function(stream, bytes)
		stream.bytes = stream.bytes .. bytes
	end,
	writeBool = function(stream, bool)
		stream.bytes = stream.bytes .. pack("string", "B", bool and 1 or 0)
	end,
	readBool = function(stream)
		local n, bytes = unpack("B", stream.bytes, stream.index)
		stream.index = bytes

		return n == 1, bytes
	end,
	writeInt = function(stream, int)
		stream.bytes = stream.bytes .. pack("string", "i4", int)
	end,
	readInt = function(stream)
		local i, bytes = unpack("i4", stream.bytes, stream.index)
		stream.index = bytes

		return i, bytes
	end,
	writeFloat = function(stream, float)
		stream.bytes = stream.bytes .. pack("string", "f", float)
	end,
	readFloat = function(stream)
		local f, bytes = unpack("f", stream.bytes, stream.index)
		stream.index = bytes

		return f, bytes
	end,
	writeDouble = function(stream, double)
		stream.bytes = stream.bytes .. pack("string", "d", double)
	end,
	readDouble = function(stream)
		local d, bytes = unpack("d", stream.bytes, stream.index)
		stream.index = bytes
		
		return d, bytes
	end,
	writeLong = function(stream, long)
		stream.bytes = stream.bytes .. pack("string", "l", long)
	end,
	readLong = function(stream)
		local l, bytes = unpack("l", stream.bytes, stream.index)
		stream.index = bytes

		return l, bytes
	end,
	writeNumber = function(stream, number)
		stream.bytes = stream.bytes .. pack("string", "n", number)
	end,
	readNumber = function(stream)
		local n, bytes = unpack("n", stream.bytes, stream.index)
		stream.index = bytes

		return n, bytes
	end,
	writeString = function(stream, str)
		stream.bytes = stream.bytes .. pack("string", "s", str)
	end,
	readString = function(stream)
		local s, bytes = unpack("s", stream.bytes, stream.index)
		stream.index = bytes
		
		return s, bytes
	end,
	pack = function(stream, format, ...)
		stream.bytes = stream.bytes .. pack("string", format, ...)
	end,
	unpack = function(stream, format)
		return unpack(format, stream.bytes, stream.index)
	end,
	setBytes = function(stream, bytes)
		stream.bytes = bytes
	end,
	getBytes = function(stream)
		return stream.bytes
	end,
	seek = function(stream, i)
		stream.index = i
	end,
	peek = function(stream)
		return stream.index
	end,
	sub = function(stream, s, e)
		return stream.bytes:sub(s, e)
	end
}
mt_stream.__index = mt_stream

local net_thread, channel_send, channel_receive

local states, callbacks, packet, stream_send, stream_read = 
	{}, {}, setmetatable({ bytes = "", index = 1 }, mt_stream), setmetatable({ bytes = "", index = 1 }, mt_stream), setmetatable({ bytes = "", index = 1 }, mt_stream)

local function init(address, max_connections, max_channels, bandwidth_in, bandwidth_out)
	channel_send, channel_receive = thread.newChannel(), thread.newChannel()

	if net_thread ~= nil then
		
	end

	net_thread = thread.newThread([[
		local address, max_connections, max_channels, bandwidth_in, bandwidth_out, channel_send, channel_receive = ...

		local enet, data = require("enet"), require("love.data")
		local pack, unpack = data.pack, data.unpack

		local mt_stream = {
			bytes = "", index = 1,

			__len = function(stream)
				return #stream.bytes
			end,
			writeByte = function(stream, byte)
				stream.bytes = stream.bytes .. pack("string", "B", byte)
			end,
			readByte = function(stream)
				local n, bytes = unpack("B", stream.bytes, stream.index)
				stream.index = bytes

				return n, bytes
			end,
			writeBytes = function(stream, bytes)
				stream.bytes = stream.bytes .. bytes
			end,
			writeBool = function(stream, bool)
				stream.bytes = stream.bytes .. pack("string", "B", bool and 1 or 0)
			end,
			readBool = function(stream)
				local n, bytes = unpack("B", stream.bytes, stream.index)
				stream.index = bytes

				return n == 1, bytes
			end,
			writeInt = function(stream, int)
				stream.bytes = stream.bytes .. pack("string", "i4", int)
			end,
			readInt = function(stream)
				local i, bytes = unpack("i4", stream.bytes, stream.index)
				stream.index = bytes

				return i, bytes
			end,
			writeFloat = function(stream, float)
				stream.bytes = stream.bytes .. pack("string", "f", float)
			end,
			readFloat = function(stream)
				local f, bytes = unpack("f", stream.bytes, stream.index)
				stream.index = bytes

				return f, bytes
			end,
			writeDouble = function(stream, double)
				stream.bytes = stream.bytes .. pack("string", "d", double)
			end,
			readDouble = function(stream)
				local d, bytes = unpack("d", stream.bytes, stream.index)
				stream.index = bytes
				
				return d, bytes
			end,
			writeLong = function(stream, long)
				stream.bytes = stream.bytes .. pack("string", "l", long)
			end,
			readLong = function(stream)
				local l, bytes = unpack("l", stream.bytes, stream.index)
				stream.index = bytes
				
				return l, bytes
			end,
			writeNumber = function(stream, number)
				stream.bytes = stream.bytes .. pack("string", "n", number)
			end,
			readNumber = function(stream)
				local n, bytes = unpack("n", stream.bytes, stream.index)
				stream.index = bytes
				
				return n, bytes
			end,
			writeString = function(stream, str)
				stream.bytes = stream.bytes .. pack("string", "s", str)
			end,
			readString = function(stream)
				local s, bytes = unpack("s", stream.bytes, stream.index)
				stream.index = bytes
				
				return s, bytes
			end,
			pack = function(stream, format, ...)
				stream.bytes = stream.bytes .. pack("string", format, ...)
			end,
			unpack = function(stream, format)
				return unpack(format, stream.bytes, stream.index)
			end,
			setBytes = function(stream, bytes)
				stream.bytes = bytes
			end,
			getBytes = function(stream)
				return stream.bytes
			end,
			seek = function(stream, i)
				stream.index = i
			end,
			peek = function(stream)
				return stream.index
			end,
			sub = function(stream, s, e)
				return stream.bytes:sub(s, e)
			end
		}
		mt_stream.__index = mt_stream

		local stream = setmetatable({ bytes = "", index = 1 }, mt_stream)

		host = enet.host_create(address, max_connections, max_channels, bandwidth_in, bandwidth_out)

		local states = {}
		for i = 1, max_connections do
			states[i] = {
				id = 0,
				index = i,
				address = "",
				ip = "",
				port = "",
				state = "disconnected"
			}
		end

		local statesByAddress = {}

		while true do
			stream:setBytes("")
			stream:seek(1)

			if host then
				--STATE CHANGES
				for index, state in pairs(states) do
					local peer = host:get_peer(index)

					if peer then
						if state.state ~= peer:state() then
							state.id = peer:connect_id()
							state.address = tostring(peer)
							state.ip = tostring(peer):match("(.*):.*")
							state.port = tostring(peer):match(".*:(.*)")
							state.state = peer:state()

							if state.state == "connected" then
								statesByAddress[state.address] = state
							end

							if state.state == "disconnected" then
								statesByAddress[state.address] = nil
							end

							stream:writeByte(0)
							stream:writeString(state.address)
							stream:writeNumber(state.id)
							stream:writeInt(peer:round_trip_time())

							local status = state.state

							if status == "disconnected" then
								stream:writeByte(1)
							elseif status == "connecting" then
								stream:writeByte(2)
							elseif status == "acknowledging_connect" then
								stream:writeByte(3)
							elseif status == "connection_pending" then
								stream:writeByte(4)
							elseif status == "connection_succeeded" then
								stream:writeByte(5)
							elseif status == "connected" then
								stream:writeByte(6)
							elseif status == "disconnect_later" then
								stream:writeByte(7)
							elseif status == "disconnecting" then
								stream:writeByte(8)
							elseif status == "acknowledging_disconnect" then
								stream:writeByte(9)
							elseif status == "zombie" then
								stream:writeByte(10)
							elseif status == "unknown" then
								stream:writeByte(11)
							else
								stream:writeByte(1)
							end

							channel_receive:push(stream:getBytes())
							stream:setBytes("")
						end
					end
				end

				local status, packet
				status, packet = pcall(host.service, host)

				--RECEIVING PACKETS
				while packet do
					local state = states[packet.peer:index()]
					if packet.type == "receive" then
						stream:writeByte(1)
						stream:writeString(state.address)
						stream:writeNumber(state.id)
						stream:writeInt(packet.peer:round_trip_time())
						stream:writeBytes(packet.data)

						channel_receive:push(stream:getBytes())
						stream:setBytes("")
					end

					status, packet = pcall(host.service, host)
				end

				--SENDING PACKETS
				local outgoing = channel_send:pop()

				while outgoing do
					stream:setBytes(outgoing)
					stream:seek(1)

					local action = stream:readByte()

					if action == 0 then
						host:connect(stream:readString())
					elseif action == 1 then
						local state = statesByAddress[stream:readString()]

						if state then
							host:get_peer(state.index):disconnect(stream:readByte())
						end
					elseif action == 2 then
						local channel, flag, address, data = stream:readByte(), stream:readByte(), stream:readString(), stream:sub(stream:peek())

						if flag == 0 then
							flag = "reliable"
						elseif flag == 1 then
							flag = "unreliable"
						elseif flag == 2 then
							flag = "unsequenced"
						else
							flag = "reliable"
						end

						local state = statesByAddress[address]
						if state then
							local peer = host:get_peer(state.index)
							if peer then
								peer:send(data, channel, flag)
							end
						end

					elseif action == 3 then
						local channel, flag, data = stream:readByte(), stream:readByte(), stream:sub(stream:peek())

						if flag == 0 then
							flag = "reliable"
						elseif flag == 1 then
							flag = "unreliable"
						elseif flag == 2 then
							flag = "unsequenced"
						else
							flag = "reliable"
						end

						host:broadcast(data, channel, flag)
					end

					outgoing = channel_send:pop()
				end
			end
		end
	]])

	net_thread:start(address, max_connections, max_channels, bandwidth_in, bandwidth_out, channel_send, channel_receive)
end

local function connect(address, server)
	if net_thread and channel_send then
		packet:pack("Bs", 0, address)
		channel_send:push(packet:getBytes())
		packet:setBytes("")
	end
end

local function disconnect(address, code)
	if net_thread and channel_send then
		packet:pack("BsB", 1, address, code or 0)
		channel_send:push(packet:getBytes())
		packet:setBytes("")
	end    
end

local function send(address, flag, channel)
	if net_thread and channel_send then
		packet:pack("BBBs", 2, channel or 0, flag or 0, address)
		packet:writeBytes(stream_send:getBytes())
		channel_send:push(packet:getBytes())
		stream_send:setBytes("")
		packet:setBytes("")
	 end
end

local function broadcast(flag, channel)
	if net_thread and channel_send then
		packet:pack("BBB", 3, channel or 0, flag or 0)
		packet:writeBytes(stream_send:getBytes())
		channel_send:push(packet:getBytes())
		stream_send:setBytes("")
		packet:setBytes("")
	end
end

local function update()
	local packet = channel_receive:pop()

	while packet ~= nil do
		stream_read:setBytes(packet)
		stream_read:seek(1)

		local type = stream_read:readByte()

		if type == 0 then
			local address = stream_read:readString()
			local connectId = stream_read:readNumber()
			local roundTripTime = stream_read:readInt()

			local state = stream_read:readByte()

			if state == 1 then
				state = "disconnected"
			elseif state == 2 then
				state = "connecting"
			elseif state == 3 then
				state = "acknowledging_connect"
			elseif state == 4 then
				state = "connection_pending"
			elseif state == 5 then
				state = "connection_succeeded"
			elseif state == 6 then
				state = "connected"
			elseif state == 7 then
				state = "disconnect_later"
			elseif state == 8 then
				state = "disconnecting"
			elseif state == 9 then
				state = "acknowledging_disconnect"
			elseif state == 10 then
				state = "zombie"
			elseif state == 11 then
				state = "unknown"
			else
				state = "disconnected"
			end

			for _, callback in pairs(states) do
				callback(address, connectId, state, roundTripTime)
			end
		elseif type == 1 then
			local address = stream_read:readString()
			local connectId = stream_read:readNumber()
			local roundTripTime = stream_read:readInt()

			local message, bytes = stream_read:readString()

			stream_read:setBytes(stream_read:sub(bytes))
			stream_read:seek(1)
 
			if callbacks[message] ~= nil then
				for _, callback in pairs(callbacks[message]) do
					stream_read:seek(1)
					callback(address, connectId, roundTripTime)
				end
			end
		end

		packet = channel_receive:pop()
	end
end

local function receive(message, callback)
	if callbacks[message] == nil then
		callbacks[message] = {}
	end

	table.insert(callbacks[message], callback)
end

local function state(callback)
	table.insert(states, callback)
end

local function start(message)
	stream_send:setBytes("")
	stream_send:writeString(message)
end

local function writeByte(byte)
	stream_send:writeByte(byte)
end

local function readByte(byte)
	return stream_read:readByte(byte)
end

local function writeBool(bool)
	stream_send:writeBool(bool)
end

local function readBool()
	return stream_read:readBool()
end

local function writeInt(int)
	stream_send:writeInt(int)
end

local function readInt()
	return stream_read:readInt()
end

local function writeFloat(float)
	stream_send:writeFloat(float)
end

local function readFloat()
	return stream_read:readFloat()
end

local function writeDouble(double)
	stream_send:writeDouble(double)
end

local function readDouble()
	return stream_read:readDouble()
end

local function writeLong(long)
	stream_send:writeLong(long)
end

local function readLong()
	return stream_read:readLong()
end

local function writeNumber(number)
	stream_send:writeNumber(number)
end

local function readNumber()
	return stream_read:readNumber()
end

local function writeString(str)
	stream_send:writeString(str)
end

local function readString()
	return stream_read:readString()
end

local function writeFormat(format, ...)
	stream_send:pack(format, ...)
end

local function readFormat(format)
	return stream_read:unpack(format)
end

local max = math.max
local min = math.min

local function writeColour(r, g, b, a)
	stream_send:pack("ffff", 
		min(max(r, 0.0), 1.0), 
		min(max(g, 0.0), 1.0), 
		min(max(b, 0.0), 1.0), 
		min(max(a, 0.0), 1.0)
	)
end

local function readColour()
	local r, g, b, a, i = stream_read:unpack("ffff")
	stream_read:seek(i)

	return r, g, b, a
end

local function seek(index)
	stream_read:seek(index)
end

return {
	init = init,
	connect = connect,
	disconnect = disconnect,
	broadcast = broadcast,
	update = update,
	receive = receive,
	state = state,
	send = send,
	start = start,
	writeByte = writeByte,
	readByte = readByte,
	writeBool = writeBool,
	readBool = readBool,
	writeInt = writeInt,
	readInt = readInt,
	writeFloat = writeFloat,
	readFloat = readFloat,
	writeDouble = writeDouble,
	readDouble = readDouble,
	writeLong = writeLong,
	readLong = readLong,
	writeNumber = writeNumber,
	readNumber = readNumber,
	writeString = writeString,
	readString = readString,
	writeColour = writeColour,
	readColour = readColour,
	writeFormat = writeFormat,
	readFormat = readFormat,
	seek = seek
}