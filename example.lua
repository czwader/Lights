--use example separately in the script

-- config
config = {}

config.lights = {
    {
        coords = vector3(0,0,0),
        onlyNight = true,
        setNight = 20, --the hour when the light should start
        setDay = 6, --the hour when the light should be turned off
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

        local light = createLight(GetCurrentResourceName())
        light.render()
        light.setCoord(v.coords)
        light.onlyNight(v.onlyNight) --must be true to use setNight and setDay
        light.setNight(v.setNight)
        light.setDay(v.setDay)
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

createLight() --function that you put in the player/resource load event