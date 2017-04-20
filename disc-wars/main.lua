local anim8 = require 'lib/anim8'

function love.keypressed(key, unicode)
    if key == "escape" then
        love.event.push("quit")
    end
end

function love.load()
    love.graphics.setDefaultFilter("nearest")

    enemy = {
        img = love.graphics.newImage("assets/infected-program.png"),
        x = 100, y = 100,
    }

    mcp = {}
    mcp.img = love.graphics.newImage('assets/mcp.png')
    local g = anim8.newGrid(96, 172, mcp.img:getWidth(), mcp.img:getHeight())
    mcp.animation = anim8.newAnimation(g('1-4',1), 0.1)
    mcp.x = 10
    mcp.y = 10

    enemy.x = love.graphics:getWidth() - 10 - enemy.img:getWidth()
    enemy.y = (love.graphics:getHeight() / 2) - (enemy.img:getHeight() / 2)

    bg = {
        x = 0, y = 0, img = love.graphics.newImage("assets/bg.png"),
    }

    disk = {
        default_speed = 800,
        side_speed = 950,
        back_speed = 1000,

        x = 0, y = 0, img = love.graphics.newImage('assets/disk.png'),
        x_speed = 0, y_speed = 0,
        got_x = false,
        got_y = false,

        angle = 0,
        sign = 1,

        going_back = false,
        is_thrown = false,
    }
    disk.width = disk.img:getWidth()
    disk.height = disk.img:getHeight()
    disk.x_speed = disk.default_speed
    disk.y_speed = disk.default_speed

    player = {
        x = 0, y = 0, img = love.graphics.newImage("assets/tron.png"),
        speed = 400,

        throw_timer = 0,
        throw_timerMax = 0.5,
    }
    player.width = player.img:getWidth()
    player.height = player.img:getHeight()

    player.x = (love.graphics:getWidth() / 2) - (player.width / 2)
    player.y = (love.graphics:getHeight() / 2) - (player.height / 2)
    player.throw_timer = player.throw_timerMax
end

