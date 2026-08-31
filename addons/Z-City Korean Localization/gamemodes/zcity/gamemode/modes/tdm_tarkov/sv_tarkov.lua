local MODE = MODE

util.AddNetworkString("zc_tarkov_start")
util.AddNetworkString("zc_tarkov_scavs_arrived")
util.AddNetworkString("zc_tarkov_scav_role")
util.AddNetworkString("zc_tarkov_end")

local TEAM_BEAR = 0
local TEAM_USEC = 1
local TEAM_SCAV = 2

local teamNames = {
	[TEAM_BEAR] = "BEAR",
	[TEAM_USEC] = "USEC",
	[TEAM_SCAV] = "SCAV"
}

local teamColors = {
	[TEAM_BEAR] = Color(180, 75, 45),
	[TEAM_USEC] = Color(55, 135, 205),
	[TEAM_SCAV] = Color(180, 145, 55)
}

local primaryWeapons = {
	[TEAM_BEAR] = {"weapon_ak74", "weapon_akm", "weapon_rpk"},
	[TEAM_USEC] = {"weapon_m4a1", "weapon_m16a2", "weapon_mp5"}
}

local primaryFallbacks = {
	[TEAM_BEAR] = "weapon_akm",
	[TEAM_USEC] = "weapon_m4a1"
}

local secondaryWeapons = {
	[TEAM_BEAR] = {"weapon_glock17", "weapon_revolver2"},
	[TEAM_USEC] = {"weapon_hk_usp", "weapon_glock17"}
}

local scavWeapons = {
	"weapon_sks",
	"weapon_mosin",
	"weapon_ak74u",
	"weapon_doublebarrel",
	"weapon_mp5"
}

local scavSecondaryWeapons = {
	"weapon_glock17",
	"weapon_revolver2",
	"weapon_hk_usp"
}

local function CurrentModeIsTarkov()
	local round = CurrentRound and CurrentRound()
	return round and round.name == "tarkov"
end

