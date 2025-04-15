local Concord = require("libraries.concord")

local BoidSystem = Concord.system({
  pool = {"position", "velocity", "boid"}
})

function BoidSystem:update(dt)
  local entities = self.pool
  local screenW = love.graphics.getWidth()
  local screenH = love.graphics.getHeight()
  if #entities == 0 then return end

  -- Pre-calculate parameters
  local firstBoid = entities[1].boid
  local cellSize = firstBoid.visualRange
  local vr2 = cellSize * cellSize
  local sepDist2 = firstBoid.separationDistance * firstBoid.separationDistance

  -- Build spatial partitioning grid
  local partitions = {}
  for _, e in ipairs(entities) do
    local cx = math.floor(e.position.x / cellSize)
    local cy = math.floor(e.position.y / cellSize)
    local key = cx .. "_" .. cy
    if not partitions[key] then partitions[key] = {} end
    table.insert(partitions[key], e)
  end

  -- Process each boid
  for _, e in ipairs(entities) do
    local pos = e.position
    local vel = e.velocity
    local boid = e.boid

    -- Local accumulators
    local ax, ay = 0, 0
    local cx_sum, cy_sum = 0, 0
    local sx, sy = 0, 0
    local total = 0

    -- Determine cell of current boid
    local baseCx = math.floor(pos.x / cellSize)
    local baseCy = math.floor(pos.y / cellSize)

    -- Check neighbors in adjacent cells
    for dx = -1, 1 do
      for dy = -1, 1 do
        local cell = partitions[(baseCx + dx) .. "_" .. (baseCy + dy)]
        if cell then
          for _, other in ipairs(cell) do
            if other ~= e then
              local ox, oy = other.position.x, other.position.y
              local dx_ = ox - pos.x
              local dy_ = oy - pos.y
              local dist2 = dx_*dx_ + dy_*dy_
              if dist2 < vr2 then
                -- Alignment
                ax = ax + other.velocity.dx
                ay = ay + other.velocity.dy
                -- Cohesion
                cx_sum = cx_sum + ox
                cy_sum = cy_sum + oy
                -- Separation
                if dist2 < sepDist2 and dist2 > 0 then
                  local invD = 1 / math.sqrt(dist2)
                  sx = sx + (pos.x - ox) * invD
                  sy = sy + (pos.y - oy) * invD
                end
                total = total + 1
              end
            end
          end
        end
      end
    end

    if total > 0 then
      -- Compute alignment force
      ax, ay = ax/total, ay/total
      local magA = math.sqrt(ax*ax + ay*ay)
      if magA > 0 then
        ax = (ax/magA) * boid.maxSpeed - vel.dx
        ay = (ay/magA) * boid.maxSpeed - vel.dy
      end

      -- Compute cohesion force
      cx_sum = (cx_sum/total - pos.x)
      cy_sum = (cy_sum/total - pos.y)
      local magC = math.sqrt(cx_sum*cx_sum + cy_sum*cy_sum)
      if magC > 0 then
        cx_sum = (cx_sum/magC) * boid.maxSpeed - vel.dx
        cy_sum = (cy_sum/magC) * boid.maxSpeed - vel.dy
      end

      -- Compute separation force
      local magS = math.sqrt(sx*sx + sy*sy)
      if magS > 0 then
        sx = (sx/magS) * boid.maxSpeed - vel.dx
        sy = (sy/magS) * boid.maxSpeed - vel.dy
      end

      -- Combine forces with weights
      local wa = boid.alignWeight or 1.0
      local wc = boid.cohesionWeight or 0.8
      local ws = boid.separationWeight or 2.0
      local steerX = ax * wa + cx_sum * wc + sx * ws
      local steerY = ay * wa + cy_sum * wc + sy * ws

      -- Border avoidance
      local margin, turnF = 50, boid.maxForce
      if pos.x < margin then steerX = steerX + ((margin - pos.x)/margin) * turnF end
      if pos.x > screenW - margin then steerX = steerX - ((pos.x - (screenW - margin))/margin) * turnF end
      if pos.y < margin then steerY = steerY + ((margin - pos.y)/margin) * turnF end
      if pos.y > screenH - margin then steerY = steerY - ((pos.y - (screenH - margin))/margin) * turnF end

      -- Limit force magnitude
      local steerMag = math.sqrt(steerX*steerX + steerY*steerY)
      if steerMag > boid.maxForce then
        steerX = (steerX/steerMag) * boid.maxForce
        steerY = (steerY/steerMag) * boid.maxForce
      end

      -- Update velocity
      vel.dx = vel.dx + steerX * dt
      vel.dy = vel.dy + steerY * dt

      -- Limit speed
      local speed = math.sqrt(vel.dx*vel.dx + vel.dy*vel.dy)
      if speed > boid.maxSpeed then
        vel.dx = (vel.dx/speed) * boid.maxSpeed
        vel.dy = (vel.dy/speed) * boid.maxSpeed
      end
    end
  end
end

return BoidSystem