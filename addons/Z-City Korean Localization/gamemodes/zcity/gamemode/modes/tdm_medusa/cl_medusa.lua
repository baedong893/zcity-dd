local MODE = MODE

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

local fighter = {
	objectiveKey = "objective_medusa_survive",
	nameKey = "role_medusa",
	color1 = Color(80, 200, 120)
}

function MODE:RenderScreenspaceEffects()
	if zb.ROUND_START + 7.5 < CurTime() then return end

	local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(), 0, 1)

	surface.SetDrawColor(0, 0, 0, 255 * fade)
	surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

function MODE:HUDPaint()
	if not lply:Alive() then return end
	if zb.ROUND_START + 8.5 < CurTime() then return end

	zb.RemoveFade()

	local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)
	local colorRole = Color(fighter.color1.r, fighter.color1.g, fighter.color1.b, 255 * fade)
	local colorObj = Color(fighter.color1.r, fighter.color1.g, fighter.color1.b, 255 * fade)

	draw.SimpleText(T("mode_name_medusa", "Medusa") .. " | " .. T("mode_name_dm", "Deathmatch"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0, 162, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T("common_your_role_spaced", "Your role: ") .. T(fighter.nameKey, "Medusa"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, colorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T(fighter.objectiveKey, "Petrify everyone and survive until the end."), "ZB_HomicideMedium", sw * 0.5, sh * 0.9, colorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
