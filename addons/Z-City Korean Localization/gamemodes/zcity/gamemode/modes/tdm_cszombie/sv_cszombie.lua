local MODE = MODE

MODE.StartMoney = 10000
MODE.BuyTime = 20
MODE.start_time = 20
MODE.ROUND_TIME = 240
MODE.end_time = 10
MODE.Chance = 0.03
MODE.ForBigMaps = false
MODE.buymenu = true
MODE.randomSpawns = true

util.AddNetworkString("zb_cs_round_intermission")
util.AddNetworkString("zb_cszombie_round_stats")

local zombieRoleColor = Color(60, 180, 60)
local humanRoleColor = Color(0, 120, 190)

local countdownSounds = {
	[10] = "fvoxnumber/ten.wav",
	[9] = "fvoxnumber/nine.wav",
	[8] = "fvoxnumber/eight.wav",
	[7] = "fvoxnumber/seven.wav",
	[6] = "fvoxnumber/six.wav",
	[5] = "fvoxnumber/five.wav",
	[4] = "fvoxnumber/four.wav",
	[3] = "fvoxnumber/three.wav",
	[2] = "fvoxnumber/two.wav",
	[1] = "fvoxnumber/one.wav"
}

for _, soundPath in pairs(countdownSounds) do
	resource.AddFile("sound/" .. soundPath)
end

local infectionStartSounds = {
	"npc/zombie_poison/pz_call1.wav",
	"npc/fast_zombie/fz_alert_far1.wav"
}

local function PlayGlobalSound(soundPath)
	BroadcastLua("surface.PlaySound(" .. string.format("%q", soundPath) .. ")")
end

local function PlayZombieBloodBurst(ply)
	if not IsValid(ply) then return end

	local pos = ply:GetPos() + Vector(0, 0, 45)

	for _ = 1, 8 do
		local effect = EffectData()
		effect:SetOrigin(pos + VectorRand(-12, 12))
		effect:SetNormal((VectorRand() + Vector(0, 0, 0.6)):GetNormalized())
		effect:SetScale(math.Rand(2, 4))
		effect:SetColor(BLOOD_COLOR_RED)
		util.Effect("BloodImpact", effect, true, true)
	end

	for _ = 1, 5 do
		local startPos = pos + VectorRand(-20, 20)
		util.Decal("Blood", startPos, startPos - Vector(0, 0, 120), ply)
	end

	ply:EmitSound("physics/flesh/flesh_bloody_break.wav", 90, math.random(90, 105))
end

local function CreateZombieDeathRagdoll(ply)
	if not IsValid(ply) then return end

	local rag = ents.Create("prop_ragdoll")
	if not IsValid(rag) then return end

	rag:SetModel(ply:GetModel())
	rag:SetPos(ply:GetPos())
	rag:SetAngles(Angle(0, ply:EyeAngles().y, 0))
	rag:SetSkin(ply:GetSkin() or 0)
	rag:SetColor(ply:GetColor())
	rag:SetMaterial(ply:GetMaterial() or "")
	rag:Spawn()
	rag:Activate()
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	rag.ZC_CSZombieCorpse = true
	rag:SetNetVar("ZC_CSZombieCorpse", true)

	for i = 0, ply:GetNumBodyGroups() - 1 do
		rag:SetBodygroup(i, ply:GetBodygroup(i))
	end

	local vel = ply:GetVelocity()
	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local phys = rag:GetPhysicsObjectNum(i)
		if IsValid(phys) then
			phys:Wake()
			phys:SetVelocity(vel)
		end
	end

	ply:SetNWEntity("RagdollDeath", rag)
	ply.RagdollDeath = rag
	SafeRemoveEntityDelayed(rag, 30)

	return rag
end

function MODE:CanLaunch()
	return player.GetCount() >= 2
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_T")), zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_CT"))
end

function MODE.GuiltCheck(Attacker, Victim)
	if Attacker.IsCSZombie ~= Victim.IsCSZombie then
		return 0, false
	end

	return 1, true
end

