debugger = true
audioEnabled = false

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- speed of enemies will increase every seconds
difficultSpeed = 0

lives = 3

-- player positions when moving the plane
positions = {
	right = nil,
	left = nil,
	up = nil,
	still = nil
}

-- bg object
bg = { x = 0, y = 0, img = nil, speed = 60 }

-- Player Object
player = { x = 200, y = 710, speed = 150, img = nil }
isAlive = true
score  = 0

-- Image Storage
bulletImg = nil
laserImg = nil

laserActive = false

enemyImg = nil
enemyImgDestoyed = nil

-- Sound Storage
gunSound = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen

-- check if the game is paused
paused = false

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function drawBackground(bgImg, xPos, yPos)
  for i = 1, math.ceil(love.graphics.getWidth()/bgImg:getWidth()) do
    for j = 1, math.ceil(love.graphics.getHeight()/bgImg:getHeight()) do
      love.graphics.draw(bgImg, (i-1)*bgImg:getWidth() + xPos, (j-1)*bgImg:getHeight() + yPos)
    end
  end
end

-- Loading
function love.load(arg)
	positions.still = love.graphics.newImage('assets/plane.png')
	positions.right = love.graphics.newImage('assets/plane-right.png')
	positions.left = love.graphics.newImage('assets/plane-left.png')
	positions.up = love.graphics.newImage('assets/plane-up.png')

	player.img = positions.still

  bg.img = love.graphics.newImage("assets/bg.png")

  -- other objects  

	enemyImg = love.graphics.newImage('assets/enemy.png')
  enemyImgDestoyed = love.graphics.newImage('assets/enemy-destroyed.png')

	bulletImg = love.graphics.newImage('assets/bullet.png')
  laserImg = love.graphics.newImage('assets/laser.png')

	gunSound = love.audio.newSource('assets/gun-sound.wav', 'static')

  -- really hope Datassette ain't gonna sue me!
  soundtrack = love.audio.newSource('assets/zigzag.ogg', 'stream')

  soundtrack:setLooping(true)
  --soundtrack:play()
end

-- enable or disable audio for bullets and soundtrack
-- when various keys are pressed
function love.keypressed(key, unicode)
  if key == 'm' then
    audioEnabled = not audioEnabled
  end

  if key == 'n' then
    if soundtrack:isStopped() then
      soundtrack:play()
    else
      soundtrack:stop()
    end
  end

  if key == 'x' then
    laserActive = not laserActive
  end

  if key == 'escape' then
    love.event.push('quit')
  end

  if key == 'p' then
    paused = not paused
  end
end

-- Updating
function love.update(dt)
  if bg.y < bg.img:getHeight() then
    bg.y = bg.y + (bg.speed * dt)
  else
    bg.y = 0
  end

  difficultSpeed = difficultSpeed + (5 * dt)

  player.img = positions.still

	-- Time out how far apart our shots can be.
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	-- Time out enemy creation
	createEnemyTimer = createEnemyTimer - (1 * dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		-- Create an enemy
		randomNumber = math.random(10, love.graphics.getWidth() - enemyImg:getWidth())
		newEnemy = { x = randomNumber, y = -enemyImg:getHeight(), img = enemyImg, died = false, diedTimer = 0 }
		table.insert(enemies, newEnemy)
	end


	-- update the positions of bullets
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)

		if bullet.y < 0 then -- remove bullets when they pass off the screen
			table.remove(bullets, i)
		end
	end

	-- update the positions of enemies
	for i, enemy in ipairs(enemies) do
    if enemy.died then
      enemy.img = enemyImgDestoyed
      enemy.diedTimer = enemy.diedTimer + (1 * dt)

      if enemy.diedTimer > 0.2 then
        table.remove(enemies, i)
      end
    else
      enemy.y = enemy.y + ((100 + difficultSpeed) * dt)
    end

		if enemy.y > 850 then -- remove enemies when they pass off the screen
			table.remove(enemies, i)

			if score > 0 then
				score = score - 1
			end
		end
	end

	-- run our collision detection
	-- Since there will be fewer enemies on screen than bullets we'll loop them first
	-- Also, we need to see if the enemies hit our player
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				
        enemy.died = true

        --table.remove(enemies, i)
				score = score + 1
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) 
		and isAlive then
			table.remove(enemies, i)
			isAlive = false
		end
	end

  if love.keyboard.isDown('space', 'rctrl', 'lctrl', 'ctrl') and canShoot then
    -- Create some bullets
    if laserActive then
      canShootTimerMax = 0.002
      newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = laserImg }
    else
      canShootTimerMax = 0.2
      newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
    end

    table.insert(bullets, newBullet)
    
    if audioEnabled then
      gunSound:play()
    end
    
    canShoot = false
    canShootTimer = canShootTimerMax
  end

	-- Horizontal movement
	if love.keyboard.isDown('left','a') then
		player.img = positions.left

		if player.x > 0 then -- binds us to the map
			player.x = player.x - (player.speed*dt)
		end
	elseif love.keyboard.isDown('right','d') then
		player.img = positions.right

		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed*dt)
		end
	end

	-- Vertical movement
	if love.keyboard.isDown('up', 'w') then
		player.img = positions.up

		if player.y > (love.graphics.getHeight() / 2) then -- player cannot fly over the mid of the window
			player.y = player.y - (player.speed*dt)
		end
	elseif love.keyboard.isDown('down', 's') then
		if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
			player.y = player.y + (player.speed*dt)
		end
	end

  -- when player dies clear everything
  if not isAlive then
    bullets = {}
    enemies = {}
  end

	if not isAlive and lives > 0 and love.keyboard.isDown('r') then
		-- reset timers
		canShootTimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax

		-- move player back to default position
		player.x = 50
		player.y = 710

		isAlive = true

    lives = lives - 1
	end
end

-- Drawing
function love.draw()
  love.graphics.setColor(255,255,255)

  drawBackground(bg.img, bg.x, bg.y)
  drawBackground(bg.img, bg.x, bg.y - bg.img:getHeight())
  
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("SCORE: " .. tostring(score), 400, 10)

	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
	elseif lives == 0 then
    love.graphics.print("GAME OVER, SCORE: " .. score, love.graphics:getWidth()/2-70, love.graphics:getHeight()/2-10)
  else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-55, love.graphics:getHeight()/2-10)
	end

  love.graphics.print("LIVES: " .. lives, love.graphics:getWidth()/2-10, 10)

	if debugger then
		fps = tostring(love.timer.getFPS())
		love.graphics.print("Current FPS: "..fps, 9, 10)
	end
end
