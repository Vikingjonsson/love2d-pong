Ball = Class {}

local function checkCollisionAABB(a, b)
  if a.x < b.x + b.width and a.y < b.y + b.height and b.x < a.x + a.width and b.y < a.y + a.height then
    return true
  end
  return false
end

function Ball:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.dx = 0
  self.dy = 0
end

function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt

  local touchedBottomEade = self.y + self.height > VIRTUAL_HEIGHT
  self.dy = touchedBottomEade and -self.dy or self.dy
  self.y = touchedBottomEade and VIRTUAL_HEIGHT - self.height or self.y

  local touchedTopEdge = self.y < 0
  self.dy = touchedTopEdge and -self.dy or self.dy
  self.y = touchedTopEdge and 0 or self.y
end

function Ball:onCollision(collider)
  return checkCollisionAABB(self, collider)
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
