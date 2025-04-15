local Concord = require("libraries.concord")

local Position = Concord.component("position", function(e, x, y)
    e.x = x or 0
    e.y = y or 0
end)

return Position
