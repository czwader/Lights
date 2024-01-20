--use example separately in the script

-- config
config = {}

config.lights = {
    {
        coords = vector3(0,0,0),
        onlyNight = true,
        renderDistance = 50,
        color = {
            r = 255,
            g = 0,
            b = 0
        },
        range = 50.0,
        intensity = 1.0
        shadow = 10.0
    }
}


-- client script
local lights = {}

function createLight()
    for k, v in pairs(config.lights) do
        if lights[k] ~= nil then
            pcall(lights[k].destroy)
        end

        local light = exports["Lights"]:createLight(GetCurrentResourceName())
        light.render()
        light.setCoord(v.coords)
        light.onlyNight(v.onlyNight)
        light.setRenderDist(v.renderDistance)
        light.setColor(v.color)
        light.setRange(v.range)
        light.setIntensity(v.intensity)
        light.setShadow(v.shadow)

        lights[k] = light
    end
end

function stopRenderAllLights()
    for k, light in pairs(lights) do
        light.stopRender() -- just call once and not every tick!
    end
end

function renderAllLights()
    for k, light in pairs(lights) do
        light.render() -- just call once and not every tick!
    end
end


RegisterCommand("lightRender", function()
    renderAllLights()
end)

RegisterCommand("lightStopRender", function()
    stopRenderAllLights()
end)

createLight() --function that you put in the player load event
