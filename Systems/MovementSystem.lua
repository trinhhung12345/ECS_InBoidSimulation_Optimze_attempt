local Concord = require("libraries.concord")

local MovementSystem = Concord.system({
  pool = {"position", "velocity"}
})

function MovementSystem:update(dt)
  for _, e in ipairs(self.pool) do
    -- Cập nhật trực tiếp position mà không qua physics
    local speed = CONFIG.speedMultiplier or 1.0
    e.position.x = e.position.x + e.velocity.dx * dt * speed
    e.position.y = e.position.y + e.velocity.dy * dt * speed
  end
end

return MovementSystem

