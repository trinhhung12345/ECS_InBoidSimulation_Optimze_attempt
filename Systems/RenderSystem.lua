local Concord = require("libraries.concord")

local RenderSystem = Concord.system({
  pool = {"position", "velocity", "boid"}
})

function RenderSystem:draw()
  for _, e in ipairs(self.pool) do
    local x, y = e.position.x, e.position.y
    local angle = math.atan2(e.velocity.dy, e.velocity.dx)

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)

    local s = e.boid.size or 5
    -- Vẽ tam giác boid
    love.graphics.polygon("fill",
      -s, -s/2,
      -s,  s/2,
       s,    0
    )
    love.graphics.pop()
  end
end

return RenderSystem
