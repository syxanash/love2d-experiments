-- Configuration
function love.conf(t)
	t.title = "Poop Runner" -- The title of the window the game is in (string)
	t.version = "0.9.1"         -- The LÖVE version this game was made for (string)
  t.author = "Simone Marzulli" -- that's me Simone :D
	t.window.width = 512        -- we want our game to be long and thin.
	t.window.height = 700

  --t.window.fullscreen = true

	-- For Windows debugging
	t.console = true
end
