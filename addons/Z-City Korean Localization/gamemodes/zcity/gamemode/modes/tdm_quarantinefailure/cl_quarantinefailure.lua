local MODE = MODE

local REPORTED_COLOR = Color(255, 45, 45)
local PHONE_AIM_COLOR = Color(45, 255, 105)

local ROLE_DATA = {
	carrier = {name = "qf_role_carrier", fallback = "최초 감염원", objective = "qf_objective_carrier", objectiveFallback = "바이오볼을 먹거나 던져 모든 생존자를 감염시키세요.", color = Color(220, 65, 65)},
	doctor = {name = "qf_role_doctor", fallback = "의사", objective = "qf_objective_doctor", objectiveFallback = "단 하나의 치료제로 감염자를 구하세요.", color = Color(75, 225, 145)},
	soldier = {name = "qf_role_soldier", fallback = "격리군", objective = "qf_objective_soldier", objectiveFallback = "시민의 신고를 확인하고 감염자를 저지하세요.", color = Color(75, 155, 255)},
	citizen = {name = "qf_role_citizen", fallback = "시민", objective = "qf_objective_citizen", objectiveFallback = "휴대폰으로 수상한 사람을 신고하고 살아남으세요.", color = Color(205, 205, 205)},
	infected = {name = "qf_role_infected", fallback = "감염자", objective = "qf_objective_infected", objectiveFallback = "생존자를 공격해 감염을 퍼뜨리세요.", color = Color(125, 225, 70)}
}

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

local function IsQuarantineRound()
	local round = CurrentRound and CurrentRound()
	return round and round.name == "quarantinefailure"
end

local function LocalRole()
	local ply = LocalPlayer()
	return IsValid(ply) and ply:GetNWString("ZC_QuarantineRole", "") or ""
end

function MODE:PreDrawHalos()
	if not IsQuarantineRound() then return end

	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return end
	local role = LocalRole()

	if role == "soldier" then
		local targets = {}
		for _, target in player.Iterator() do
			if target ~= ply and target:Alive() and target:GetNWBool("ZC_QuarantineReported", false) then
				targets[#targets + 1] = target
			end
		end

		if #targets > 0 then halo.Add(targets, REPORTED_COLOR, 3, 3, 2, true, true) end
	elseif role == "citizen" and not ply:GetNWBool("ZC_QuarantineReporting", false) then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == self.PhoneWeapon and wep.FindReportTarget then
			local target = wep:FindReportTarget(ply)
			if IsValid(target) and target ~= ply and target:Alive() and target:GetNWString("ZC_QuarantineRole", "") ~= "soldier" and not target:GetNWBool("ZC_QuarantineReported", false) then
				halo.Add({target}, PHONE_AIM_COLOR, 2, 2, 1, true, true)
			end
		end
	end
end

function MODE:PostDrawTranslucentRenderables()
end

function MODE:RenderScreenspaceEffects()
	if not IsQuarantineRound() then return end
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local state = ply:GetNWString("ZC_QuarantineInfectionState", "healthy")
	if state == "exposed" then
		DrawColorModify({
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0.025,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = -0.02,
			["$pp_colour_contrast"] = 1.05,
			["$pp_colour_colour"] = 0.85,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0.08,
			["$pp_colour_mulb"] = 0
		})
	elseif state == "infected" then
		DrawColorModify({
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0.035,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = -0.04,
			["$pp_colour_contrast"] = 1.12,
			["$pp_colour_colour"] = 0.65,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0.12,
			["$pp_colour_mulb"] = 0
		})
	end
end

function MODE:HUDPaint()
	if not IsQuarantineRound() then return end
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local sw, sh = ScrW(), ScrH()
	local role = LocalRole()
	local roleData = ROLE_DATA[role] or ROLE_DATA.citizen
	local fade = math.Clamp(1 - (CurTime() - (ROUND_START or 0)) / 8, 0, 1)

	if fade > 0 and role ~= "" then
		draw.SimpleText(T("mode_name_quarantinefailure", "Containment Failure"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(105, 225, 95, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(T("common_your_role", "Your role: ") .. T(roleData.name, roleData.fallback), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, Color(roleData.color.r, roleData.color.g, roleData.color.b, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(T(roleData.objective, roleData.objectiveFallback), "ZB_HomicideMedium", sw * 0.5, sh * 0.88, Color(235, 235, 235, 235 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if ply:GetNWString("ZC_QuarantineInfectionState", "healthy") == "exposed" then
		local remaining = math.max(math.ceil(ply:GetNWFloat("ZC_QuarantineConversionTime", 0) - CurTime()), 0)
		draw.SimpleText(T("qf_infection_countdown", "변이까지: ") .. remaining, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.72, Color(155, 255, 85), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function MODE:RoundStart()
end

function MODE:EndRound()
end
