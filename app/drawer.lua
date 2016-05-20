function drawer()
    love.graphics.setColor(255,255,255)

    drawBackground(bg.img, bg.x, bg.y)
    drawBackground(bg.img, bg.x, bg.y - bg.img:getHeight())

    for i, poop in ipairs(poops) do
        love.graphics.draw(poop.img, poop.x, poop.y)

        if debugging then
            love.graphics.setColor(0,255,0)
            love.graphics.rectangle("fill", poop.x+8,poop.y+16,poop.img:getWidth()-16,poop.img:getHeight()-24, 10, 10 )
            love.graphics.setColor(255,255,255)
        end
    end

    if isAlive then
        if player.isMoving then
            if player.jumped then
                love.graphics.draw(player.anim.jumped, player.x-50, player.y+25)
            else
                player.anim.move:draw(player.x, player.y)
            end
        else
            player.anim.still:draw(player.x, player.y)
        end
    else
        love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-55, love.graphics:getHeight()/2-10)
    end

    if debugging then
        love.graphics.setColor(0,255,0)
        love.graphics.rectangle("fill", player.x+24,player.y+224,player.width-48,player.height-224, 10, 10 )
        love.graphics.setColor(255,255,255)
    end

    if debugging then
        fps = tostring(love.timer.getFPS())
        love.graphics.print("Current FPS:" .. fps, 9, 10)
    end
end

function drawBackground(bgImg, xPos, yPos)
  for i = 1, math.ceil(love.graphics.getWidth()/bgImg:getWidth()) do
    for j = 1, math.ceil(love.graphics.getHeight()/bgImg:getHeight()) do
      love.graphics.draw(bgImg, (i-1)*bgImg:getWidth() + xPos, (j-1)*bgImg:getHeight() + yPos)
    end
  end
end
