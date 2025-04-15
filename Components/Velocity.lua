local Concord = require("libraries.concord")

local Velocity = Concord.component("velocity", function(e, dx, dy)
    e.dx = dx or 0
    e.dy = dy or 0
end)

return Velocity
