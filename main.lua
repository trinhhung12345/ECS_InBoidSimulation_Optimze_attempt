local ProFi = require("libraries.ProFi")
ProFi:start() -- Bắt đầu đo

local Concord = require("libraries.concord")
-- Tự động load các namespace của component và system
Concord.utils.loadNamespace("components")
Concord.utils.loadNamespace("systems")

-- Tạo world vật lý (physics world) với trọng lực = 0
-- local physicsWorld = love.physics.newWorld(0, 0)

-- Tạo Concord world và thêm các hệ thống
local world = Concord.world()
world:addSystems(
    require("systems.BoidSystem"),
    require("systems.BoundarySystem"),
    require("systems.MovementSystem"),
    require("systems.RenderSystem")
)

local NUM_BOIDS = 1000
local boids = {}
-- Global config cho boid
CONFIG = {
    boidSize = 8,
    alignWeight = 1.0,
    cohesionWeight = 0.8,
    separationWeight = 2.0,
    visualRange = 50,
    separationDistance = 30
}

function love.load()
    -- for i = 1, NUM_BOIDS do
    --     local x = math.random(50, love.graphics.getWidth()-50)
    --     local y = math.random(50, love.graphics.getHeight()-50)
    --     local angle = math.random() * 2 * math.pi
    --     local dx = math.cos(angle) * 50
    --     local dy = math.sin(angle) * 50

    --     -- Tạo entity boid với các component Position, Velocity, Boid
    --     local entity = Concord.entity(world)
    --         :give("position", x, y)
    --         :give("velocity", dx, dy)
    --         :give("boid", {visualRange = 50, maxSpeed = 100, maxForce = 50, separationDistance = 30})

    --     -- Tạo physics body cho boid (là một tam giác cân, đỉnh hướng lên trên)
    --     local body = love.physics.newBody(physicsWorld, x, y, "dynamic")
    --     body:setMass(1)
    --     local shape = love.physics.newPolygonShape(0, -10, -7, 10, 7, 10)  -- tam giác: đỉnh ở (0,-10)
    --     local fixture = love.physics.newFixture(body, shape)
    --     entity:give("physics", body, shape, fixture)
    --     table.insert(boids, entity)
    -- end
    for i = 1, NUM_BOIDS do
        local x = math.random(50, love.graphics.getWidth() - 50)
        local y = math.random(50, love.graphics.getHeight() - 50)
        local angle = math.random() * 2 * math.pi
        local dx = math.cos(angle) * 50
        local dy = math.sin(angle) * 50

        local entity = Concord.entity(world)
            :give("position", x, y)
            :give("velocity", dx, dy)
            :give("boid", {
                visualRange = CONFIG.visualRange,
                separationDistance = CONFIG.separationDistance,
                alignWeight = CONFIG.alignWeight,
                cohesionWeight = CONFIG.cohesionWeight,
                separationWeight = CONFIG.separationWeight,
                maxSpeed = 100,
                maxForce = 50,
                size = CONFIG.boidSize
            })

        table.insert(boids, entity)
    end
end

function love.update(dt)
    local startTime = love.timer.getTime()

    -- physicsWorld:update(dt)  -- cập nhật physics
    world:emit("update", dt) -- cập nhật hệ thống ECS

    local elapsedTime = love.timer.getTime() - startTime
    print(string.format("Thoi gian cap nhat frame: %.2f ms", elapsedTime * 1000))
end

function love.draw()
    -- Hiển thị giá trị hiện tại và phím điều khiển
    love.graphics.print(
        string.format(
            "Align: %.2f (1/2), Cohesion: %.2f (3/4), Separation: %.2f (5/6), Range: %d (7/8), Size: %d (9/0)",
            CONFIG.alignWeight,
            CONFIG.cohesionWeight,
            CONFIG.separationWeight,
            CONFIG.visualRange,
            CONFIG.boidSize
        ),
        10, 10
    )
    world:emit("draw")
end

function love.quit()
    ProFi:stop()
    ProFi:writeReport("profiling_report.txt")
    love.event.quit()
end

function love.keypressed(key)
    if key == "1" then
        CONFIG.alignWeight = CONFIG.alignWeight + 0.1
    elseif key == "2" then
        CONFIG.alignWeight = math.max(0, CONFIG.alignWeight - 0.1)
    elseif key == "3" then
        CONFIG.cohesionWeight = CONFIG.cohesionWeight + 0.1
    elseif key == "4" then
        CONFIG.cohesionWeight = math.max(0, CONFIG.cohesionWeight - 0.1)
    elseif key == "5" then
        CONFIG.separationWeight = CONFIG.separationWeight + 0.1
    elseif key == "6" then
        CONFIG.separationWeight = math.max(0, CONFIG.separationWeight - 0.1)
    elseif key == "7" then
        CONFIG.visualRange = CONFIG.visualRange + 10
    elseif key == "8" then
        CONFIG.visualRange = math.max(0, CONFIG.visualRange - 10)
    elseif key == "9" then
        CONFIG.boidSize = CONFIG.boidSize + 1
    elseif key == "0" then
        CONFIG.boidSize = math.max(1, CONFIG.boidSize - 1)
    end
    -- Cập nhật component boid cho tất cả entities
    for _, e in ipairs(boids) do
        e.boid.alignWeight = CONFIG.alignWeight
        e.boid.cohesionWeight = CONFIG.cohesionWeight
        e.boid.separationWeight = CONFIG.separationWeight
        e.boid.visualRange = CONFIG.visualRange
        e.boid.separationDistance = CONFIG.separationDistance
        e.boid.size = CONFIG.boidSize
    end
end
