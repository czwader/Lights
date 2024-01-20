-- Taken from relisoft_core https://github.com/Isigar/relisoft_core/blob/master/client/v2/native/marker.lua

local lights = {}
local nearLights = {}

CreateThread(function()
    while true do 
        Wait(config.checkPlayerPosition)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for i, self in pairs(lights) do 
            local distance = #(coords - self.coord)
            if distance < config.nearObjectDistance then
                nearLights[self.id] = self
            else
                self.rendering = false
                lights[i] = self
                nearLights[self.id] = nil
            end
        end
    end

end)

CreateThread(function()
    while true do 
        Wait(1000)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for i, self in pairs(nearLights) do 
            local distance = #(coords - self.coord)
            if self.night then 
                local hour = GetClockHours()
                
                if distance < self.renderDist and not self.stopRendering and hour >= self.nightVar or hour <= self.dayVar then 
                    self.rendering = true
                else
                    self.rendering = false
                end
            else
                if distance < self.renderDist and not self.stopRendering then 
                    self.rendering = true
                else
                    self.rendering = false
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        local sleep = true
        
        for i,self in pairs(nearLights) do  
            if self.rendering and not self.destroyed then       
                DrawLightWithRangeAndShadow(
                    self.coord, self.color.r, self.color.g, self.color.b,
                    self.range, self.intensity, self.shadow
                )
                sleep = false
            end
        end
        if sleep then 
            Wait(1000)  
        end
    end
end)

function createLight(res)
    local self = {}
    self.id = tableLength(lights)+1
    self.resource = res 
    self.coord = vector3(0,0,0)
    self.renderDist = 20
    self.rendering = false
    self.stopRendering = false
    self.nightVar = 20
    self.dayVar = 6
    self.color = {
        r = 255,
        g = 255,
        b = 255,
    }
    self.range = 0
    self.intensity = 0
    self.shadow = 0
    self.night = false

    self.setId = function(param)
        self.id = param
        self.update()
    end

    self.getId = function()
        return self.id
    end

    self.setCoord = function(param)
        self.coord = param
        self.update()
        return self
    end

    self.setRenderDist = function(param)
        self.renderDist = param
        self.update()
        return self
    end

    self.render = function(param)
        self.rendering = true 
        self.stopRendering = false
        self.firstUpdate = false
        self.update()
    end

    self.stopRender = function(param)
        self.rendering = false 
        self.stopRendering = true
        self.update()
    end

    self.destroy = function()
        self.stopRendering = true
        self.rendering = false
        self.destroyed = true
        self.update(true)
    end

    self.isRendering = function()
        return self.rendering
    end
    
    self.setColor = function(param)
        self.color = param
        self.update()
    end

    self.setRange = function(param)
        self.range = param
    end

    self.setIntensity = function(param)
        self.intensity = param
    end

    self.setShadow = function(param)
        self.shadow = param
    end

    self.onlyNight = function(param)
        self.night = param
    end

    self.setNight = function(param)
        self.nightVar = param 
        self.update()
    end

    self.setDay = function(param)
        self.dayVar = param 
        self.update()
    end

    self.update = function(destroy)
        if self.firstUpdate then
            return
        end

        if destroy then
            for k,v in pairs(nearLights) do
                if v.getId() == self.getId() then
                    nearLights[k] = nil
                end
            end

            for k,v in pairs(lights) do
                if v.getId() == self.getId() then
                    lights[k] = nil
                end
            end
        else
            for k,v in pairs(lights) do
                if v.getId() == self.getId() then
                    lights[k] = v
                end
            end
        end
        
    end
    table.insert(lights, self)
        
    return self
end

AddEventHandler('onResourceStop', function(res)
    for k,v in pairs(lights) do
        if v.resource == res then
            v.destroy()
        end
    end
end)

function tableLength(tb)
    local count = 0
    if isTable(tb) then
        for _ in pairs(tb) do
            count = count + 1
        end
        return count
    end
    return nil
end

function isTable(table)
    if table ~= nil then
        if type(table) == "table" then
            return true
        end
        return false
    else
        return false
    end
end


exports('createLight', createLight)