function MODE:ResetZombieStats(ply)
	if not IsValid(ply) then return end

	ply.CSZombieDamageDealt = 0
	ply.CSZombieInfections = 0
	ply.CSZombieSurvivalStart = nil
	ply.CSZombieSurvivalTime = 0
	ply.CSZombieSurvivalStopped = false
end

function MODE:StartSurvivalTimers()
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		ply.CSZombieSurvivalStart = CurTime()
		ply.CSZombieSurvivalTime = 0
		ply.CSZombieSurvivalStopped = false
	end
end

function MODE:StopSurvivalTimer(ply, forceZero)
	if not IsValid(ply) or ply.CSZombieSurvivalStopped then return end

	ply.CSZombieSurvivalStopped = true

	if forceZero then
		ply.CSZombieSurvivalTime = 0
		return
	end

	local startTime = ply.CSZombieSurvivalStart or (zb.ROUND_BEGIN or CurTime())
	ply.CSZombieSurvivalTime = math.max(CurTime() - startTime, ply.CSZombieSurvivalTime or 0)
end

function MODE:BuildZombieStats()
	local stats = {}

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		if not ply.CSZombieSurvivalStopped then
			self:StopSurvivalTimer(ply, false)
		end

		stats[#stats + 1] = {
			name = ply:Nick(),
			damage = math.Clamp(math.floor(ply.CSZombieDamageDealt or 0), 0, 1048575),
			infections = math.Clamp(ply.CSZombieInfections or 0, 0, 1023),
			survival = math.Clamp(math.floor(ply.CSZombieSurvivalTime or 0), 0, 65535)
		}
	end

	return stats
end

