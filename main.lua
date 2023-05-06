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
score.max = 0

-- Possible game states: MENU, GAME, HOWTOPLAY, SETTINGS, GAMEOVER 
gameState = "GAME"

gameMenu = {"Start Game", "How to Play", "Settings", "Quit"}
selectedMenu = 1

font = love.graphics.newFont("assets/retro.ttf", 20)
sound = love.audio.newSource("assets/paddle.mp3", "static")

function love.load()
  -- check if game is over 
  if score.cpu > score.max or score.human > score.max then
    gameState = "GAMEOVER"
  else
    WIDTH, HEIGHT = love.graphics.getDimensions()
    LEFT = 35
    RIGHT = WIDTH - 5
    TOP = 35
    BOTTOM = HEIGHT - 5

    LEFTPADDLE = LEFT + 5
    RIGHTPADDLE = RIGHT - 5

    FONTHEIGHT = font:getHeight()

    -- game ball
    ball = createBall()

    -- ai
    rightPaddle = createPaddle(1)
    -- human
    leftPaddle = createPaddle(2)
  end
end

function createBall()
  b = {}
  b.x = WIDTH/2
  b.y = HEIGHT/2
  b.radius = 5
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
  paddle.width = 5
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

function love.update(dt)
  local function moveBall()
    ball.x = ball.x + ball.directionX * ball.speed * dt
    ball.y = ball.y + ball.directionY * ball.speed * dt

    -- Right wall
    if ball.x >= RIGHT then
      score.cpu = score.cpu + 1
      love.load()
      -- Left wall
    elseif ball.x <= LEFT then
      score.human = score.human + 1
      love.load()
      -- Bottom wall
    elseif ball.y >= BOTTOM then
      ball.directionY = -ball.directionY 
      ball.y = BOTTOM - 1
      -- Top wall
    elseif ball.y <= TOP then
      ball.directionY = -ball.directionY 
      ball.y = TOP + 1
      -- Left paddle
    elseif ball.x <= (LEFTPADDLE+5) and ball.y <= (leftPaddle.y+leftPaddle.height-7) and ball.y >= (leftPaddle.y-leftPaddle.height+20) and ball.directionX < 0 then
      ball.directionX = -ball.directionX 
      ball.x = LEFTPADDLE + 10
      ball.colourR = randomInt(255) 
      ball.colourG = randomInt(255) 
      ball.colourB = randomInt(255) 
      sound:play()
      -- Right paddle
    elseif ball.x >= (RIGHTPADDLE-5) and ball.y <= (rightPaddle.y+rightPaddle.height-7) and ball.y >= (rightPaddle.y-rightPaddle.height+20) and ball.directionX > 0 then
      ball.directionX = -ball.directionX 
      ball.x = RIGHTPADDLE - 10
      ball.colourR = randomInt(255) 
      ball.colourG = randomInt(255) 
      ball.colourB = randomInt(255) 
      sound:play()
    end	
  end

  local function movePaddle(p)
    p.y = p.y + p.speed * p.direction * dt
    if p.y <= TOP or p.y >= (BOTTOM - 40) then
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
  elseif gameState == "GAMEOVER" then
    if x > 0 then
      love.event.quit()
    end
  end
end

function love.draw()
  love.graphics.setFont(font)
  if gameState == "MENU" then
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
  love.graphics.print("GAME OVER", WIDTH/2, 70+HEIGHT/2, 1.5*math.pi)
  love.graphics.print("FINAL SCORE", 20+WIDTH/2, 70+HEIGHT/2, 1.5*math.pi)
  love.graphics.print(score.cpu.."-"..score.human, 40+WIDTH/2, 70+HEIGHT/2, 1.5*math.pi)
  if score.cpu > score.human then
    gameOverMessage = "YOU LOSE"
  else
    gameOverMessage = "YOU WIN"
  end
  love.graphics.print(gameOverMessage, 60+WIDTH/2, 70+HEIGHT/2, 1.5*math.pi)
end

function drawMenu()
  -- Game menu
end

function drawHowToPlay()
  -- How to play
end

function drawSettings()
  -- Game settings
end

function drawGame()
  -- Score board
  love.graphics.print(score.cpu.."-"..score.human, WIDTH/2, 40+HEIGHT/2, 1.5*math.pi)
  love.graphics.line(WIDTH/2, 0, WIDTH/2, HEIGHT)

  -- Game ball
  love.graphics.setColor(love.math.colorFromBytes(ball.colourR, ball.colourB, ball.colourG))
  love.graphics.circle("fill", ball.x, ball.y, ball.radius)

  -- Paddles
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", leftPaddle.x, leftPaddle.y, leftPaddle.width, leftPaddle.height)
  love.graphics.rectangle("fill", rightPaddle.x, rightPaddle.y, rightPaddle.width, rightPaddle.height)
end
