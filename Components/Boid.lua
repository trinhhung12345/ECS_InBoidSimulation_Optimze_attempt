local Concord = require("libraries.concord")

local Boid = Concord.component("boid", function(e, params)
    e.visualRange = params.visualRange or 50
    e.maxSpeed = params.maxSpeed or 100
    e.maxForce = params.maxForce or 90
    e.separationDistance = params.separationDistance or 120
end)

return Boid
