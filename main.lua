-- Author: Patrick Moehrke
-- License: MIT
-- Copyright 2023 Patrick Moehrke
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-- Game menu source: https://love2d.org/forums/posting.php?mode=quote&f=3&p=226031&sid=e3c771a4c6dc4b423cb77c43dd589eb8

score = {}
score.cpu = 0
score.human = 0
score.max = 5

-- Possible game states: MENU, GAME, HOWTOPLAY, SETTINGS, GAMEOVER 
gameState = "MENU"

gameMenu = {"Start Game", "How to Play", "Settings", "Quit"}
selectedMenu = 1

fontHeight = 20
font = love.graphics.newFont("assets/retro.ttf", fontHeight)
sound = love.audio.newSource("assets/paddle.mp3", "static")

function love.load()
  -- check if game is over 
  if score.cpu > score.max or score.human > score.max then
    gameState = "GAMEOVER"
  else
    WIDTH, HEIGHT = love.graphics.getDimensions()
    LEFT = 45
    RIGHT = WIDTH - 5
    TOP = 25
    BOTTOM = HEIGHT - 75

    LEFTPADDLE = LEFT + 25
    RIGHTPADDLE = RIGHT - 25

    -- game ball
    ball = createBall(5)

    -- ai
    rightPaddle = createPaddle(1)
    -- human
    leftPaddle = createPaddle(2)
  end
end

function createBall(r)
  b = {}
  b.x = WIDTH/2
  b.y = HEIGHT/2
  b.radius = r
  b.speed = 120
  b.directionX = 0.8
  b.directionY = 0.9
  b.colourR = randomInt(255) 
  b.colourG = randomInt(255) 
  b.colourB = randomInt(255) 
  return b
end

function createPaddle(opp)
  paddle = {}
  paddle.height = 75
  paddle.width = 10
  paddle.speed = 120
  paddle.direction = 1
  paddle.y = HEIGHT/2
  if opp == 1 then
    paddle.x = RIGHTPADDLE
  else
    paddle.x = LEFTPADDLE
  end
  return paddle
end

function randomInt(n)
  return math.floor(math.random()*n) + 1
end

function checkCollision(ba, pa)
  local dx = ba.x - pa.x 
  local dy = ba.y - pa.y 
  return (pa.x - (pa.height / 2) < dx) and (pa.x + (pa.height / 2) > dx) and (pa.y - (pa.width / 2) < dy) and (pa.y +(pa.width / 2) > dy)
  
end

function love.update(dt)
  local function moveBall()
    ball.x = ball.x + ball.directionX * ball.speed * dt
    ball.y = ball.y + ball.directionY * ball.speed * dt

    -- Right wall
    if ball.x >= RIGHTPADDLE then
      score.cpu = score.cpu + 1
      love.load()
      -- Left wall
    elseif ball.x <= LEFTPADDLE then
      score.human = score.human + 1
      love.load()
      -- Bottom wall
    elseif ball.y >= BOTTOM+45 then
      ball.directionY = -ball.directionY 
      ball.y = BOTTOM+45 - 1
      -- Top wall
    elseif ball.y <= TOP then
      ball.directionY = -ball.directionY 
      ball.y = TOP + 1
      -- Left paddle
    elseif ball.x <= (LEFTPADDLE+5) and ball.y <= (leftPaddle.y+leftPaddle.height-2) and ball.y >= (leftPaddle.y-leftPaddle.height+20) and ball.directionX < 0 then
    --elseif checkCollision(ball, paddle) then
    ball.directionX = -ball.directionX 
    ball.colourR = randomInt(255)
    ball.colourG = randomInt(255) 
    ball.colourB = randomInt(255)
    sound:play()
      -- Right paddle
    elseif ball.x >= (RIGHTPADDLE-5) and ball.y <= (rightPaddle.y+rightPaddle.height-2) and ball.y >= (rightPaddle.y-rightPaddle.height+20) and ball.directionX > 0 then
    ball.directionX = -ball.directionX 
    ball.colourR = randomInt(255)
    ball.colourG = randomInt(255) 
    ball.colourB = randomInt(255)
    sound:play()
    end	

  end

  local function movePaddle(p)
    p.y = p.y + p.speed * p.direction * dt
    if p.y <= TOP or p.y >= BOTTOM-5 then
      p.direction = -p.direction
    end
  end

  if gameState == "GAME" then
    moveBall()
    movePaddle(rightPaddle)
    movePaddle(leftPaddle)
  end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  if gameState == "GAME" then
    if x > WIDTH/2 then
      rightPaddle.direction = -rightPaddle.direction
    else
      leftPaddle.direction = -leftPaddle.direction
    end
  elseif gameState == "MENU" then
    -- click menu items
    gameState = "GAME"
  elseif gameState == "GAMEOVER" then
    --if x > 0 then
    love.event.quit()
    --end
  end