local function GiveWeaponWithAmmo(ply, choices, fallback, spareMagazines)
	local class = istable(choices) and choices[math.random(#choices)] or choices
	if not class or not weapons.GetStored(class) then class = fallback end
	if not class or not weapons.GetStored(class) then return end

	local weapon = ply:Give(class)
	if not IsValid(weapon) then return end

	local clipSize = tonumber(weapon:GetMaxClip1()) or 0
	local ammoType = weapon:GetPrimaryAmmoType()
	if clipSize > 0 and ammoType and ammoType >= 0 then
		ply:GiveAmmo(clipSize * (spareMagazines or 2), ammoType, true)
	end

	return weapon
end

local function GiveCommonEquipment(ply)
	ply:Give("weapon_bandage_sh")
	ply:Give("weapon_tourniquet")
	ply:Give("weapon_fentanyl")

	local radio = ply:Give("weapon_walkie_talkie")
	if IsValid(radio) then
		if ply:Team() == TEAM_BEAR then
			radio.Frequency = 92.5
		elseif ply:Team() == TEAM_USEC then
			radio.Frequency = 104.5
		else
			radio.Frequency = 112.5
		end
	end

	ply:Give("weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")
	if ply.organism then ply.organism.allowholster = true end
end

local function PreparePlayer(ply)
	ply:SetSuppressPickupNotices(true)
	ply.noSound = true
	ply:StripWeapons()
	ply.armors = ply.armors or {}
	ply:SetMaxHealth(100)
	ply:SetHealth(100)
	ply:SetArmor(0)
end

local function FinishPlayerSetup(ply)
	ply.noSound = false
	ply:SetSuppressPickupNotices(false)
end

function MODE:GiveStartingEquipment(ply)
	local teamId = ply:Team()
	PreparePlayer(ply)

	if teamId == TEAM_BEAR then
		ply:SetPlayerClass("commanderforces")
		zb.GiveRole(ply, "BEAR", teamColors[TEAM_BEAR])
		ply:SetNetVar("CurPluv", "pluvred")
	else
		ply:SetPlayerClass("swat")
		zb.GiveRole(ply, "USEC", teamColors[TEAM_USEC])
		ply:SetNetVar("CurPluv", "pluvblue")
	end

	GiveWeaponWithAmmo(ply, primaryWeapons[teamId], primaryFallbacks[teamId], 2)
	GiveWeaponWithAmmo(ply, secondaryWeapons[teamId], "weapon_glock17", 1)
	hg.AddArmor(ply, "ent_armor_vest4")
	hg.AddArmor(ply, teamId == TEAM_BEAR and "ent_armor_helmet5" or "ent_armor_helmet6")
	GiveCommonEquipment(ply)
	FinishPlayerSetup(ply)
end

function MODE:GiveScavEquipment(ply, isBoss)
	PreparePlayer(ply)

	if isBoss then
		ply:SetPlayerClass("nationalguard")
		zb.GiveRole(ply, "SCAV Boss", Color(205, 70, 45))
		ply:SetMaxHealth(140)
		ply:SetHealth(140)
		GiveWeaponWithAmmo(ply, "weapon_pkm", "weapon_rpk", 3)
		hg.AddArmor(ply, "ent_armor_vest1")
		hg.AddArmor(ply, "ent_armor_helmet7")
		hg.AddArmor(ply, "ent_armor_mask1")
		ply:Give("weapon_medkit_sh")
	else
		ply:SetPlayerClass("Refugee", {bNoEquipment = true})
		zb.GiveRole(ply, "SCAV", teamColors[TEAM_SCAV])
		GiveWeaponWithAmmo(ply, scavWeapons, "weapon_sks", 1)
		GiveWeaponWithAmmo(ply, scavSecondaryWeapons, "weapon_glock17", 1)
		if math.random(2) == 1 then hg.AddArmor(ply, "ent_armor_vest2") end
	end

	ply:SetNetVar("CurPluv", "pluvgreen")
	GiveCommonEquipment(ply)
	FinishPlayerSetup(ply)
end

function MODE:Intermission()
	game.CleanUpMap()

	self.saved.ScavsArrived = false
	self.saved.ScavBoss = nil
	self.saved.Winner = nil
	self.saved.ScavPlayers = {}

	self.CTPoints = {}
	table.CopyFromTo(zb.GetMapPoints("HMCD_TDM_CT"), self.CTPoints)
	self.TPoints = {}
	table.CopyFromTo(zb.GetMapPoints("HMCD_TDM_T"), self.TPoints)

	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then
			ply:SetupTeam(ply:Team())
		end
	end
end

function MODE:GiveEquipment()
	timer.Simple(0.1, function()
		if not CurrentModeIsTarkov() or zb.ROUND_STATE == 3 then return end

		for _, ply in player.Iterator() do
			if ply:Alive() and (ply:Team() == TEAM_BEAR or ply:Team() == TEAM_USEC) then
				self:GiveStartingEquipment(ply)
			end
		end
	end)
end

function MODE:RoundStart()
	self.saved.RoundStartedAt = CurTime()
	self.saved.ScavsArrived = false

	for _, ply in player.Iterator() do
		if ply:Alive() then ply:Freeze(false) end
	end

	net.Start("zc_tarkov_start")
		net.WriteFloat(self.ScavArrivalDelay)
	net.Broadcast()
end

function MODE:GetScavCandidates()
	local candidates = {}
	for _, ply in RandomPairs(player.GetAll()) do
		if ply:Team() ~= TEAM_SPECTATOR and not ply:Alive() then
			candidates[#candidates + 1] = ply
		end
	end

	return candidates
end

function MODE:DeployScavs()
	if self.saved.ScavsArrived then return end
	self.saved.ScavsArrived = true

	local candidates = self:GetScavCandidates()
	local count = math.min(#candidates, self.ScavMaxCount)
	local insertionPoint = zb:GetRandomSpawn()
	local boss

	for index = 1, count do
		local ply = candidates[index]
		local isBoss = index == 1

		ply:Spawn()
		ply:SetTeam(TEAM_SCAV)
		if insertionPoint then hg.tpPlayer(insertionPoint, ply, index, 0) end

		self:GiveScavEquipment(ply, isBoss)
		self.saved.ScavPlayers[ply] = true

		if isBoss then
			boss = ply
			self.saved.ScavBoss = ply
		end

		net.Start("zc_tarkov_scav_role")
			net.WriteBool(isBoss)
		net.Send(ply)
	end

	net.Start("zc_tarkov_scavs_arrived")
		net.WriteUInt(count, 5)
		net.WriteEntity(IsValid(boss) and boss or NULL)
	net.Broadcast()
end

function MODE:RoundThink()
	if self.saved.ScavsArrived then return end

	local startedAt = self.saved.RoundStartedAt or zb.ROUND_BEGIN or CurTime()
	if CurTime() - startedAt >= self.ScavArrivalDelay then
		local bearAlive = false
		local usecAlive = false
		for _, ply in player.Iterator() do
			if not ply:Alive() or (ply.organism and ply.organism.incapacitated) then continue end
			if ply:Team() == TEAM_BEAR then bearAlive = true end
			if ply:Team() == TEAM_USEC then usecAlive = true end
		end
		if not bearAlive or not usecAlive then return end

		self:DeployScavs()
	end
end

function MODE:CheckAlivePlayers()
	local aliveTeams = {
		[TEAM_BEAR] = {},
		[TEAM_USEC] = {}
	}
	if self.saved.ScavsArrived then aliveTeams[TEAM_SCAV] = {} end

	for _, ply in player.Iterator() do
		local teamId = ply:Team()
		if not aliveTeams[teamId] or not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		aliveTeams[teamId][#aliveTeams[teamId] + 1] = ply
	end

	return aliveTeams
end

function MODE:ShouldRoundEnd()
	local aliveTeams = self:CheckAlivePlayers()
	local teamCount = 0
	local winner = -1

	for teamId, members in pairs(aliveTeams) do
		if #members > 0 then
			teamCount = teamCount + 1
			winner = teamId
		end
	end

	if teamCount <= 1 then
		self.saved.Winner = winner
		return true
	end

	return false
end

function MODE:GetLeadingTeam()
	local bestTeam = -1
	local bestCount = 0
	local tied = false

	for teamId, members in pairs(self:CheckAlivePlayers()) do
		local count = #members
		if count > bestCount then
			bestTeam = teamId
			bestCount = count
			tied = false
		elseif count > 0 and count == bestCount then
			tied = true
		end
	end

	return tied and -1 or bestTeam
end

function MODE:BoringRoundFunction()
	self.saved.Winner = self:GetLeadingTeam()
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_T")), zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_CT"))
end

function MODE:GetPlySpawn(ply)
end

function MODE:CanSpawn()
end

function MODE:EndRound()
	if self.saved.Winner == nil then self.saved.Winner = self:GetLeadingTeam() end

	local winner = self.saved.Winner
	local winnerName = teamNames[winner]
	if winnerName then
		PrintMessage(HUD_PRINTTALK, "[Tarkov Raid] " .. winnerName .. " 팀이 생존했습니다.")
	else
		PrintMessage(HUD_PRINTTALK, "[Tarkov Raid] 생존 팀 없이 교전이 종료되었습니다.")
	end

	for _, ply in player.Iterator() do
		if winnerName and ply:Team() == winner then
			ply:GiveExp(math.random(15, 30))
			ply:GiveSkill(math.Rand(0.1, 0.15))
		else
			ply:GiveSkill(-math.Rand(0.05, 0.1))
		end
	end

	net.Start("zc_tarkov_end")
		net.WriteInt(winner or -1, 4)
	net.Broadcast()
end

function MODE:PlayerDeath(ply)
end
