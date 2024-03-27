local lib_zones = lib.zones
local core = Framework.core
local polyzone = {
    pos = vector4(0),
    isNear = false,
    mods = nil,
    free = false,
}

local function checkVehicleClass(classes)
    local currentClass = GetVehicleClass(cache.vehicle)
    for k,v in ipairs(classes) do
        if currentClass == v then
            return true
        end
    end
    return false
end
---comment
local function isAllowed(group, job)
    local name = job.name
    local grade = group[name]
    return grade and grade <= job.grade.name
end

---@param custom {locData: vector4, mods: table<string, boolean>, group: table<string, number>}
local function onEnter(custom)
    local locData, mods, group, free, classes in custom
    if group and type(group) == 'table' then
        local playerData = core.getPlayerData()
        if not isAllowed(group, playerData.job) then return end
    end

    if classes and not checkVehicleClass(classes) then return end

    lib.showTextUI('[G] - Customs')
    polyzone.pos = locData
    polyzone.mods = mods
    polyzone.free = free
    polyzone.isNear = true
end

local function onExit()
    lib.hideTextUI()
    polyzone.pos = nil
    polyzone.isNear = false
end

CreateThread(function()
    local locations = require 'data.config'.locations
    for _, v in ipairs(locations) do
        local pos = v.pos
        local blip_data = v.blip

        lib_zones.box({
            coords = pos.xyz,
            size = vec3(8, 8, 6),
            rotation = pos.w,
            mods = v.mods,
            group = v.group,
            free = v.free,
            classes = v.classes,
            onEnter = onEnter,
            onExit = onExit,
            locData = vector4(pos.x, pos.y, pos.z, pos.w)
        })

        if blip_data then
            local sprite, scale, color, shortRange, label in blip_data
            local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
            SetBlipDisplay(blip, 4)
            SetBlipSprite(blip, sprite)
	    SetBlipScale(blip, scale)
            SetBlipColour(blip, color)
	    SetBlipAsShortRange(blip, shortRange or false)

            BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(label)
			EndTextCommandSetBlipName(blip)
        end
    end
end)

return polyzone
