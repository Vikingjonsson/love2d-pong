if os.getenv('LOCAL_LUA_DEBUGGER_VSCODE') == '1' then
  require('lldebugger').start()
end

local push = require 'lib.push.push'
local Ball = require 'src.Ball'
local Paddle = require 'src.Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

local function rgba(red, green, blue, alpha)
  return red / 255, green / 255, blue / 255, alpha
end

local player1, player2, ball
local small_font, score_font
local players = {}
local sounds = {}
local scores = {
  p1 = 0,
  p2 = 0
}

STATES = {
  PLAY = 'play',
  START = 'start',
  SERVE = 'serve',
  DONE = 'done'
}

GAME_STATE = STATES.START

local serving_player = 1

function love.load()
  math.randomseed(os.time())
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle('Pong!')
  small_font = love.graphics.newFont('assets/font/8bit16.ttf', 8)
  score_font = love.graphics.newFont('assets/font/8bit16.ttf', 32)

  sounds = {
    paddle_hit = love.audio.newSource('assets/sounds/paddle_hit.wav', 'static'),
    score = love.audio.newSource('assets/sounds/score.wav', 'static'),
    wall_hit = love.audio.newSource('assets/sounds/wall_hit.wav', 'static')
  }

  ---@type Ball
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
  ---@type Paddle
  player1 = Paddle(10, 30, 5, 20, {up = 'w', down = 's'})
  ---@type Paddle
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20, {up = 'o', down = 'l'})
  ---@type Paddle[]
  players = {player1, player2}

  push:setupScreen(
    VIRTUAL_WIDTH,
    VIRTUAL_HEIGHT,
    WINDOW_WIDTH,
    WINDOW_HEIGHT,
    {
      fullscreen = false,
      resizable = false,
      vsync = true,
      highdpi = true
    }
  )
end

function love.update(dt)
  if GAME_STATE == STATES.SERVE then
    ball:reset()

    ball.dy = math.random(-50, 50)
    if serving_player == 1 then
      ball.dx = math.random(140, 200)
    else
      ball.dx = -math.random(140, 200)
    end
  end

  player1:update(dt)
  player2:update(dt)

  if GAME_STATE == STATES.PLAY then
    ball:update(dt)

    if ball.x > VIRTUAL_WIDTH then
      scores.p1 = scores.p1 + 1

      if scores.p1 == 10 then
        GAME_STATE = STATES.DONE
      else
        GAME_STATE = STATES.SERVE
      end
    end

    if ball.x + ball.width < 0 then
      scores.p2 = scores.p2 + 1

      if scores.p2 == 10 then
        GAME_STATE = STATES.DONE
      else
        GAME_STATE = STATES.SERVE
      end
    end

    for index, player in ipairs(players) do
      if ball:on_collision(player) then
        sounds.paddle_hit:play()
        ball.x = index == 1 and player.x + player.width or player.x - ball.width
        ball.dx = -ball.dx * 1.05
      end
    end
  end
end

function love.draw()
  push:start()
  love.graphics.clear(rgba(40, 45, 52, 1))

  -- game play
  player1:draw()
  player2:draw()
  ball:draw()

  -- HUD
  love.graphics.setFont(score_font)
  love.graphics.print(tostring(scores.p1), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(scores.p2), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

  love.graphics.setFont(small_font)
  if GAME_STATE == STATES.SERVE then
    love.graphics.printf('Player ' .. tostring(serving_player) .. ' ' .. GAME_STATE, 0, 20, VIRTUAL_WIDTH, 'center')
  elseif GAME_STATE == STATES.DONE then
    local winning_message = ''
    if scores.p1 == 10 then
      winning_message = 'Player 1 '
    else
      winning_message = 'Player 2'
    end

    love.graphics.printf(winning_message .. 'Wins', 0, 20, VIRTUAL_WIDTH, 'center')
  else
    love.graphics.printf(GAME_STATE, 0, 20, VIRTUAL_WIDTH, 'center')
  end

  push:finish()
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  if key == 'return' and GAME_STATE == STATES.START then
    GAME_STATE = STATES.SERVE
  elseif key == 'return' and GAME_STATE == STATES.SERVE then
    serving_player = serving_player == 1 and 2 or 1
    GAME_STATE = STATES.PLAY
  elseif key == 'return' and GAME_STATE == STATES.DONE then
    scores.p1 = 0
    scores.p2 = 0
    GAME_STATE = STATES.SERVE
  end
end
