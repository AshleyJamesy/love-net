io.stdout:setvbuf("no")

DEBUG = false
SERVER = false
DEDICATED = false
CLIENT = true

for _, argument in ipairs(arg) do 
	if argument == "-debug" then
		DEBUG = true
	elseif argument == "-server" then
		SERVER = true
	elseif argument == "-dedicated" then
		CLIENT = false
		SERVER = true
		DEDICATED = true
	end
end

function love.conf(t)
	t.identity = nil                    -- The name of the save directory (string)
    t.appendidentity = false            -- Search files in source directory before save directory (boolean)
    t.version = "11.3"                  -- The LÖVE version this game was made for (string)
    t.console = false                   -- Attach a console (boolean, Windows only)
    t.accelerometerjoystick = true      -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.externalstorage = false           -- True to save files (and read from the save directory) in external storage on Android (boolean) 
    t.gammacorrect = false              -- Enable gamma-correct rendering, when supported by the system (boolean)

	t.modules.audio = not DEDICATED
	t.modules.event = true
	t.modules.graphics = not DEDICATED
	t.modules.image = not DEDICATED
	t.modules.joystick = not DEDICATED
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = true
	t.modules.sound = not DEDICATED
	t.modules.system = true
	t.modules.timer = true
	t.modules.touch = not DEDICATED
	t.modules.video = not DEDICATED
	t.modules.window = not DEDICATED
	t.modules.thread = true

	require("love.system")

	if not DEDICATED then
		t.audio.mic = false 					-- Request and use microphone capabilities in Android (boolean)
		t.audio.mixwithsystem = true 			-- Keep background music playing when opening LOVE (boolean, iOS and Android only)

		t.window.title = "love-net"				-- The window title (string)
		t.window.icon = nil 					-- Filepath to an image to use as the window's icon (string)
		t.window.width = 800 					-- The window width (number)
		t.window.height = 680 					-- The window height (number)
		t.window.borderless = false 			-- Remove all border visuals from the window (boolean)
		t.window.resizable = false 				-- Let the window be user-resizable (boolean)
		t.window.minwidth = 1 					-- Minimum window width if the window is resizable (number)
		t.window.minheight = 1 					-- Minimum window height if the window is resizable (number)
		t.window.fullscreen = false 			-- Enable fullscreen (boolean)
		t.window.fullscreentype = "desktop" 	-- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
		t.window.vsync = 1 						-- Vertical sync mode (number)
		t.window.msaa = 0 						-- The number of samples to use with multi-sampled antialiasing (number)
		t.window.depth = nil 					-- The number of bits per sample in the depth buffer
		t.window.stencil = nil 					-- The number of bits per sample in the stencil buffer
		t.window.display = 1 					-- Index of the monitor to show the window in (number)
		t.window.highdpi = false 				-- Enable high-dpi mode for the window on a Retina display (boolean)
		t.window.usedpiscale = true 			-- Enable automatic DPI scaling when highdpi is set to true as well (boolean)
		t.window.x = nil 						-- The x-coordinate of the window's position in the specified display (number)
		t.window.y = nil 						-- The y-coordinate of the window's position in the specified display (number)
	end
end

function love.run()
	math.randomseed(os.time())
	
	local t = love.timer
	local g = love.graphics

	if love.load then 
		love.load(love.arg.parseGameArguments(arg), arg)
	end
	
	t.step()
	
	local dt = 0.0
	local acc = 0.0

	--don't need a render call for dedicated
	if DEDICATED then
		return function()
			if love.event then
				love.event.pump()
				for name, a, b, c, d, e, f in love.event.poll() do
					if name == 'quit' then
						if not love.quit or not love.quit() then
							return a or 0
						end
					end
					
					love.handlers[name](a, b, c, d, e, f)
				end
			end
			
			if love.timer then
				dt = t.step()
			end
			
			if love.update then
				love.update(dt)
			end
			
			t.sleep(0.001)
		end
	else
		return function()
			if love.event then
				love.event.pump()
				for name, a, b, c, d, e, f in love.event.poll() do
					if name == 'quit' then
						if not love.quit or not love.quit() then
							return a or 0
						end
					end
					
					love.handlers[name](a, b, c, d, e, f)
				end
			end
			
			if love.timer then
				dt = t.step()
			end
			
			if love.update then
				love.update(dt)
			end
			
			if g and g.isActive() then
				g.origin()
				g.clear(g.getBackgroundColor())
				
				if love.render then 
					love.render()
				end
				
				g.present()
			end
			
			t.sleep(0.001)
		end
	end
end