function love.update(dt)
    mcp.animation:update(dt)

    -- update player movments

    if love.keyboard.isDown("left") then
        if player.x > 0 then
            player.x = player.x - (player.speed * dt)
        else
            player.x = 0
        end
    elseif love.keyboard.isDown("right") then
        if player.x < love.graphics:getWidth() - player.img:getWidth() then
            player.x = player.x + (player.speed * dt)
        else
            player.x = love.graphics:getWidth() - player.img:getWidth()
        end
    end

    if love.keyboard.isDown("up") then
        if player.y > 0 then
            player.y = player.y - (player.speed * dt)
        else
            player.y = 0
        end
    elseif love.keyboard.isDown("down") then
        if player.y < love.graphics:getHeight() - player.img:getHeight() then
            player.y = player.y + (player.speed * dt)
        else
            player.y = love.graphics:getHeight() - player.img:getHeight()
        end
    end

    if disk.is_thrown and not disk.going_back and love.keyboard.isDown("c") then
        disk.going_back = true

        disk.x_speed = disk.back_speed
        disk.y_speed = disk.back_speed
    end

    if not disk.going_back and not disk.is_thrown and love.keyboard.isDown("space") then
        disk.x = player.x + (player.img:getWidth() / 2)
        disk.y = player.y + (player.img:getHeight() / 2)

        disk.is_thrown = true

        if love.keyboard.isDown("up") and love.keyboard.isDown("right") then
            disk.y_speed = -disk.y_speed
        elseif love.keyboard.isDown("down") and love.keyboard.isDown("right") then
            disk.x_speed = disk.default_speed
            disk.y_speed = disk.default_speed
        elseif love.keyboard.isDown("left") and love.keyboard.isDown("down") then
            disk.x_speed = -disk.x_speed
        elseif love.keyboard.isDown("up") and love.keyboard.isDown("left") then
            disk.x_speed = -disk.x_speed
            disk.y_speed = -disk.y_speed
        elseif love.keyboard.isDown("right") then
            disk.y_speed = 0
            disk.x_speed = disk.side_speed
        elseif love.keyboard.isDown("left") then
            disk.y_speed = 0
            disk.x_speed = -disk.side_speed
        elseif love.keyboard.isDown("up") then
            disk.x_speed = 0
            disk.y_speed = -disk.side_speed
        elseif love.keyboard.isDown("down") then
            disk.x_speed = 0
            disk.y_speed = disk.side_speed
        else
            disk.is_thrown = false
        end

        player.throw_timer = player.throw_timerMax
    end

    -- update disk axis

    if disk.going_back then
        if not disk.got_x then
            if disk.x > player.x then
                disk.x = disk.x - (disk.x_speed * dt)

                if disk.x <= player.x then
                    disk.got_x = true
                end
            elseif disk.x < player.x then
                disk.x = disk.x + (disk.x_speed * dt)

                if disk.x >= player.x then
                    disk.got_x = true
                end
            end
        end

        if not disk.got_y then
            if disk.y > player.y then
                disk.y = disk.y - (disk.y_speed * dt)

                if disk.y <= player.y then
                    disk.got_y = true
                end
            elseif disk.y < player.y then
                disk.y = disk.y + (disk.y_speed * dt)

                if disk.y >= player.y then
                    disk.got_y = true
                end
            end
        end
    end

    if disk.is_thrown and not disk.going_back then
        disk.angle = disk.angle + disk.sign * math.pi * 0.02

        disk.x = disk.x + (disk.x_speed * dt)

        if (disk.x + disk.img:getWidth() >= love.graphics:getWidth()) or (disk.x <= 0) then
            disk.x_speed = -disk.x_speed

            disk.sign = disk.sign * -1
        end

        disk.y = disk.y + (disk.y_speed * dt)

        if (disk.y + disk.img:getHeight() >= love.graphics:getHeight()) or (disk.y <= 0) then
            disk.y_speed = -disk.y_speed

            disk.sign = disk.sign * -1
        end
    end

    -- if player collides with disk then reset values of the disk
    -- like is was not thrown

    if player.throw_timer == 0 and check_collision(
        player.x, player.y, player.width, player.height,
        disk.x, disk.y, disk.width, disk.height) then

        disk.is_thrown = false
        disk.going_back = false
        disk.got_x = false
        disk.got_y = false

        disk.x_speed = disk.default_speed
        disk.y_speed = disk.default_speed
        disk.sign = 1
    end

    -- check throw timer after which the disk can be taken back

    if player.throw_timer > 0 then
        player.throw_timer = player.throw_timer - (1 * dt)

        if player.throw_timer <= 0 then
            player.throw_timer = 0
        end
    end
end

function love.draw()

    drawBackground(bg.img, bg.x, bg.y)

    love.graphics.draw(player.img, player.x, player.y)

    if disk.is_thrown or disk.going_back then
        love.graphics.draw(disk.img,
            disk.x + (disk.width / 2),
            disk.y + (disk.height / 2),
            disk.angle, 1, 1,
            disk.width/2,
            disk.height/2)
    end

    love.graphics.draw(enemy.img, enemy.x, enemy.y)

    mcp.animation:draw(mcp.img, 10, 10)
end

function drawBackground(bgImg, xPos, yPos)
    for i = 1, math.ceil(love.graphics.getWidth()/bgImg:getWidth()) do
        for j = 1, math.ceil(love.graphics.getHeight()/bgImg:getHeight()) do
            love.graphics.draw(bgImg, (i-1)*bgImg:getWidth() + xPos, (j-1)*bgImg:getHeight() + yPos)
        end
    end
end

function check_collision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2 + w2 and
         x2 < x1 + w1 and
         y1 < y2 + h2 and
         y2 < y1 + h1
end
