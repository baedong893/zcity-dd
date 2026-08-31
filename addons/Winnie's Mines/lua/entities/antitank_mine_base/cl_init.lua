include("shared.lua")

function ENT:Draw() self:DrawModel() end
local startTime = 0
local time = 0
local blurTime = 3

local function calColorBrightness(a, x_time, st_time)
    return a * (st_time - x_time) + (a * a)
end

hook.Add("RenderScreenspaceEffects", "MineExplosionBlur", function()
    local colorBrightness = calColorBrightness(blurTime, time, startTime)
    if not LocalPlayer():Alive() or startTime + blurTime <= SysTime() then return end

    time = SysTime()

    local tab = {
    ["$pp_colour_addr"]         = colorBrightness / (10 * blurTime),--(startTime - time + blurTime) / 5,
    ["$pp_colour_addg"]         = 0,
    ["$pp_colour_addb"]         = 0,
    ["$pp_colour_brightness"]   = -colorBrightness / (2 * blurTime),
    ["$pp_colour_contrast"]     = 1,
    ["$pp_colour_colour"]       = 1,
    ["$pp_colour_mulr"]         = 0.5,
    ["$pp_colour_mulg"]         = 0,
    ["$pp_colour_mulb"]         = 0}

    DrawColorModify(tab)
    DrawMotionBlur(0.7, 0.8, (startTime - time + blurTime) / (blurTime * 10)) 
end)

net.Receive("MineExplosionBlur_net", function()
    startTime = SysTime()
    LocalPlayer():SetDSP(35, false)
end)