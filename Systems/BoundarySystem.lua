local Concord = require("libraries.concord")
local BoundarySystem = Concord.system({
    pool = {"position", "velocity", "boid"}
})

function BoundarySystem:update(dt)
    local margin = 50  -- khoảng cách an toàn từ biên màn hình
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    for _, e in ipairs(self.pool) do
        local pos = e.position
        local vel = e.velocity
        local boid = e.boid
        local force = { x = 0, y = 0 }

        -- Kiểm tra theo trục X
        if pos.x < margin then
            force.x = (margin - pos.x) / margin * boid.maxForce
        elseif pos.x > screenW - margin then
            force.x = -((pos.x - (screenW - margin)) / margin * boid.maxForce)
        end

        -- Kiểm tra theo trục Y
        if pos.y < margin then
            force.y = (margin - pos.y) / margin * boid.maxForce
        elseif pos.y > screenH - margin then
            force.y = -((pos.y - (screenH - margin)) / margin * boid.maxForce)
        end

        -- Áp dụng lực tránh biên vào vận tốc của boid
        vel.dx = vel.dx + force.x * dt
        vel.dy = vel.dy + force.y * dt
    end
end

return BoundarySystem
