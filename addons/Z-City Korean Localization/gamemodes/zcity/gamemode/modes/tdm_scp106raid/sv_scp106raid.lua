local MODE = MODE

local scpRoleColor = Color(70, 20, 90)
local alphaRoleColor = Color(50, 140, 230)
local omegaRoleColor = Color(230, 160, 30)
local cleanModelColor = Vector(1, 1, 1)
local scpRoundKey = "ZC_SCP106Raid"
local scpWaitingKey = scpRoundKey .. "_Waiting"
local pocketDamageInterval = 1
local pocketDamageAmount = 1
local scpPhaseDescendSpeed = 260

local function BroadcastT(key, fallback)
	if ZCLang and ZCLang.Broadcast then
		ZCLang.Broadcast(key, fallback)
	else
		PrintMessage(HUD_PRINTTALK, fallback or key)
	end
end

local function ApplyCleanRoleModel(ply, modelPath)
	if not IsValid(ply) or not modelPath then return end

	if ApplyAppearance then
		ApplyAppearance(ply, nil, nil, nil, true)
	end

	local appearance = ply.CurAppearance
	if istable(appearance) then
		appearance.AModel = modelPath
		appearance.AClothes = {}
		appearance.AColthes = ""
		appearance.ABodygroups = {}
	end

	ply:SetModel(modelPath)
	ply:SetSkin(0)
	ply:SetSubMaterial()
	ply:SetPlayerColor(cleanModelColor)
	ply:SetNWVector("PlayerColor", cleanModelColor)

	if ply.SetBodyGroups then
		ply:SetBodyGroups("00000000000000000000")
	end
end

local function ReapplyCleanRoleModel(ply, modelPath)
	ApplyCleanRoleModel(ply, modelPath)

	timer.Simple(0, function()
		if IsValid(ply) and CurrentRound() and CurrentRound().name == "scp106raid" then
			ApplyCleanRoleModel(ply, modelPath)
		end
	end)
end

local function GetRoundPlayers()
	local players = {}

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		players[#players + 1] = ply
	end

	return players
end

local function CleanupSCP106Puddles()
	for _, ply in player.Iterator() do
		timer.Remove(ply:SteamID() .. "_S106Teleport")

		if IsValid(ply.S106_GatePuddle) then
			SafeRemoveEntity(ply.S106_GatePuddle)
		end

		ply.S106_GatePuddle = nil
		ply.S106_GatePos = nil
		ply.S106_GateNormal = nil
	end

	for _, ent in ipairs(ents.FindByClass("ent_106pd_puddle_md")) do
		SafeRemoveEntity(ent)
	end

	for _, ent in ipairs(ents.FindByClass("ent_106pd_puddle_lrg")) do
		if ent.S106_VisualOnly then
			SafeRemoveEntity(ent)
		end
	end

	for _, ent in ipairs(ents.FindByClass("ent_106pd_puddle")) do
		if ent.S106_VisualOnly then
			SafeRemoveEntity(ent)
		end
	end
end

local function GiveAmmoForWeapon(ply, weapon)
	if not IsValid(ply) or not IsValid(weapon) or not weapon.GetPrimaryAmmoType then return end

	local ammoType = weapon:GetPrimaryAmmoType()
	if ammoType and ammoType >= 0 then
		local maxClip = math.max(weapon:GetMaxClip1() or 30, 30)
		ply:GiveAmmo(maxClip * 4, ammoType, true)
	end
end

local function GiveCommonMTFItems(ply)
	ply:Give("weapon_hands_sh")
	ply:Give("weapon_bandage_sh")
	ply:Give("weapon_tourniquet")
	ply:Give("weapon_walkie_talkie")

	if hg and hg.AddArmor then
		hg.AddArmor(ply, "vest4")
		hg.AddArmor(ply, "helmet1")
	end
end

local function ResetSpawnCache()
	zb.tspawn = nil
	zb.ctspawn = nil
	zb.teamSpawnPair = nil
end

local function IsSCP106(ply, round)
	return IsValid(ply) and round and ply == round.saved.SCP106
end

local function IsSCP106PhaseMoving(ply)
	if not IsValid(ply) then return false end

	local weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) or weapon:GetClass() ~= "swep_106_pd" then return false end
	if not ply:KeyDown(IN_RELOAD) or not ply:KeyDown(IN_FORWARD) then return false end
	if ply:EyeAngles():Forward().z > -0.35 then return false end

	return ply:GetNotSolid() or ply:GetMoveType() == MOVETYPE_NOCLIP
end

