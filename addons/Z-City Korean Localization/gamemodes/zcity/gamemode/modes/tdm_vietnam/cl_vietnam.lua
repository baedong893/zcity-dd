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

local abilityRequestNet = "ZCityVietnamUseAbility"
local reconNet = "ZCityVietnamRecon"
local reconUntil = 0
local abilityColors = {
	[0] = Color(125, 45, 30, 190),
	[1] = Color(35, 85, 145, 190)
}
local abilitySelectedColors = {
	[0] = Color(220, 90, 55, 220),
	[1] = Color(75, 155, 235, 220)
}

local function IsVietnamRound()
	return zb and (zb.CROUND_MAIN == MODE.name or zb.CROUND == MODE.name)
end

local function GetTeamCooldownKey(teamId, abilityId)
	return "ZCityVietnamTeamCooldown_" .. teamId .. "_" .. abilityId
end

local function GetAbilityCooldown(ply, abilityId, ability)
	if ability.SharedTeamCooldown then
		return math.max(GetGlobalFloat(GetTeamCooldownKey(ply:Team(), abilityId), 0) - CurTime(), 0)
	end

	return math.max(ply:GetNWFloat("ZCityVietnamCooldown_" .. abilityId, 0) - CurTime(), 0)
end

local function BuildAbilityLabel(ply, abilityId, ability)
	local label = ability.Name .. "\n" .. ability.Description
	local cooldown = GetAbilityCooldown(ply, abilityId, ability)

	if abilityId == "ambush" then
		local duration = istable(ability.Duration) and ability.Duration[ply:Team()] or ability.Duration
		label = ability.Name .. " " .. tostring(duration or 0) .. "초\n" .. ability.Description
	elseif abilityId == "tunnel" then
		local tunnelEnd = ply:GetNWFloat("ZCityVietnamTunnelEnd", 0)
		if tunnelEnd > CurTime() then
			label = ability.Name .. "\n건설 완료까지 " .. string.format("%.1f초", tunnelEnd - CurTime())
		end
	end

	if cooldown > 0 then
		label = label .. "\n쿨타임 " .. math.ceil(cooldown) .. "초"
	end

	return label, cooldown
end


function MODE:HG_GetRadialMenuOverride(ply)
	if not IsVietnamRound() or not IsValid(ply) or not ply:Alive() or ply:Team() == TEAM_SPECTATOR then return end
	if ply.organism and ply.organism.otrub then return end

	local abilityIds = MODE.TeamAbilities and MODE.TeamAbilities[ply:Team()]
	if not istable(abilityIds) then return end

	local options = {}
	for _, abilityId in ipairs(abilityIds) do
		local ability = MODE.Abilities and MODE.Abilities[abilityId]
		if not ability or not ability.Teams or not ability.Teams[ply:Team()] then continue end

		local label, cooldown = BuildAbilityLabel(ply, abilityId, ability)
		options[#options + 1] = {
			function()
				if cooldown > 0 then
					chat.AddText(Color(235, 180, 70), ability.Name .. " 재사용까지 " .. math.ceil(cooldown) .. "초 남았습니다.")
					return
				end

				net.Start(abilityRequestNet)
					net.WriteString(abilityId)
				net.SendToServer()
			end,
			label,
			nil,
			nil,
			nil,
			abilityColors[ply:Team()],
			abilitySelectedColors[ply:Team()]
		}
	end

	return options
end


net.Receive(reconNet, function()
	reconUntil = math.max(reconUntil, CurTime() + net.ReadFloat())
end)

function MODE:PreDrawHalos()
	if reconUntil <= CurTime() or not IsVietnamRound() then return end

	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() or ply:Team() ~= 1 then return end

	local targets = {}
	for _, enemy in player.Iterator() do
		if enemy == ply or not enemy:Alive() or enemy:Team() == TEAM_SPECTATOR or enemy:Team() == ply:Team() then continue end

		local target = hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(enemy) or enemy
		if IsValid(target) then targets[#targets + 1] = target end
	end

	if #targets > 0 then
		halo.Add(targets, Color(235, 55, 40), 2, 2, 1, true, true)
	end
end

local function GetAmbushSoundOwner(ent)
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return ent end
	if not ent.GetOwner then return end

	local owner = ent:GetOwner()
	return IsValid(owner) and owner:IsPlayer() and owner or nil
end

function MODE:EntityEmitSound(soundData)
	local owner = GetAmbushSoundOwner(soundData.Entity)
	if IsValid(owner) and owner:GetNWBool("ZCityVietnamAmbush", false) then return false end
end

function MODE:HUDPaint()
	self:AddHudPaint()

	local startTime = zb.ROUND_START or CurTime()
	local sw, sh = ScrW(), ScrH()
	local time = string.FormattedTime(math.max(startTime + (zb.ROUND_TIME or 300) - CurTime(), 0), "%02i:%02i:%02i")
	local fade = math.Clamp(startTime + 8 - CurTime(), 0, 1)
	local teamData = teams[LocalPlayer():Team()] or teams[0]

	draw.SimpleText(time, "ZB_HomicideMedium", sw * 0.5, sh * 0.95, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local tunnelEnd = LocalPlayer():GetNWFloat("ZCityVietnamTunnelEnd", 0)
	local ambushEnd = LocalPlayer():GetNWFloat("ZCityVietnamAmbushEnd", 0)
	if tunnelEnd > CurTime() then
		draw.SimpleText("땅굴망 건설 완료까지 " .. string.format("%.1f초", tunnelEnd - CurTime()), "ZB_HomicideMedium", sw * 0.5, sh * 0.88, Color(205, 175, 105), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif ambushEnd > CurTime() then
		draw.SimpleText("매복 " .. string.format("%.1f초", ambushEnd - CurTime()), "ZB_HomicideMedium", sw * 0.5, sh * 0.88, Color(180, 215, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if fade <= 0 or not LocalPlayer():Alive() then return end

	draw.SimpleText(T("mode_name_vietnam", "Vietnam War"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.12, Color(235, 230, 210, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T("mode_team_prefix", "Your team: ") .. T(teamData.nameKey, teamData.name), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, Color(teamData.color.r, teamData.color.g, teamData.color.b, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T(teamData.objectiveKey, teamData.objective), "ZB_HomicideMedium", sw * 0.5, sh * 0.78, Color(230, 230, 230, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
