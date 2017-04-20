function love.keypressed(key, unicode)
    if key == "escape" then
        love.event.push("quit")
    end
end

function love.load()
    love.mouse.setVisible(true)

    logo = {
        x = 0, y = 0, img = love.graphics.newImage('dvd.png'),
        x_speed = 100, y_speed = 100,

        rnd_r = 255,
        rnd_g = 255,
        rnd_b = 255,
    }

    cubetto = {
        is_placed = true,

        x = 0, y = 0,

        width = 20,
        height = 20,
    }
end

function love.update(dt)

        cubetto.x, cubetto.y = love.mouse.getPosition()

    -- update logo axis

    logo.x = logo.x + (logo.x_speed * dt)

    if (logo.x + logo.img:getWidth() >= love.graphics:getWidth()) or (logo.x <= 0) then
        logo.x_speed = -logo.x_speed
        random_logo()
    end

    logo.y = logo.y + (logo.y_speed * dt)

    if (logo.y + logo.img:getHeight() >= love.graphics:getHeight()) or (logo.y <= 0) then
        logo.y_speed = -logo.y_speed
        random_logo()
    end

    if check_collision(
        logo.x, logo.y, logo.img:getWidth(), logo.img:getHeight(),
        cubetto.x, cubetto.y, cubetto.width, cubetto.height) and cubetto.is_placed then
        --cubetto.is_placed = false
        logo.x_speed = -logo.x_speed
        logo.y_speed = -logo.y_speed
    end
end

function love.draw()
    love.graphics.setColor(logo.rnd_r, logo.rnd_g, logo.rnd_b)
    love.graphics.draw(logo.img, logo.x, logo.y)

    love.graphics.setColor(255,255,255)

    if cubetto.is_placed then
        love.graphics.rectangle("fill", cubetto.x, cubetto.y, cubetto.width, cubetto.height)
    end
end

function check_collision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2 + w2 and
         x2 < x1 + w1 and
         y1 < y2 + h2 and
         y2 < y1 + h1
end

function random_logo()
    logo.rnd_r = love.math.random(0, 255)
    logo.rnd_g = love.math.random(0, 255)
    logo.rnd_b = love.math.random(0, 255)
end
