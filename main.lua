if os.getenv('LOCAL_LUA_DEBUGGER_VSCODE') == '1' then
  require('lldebugger').start()
end

local push = require 'lib.push.push'
local Ball = require 'src.Ball'
local Paddle = require 'src.Paddle'
local constants = require 'src.constants'

local function rgba(red, green, blue, alpha)
  return red / 255, green / 255, blue / 255, alpha
end



local STATES = {
  PLAY = 'play',
  START = 'start',
  SERVE = 'serve',
  DONE = 'done'
}
local MAX_SCORE = 10
local small_font, score_font
local game_state = STATES.START
local serving_player = 1
local player1, player2, ball
local players = {}
local sounds = {}
local scores = {
  p1 = 0,
  p2 = 0
}

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
  ball = Ball(constants.VIRTUAL_WIDTH / 2 - 2, constants.VIRTUAL_HEIGHT / 2 - 2, 4, 4)
  ---@type Paddle
  player1 = Paddle(10, 30, 5, 20, {up = 'w', down = 's'})
  ---@type Paddle
  player2 = Paddle(constants.VIRTUAL_WIDTH - 10, constants.VIRTUAL_HEIGHT - 50, 5, 20, {up = 'o', down = 'l'})
  ---@type Paddle[]
  players = {player1, player2}

  push:setupScreen(
    constants.VIRTUAL_WIDTH,
    constants.VIRTUAL_HEIGHT,
    constants.WINDOW_WIDTH,
    constants.WINDOW_HEIGHT,
    {
      fullscreen = false,
      resizable = false,
      vsync = true,
      highdpi = true
    }
  )
end

function love.update(dt)
  if game_state == STATES.SERVE then
    ball:reset()
    ball.dy = math.random(-50, 50)
    local HORIZONTAL_SPEED = math.random(140, 200)
    ball.dx = serving_player == 1 and HORIZONTAL_SPEED or -HORIZONTAL_SPEED
  end

  player1:update(dt)
  player2:update(dt)

  if game_state == STATES.PLAY then
    ball:update(dt)

    if ball.x > constants.VIRTUAL_WIDTH then
      scores.p1 = scores.p1 + 1
      game_state = scores.p1 == MAX_SCORE and STATES.DONE or STATES.SERVE
    end

    if ball.x + ball.width < 0 then
      scores.p2 = scores.p2 + 1
      game_state = scores.p2 == MAX_SCORE and STATES.DONE or STATES.SERVE
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
  love.graphics.print(tostring(scores.p1), constants.VIRTUAL_WIDTH / 2 - 50, constants.VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(scores.p2), constants.VIRTUAL_WIDTH / 2 + 30, constants.VIRTUAL_HEIGHT / 3)
  love.graphics.setFont(small_font)

  if game_state == STATES.SERVE then
    love.graphics.printf(
      'Player ' .. tostring(serving_player) .. ' ' .. game_state,
      0,
      20,
      constants.VIRTUAL_WIDTH,
      'center'
    )
  end

  if game_state == STATES.DONE then
    local winning_message = scores.p1 == MAX_SCORE and 'Player 1' or 'Player 2'
    love.graphics.printf(winning_message .. 'Wins', 0, 20, constants.VIRTUAL_WIDTH, 'center')
  end

  if game_state ~= STATES.DONE and game_state ~= STATES.SERVE then
    love.graphics.printf(game_state, 0, 20, constants.VIRTUAL_WIDTH, 'center')
  end

  push:finish()
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  local KEY_RETURN = 'return'
  if key == KEY_RETURN and game_state == STATES.DONE then
    scores.p1 = 0
    scores.p2 = 0
    game_state = STATES.SERVE
  end

  if key == KEY_RETURN and game_state == STATES.SERVE then
    serving_player = serving_player == 1 and 2 or 1
    game_state = STATES.PLAY
  end

  if key == KEY_RETURN and game_state == STATES.START then
    game_state = STATES.SERVE
  end

end
