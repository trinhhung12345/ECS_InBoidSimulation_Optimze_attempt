local Concord = require("libraries.concord")

local Physics = Concord.component("physics", function(e, body, shape, fixture)
    e.body = body
    e.shape = shape
    e.fixture = fixture
end)

return Physics
