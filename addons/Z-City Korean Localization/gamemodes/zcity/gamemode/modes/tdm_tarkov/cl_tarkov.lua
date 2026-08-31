MODE.name = "tarkov"
local MODE = MODE

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

local colors = {
	[0] = Color(205, 95, 55),
	[1] = Color(65, 145, 220),
	[2] = Color(205, 165, 65)
}

local scavArrivalDelay = MODE.ScavArrivalDelay or 180
local scavsArrived = false
local localScavBoss = false
local scavRoleUntil = 0
local roundEnded = false

surface.CreateFont("ZC_TarkovTimer", {
	font = "Bahnschrift",
	size = ScreenScale(12),
	extended = true,
	weight = 650,
	antialias = true
})

local function RoleInfo(teamId)
	if teamId == 0 then
		return T("role_bear", "BEAR"), T("mode_tarkov_bear_obj", "Eliminate USEC before SCAVs arrive."), colors[0]
	elseif teamId == 1 then
		return T("role_usec", "USEC"), T("mode_tarkov_usec_obj", "Eliminate BEAR before SCAVs arrive."), colors[1]
	elseif localScavBoss then
		return T("role_scav_boss", "SCAV Boss"), T("mode_tarkov_boss_obj", "Lead the SCAV team with your PKM."), Color(220, 75, 45)
	end

	return T("role_scav", "SCAV"), T("mode_tarkov_scav_obj", "Enter the area and eliminate the surviving PMCs."), colors[2]
end

net.Receive("zc_tarkov_start", function()
	scavArrivalDelay = net.ReadFloat()
	scavsArrived = false
	localScavBoss = false
	scavRoleUntil = 0
	roundEnded = false
	zb.RemoveFade()
	surface.PlaySound("buttons/button17.wav")
end)

net.Receive("zc_tarkov_scavs_arrived", function()
	local count = net.ReadUInt(5)
	local boss = net.ReadEntity()
	scavsArrived = true

	if count > 0 then
		chat.AddText(Color(205, 165, 65), T("mode_tarkov_scav_arrived", "SCAVs have entered the area."))
		if IsValid(boss) then
			chat.AddText(Color(220, 75, 45), T("mode_tarkov_boss_arrived", "A heavily armed SCAV boss is leading them."))
		end
	else
		chat.AddText(Color(150, 150, 150), T("mode_tarkov_no_scavs", "No SCAV reinforcements were available."))
	end

	surface.PlaySound("ambient/alarms/warningbell1.wav")
end)

net.Receive("zc_tarkov_scav_role", function()
	localScavBoss = net.ReadBool()
	scavRoleUntil = CurTime() + 8
	zb.RemoveFade()
end)

net.Receive("zc_tarkov_end", function()
	net.ReadInt(4)
	roundEnded = true
	scavRoleUntil = 0
end)

function MODE:RenderScreenspaceEffects()
	local startTime = zb.ROUND_START or CurTime()
	local opening = math.max(startTime + 7.5 - CurTime(), 0)
	local scavOpening = math.max(scavRoleUntil - CurTime(), 0)
	local fade = math.Clamp(math.max(opening, scavOpening), 0, 1)
	if fade <= 0 then return end

	surface.SetDrawColor(0, 0, 0, 255 * fade)
	surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

function MODE:HUDPaint()
	if roundEnded then return end

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local startTime = zb.ROUND_START or CurTime()
	local now = CurTime()
	local arrivalTime = startTime + scavArrivalDelay
	local sw, sh = ScrW(), ScrH()

	surface.SetFont("ZC_TarkovTimer")
	local timerText
	local timerColor
	if not scavsArrived and now < arrivalTime then
		timerText = T("mode_tarkov_scav_timer", "SCAV arrival: ") .. string.FormattedTime(math.max(arrivalTime - now, 0), "%02i:%02i")
		timerColor = Color(220, 220, 220)
	else
		local roundTime = MODE.ROUND_TIME or 360
		local timeLeft = string.FormattedTime(math.max(startTime + roundTime - now, 0), "%02i:%02i")
		timerText = T("mode_tarkov_scav_active", "SCAVs are in the area: ") .. timeLeft
		timerColor = Color(220, 165, 65)
	end
	draw.SimpleText(timerText, "ZC_TarkovTimer", sw * 0.5, sh * 0.055, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local showOpening = now < startTime + 8 or now < scavRoleUntil
	if not showOpening or not ply:Alive() then return end

	zb.RemoveFade()
	local roleName, objective, roleColor = RoleInfo(ply:Team())
	local fade = math.Clamp(math.max(startTime + 8 - now, scavRoleUntil - now), 0, 1)
	local titleColor = Color(0, 162, 255, 255 * fade)
	local activeRoleColor = Color(roleColor.r, roleColor.g, roleColor.b, 255 * fade)

	draw.SimpleText("ZBattle | " .. T("mode_name_tarkov", "Tarkov Raid"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T("common_your_role", "Your role: ") .. roleName, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, activeRoleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, activeRoleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
