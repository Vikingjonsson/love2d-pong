local Class = require 'lib.hump.class'
local constants = require 'src.constants'

--region Ball
---@class Ball
local Ball = Class {}

---@tparam a table<string, number> representing a rectangle
---@tparam b table<string, number> representing a rectangle
---@return boolean result true if collision has happened otherwise false
local function check_collision_AABB(a, b)
  local has_collision = a.x < b.x + b.width and a.y < b.y + b.height and b.x < a.x + a.width and b.y < a.y + a.height
  return has_collision
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

  local TOUCHED_TOP = self.y < 0
  local TOUCH_BOTTOM = self.y + self.height > constants.VIRTUAL_HEIGHT

  self.dy = TOUCH_BOTTOM and -self.dy or self.dy
  self.dy = TOUCHED_TOP and -self.dy or self.dy
end

---@tparam collider table<string, number> representing a rectangle
---@return boolean result true if collision has happened otherwise false
function Ball:on_collision(collider)
  return check_collision_AABB(self, collider)
end

---Draw ball
function Ball:draw()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

---Reset the ball's state
function Ball:reset()
  self.x = constants.VIRTUAL_WIDTH / 2 - 2
  self.y = constants.VIRTUAL_HEIGHT / 2 - 2
  self.dx = 0
  self.dy = 0
end

return Ball
--endregion Ball
