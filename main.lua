function love.load()
    local neuralNetwork = require("neuralNetwork")
    neuralNetwork.load()
    love.window.setTitle("Neural Network Visualization")
    fps = nil
end

function love.update(dt)
    neuralNetwork.update(dt)
    fps = love.timer.getFPS()
end

function love.draw()
    neuralNetwork.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. fps, 10, 10)
end