local function IsMTF(ply, round)
	return IsValid(ply) and ply:IsPlayer() and round and ply ~= round.saved.SCP106 and ply:Team() ~= TEAM_SPECTATOR
end

local function IsInSCP106PocketDimension(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if not ply.IsDreaming or not ply:IsDreaming() then return false end
	if not ply.GetDream then return false end

	local dream = ply:GetDream()
	return istable(dream) and dream.Name == "scp106"
end

local function ApplySCP106Impact(ply, dmg)
	if not IsValid(ply) or not dmg then return end

	local dir = dmg:GetDamageForce()
	if dir:LengthSqr() <= 0 then
		local attacker = dmg:GetAttacker()
		if IsValid(attacker) then
			dir = ply:WorldSpaceCenter() - attacker:WorldSpaceCenter()
		else
			dir = ply:GetForward()
		end
	end

	dir.z = math.Clamp(dir.z, -0.15, 0.2)
	if dir:LengthSqr() <= 0 then return end
	dir:Normalize()

	dmg:SetDamageForce(vector_origin)
	ply:SetVelocity(dir * 110)
end

function MODE.GuiltCheck(attacker, victim)
	local round = CurrentRound and CurrentRound()
	if not round or round.name ~= "scp106raid" then return end

	if IsMTF(attacker, round) and IsMTF(victim, round) then
		return 0, false
	end
end

function MODE:ResetSCPOrganismDamage(ply)
	if not IsSCP106(ply, self) then return end

	local org = ply.organism
	if not org then return end

	org.alive = ply:Alive()
	org.otrub = false
	org.fake = false
	org.needotrub = false
	org.needfake = false
	org.incapacitated = false
	org.critical = false
	org.canmove = true
	org.canmovehead = true

	org.pain = 0
	org.avgpain = 0
	org.painadd = 0
	org.shock = 0
	org.hurt = 0
	org.hurtadd = 0
	org.immobilization = 0
	org.consciousness = 1
	org.disorientation = 0
	org.stun = 0
	org.lightstun = 0

	org.heart = 0
	org.heartstop = false
	org.heartstoptime = nil
	org.pulse = 70
	org.heartbeat = 70

	org.o2 = org.o2 or {range = 30, regen = 4, k = 0.5}
	org.o2.range = org.o2.range or 30
	org.o2.regen = org.o2.regen or 4
	org.o2.k = org.o2.k or 0.5
	org.o2[1] = org.o2.range
	org.o2.curregen = org.o2.regen
	org.CO = 0
	org.COregen = 0
	org.holdingbreath = false

	org.bleed = 0
	org.internalBleed = 0
	org.wounds = {}
	org.arterialwounds = {}
	ply:SetNetVar("wounds", org.wounds)
	ply:SetNetVar("arterialwounds", org.arterialwounds)

	org.brain = 0
	org.skull = 0
	org.jaw = 0
	org.chest = 0
	org.pelvis = 0
	org.spine1 = 0
	org.spine2 = 0
	org.spine3 = 0
	org.lleg = 0
	org.rleg = 0
	org.larm = 0
	org.rarm = 0
	org.liver = 0
	org.stomach = 0
	org.intestines = 0
	org.llegdislocation = false
	org.rlegdislocation = false
	org.larmdislocation = false
	org.rarmdislocation = false
	org.jawdislocation = false
	org.llegamputated = false
	org.rlegamputated = false
	org.larmamputated = false
	org.rarmamputated = false
	org.headamputated = false
end

function MODE:CanLaunch()
	return player.GetCount() >= 2
end

function MODE:Intermission()
	game.CleanUpMap()
	ResetSpawnCache()

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply:SetupTeam(0)
	end

	net.Start("tdm_start")
		net.WriteString(self.name)
	net.Broadcast()
end

function MODE:PickSCP106()
	local players = GetRoundPlayers()
	if #players <= 0 then return nil end

	local scp = table.Random(players)
	self.saved.SCP106 = scp
	return scp
end

function MODE:ApplySCP106(ply)
	if not IsValid(ply) then return end

	ply:SetNWString(scpRoundKey .. "_Role", "scp")
	ply:SetNWBool(scpWaitingKey, true)
	ply:SetupTeam(1)
	ply:Spawn()
	ply:SetupTeam(1)
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

	ReapplyCleanRoleModel(ply, self.SCPModel)
	zb.GiveRole(ply, "SCP-106", scpRoleColor)

	local health = 600 + math.max(#GetRoundPlayers() - 2, 0) * 150
	ply:SetMaxHealth(health)
	ply:SetHealth(health)
	self:ResetSCPOrganismDamage(ply)
	ply:Freeze(true)
	ply:SetMoveType(MOVETYPE_NONE)
	ply:SetNoDraw(true)
	ply:SetNotSolid(true)

	timer.Simple(0.1, function()
		if IsValid(ply) then
			ply.noSound = false
			ply:SetSuppressPickupNotices(false)
		end
	end)
end

function MODE:ReleaseSCP106()
	local scp = self.saved.SCP106
	if not IsValid(scp) then return end
	if not scp:Alive() then return end

	scp:SetNWBool(scpWaitingKey, false)
	scp:Freeze(false)
	scp:SetMoveType(MOVETYPE_WALK)
	scp:SetNoDraw(false)
	scp:SetNotSolid(false)
	scp:StripWeapons()
	scp:RemoveAllAmmo()
	self:ResetSCPOrganismDamage(scp)

	local weapon = scp:Give(self.SCPWeapon)
	if IsValid(weapon) then
		scp:SelectWeapon(self.SCPWeapon)
	end

	BroadcastT("sv_scp_escaped", "SCP-106이 격리실을 벗어났습니다!")
end

function MODE:ApplyMTF(ply, wave)
	if not IsValid(ply) then return end

	local isOmega = wave == 2
	local modelPath = isOmega and self.OmegaModel or self.AlphaModel
	local weaponClass = isOmega and self.OmegaWeapon or self.AlphaWeapon
	local roleName = isOmega and "오메가 기동특무부대" or "알파 기동특무부대"
	local roleColor = isOmega and omegaRoleColor or alphaRoleColor

	ply:SetNWString(scpRoundKey .. "_Role", isOmega and "omega" or "alpha")
	ply:SetNWBool(scpWaitingKey, false)
	ply:SetupTeam(0)
	ply:Spawn()
	ply:SetupTeam(0)
	ply:Freeze(false)
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetNoDraw(false)
	ply:SetNotSolid(false)
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

	ReapplyCleanRoleModel(ply, modelPath)
	zb.GiveRole(ply, roleName, roleColor)

	ply:SetMaxHealth(isOmega and 125 or 100)
	ply:SetHealth(ply:GetMaxHealth())
	GiveCommonMTFItems(ply)

	local weapon = ply:Give(weaponClass)
	if IsValid(weapon) then
		GiveAmmoForWeapon(ply, weapon)
		ply:SelectWeapon(weaponClass)
	end

	timer.Simple(0.1, function()
		if IsValid(ply) then
			ply.noSound = false
			ply:SetSuppressPickupNotices(false)
		end
	end)
end

function MODE:SpawnMTFWave(wave)
	self.saved.SupportWave = wave
	self.saved.NextSupportTime = nil
	ResetSpawnCache()

	local scp = self.saved.SCP106
	local spawned = 0

	for _, ply in player.Iterator() do
		if ply == scp then continue end
		if ply:Team() == TEAM_SPECTATOR then continue end
		self:ApplyMTF(ply, wave)
		spawned = spawned + 1
	end

	if wave == 1 then
		BroadcastT("sv_scp_support", "기동특무부대 추가 지원이 도착했습니다!")
	elseif wave == 2 then
		BroadcastT("sv_scp_omega", "마지막 지원, 오메가 기동특무부대가 투입되었습니다!")
	end

	return spawned
end

function MODE:GiveEquipment()
	timer.Simple(0.1, function()
		if CurrentRound() ~= self then return end

		ResetSpawnCache()
		self.saved.Winner = nil
		self.saved.SupportWave = 0
		self.saved.NextSupportTime = nil
		self.saved.SCP106 = self:PickSCP106()

		local scp = self.saved.SCP106
		if not IsValid(scp) then return end

		self:ApplySCP106(scp)

		for _, ply in player.Iterator() do
			if ply == scp then continue end
			if ply:Team() == TEAM_SPECTATOR then continue end
			self:ApplyMTF(ply, 0)
		end

		BroadcastT("sv_scp_started", "SCP-106 격리 작전이 시작되었습니다.")

		timer.Create("ZC_SCP106RaidRelease", self.SCPReleaseDelay or 15, 1, function()
			if CurrentRound() ~= self then return end
			self:ReleaseSCP106()
		end)
	end)
end

function MODE:GetAliveMTF()
	local mtf = {}
	local scp = self.saved.SCP106

	for _, ply in player.Iterator() do
		if ply == scp then continue end
		if ply:Team() == TEAM_SPECTATOR then continue end
		if not ply:Alive() then continue end
		mtf[#mtf + 1] = ply
	end

	return mtf
end

function MODE:RoundThink()
	if self.saved.Winner then return end
	local scp = self.saved.SCP106
	if IsValid(scp) and scp:Alive() then
		self:ResetSCPOrganismDamage(scp)

		if scp:GetNWBool(scpWaitingKey, false) then
			scp:SetVelocity(-scp:GetVelocity())
			scp:Freeze(true)
			scp:SetMoveType(MOVETYPE_NONE)
		elseif hg and hg.FakeUp and IsValid(scp.FakeRagdoll) then
			hg.FakeUp(scp, true, true)
		end
	end

	if (self.saved.NextPocketDamage or 0) <= CurTime() then
		self.saved.NextPocketDamage = CurTime() + pocketDamageInterval

		for _, ply in player.Iterator() do
			if ply == scp then continue end
			if not ply:Alive() or ply:Team() == TEAM_SPECTATOR then continue end
			if not IsInSCP106PocketDimension(ply) then continue end

			local health = ply:Health()
			if health <= pocketDamageAmount then
				ply:Kill()
			else
				ply:SetHealth(health - pocketDamageAmount)
			end
		end
	end

	if self.saved.NextSupportTime and CurTime() >= self.saved.NextSupportTime then
		self:SpawnMTFWave(self.saved.PendingSupportWave or 1)
	end
end

function MODE:ShouldRoundEnd()
	local scp = self.saved.SCP106
	if not IsValid(scp) then
		self.saved.Winner = "mtf"
		return true
	end

	if not scp:Alive() then
		self.saved.Winner = "mtf"
		return true
	end

	if #self:GetAliveMTF() > 0 then return nil end

	local wave = self.saved.SupportWave or 0
	if wave < 2 then
		if not self.saved.NextSupportTime then
			self.saved.PendingSupportWave = wave + 1
			self.saved.NextSupportTime = CurTime() + (self.SupportDelay or 5)

			if self.saved.PendingSupportWave == 1 then
				BroadcastT("sv_scp_need_support", "SCP 106의 격리가 실패했다. 추가 지원을 요청한다!")
			else
				BroadcastT("sv_scp_alpha_dead", "알파 부대가 전멸했습니다. 마지막 지원을 요청합니다!")
			end
		end

		return false
	end

	self.saved.Winner = "scp"
	return true
end

function MODE:EndRound()
	timer.Remove("ZC_SCP106RaidRelease")
	CleanupSCP106Puddles()

	for _, ply in player.Iterator() do
		ply:SetNWString(scpRoundKey .. "_Role", "")
		ply:SetNWBool(scpWaitingKey, false)
		ply:SetSuppressPickupNotices(false)
		ply.noSound = false
		ply:Freeze(false)
		ply:SetNoDraw(false)
		ply:SetNotSolid(false)
		ply:SetMoveType(MOVETYPE_WALK)
	end

	timer.Simple(2, function()
		net.Start("tdm_roundend")
		net.Broadcast()
	end)

	if self.saved.Winner == "mtf" then
		BroadcastT("sv_scp_mtf_win", "SCP 106을 성공적으로 격리했습니다!")
	elseif self.saved.Winner == "scp" then
		BroadcastT("sv_scp_scp_win", "SCP 106의 격리가 실패했다. 당장 추가 지원을 요청해라!")
	end
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_T")), zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_CT"))
end

function MODE:ShowSpare1()
end

function MODE:EntityTakeDamage(ent, dmg)
	if not IsValid(ent) or not ent:IsPlayer() then return end

	local attacker = dmg:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and attacker ~= ent and IsMTF(attacker, self) and IsMTF(ent, self) then
		dmg:SetDamage(0)
		dmg:ScaleDamage(0)
		return true
	end

	if IsSCP106(ent, self) then
		ApplySCP106Impact(ent, dmg)
		self:ResetSCPOrganismDamage(ent)
		timer.Simple(0, function()
			if CurrentRound() == self and IsValid(ent) then
				if IsValid(ent.FakeRagdoll) and hg and hg.FakeUp then
					hg.FakeUp(ent, true, true)
				end

				self:ResetSCPOrganismDamage(ent)
			end
		end)
	end
end

function MODE:SetupMove(ply, mv)
	if not IsSCP106(ply, self) then return end
	if ply:GetNWBool(scpWaitingKey, false) then
		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)
		mv:SetUpSpeed(0)
		mv:SetMaxSpeed(0)
		mv:SetMaxClientSpeed(0)
		return
	end

	if IsSCP106PhaseMoving(ply) then
		mv:SetUpSpeed(-scpPhaseDescendSpeed)
		mv:SetVelocity(mv:GetVelocity() + Vector(0, 0, -scpPhaseDescendSpeed))
	end
end
