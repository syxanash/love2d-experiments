function loader()
    -- background object

    bg = { x = 0, y = 0, img = nil, speed = 100 }

    jumpTimerMax = 1.5
    jumpTimer = jumpTimerMax

    spawnPoopTimerMax = 1.5
    spawnPoopTimer = spawnPoopTimerMax

    poopAssets = {}
    poops = {}

    isAlive = true

    player = {
        x = 200, y = 400, speed = 100,
        width = 104, height = 272,

        anim = {
            still = nil, move = nil, jumped = nil
        },

        direction = 'left',
        isMoving = false,
        jumped = false
    }

    bg.img = love.graphics.newImage("assets/bg-street.png")

    poopAssets = {
        love.graphics.newImage('assets/shit-1.png'),
        love.graphics.newImage('assets/shit-2.png')
    }

    player.anim.jumped = love.graphics.newImage("assets/jumped.png");
    player.anim.move = newAnimation(love.graphics.newImage("assets/running.png"), player.width, player.height, 0.1, 0)
    player.anim.still = newAnimation(love.graphics.newImage("assets/still.png"), 136, 280, 0.2, 0)

    -- Mode constants:
    -- loop
    -- bounce
    -- once

    -- Sets the mode to "bounce"
    player.anim.move:setMode("loop")
    player.anim.still:setMode("loop")
end
