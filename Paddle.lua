local Class = require 'lib.hump.class'

---@class Paddle
local Paddle = Class {}

---@param x number
---@param y number
---@param width number
---@param height number
---@param controller table<string, string>
function Paddle:init(x, y, width, height, controller)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.speed = 180
  self.up = controller.up
  self.down = controller.down
end

---@param dt number
function Paddle:update(dt)
  self.y = love.keyboard.isDown(self.up) and self.y - self.speed * dt or self.y
  self.y = love.keyboard.isDown(self.down) and self.y + self.speed * dt or self.y

  -- keep paddle in screen
  self.y = self.y + self.height > VIRTUAL_HEIGHT and VIRTUAL_HEIGHT - self.height or self.y
  self.y = self.y > 0 and self.y or 0
end

function Paddle:draw()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

return Paddle
