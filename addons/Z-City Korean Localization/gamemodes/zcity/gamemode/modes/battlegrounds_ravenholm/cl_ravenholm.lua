MODE.name = "ravenholm"
local MODE = MODE

-- Keep a single sound handle across Lua reloads, including waiting-room reselection.
zb.RavenholmIntroState = zb.RavenholmIntroState or {}
local playback = zb.RavenholmIntroState

local function StopIntro()
    if playback.sound then playback.sound:Stop() end
    playback.sound = nil
end

local function ResetIntro(key)
    StopIntro()
    table.Empty(playback)
    playback.key = key
end

local function IntroKey(mode, start)
    return GetGlobalString(mode.VariantNetworkKey, "") .. ":" .. start
end

local function ScreenDuration(variant)
    return variant.IntroScreenDuration or variant.IntroDuration
end

hook.Add("Think", "ZCityRavenholmIntro", function()
    local variant = CurrentRound() == MODE and MODE:GetVariant()
    local start = GetGlobalFloat(MODE.IntroNetworkKey, 0)
    if not variant or start <= 0 or zb.ROUND_STATE == 3 then
        if next(playback) then ResetIntro() end
        return
    end

    local key = IntroKey(MODE, start)
    if playback.key ~= key then ResetIntro(key) end
    local now = CurTime()
    if playback.startedAt then
        if now >= playback.endsAt then StopIntro() end
        return
    end
    -- Keep an expired intro silent on reconnect, but do not discard a live intro
    -- merely because mode/network initialization took more than 0.75 seconds.
    if now < start or now >= start + ScreenDuration(variant) then return end
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if now < (playback.nextFileCheck or 0) then return end
    playback.nextFileCheck = now + 0.25
    if not file.Exists("sound/" .. variant.IntroSound, "GAME") then
        if not playback.missingReported then
            ErrorNoHalt("[ZCity intro] Missing sound/" .. variant.IntroSound .. "; reconnect to download the intro sounds.\n")
            playback.missingReported = true
        end
        return
    end

    playback.sound = CreateSound(ply, variant.IntroSound)
    if not playback.sound then return end
    playback.startedAt = now
    playback.endsAt = now + variant.IntroDuration
    playback.screenEndsAt = now + ScreenDuration(variant)
    playback.sound:SetSoundLevel(0)
    playback.sound:PlayEx(1, 100)
end)

function MODE:DrawIntro()
    local variant = self:GetVariant()
    local start = GetGlobalFloat(self.IntroNetworkKey, 0)
    if not variant or start <= 0 or zb.ROUND_STATE == 3 then return end
    -- The full music continues into gameplay; only the title card uses the shorter duration.
    local endTime = playback.key == IntroKey(self, start) and playback.screenEndsAt or start + ScreenDuration(variant)
    local fade = math.max(
        math.Clamp((endTime + self.IntroFadeTime - CurTime()) / self.IntroFadeTime, 0, 1),
        math.Clamp(zb.fade or 0, 0, 1)
    )
    if fade <= 0 then return end
    local sw, sh = ScrW(), ScrH()
    local alpha = math.floor(255 * fade)
    surface.SetDrawColor(0, 0, 0, alpha)
    surface.DrawRect(0, 0, sw, sh)
    -- HUDPaint runs inside Z-City's custom RenderView with the correct 2D context.
    -- Keep the backdrop and briefing together, as in the other mode introductions.
    draw.SimpleText("ZBattle | " .. variant.PrintName, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1,
        Color(0, 162, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(variant.IntroSubtitle or "", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5,
        Color(235, 185, 55, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.DrawText(variant.IntroDescription or self:GetStartMessage(), "ZB_HomicideMedium", sw * 0.5, sh * 0.86,
        Color(235, 235, 235, alpha), TEXT_ALIGN_CENTER)
    return true
end

function MODE:PostDrawTranslucentRenderables()
end

function MODE:HUDPaint()
    if self:DrawIntro() then return end
    if zb.ROUND_STATE ~= 1 then return end
    local alive = GetGlobalInt(self.SurvivorCountNetworkKey, 0)
    local remaining = math.max((zb.ROUND_START or CurTime()) + (zb.ROUND_TIME or self.ROUND_TIME) - CurTime(), 0)
    draw.SimpleText(self:GetRoundPrintName(), "ZC_BG_Title", ScrW() * 0.5, ScrH() * 0.045,
        Color(235, 185, 55), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("생존 " .. alive .. "명  |  " .. string.FormattedTime(remaining, "%02i:%02i"),
        "ZC_BG_Info", ScrW() * 0.5, ScrH() * 0.078, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
