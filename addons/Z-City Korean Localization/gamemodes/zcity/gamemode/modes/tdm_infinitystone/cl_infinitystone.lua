local MODE = MODE

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

local stoneMarkerColors = {
	[1] = {name = "SOUL", color = Color(255, 140, 40), core = Color(255, 220, 120)},
	[2] = {name = "REALITY", color = Color(220, 45, 55), core = Color(255, 145, 145)},
	[3] = {name = "SPACE", color = Color(45, 110, 255), core = Color(135, 205, 255)},
	[4] = {name = "POWER", color = Color(160, 70, 255), core = Color(95, 180, 255)},
	[5] = {name = "TIME", color = Color(45, 220, 95), core = Color(165, 255, 185)},
	[6] = {name = "MIND", color = Color(255, 215, 45), core = Color(255, 245, 150)},
}
local powerStonePos
local stonePositions = {}
local infinityStartSoundPath = "zcity/infinitystone/FINE-I_LL-DO-IT-MYSELF.wav"
local lastInfinityStartSoundKey

local function IsInfinityStoneRound()
	local round = CurrentRound()
	return round and round.name == "infinitystone"
end

local function PlayInfinityStartSound()
	if not IsInfinityStoneRound() then return end

	local soundKey = zb.ROUND_START or 0
	if lastInfinityStartSoundKey == soundKey then return end

	lastInfinityStartSoundKey = soundKey
	surface.PlaySound(infinityStartSoundPath)
end

net.Receive("ZCityInfinityPowerStonePos", function()
	local hasPosition = net.ReadBool()
	powerStonePos = hasPosition and net.ReadVector() or nil
end)

net.Receive("ZCityInfinityStonePositions", function()
	stonePositions = {}

	local count = net.ReadUInt(4)
	for _ = 1, count do
		local id = net.ReadUInt(4)
		stonePositions[id] = net.ReadVector()
	end
end)

net.Receive("ZCityInfinityStartSound", function()
	PlayInfinityStartSound()
end)

function MODE:PreDrawHalos()
end

function MODE:PostDrawTranslucentRenderables()
end

function MODE:HUDPaint()
	local startTime = zb.ROUND_START or CurTime()

	if startTime + 8 >= CurTime() then
		PlayInfinityStartSound()
	end

	if startTime + 8 >= CurTime() and LocalPlayer():Alive() then
		zb.RemoveFade()

		local fade = math.Clamp(startTime + 8 - CurTime(), 0, 1)
		draw.SimpleText(T("mode_name_infinitystone", "Infinity Stone"), "ZB_HomicideMediumLarge", ScrW() * 0.5, ScrH() * 0.1, Color(160, 70, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(T("mode_infinity_quote", "Fine. I'll do it myself."), "ZB_HomicideMediumLarge", ScrW() * 0.5, ScrH() * 0.5, Color(245, 245, 245, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local time = string.FormattedTime(math.max(startTime + (zb.ROUND_TIME or 240) - CurTime(), 0), "%02i:%02i:%02i")
	draw.SimpleText(time, "ZB_HomicideMedium", ScrW() * 0.5, ScrH() * 0.95, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "ZCityInfinityPowerStoneMarker", function()
	if not IsInfinityStoneRound() then return end

	if next(stonePositions) == nil and powerStonePos then
		stonePositions[4] = powerStonePos
	end

	for id, pos in pairs(stonePositions) do
		if not isvector(pos) then continue end

		local screenPos = (pos + Vector(0, 0, 32)):ToScreen()
		if not screenPos.visible then continue end

		local marker = stoneMarkerColors[id] or stoneMarkerColors[4]
		local x = math.Clamp(screenPos.x, 34, ScrW() - 34)
		local y = math.Clamp(screenPos.y, 34, ScrH() - 34)
		local pulse = 0.75 + math.sin(CurTime() * 5 + id) * 0.25
		local size = 18 + 8 * pulse

		surface.SetDrawColor(marker.color.r, marker.color.g, marker.color.b, 220)
		surface.DrawOutlinedRect(x - size * 0.5, y - size * 0.5, size, size, 2)

		surface.SetDrawColor(marker.core.r, marker.core.g, marker.core.b, 180)
		surface.DrawRect(x - 3, y - size, 6, size * 2)
		surface.DrawRect(x - size, y - 3, size * 2, 6)

		draw.SimpleText(marker.name, "DermaDefaultBold", x, y + size + 8, marker.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end)