function MODE:SendZombieStats(stats)
	stats = stats or self:BuildZombieStats()

	net.Start("zb_cszombie_round_stats")
		net.WriteUInt(math.min(#stats, 64), 7)
		for i = 1, math.min(#stats, 64) do
			local data = stats[i]
			net.WriteString(data.name)
			net.WriteUInt(data.damage, 20)
			net.WriteUInt(data.infections, 10)
			net.WriteUInt(data.survival, 16)
		end
	net.Broadcast()
end

function MODE:Intermission()
	game.CleanUpMap()

	self.InfectionStarted = false
	self.Winner = nil
	self.CountdownStarted = false

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		ply.IsCSZombie = false
		ply:SetNWBool("CSZombie_IsZombie", false)
		self:ResetZombieStats(ply)
		ply:SetupTeam(1)
		ply:SetNWInt("TDM_Money", self.StartMoney)

		zb.GiveRole(ply, "Human", humanRoleColor)

		net.Start("zb_cs_round_intermission")
			net.WriteBool(true)
			net.WriteInt(0, 6)
		net.Send(ply)
	end

	net.Start("tdm_start")
		net.WriteString("cszombie")
	net.Broadcast()

	PrintMessage(HUD_PRINTTALK, "CS Zombie: 무기를 구매하십시오. 감염은 곧 시작됩니다.")
	self:ScheduleInfectionCountdown()
end

function MODE:ScheduleInfectionCountdown()
	if self.CountdownStarted then return end
	self.CountdownStarted = true

	for number, soundPath in pairs(countdownSounds) do
		local timerName = "CSZombieCountdown_" .. number
		if timer.Exists(timerName) then
			timer.Remove(timerName)
		end

		local delay = math.max((zb.ROUND_BEGIN or CurTime()) - CurTime() - number, 0)
		timer.Create(timerName, delay, 1, function()
			local round = CurrentRound()
			if not round or round.name ~= "cszombie" then return end

			PlayGlobalSound(soundPath)
		end)
	end
end

function MODE:PlayInfectionStartSounds(zombies)
	local round = CurrentRound()
	if not round or round.name ~= "cszombie" then return end

	PlayGlobalSound(table.Random(infectionStartSounds))

	for _, ply in ipairs(zombies or {}) do
		if IsValid(ply) and ply.IsCSZombie and ply:Alive() then
			ply:EmitSound("npc/fast_zombie/fz_scream1.wav", 100, 100)
		end
	end
end

function MODE:GiveEquipment()
	timer.Simple(0.1, function()
		if CurrentRound() ~= self then return end

		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then continue end

			ply:SetSuppressPickupNotices(true)
			ply.noSound = true
			ply:SetPlayerClass("swat")
			ply:SetNetVar("CurPluv", "pluvberet")
			ply.organism.allowholster = true

			ply:Give("weapon_hands_sh")
			ply:Give("weapon_bandage_sh")
			ply:Give("weapon_tourniquet")
			ply:SelectWeapon("weapon_hands_sh")

			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"] = inv["Weapons"] or {}
			inv["Weapons"]["hg_sling"] = true
			ply:SetNetVar("Inventory", inv)

			timer.Simple(0.1, function()
				if IsValid(ply) then
					ply.noSound = false
					ply:SetSuppressPickupNotices(false)
				end
			end)
		end
	end)
end

function MODE:GetAliveCounts()
	local humans = 0
	local zombies = 0

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then continue end

		if ply.IsCSZombie then
			zombies = zombies + 1
		else
			humans = humans + 1
		end
	end

	return humans, zombies
end

function MODE:GetZombieHealth()
	local count = 0

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then continue end
		count = count + 1
	end

	return math.max(count, 1) * 300
end

function MODE:StabilizeZombieOrganism(ply)
	if not IsValid(ply) or not ply.IsCSZombie then return end

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

	org.stun = 0
	org.lightstun = 0
end

function MODE:ResetZombieOrganismDamage(ply, force)
	if not IsValid(ply) or not ply.IsCSZombie then return end

	local org = ply.organism
	if not org then return end

	local now = CurTime()
	if not force and (ply.CSZombieNextOrganismReset or 0) > now then
		self:StabilizeZombieOrganism(ply)
		return
	end
	ply.CSZombieNextOrganismReset = now + 0.08

	org.pain = 0
	org.avgpain = 0
	org.painadd = 0
	org.shock = 0
	org.hurt = 0
	org.hurtadd = 0
	org.immobilization = 0
	org.consciousness = 1
	org.disorientation = 0

	org.heart = 0
	org.heartstop = false
	org.heartstoptime = nil
	org.pulse = 70
	org.heartbeat = 70

	org.lungsL = org.lungsL or {0, 0}
	org.lungsR = org.lungsR or {0, 0}
	org.lungsL[1] = 0
	org.lungsL[2] = 0
	org.lungsR[1] = 0
	org.lungsR[2] = 0
	org.trachea = 0
	org.pneumothorax = 0
	org.lungsfunction = true

	org.o2 = org.o2 or {range = 30, regen = 4, k = 0.5}
	org.o2.range = org.o2.range or 30
	org.o2.regen = org.o2.regen or 4
	org.o2.k = org.o2.k or 0.5
	org.o2[1] = org.o2.range
	org.o2.curregen = org.o2.regen
	org.CO = 0
	org.COregen = 0
	org.holdingbreath = false

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

	self:StabilizeZombieOrganism(ply)
end

function MODE:SelectInitialZombies()
	local candidates = {}

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then continue end
		table.insert(candidates, ply)
	end

	if #candidates <= 1 then
		PrintMessage(HUD_PRINTTALK, "CS Zombie: 플레이어가 부족해서 감염을 시작할 수 없습니다.")
		return
	end

	local zombieCount = math.max(math.floor(#candidates / 5), 1)
	zombieCount = math.min(zombieCount, #candidates - 1)

	local selectedZombies = {}

	for _ = 1, zombieCount do
		local index = math.random(#candidates)
		local ply = table.remove(candidates, index)

		if IsValid(ply) then
			self:MakeZombie(ply, true)
			table.insert(selectedZombies, ply)
		end
	end

	PrintMessage(HUD_PRINTTALK, "CS Zombie: 감염이 시작되었습니다!")
	self:PlayInfectionStartSounds(selectedZombies)
end

function MODE:MakeZombie(ply, initial)
	if not IsValid(ply) then return end
	if ply:Team() == TEAM_SPECTATOR then return end

	local pos = ply:GetPos()
	local ang = ply:EyeAngles()

	PlayZombieBloodBurst(ply)
	self:StopSurvivalTimer(ply, initial)

	ply.IsCSZombie = true
	ply:SetNWBool("CSZombie_IsZombie", true)

	if not ply:Alive() then
		ply:Spawn()
		ply:SetPos(pos)
		ply:SetEyeAngles(ang)
	end

	ply:SetTeam(0)
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:Extinguish()
	ply:GodDisable()
	ply:SetPlayerClass()
	ply:SetModel(table.Random(self.ZombieModels))
	local zombieHealth = self:GetZombieHealth()
	ply:SetMaxHealth(zombieHealth)
	ply:SetHealth(zombieHealth)
	ply:SetWalkSpeed(230)
	ply:SetRunSpeed(380)
	ply:SetJumpPower(260)
	ply:SetNetVar("CurPluv", "pluv")
	self:ResetZombieOrganismDamage(ply, true)

	local claws = ply:Give("weapon_zombie_claws")
	if IsValid(claws) then
		ply:SelectWeapon("weapon_zombie_claws")
	end

	zb.GiveRole(ply, "Zombie", zombieRoleColor)
	ply:ChatPrint("당신은 좀비입니다. 인간을 감염시키십시오.")
end

function MODE:InfectHuman(attacker, victim)
	if not IsValid(attacker) or not IsValid(victim) then return end
	if not attacker.IsCSZombie or victim.IsCSZombie then return end
	if victim:Team() == TEAM_SPECTATOR or not victim:Alive() then return end

	local name = victim:Name()
	attacker.CSZombieInfections = (attacker.CSZombieInfections or 0) + 1

	if hg.FakeUp and IsValid(victim.FakeRagdoll) then
		hg.FakeUp(victim, true, true)
	end

	self:MakeZombie(victim, false)
	PrintMessage(HUD_PRINTTALK, "CS Zombie: " .. name .. " 님이 감염되었습니다!")
end

function MODE:RoundThink()
	if not self.InfectionStarted and CurTime() >= (zb.ROUND_BEGIN or 0) then
		self.InfectionStarted = true
		self:StartSurvivalTimers()
		self:SelectInitialZombies()
	end

	for _, ply in player.Iterator() do
		if ply.IsCSZombie and ply:Alive() then
			self:StabilizeZombieOrganism(ply)

			local now = CurTime()
			if (ply.CSZombieNextMoveRefresh or 0) <= now then
				ply.CSZombieNextMoveRefresh = now + 0.5
				ply:SetWalkSpeed(230)
				ply:SetRunSpeed(380)
				ply:SetJumpPower(260)
			end

			if not ply.CSZombieStunUntil or ply.CSZombieStunUntil < CurTime() then
				ply.CSZombieStunUntil = nil
				ply.CSZombieStunAttacker = nil
			end

			if hg.FakeUp and IsValid(ply.FakeRagdoll) then
				hg.FakeUp(ply, true, true)
			end

			if (ply.CSZombieNextWeaponCheck or 0) <= now then
				ply.CSZombieNextWeaponCheck = now + 0.5

				local wep = ply:GetActiveWeapon()
				if not IsValid(wep) or wep:GetClass() ~= "weapon_zombie_claws" or #ply:GetWeapons() > 1 then
					ply:StripWeapons()
					ply:Give("weapon_zombie_claws")
					ply:SelectWeapon("weapon_zombie_claws")
				end
			end
		end
	end
end

function MODE:ShouldRoundEnd()
	if not self.InfectionStarted then
		if zb.GetActivePlayerCount and zb.GetActivePlayerCount() <= 1 then
			self.Winner = "humans"
			return true
		end

		return false
	end

	local humans, zombies = self:GetAliveCounts()

	if humans == 0 then
		self.Winner = "zombies"
		return true
	end

	if zombies == 0 then
		self.Winner = "humans"
		return true
	end

	return nil
end

function MODE:EndRound()
	local roundStats = self:BuildZombieStats()

	timer.Simple(2, function()
		net.Start("tdm_roundend")
		net.Broadcast()
	end)

	timer.Simple(2.15, function()
		if self.SendZombieStats then
			self:SendZombieStats(roundStats)
		end
	end)

	local winner = self.Winner or "humans"

	if winner == "zombies" then
		PrintMessage(HUD_PRINTTALK, "CS Zombie: 좀비가 모든 인간을 감염시켰습니다.")
	else
		PrintMessage(HUD_PRINTTALK, "CS Zombie: 인간이 생존했습니다.")
	end

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		local won = (winner == "zombies" and ply.IsCSZombie) or (winner == "humans" and not ply.IsCSZombie)

		if won then
			ply:GiveExp(math.random(15, 30))
			ply:GiveSkill(math.Rand(0.1, 0.15))
		else
			ply:GiveSkill(-math.Rand(0.05, 0.1))
		end
	end
end

function MODE:PlayerDeath(ply)
	if not IsValid(ply) then return end

	if ply.IsCSZombie then
		CreateZombieDeathRagdoll(ply)
	else
		self:StopSurvivalTimer(ply, false)
	end
end

function MODE:PlayerCanPickupWeapon(ply, wep)
	if ply.IsCSZombie and IsValid(wep) and wep:GetClass() ~= "weapon_zombie_claws" then
		return false
	end
end

function MODE:EntityTakeDamage(ent, dmg)
	local attacker = dmg:GetAttacker()
	if IsValid(ent) and ent:IsPlayer() and IsValid(attacker) and attacker:IsPlayer() and attacker ~= ent then
		attacker.CSZombieDamageDealt = (attacker.CSZombieDamageDealt or 0) + math.max(dmg:GetDamage(), 0)
	end

	if not IsValid(ent) or not ent:IsPlayer() or not ent.IsCSZombie then return end
	if not dmg:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then return end

	if not IsValid(attacker) or not attacker:IsPlayer() or attacker.IsCSZombie then return end

	local weapon = attacker:GetActiveWeapon()
	if not IsValid(weapon) or weapon:GetClass() == "weapon_hands_sh" then return end

	ent.CSZombieStunUntil = CurTime() + 0.3
	ent.CSZombieStunAttacker = attacker

	local knockDir = dmg:GetDamageForce()
	if knockDir:LengthSqr() <= 0 then
		knockDir = ent:GetPos() - attacker:GetShootPos()
	end

	knockDir.z = 0
	if knockDir:LengthSqr() > 0 then
		knockDir:Normalize()
		local knockPower = math.Clamp(16 + dmg:GetDamage() * 0.55, 16, 34)
		ent:SetVelocity(knockDir * knockPower + Vector(0, 0, 4))
	end

	self:ResetZombieOrganismDamage(ent)
end

function MODE:SetupMove(ply, mv)
	if not ply.IsCSZombie then return end
	if not ply.CSZombieStunUntil or ply.CSZombieStunUntil < CurTime() then
		ply.CSZombieStunUntil = nil
		ply.CSZombieStunAttacker = nil
		return
	end
	if not IsValid(ply.CSZombieStunAttacker) or ply.CSZombieStunAttacker.IsCSZombie then
		ply.CSZombieStunUntil = nil
		ply.CSZombieStunAttacker = nil
		return
	end

	mv:SetMaxSpeed(45)
	mv:SetMaxClientSpeed(45)
end

hook.Add("SetupMove", "CSZombieBulletStun", function(ply, mv)
	local round = CurrentRound and CurrentRound()
	if not round or round.name ~= "cszombie" then return end
	if not ply.IsCSZombie then return end
	if not ply.CSZombieStunUntil or ply.CSZombieStunUntil < CurTime() then
		ply.CSZombieStunUntil = nil
		ply.CSZombieStunAttacker = nil
		return
	end
	if not IsValid(ply.CSZombieStunAttacker) or ply.CSZombieStunAttacker.IsCSZombie then
		ply.CSZombieStunUntil = nil
		ply.CSZombieStunAttacker = nil
		return
	end

	mv:SetForwardSpeed(mv:GetForwardSpeed() * 0.15)
	mv:SetSideSpeed(mv:GetSideSpeed() * 0.15)
	mv:SetMaxSpeed(45)
	mv:SetMaxClientSpeed(45)
end)
