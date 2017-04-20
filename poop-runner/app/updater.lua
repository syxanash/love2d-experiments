function updater(dt)
    if spawnPoopTimerMax > 0.2 then
        spawnPoopTimerMax = spawnPoopTimerMax - (0.005 * dt)

        print(spawnPoopTimerMax)
    else
        print('max poop limit reached')
    end

    -- jumping timer

    if player.jumped then
        jumpTimer = jumpTimer - (1 * dt)

        if jumpTimer < (jumpTimerMax/2) then
            player.y = player.y + (player.speed * 2 * dt)
        else
            player.y = player.y - (player.speed * 2 * dt)
        end

        --print('player has jumped!!!')
    else
        --print('player is on ground')
    end

    if jumpTimer < 0 then
        jumpTimer = jumpTimerMax
        player.jumped = false
    end

    -- set the timer to spawn a new poop
    spawnPoopTimer = spawnPoopTimer - (1 * dt)
    if spawnPoopTimer < 0 and player.isMoving then
        spawnPoopTimer = spawnPoopTimerMax

        poopImg = poopAssets[love.math.random(#poopAssets)]
        randomNumber = love.math.random(poopImg:getWidth(), love.graphics.getWidth() - poopImg:getWidth())
        newPoop = { x = randomNumber, y = -poopImg:getHeight(), img = poopImg, speed = bg.speed }

        table.insert(poops, newPoop)
    end

    -- update position of poop
    for i, poop in ipairs(poops) do
        if not love.keyboard.isDown('down') and player.isMoving then
            poop.y = poop.y + (poop.speed * dt)
        end

        if poop.y > love.graphics:getHeight() then
            table.remove(poops, i)
        end
    end

    for i, poop in ipairs(poops) do
        if not player.jumped and CheckCollision(poop.x+8,poop.y+16,poop.img:getWidth()-16,poop.img:getHeight()-24, player.x+24,player.y+224,player.width-48,player.height-224) and isAlive then

          table.remove(poops, i)
          isAlive = false
        end
    end

      -- update player positions

    if love.keyboard.isDown('space') then
        player.jumped = true
    end

    if not player.isMoving then
        player.anim.still:update(dt)
    end

    if love.keyboard.isDown('up') then
        player.isMoving = true
        player.anim.move:update(dt)

        if player.y > 200 then
            player.y = player.y - (player.speed * dt)
        end
    elseif love.keyboard.isDown('down') then
        player.isMoving = true
        player.anim.move:update(dt)

        if player.y + player.height < love.graphics:getHeight() then
            player.y = player.y + ((player.speed / 2) * dt)
        end
    else
        player.isMoving = false
    end

    if love.keyboard.isDown('right') then
        player.isMoving = true
        player.anim.move:update(dt)

        if player.x + player.width < love.graphics:getWidth() then
            player.x = player.x + (player.speed * dt)
        end
    elseif love.keyboard.isDown('left') then
        player.isMoving = true
        player.anim.move:update(dt)

        if player.x > 0 then
            player.x = player.x - (player.speed * dt)
        end
    end

    if not isAlive then
        poops = {}
    end

    if not isAlive and love.keyboard.isDown('r') then
        spawnPoopTimer = spawnPoopTimerMax

        isAlive = true
    end

    if player.isMoving and not love.keyboard.isDown('down') then
        if bg.y < bg.img:getHeight() then
            bg.y = bg.y + (bg.speed * dt)
        else
            bg.y = 0
        end
    end
end

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2 + w2 and
         x2 < x1 + w1 and
         y1 < y2 + h2 and
         y2 < y1 + h1
end
