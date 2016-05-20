require "lib/AnAL/AnAL"

require "loader"
require "updater"
require "drawer"

debugging = false

function love.keypressed(key, unicode)
  if key == 'escape' then
    love.event.push('quit')
  elseif key == 'd' then
    debugging = not debugging
  end
end

function love.load()
    loader()
end

function love.update(dt)
    updater(dt)
end

function love.draw()
    drawer()
end