end

function love.draw()
  love.graphics.setFont(font)
  if gameState == "MENU" or gameState == "RETRY" then
    drawMenu()
  elseif gameState == "HOWTOPLAY" then
    drawHowToPlay()
  elseif gameState == "SETTINGS" then
    drawSettings()
  elseif gameState == "GAME" then
    drawGame()
  elseif gameState == "GAMEOVER" then 
    drawGameOver()
  end
end

function drawGameOver()
  local gameOverMessage = ""
  love.graphics.printf("GAME OVER", WIDTH/2, HEIGHT, HEIGHT, "center", 1.5*math.pi)
  love.graphics.printf("FINAL SCORE: "..score.cpu.."-"..score.human, fontHeight+WIDTH/2, HEIGHT, HEIGHT, "center", 1.5*math.pi)
  if score.cpu > score.human then
    gameOverMessage = "YOU LOSE!"
  elseif score.cpu < score.human then
    gameOverMessage = "YOU WIN!"
  else 
    gameOverMessage = "DRAW!"
  end
  love.graphics.printf(gameOverMessage, (2*fontHeight)+WIDTH/2, HEIGHT, HEIGHT, "center", 1.5*math.pi)
  love.graphics.printf("RETRY?", (4*fontHeight)+WIDTH/2, HEIGHT, HEIGHT, "center", 1.5*math.pi)
  love.graphics.printf("QUIT", (5*fontHeight)+WIDTH/2, HEIGHT, HEIGHT, "center", 1.5*math.pi)
end

function drawMenu()
  -- Game menu
  local horizonalCentre = WIDTH/2
  local verticalCentre = HEIGHT/2
  local startX = horizonalCentre - (fontHeight*(#gameMenu / 2))

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("PONG", -(3*fontHeight)+WIDTH/2, HEIGHT, HEIGHT, "center", 1.5*math.pi)

  -- draw menu items
  for i = 1, #gameMenu do
    if i == selectedMenu then 
    -- colour yellow
      love.graphics.setColor(1, 1, 0, 1)
    else
    -- colour white
      love.graphics.setColor(1, 1, 1, 1)
    end
    -- draw menu item
    love.graphics.printf(gameMenu[i], (i*fontHeight)+WIDTH/2, HEIGHT, HEIGHT, "center", 1.5*math.pi)
  end
end

function drawHowToPlay()
  -- How to play
end

function drawSettings()
  -- Game settings
end

function drawGame()
  -- Score board
  love.graphics.printf(score.cpu.."-"..score.human, WIDTH/2, HEIGHT, HEIGHT, "center", 1.5*math.pi)
  love.graphics.line(WIDTH/2, 0, WIDTH/2, HEIGHT)

  -- Game ball
  love.graphics.setColor(love.math.colorFromBytes(ball.colourR, ball.colourB, ball.colourG))
  love.graphics.circle("fill", ball.x, ball.y, ball.radius)

  -- Paddles
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", leftPaddle.x, leftPaddle.y, leftPaddle.width, leftPaddle.height)
  love.graphics.rectangle("fill", rightPaddle.x, rightPaddle.y, rightPaddle.width, rightPaddle.height)
end
