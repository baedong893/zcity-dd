local MODE = MODE

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

MODE.name = "vietnam"

local teams = {
	[0] = {
		name = "Viet Cong",
		nameKey = "role_viet_cong",
		objective = "Eliminate the US Army.",
		objectiveKey = "mode_vietnam_vc_obj",
		color = Color(190, 60, 45)
	},
	[1] = {
		name = "US Army",
		nameKey = "role_us_army",
		objective = "Eliminate the Viet Cong.",
		objectiveKey = "mode_vietnam_us_obj",
		color = Color(70, 140, 230)
	}
}

function MODE:HUDPaint()
	self:AddHudPaint()

	local startTime = zb.ROUND_START or CurTime()
	local sw, sh = ScrW(), ScrH()
	local time = string.FormattedTime(math.max(startTime + (zb.ROUND_TIME or 300) - CurTime(), 0), "%02i:%02i:%02i")
	local fade = math.Clamp(startTime + 8 - CurTime(), 0, 1)
	local teamData = teams[LocalPlayer():Team()] or teams[0]

	draw.SimpleText(time, "ZB_HomicideMedium", sw * 0.5, sh * 0.95, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if fade <= 0 or not LocalPlayer():Alive() then return end

	draw.SimpleText(T("mode_name_vietnam", "Vietnam War"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.12, Color(235, 230, 210, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T("mode_team_prefix", "Your team: ") .. T(teamData.nameKey, teamData.name), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, Color(teamData.color.r, teamData.color.g, teamData.color.b, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T(teamData.objectiveKey, teamData.objective), "ZB_HomicideMedium", sw * 0.5, sh * 0.78, Color(230, 230, 230, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
