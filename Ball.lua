local Class = require 'lib.hump.class'

--region Ball
---@class Ball
local Ball = Class {}

---@param a table<string, number>
---@param b table<string, number>
local function check_collision_AABB(a, b)
  if a.x < b.x + b.width and a.y < b.y + b.height and b.x < a.x + a.width and b.y < a.y + a.height then
    return true
  end
  return false
end

---@param x number
---@param y number
---@param width number
---@param height number
function Ball:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.dx = 0
  self.dy = 0
end

---@param dt number
function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt

  local touch_bottom = self.y + self.height > VIRTUAL_HEIGHT
  self.dy = touch_bottom and -self.dy or self.dy
  self.y = touch_bottom and VIRTUAL_HEIGHT - self.height or self.y

  local touched_top = self.y < 0
  self.dy = touched_top and -self.dy or self.dy
  self.y = touched_top and 0 or self.y
end

---@param collider Paddle
function Ball:on_collision(collider)
  return check_collision_AABB(self, collider)
end

function Ball:draw()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:reset()
  self.x = VIRTUAL_WIDTH / 2 - 2
  self.y = VIRTUAL_HEIGHT / 2 - 2
  self.dx = 0
  self.dy = 0
end

return Ball
--endregion Ball
