neuralNetwork = {}

function neuralNetwork.load()
    local screenWidth, screenHeight = love.graphics.getDimensions()

    local inputCount = 1
    local hiddenCount = 240
    local outputCount = 400

    local inputSpacing = screenHeight / (inputCount + 1)
    local hiddenSpacing = screenHeight / (hiddenCount / 3 + 1)
    local outputSpacing = screenHeight / (outputCount + 1)

    local inputX = screenWidth * 0.2
    local hiddenX1 = screenWidth * 0.4
    local hiddenX2 = screenWidth * 0.5
    local hiddenX3 = screenWidth * 0.6
    local outputX = screenWidth * 0.8

    neuralNetwork.layers = {
        input = {},
        hidden = {},
        output = {}
    }

    for i = 1, inputCount do
        table.insert(neuralNetwork.layers.input, { x = inputX, y = i * inputSpacing })
    end

    for i = 1, hiddenCount / 3 do
        table.insert(neuralNetwork.layers.hidden, { x = hiddenX1, y = i * hiddenSpacing })
    end
    for i = 1, hiddenCount / 3 do
        table.insert(neuralNetwork.layers.hidden, { x = hiddenX2, y = i * hiddenSpacing })
    end
    for i = 1, hiddenCount / 3 do
        table.insert(neuralNetwork.layers.hidden, { x = hiddenX3, y = i * hiddenSpacing })
    end

    for i = 1, outputCount do
        table.insert(neuralNetwork.layers.output, { x = outputX, y = i * outputSpacing })
    end

    neuralNetwork.nodeSize = 10
    neuralNetwork.nodeColor = { 0, 1, 0 }
    neuralNetwork.connectionColor = { 1, 1, 1 }
    neuralNetwork.connectionWidth = 1

    neuralNetwork.weights = {
        inputToHidden = {},
        hiddenToOutput = {}
    }

    neuralNetwork.biases = {
        hidden = {},
        output = {}
    }

    math.randomseed(os.time())

    for i = 1, inputCount do
        neuralNetwork.weights.inputToHidden[i] = {}
        for j = 1, hiddenCount do
            neuralNetwork.weights.inputToHidden[i][j] = math.random() * 1 - 0.8
        end
    end

    for i = 1, hiddenCount do
        neuralNetwork.biases.hidden[i] = math.random() * 1 - 0.3
        neuralNetwork.weights.hiddenToOutput[i] = {}
        for j = 1, outputCount do
            neuralNetwork.weights.hiddenToOutput[i][j] = math.random() * 1 - 0.5
        end
    end

    for i = 1, outputCount do
        neuralNetwork.biases.output[i] = math.random() * 1 - 0.5
    end

    neuralNetwork.inputs = {}
    for i = 1, inputCount do
        table.insert(neuralNetwork.inputs, math.random())
    end

    neuralNetwork.outputs = {}
    for i = 1, outputCount do
        neuralNetwork.outputs[i] = 0
    end

    neuralNetwork.timer = 0 
end

function neuralNetwork.randomizeInputs()
    for i = 1, #neuralNetwork.inputs do
        neuralNetwork.inputs[i] = math.random()
    end
end

function neuralNetwork.forwardPass()
    local hiddenValues = {}

    for j = 1, #neuralNetwork.biases.hidden do
        hiddenValues[j] = neuralNetwork.biases.hidden[j]
        for i = 1, #neuralNetwork.inputs do
            hiddenValues[j] = hiddenValues[j] + neuralNetwork.inputs[i] * neuralNetwork.weights.inputToHidden[i][j]
        end
        hiddenValues[j] = math.max(0, hiddenValues[j])
    end

    for k = 1, #neuralNetwork.biases.output do
        neuralNetwork.outputs[k] = neuralNetwork.biases.output[k]
        for j = 1, #hiddenValues do
            neuralNetwork.outputs[k] = neuralNetwork.outputs[k] + hiddenValues[j] * neuralNetwork.weights.hiddenToOutput[j][k]
        end
        neuralNetwork.outputs[k] = 1 / (1 + math.exp(-neuralNetwork.outputs[k]))
    end
end

function neuralNetwork.update(dt)
    neuralNetwork.timer = neuralNetwork.timer + dt 

    if neuralNetwork.timer >= 10 then
        neuralNetwork.randomizeInputs() 
        neuralNetwork.forwardPass() 
        neuralNetwork.timer = 0
    end

    neuralNetwork.forwardPass() 
end

function neuralNetwork.draw()
    local layerNames = { "input", "hidden", "output" }

    for i = 1, #layerNames - 1 do
        local currentLayer = neuralNetwork.layers[layerNames[i]]
        local nextLayer = neuralNetwork.layers[layerNames[i + 1]]
        for _, node1 in ipairs(currentLayer) do
            for _, node2 in ipairs(nextLayer) do
                love.graphics.setColor(unpack(neuralNetwork.connectionColor))
                love.graphics.setLineWidth(neuralNetwork.connectionWidth)
                love.graphics.line(node1.x, node1.y + 100, node2.x, node2.y + 100)
            end
        end
    end

    
    for _, layer in pairs(neuralNetwork.layers) do
        for _, node in ipairs(layer) do
            love.graphics.setColor(unpack(neuralNetwork.nodeColor))
            love.graphics.circle("fill", node.x, node.y + 100, neuralNetwork.nodeSize)
        end
    end

    
    local input = neuralNetwork.inputs[1]
    local closestOutputIndex = 1
    local closestDifference = math.abs(input - neuralNetwork.outputs[1])

    for i = 2, #neuralNetwork.outputs do
        local difference = math.abs(input - neuralNetwork.outputs[i])
        if difference < closestDifference then
            closestDifference = difference
            closestOutputIndex = i
        end
    end

    
    if math.abs(closestDifference) < 1e-6 then
        closestDifference = 0
    end

    
    local accuracy = math.max(0, (1 - closestDifference) * 100)



    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Input: %.2f", input), 10, 30)
    love.graphics.print(string.format("Closest Output: %d (%.2f)", closestOutputIndex, neuralNetwork.outputs[closestOutputIndex]), 10, 50)
    love.graphics.print(string.format("Confidence: %.2f%%", accuracy), 10, 70)
end

return neuralNetwork
