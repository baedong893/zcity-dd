MODE.name = "battlegrounds"
local MODE = MODE

local GLOBAL_PREFIX = "ZC_BG_"
local safeZoneMaterial = Material("hmcd_dmzone")
local redZoneMaterial = Material("cable/redlaser")
local redZonePoints = {}
local redZoneCacheCenter = vector_origin
local redZoneCacheRadius = -1

surface.CreateFont("ZC_BG_Title", {
	font = "Bahnschrift",
	size = ScreenScale(12),
	extended = true,
	weight = 700,
	antialias = true
})

surface.CreateFont("ZC_BG_Info", {
	font = "Bahnschrift",
	size = ScreenScale(8),
	extended = true,
	weight = 600,
	antialias = true
})

local function HorizontalDistance(a, b)
	local x = a.x - b.x
	local y = a.y - b.y
	return math.sqrt(x * x + y * y)
end

local function AliveCount()
	local count = 0
	for _, ply in player.Iterator() do
		if ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and not (ply.organism and ply.organism.incapacitated) then
			count = count + 1
		end
	end
	return count
end

local function RebuildRedZonePoints(center, radius)
	redZonePoints = {}
	redZoneCacheCenter = center
	redZoneCacheRadius = radius

	for index = 0, 47 do
		local angle = math.pi * 2 * index / 48
		local sample = center + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 0)
		local trace = util.TraceLine({
			start = sample + Vector(0, 0, 1536),
			endpos = sample - Vector(0, 0, 3072),
			mask = MASK_SOLID_BRUSHONLY
		})
		redZonePoints[#redZonePoints + 1] = trace.Hit and trace.HitPos + trace.HitNormal * 3 or sample
	end
end

function MODE:PostDrawTranslucentRenderables(depth, skybox, drawingSkybox)
	if skybox or drawingSkybox then return end
	if not GetGlobalBool(GLOBAL_PREFIX .. "Active", false) then return end

	local safeCenter = GetGlobalVector(GLOBAL_PREFIX .. "Center", vector_origin)
	local safeRadius = GetGlobalFloat(GLOBAL_PREFIX .. "Radius", 0)
	if safeRadius > 0 then
		render.SetMaterial(safeZoneMaterial)
		render.DrawSphere(safeCenter, -safeRadius, 60, 60, color_white)
	end

	if not GetGlobalBool(GLOBAL_PREFIX .. "RedActive", false) then
		redZonePoints = {}
		redZoneCacheRadius = -1
		return
	end

	local center = GetGlobalVector(GLOBAL_PREFIX .. "RedCenter", vector_origin)
	local radius = GetGlobalFloat(GLOBAL_PREFIX .. "RedRadius", 0)
	if radius <= 0 then return end

	if #redZonePoints == 0 or redZoneCacheCenter:DistToSqr(center) > 1 or math.abs(redZoneCacheRadius - radius) > 0.1 then
		RebuildRedZonePoints(center, radius)
	end
	if #redZonePoints < 3 then return end

	local pulse = 0.65 + math.sin(CurTime() * 5) * 0.2
	render.SetMaterial(redZoneMaterial)
	for index, point in ipairs(redZonePoints) do
		local nextPoint = redZonePoints[index % #redZonePoints + 1]
		render.DrawBeam(point, nextPoint, 14, 0, 1, Color(255, 25, 15, 210 * pulse))
		render.DrawBeam(point + Vector(0, 0, 2), nextPoint + Vector(0, 0, 2), 3, 0, 1, Color(255, 180, 120, 240))
	end
end

function MODE:HUDPaint()
	if not GetGlobalBool(GLOBAL_PREFIX .. "Active", false) then return end
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local sw, sh = ScrW(), ScrH()
	local center = GetGlobalVector(GLOBAL_PREFIX .. "Center", vector_origin)
	local radius = GetGlobalFloat(GLOBAL_PREFIX .. "Radius", 0)
	local phase = GetGlobalInt(GLOBAL_PREFIX .. "Phase", 1)
	local phaseEnd = GetGlobalFloat(GLOBAL_PREFIX .. "PhaseEnd", 0)
	local shrinking = GetGlobalBool(GLOBAL_PREFIX .. "Shrinking", false)
	local timeLeft = math.max(phaseEnd - CurTime(), 0)
	local finalZone = phase > #(MODE.ZonePhases or {})
	local stateText = finalZone and "최종 자기장" or (shrinking and "자기장 축소" or "다음 자기장")

	draw.SimpleText("배틀그라운드", "ZC_BG_Title", sw * 0.5, sh * 0.045, Color(235, 185, 55), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	local timingText = finalZone and stateText or stateText .. " " .. string.FormattedTime(timeLeft, "%02i:%02i")
	draw.SimpleText("생존 " .. AliveCount() .. "명  |  " .. math.min(phase, #(MODE.ZonePhases or {})) .. "단계  |  " .. timingText, "ZC_BG_Info", sw * 0.5, sh * 0.078, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if ply:Alive() and radius > 0 then
		local distance = HorizontalDistance(ply:GetPos(), center)
		if distance > radius then
			local outside = math.ceil(distance - radius)
			surface.SetDrawColor(35, 95, 220, 35)
			surface.DrawRect(0, 0, sw, sh)
			draw.SimpleText("자기장 밖입니다 - 안전 구역까지 " .. outside .. "m", "ZC_BG_Title", sw * 0.5, sh * 0.16, Color(90, 165, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	if GetGlobalBool(GLOBAL_PREFIX .. "RedActive", false) then
		local redCenter = GetGlobalVector(GLOBAL_PREFIX .. "RedCenter", vector_origin)
		local redRadius = GetGlobalFloat(GLOBAL_PREFIX .. "RedRadius", 0)
		local redLeft = math.max(GetGlobalFloat(GLOBAL_PREFIX .. "RedEnd", 0) - CurTime(), 0)
		local bombardStart = GetGlobalFloat(GLOBAL_PREFIX .. "RedBombardStart", 0)
		local warningLeft = math.max(bombardStart - CurTime(), 0)
		local inRedZone = ply:Alive() and HorizontalDistance(ply:GetPos(), redCenter) <= redRadius
		local warning
		if warningLeft > 0 then
			warning = (inRedZone and "레드존 내부 - " or "레드존 - ") .. "폭격까지 " .. string.FormattedTime(warningLeft, "%02i:%02i")
		else
			warning = inRedZone and "레드존 내부 - 즉시 대피하십시오" or "레드존 폭격 " .. string.FormattedTime(redLeft, "%02i:%02i")
		end
		draw.SimpleText(warning, "ZC_BG_Info", sw * 0.5, sh * 0.115, inRedZone and Color(255, 45, 35) or Color(230, 105, 75), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local roundStart = zb.ROUND_BEGIN or CurTime()
	if ply:Alive() and CurTime() < roundStart + 8 then
		local alpha = math.Clamp((roundStart + 8 - CurTime()) * 80, 0, 255)
		draw.SimpleText("무기와 부속품을 파밍하고 최후의 한 명이 되십시오", "ZC_BG_Title", sw * 0.5, sh * 0.88, Color(235, 185, 55, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
