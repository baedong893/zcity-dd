local MODE = MODE

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

local fighter = {
	objectiveKey = "objective_wizard_survive",
	nameKey = "role_wizard",
	color1 = Color(120, 80, 255)
}

local revealColor = Color(255, 45, 45)

function MODE:PostDrawTranslucentRenderables()
end

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

	draw.SimpleText(T("mode_name_harrypotter", "Harry Potter") .. " | " .. T("mode_name_dm", "Deathmatch"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0, 162, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T("common_your_role_spaced", "Your role: ") .. T(fighter.nameKey, "Wizard"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, colorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T(fighter.objectiveKey, "Survive with magic until the end."), "ZB_HomicideMedium", sw * 0.5, sh * 0.9, colorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("PreDrawHalos", "ZCityHarryPotterRevealPlayers", function()
	local round = CurrentRound and CurrentRound()
	if not round or round.name ~= "harrypotter" then return end
	if (zb.ROUND_START or CurTime()) + (round.RevealDelay or 150) > CurTime() then return end

	local playersToReveal = {}
	for _, ply in player.Iterator() do
		if ply ~= LocalPlayer() and ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
			playersToReveal[#playersToReveal + 1] = ply
		end
	end

	if #playersToReveal > 0 then
		halo.Add(playersToReveal, revealColor, 2, 2, 1, true, true)
	end
end)
