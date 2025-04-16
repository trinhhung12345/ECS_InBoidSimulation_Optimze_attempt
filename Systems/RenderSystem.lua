local Concord = require("libraries.concord")

local RenderSystem = Concord.system({
  pool = {"position", "velocity", "boid"}
})

function RenderSystem:init()
  -- Tối đa số boid bạn sẽ có (để cấp phát mesh)
  local maxBoids = 1000

  -- Định nghĩa vertex format: position (float2) + color (byte4)
  local vertexFormat = {
    {"VertexPosition", "float", 2},
    {"VertexColor",    "byte",  4},
  }

  -- Tạo Mesh dynamic với đủ 3 đỉnh cho mỗi boid
  -- newMesh(vertexformat, vertexcount, mode, usage)
  self.mesh = love.graphics.newMesh(vertexFormat, maxBoids * 3, "triangles", "dynamic")
end

function RenderSystem:draw()
  local verts = {}
  local pool  = self.pool
  local cos, sin = math.cos, math.sin

  for i = 1, #pool do
    local e = pool[i]
    local x, y = e.position.x, e.position.y
    -- Nếu đã tính sẵn angle trong update thì dùng e.boid.angle
    local angle = e.boid.angle or math.atan2(e.velocity.dy, e.velocity.dx)
    local s     = e.boid.size  or 5

    local c  = cos(angle)
    local sn = sin(angle)

    -- Tính 3 đỉnh tam giác (rotate + translate)
    local x1 = x + (-s) * c - (-s/2) * sn
    local y1 = y + (-s) * sn + (-s/2) * c
    local x2 = x + (-s) * c - ( s/2) * sn
    local y2 = y + (-s) * sn + ( s/2) * c
    local x3 = x + ( s) * c
    local y3 = y + ( s) * sn

    -- Thêm 3 vertex: {x, y, r, g, b, a}
    verts[#verts+1] = { x1, y1, 255,255,255,255 }
    verts[#verts+1] = { x2, y2, 255,255,255,255 }
    verts[#verts+1] = { x3, y3, 255,255,255,255 }
  end

  -- Cập nhật toàn bộ vertices cùng lúc
  self.mesh:setVertices(verts)
  -- Chỉ vẽ đến vertex cuối cùng, tránh tam giác rác
  self.mesh:setDrawRange(1, #verts)

  -- 1 draw call duy nhất
  love.graphics.draw(self.mesh)
end

return RenderSystem
