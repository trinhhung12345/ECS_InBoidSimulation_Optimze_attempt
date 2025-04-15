local Concord = require("libraries.concord")

local MovementSystem = Concord.system({
  pool = {"position", "velocity"}
})

function MovementSystem:update(dt)
  for _, e in ipairs(self.pool) do
    -- Cập nhật trực tiếp position mà không qua physics
    e.position.x = e.position.x + e.velocity.dx * dt
    e.position.y = e.position.y + e.velocity.dy * dt
  end
end

return MovementSystem

