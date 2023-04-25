-- Author: Patrick Moehrke
-- License: MIT
-- Copyright 2023 Patrick Moehrke
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

score = {}
score.cpu = 0
score.human = 0
score.max = 4

font = love.graphics.newFont("assets/retro.ttf", 20)

sound = love.audio.newSource("assets/paddle.mp3", "static")

function love.load()
  WIDTH, HEIGHT = love.graphics.getDimensions()
  LEFT = 35
  RIGHT = WIDTH - 5
  TOP = 35
  BOTTOM = HEIGHT - 5

  LEFTPADDLE = LEFT + 5
  RIGHTPADDLE = RIGHT - 5

  math.randomseed(os.time())
  listOfCircles = {}
  createCircle()
  -- ai
  rightPaddle = createPaddle(1)
  -- human
  leftPaddle = createPaddle(2)
end

function createCircle()
  circ = {}
  circ.x = WIDTH/2
  circ.y = HEIGHT/2
  circ.radius = 5
  circ.speed = 120
  circ.directionX = 0.8
  circ.directionY = 0.9
  circ.colourR = randomInt(255) 
  circ.colourG = randomInt(255) 
  circ.colourB = randomInt(255) 
  table.insert(listOfCircles, circ)
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
  local function moveCircle()
    for i, v in ipairs(listOfCircles) do
      v.x = v.x + v.directionX * v.speed * dt
      v.y = v.y + v.directionY * v.speed * dt
	-- Right wall
      if v.x >= RIGHT then
	score.cpu = score.cpu + 1
	love.load()
	-- Left wall
      elseif v.x <= LEFT then
	score.human = score.human + 1
	love.load()
	-- Bottom wall
      elseif v.y >= BOTTOM then
	v.directionY = -v.directionY 
	v.y = BOTTOM - 1
	-- Top wall
      elseif v.y <= TOP then
	v.directionY = -v.directionY 
	v.y = TOP + 1
	-- Left paddle
      elseif v.x <= (LEFTPADDLE+5) and v.y <= (leftPaddle.y+leftPaddle.height-7) and v.y >= (leftPaddle.y-leftPaddle.height+20) and v.directionX < 0 then
	v.directionX = -v.directionX 
	v.x = LEFTPADDLE + 10
	v.colourR = randomInt(255) 
	v.colourG = randomInt(255) 
	v.colourB = randomInt(255) 
	sound:play()
	-- Right paddle
      elseif v.x >= (RIGHTPADDLE-5) and v.y <= (rightPaddle.y+rightPaddle.height-7) and v.y >= (rightPaddle.y-rightPaddle.height+20) and v.directionX > 0 then
	v.directionX = -v.directionX 
	v.x = RIGHTPADDLE - 10
	v.colourR = randomInt(255) 
	v.colourG = randomInt(255) 
	v.colourB = randomInt(255) 
	sound:play()
      end	
    end
  end
  local function movePaddle(p)
      p.y = p.y + p.speed * p.direction * dt
      if p.y <= TOP or p.y >= (BOTTOM - 40) then
	p.direction = -p.direction
      end
  end
  moveCircle()
  movePaddle(rightPaddle)
  movePaddle(leftPaddle)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  if x > WIDTH/2 then
    rightPaddle.direction = -rightPaddle.direction
  else
    leftPaddle.direction = -leftPaddle.direction
  end
end

function love.draw()
  love.graphics.setFont(font)
  love.graphics.print(score.cpu.."-"..score.human, WIDTH/2, 40+HEIGHT/2, 1.5*math.pi)
  love.graphics.line(WIDTH/2, 0, WIDTH/2, HEIGHT)
  for i, v in ipairs(listOfCircles) do
    love.graphics.setColor(love.math.colorFromBytes(v.colourR, v.colourB, v.colourG))
    love.graphics.circle("fill", v.x, v.y, v.radius)
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", leftPaddle.x, leftPaddle.y, leftPaddle.width, leftPaddle.height)
  love.graphics.rectangle("fill", rightPaddle.x, rightPaddle.y, rightPaddle.width, rightPaddle.height)
  if score.cpu > score.max or score.human > score.max then
    love.graphics.print("GAME OVER", 20+WIDTH/2, 50+HEIGHT/2, 1.5*math.pi)
    love.timer.sleep(1)
    love.event.quit()
  end
end
