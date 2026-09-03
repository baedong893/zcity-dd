local MODE = MODE

local GLOBAL_PREFIX = "ZC_BG_"
local TEAM_SURVIVOR = 0
local minimumZoneRadius = 90
local fieldLootTimerName = "ZC_BG_FieldLootSpawn"
local cachedMapName
local cachedMapPositions = {}

-- Remove an unfinished batch left behind by Lua auto-refresh.
timer.Remove(fieldLootTimerName)

local defaultSpawnClasses = {
	"info_player_start",
	"info_player_deathmatch",
	"info_player_counterterrorist",
	"info_player_terrorist",
	"info_player_combine",
	"info_player_rebel",
	"gmod_player_start"
}

local airdropWeapons = {
	"weapon_m249",
	"weapon_sr25",
	"weapon_pkm",
	"weapon_m4a1",
	"weapon_akm"
}

local airdropAttachments = {
	"ent_att_holo1",
	"ent_att_holo4",
	"ent_att_optic2",
	"ent_att_grip1",
	"ent_att_laser1",
	"ent_att_supressor2"
}

local function IsBattlegroundsActive()
	local round = CurrentRound and CurrentRound()
	return zb.ROUND_STATE == 1 and round and round.name == MODE.name
end

local function HorizontalDistanceSqr(a, b)
	local x = a.x - b.x
	local y = a.y - b.y
	return x * x + y * y
end

local function AddUniquePosition(output, seen, pos)
	if not isvector(pos) then return end
	local key = math.Round(pos.x / 64) .. ":" .. math.Round(pos.y / 64) .. ":" .. math.Round(pos.z / 64)
	if seen[key] then return end
	seen[key] = true
	output[#output + 1] = pos
end

local function BuildMapPositionCache()
	local mapName = game.GetMap()
	if cachedMapName == mapName and #cachedMapPositions > 0 then return cachedMapPositions end

	cachedMapName = mapName
	cachedMapPositions = {}
	local seen = {}

	for _, pointName in ipairs({"RandomSpawns", "Spawnpoint"}) do
		for _, point in ipairs(zb.GetMapPoints(pointName) or {}) do
			AddUniquePosition(cachedMapPositions, seen, point.pos or point[1])
		end
		if #cachedMapPositions >= 8 then break end
	end

	-- RandomSpawns alone are enough for players, but not for field loot or for
	-- measuring the playable area. Always sample the navmesh when one exists.
	local navAreas = navmesh.GetAllNavAreas() or {}
	local step = math.max(math.ceil(#navAreas / 256), 1)
	for index = 1, #navAreas, step do
		local area = navAreas[index]
		if area and area:IsValid() then
			AddUniquePosition(cachedMapPositions, seen, area:GetCenter())
		end
	end

	for _, class in ipairs(defaultSpawnClasses) do
		for _, ent in ipairs(ents.FindByClass(class)) do
			AddUniquePosition(cachedMapPositions, seen, ent:GetPos())
		end
	end

	if #cachedMapPositions == 0 then
		for _, ply in player.Iterator() do
			if ply:Team() ~= TEAM_SPECTATOR then
				AddUniquePosition(cachedMapPositions, seen, ply:GetPos())
			end
		end
	end

	return cachedMapPositions
end

local function CalculateInitialZone(positions)
	if #positions == 0 then return vector_origin, 1800 end

	local minX, maxX = positions[1].x, positions[1].x
	local minY, maxY = positions[1].y, positions[1].y
	local zTotal = 0
	for _, pos in ipairs(positions) do
		minX = math.min(minX, pos.x)
		maxX = math.max(maxX, pos.x)
		minY = math.min(minY, pos.y)
		maxY = math.max(maxY, pos.y)
		zTotal = zTotal + pos.z
	end

	local center = Vector((minX + maxX) * 0.5, (minY + maxY) * 0.5, zTotal / #positions)
	local radiusSqr = 0
	for _, pos in ipairs(positions) do
		radiusSqr = math.max(radiusSqr, HorizontalDistanceSqr(pos, center))
	end

	local radius = math.Clamp(math.sqrt(radiusSqr) * 1.08, 1200, 9000)
	return center, radius
end

local function ClearGlobalState()
	SetGlobalBool(GLOBAL_PREFIX .. "Active", false)
	SetGlobalBool(GLOBAL_PREFIX .. "RedActive", false)
	SetGlobalBool(GLOBAL_PREFIX .. "Shrinking", false)
	SetGlobalInt(GLOBAL_PREFIX .. "Phase", 0)
	SetGlobalFloat(GLOBAL_PREFIX .. "PhaseEnd", 0)
	SetGlobalFloat(GLOBAL_PREFIX .. "Radius", 0)
	SetGlobalFloat(GLOBAL_PREFIX .. "TargetRadius", 0)
	SetGlobalFloat(GLOBAL_PREFIX .. "RedEnd", 0)
	SetGlobalFloat(GLOBAL_PREFIX .. "RedBombardStart", 0)
	SetGlobalFloat(GLOBAL_PREFIX .. "RedRadius", 0)
	SetGlobalVector(GLOBAL_PREFIX .. "Center", vector_origin)
	SetGlobalVector(GLOBAL_PREFIX .. "TargetCenter", vector_origin)
	SetGlobalVector(GLOBAL_PREFIX .. "RedCenter", vector_origin)
end

local function SyncZone(zone)
	SetGlobalBool(GLOBAL_PREFIX .. "Active", true)
	SetGlobalBool(GLOBAL_PREFIX .. "Shrinking", zone.State == "shrinking")
	SetGlobalInt(GLOBAL_PREFIX .. "Phase", zone.Phase)
	SetGlobalFloat(GLOBAL_PREFIX .. "PhaseEnd", zone.StateEnd or 0)
	SetGlobalFloat(GLOBAL_PREFIX .. "Radius", zone.Radius)
	SetGlobalFloat(GLOBAL_PREFIX .. "TargetRadius", zone.TargetRadius or zone.Radius)
	SetGlobalVector(GLOBAL_PREFIX .. "Center", zone.Center)
	SetGlobalVector(GLOBAL_PREFIX .. "TargetCenter", zone.TargetCenter or zone.Center)
end

local function FindGround(pos)
	local trace = util.TraceLine({
		start = pos + Vector(0, 0, 2048),
		endpos = pos - Vector(0, 0, 4096),
		mask = MASK_SOLID_BRUSHONLY
	})
	return trace.Hit and trace.HitPos or pos
end

local function FindFieldLootPosition(pos)
	local groundTrace = util.TraceLine({
		start = pos + Vector(0, 0, 192),
		endpos = pos - Vector(0, 0, 1024),
		mask = MASK_SOLID_BRUSHONLY
	})
	if not groundTrace.Hit or groundTrace.HitNormal.z < 0.55 then return end

	local spawnPos = groundTrace.HitPos + groundTrace.HitNormal * 14
	local clearance = util.TraceHull({
		start = spawnPos,
		endpos = spawnPos,
		mins = Vector(-10, -10, 0),
		maxs = Vector(10, 10, 28),
		mask = MASK_SOLID
	})
	if clearance.StartSolid or clearance.AllSolid then return end

	return spawnPos
end

local function BuildFieldLootPositions(count)
	local bases = table.Copy(BuildMapPositionCache())
	if #bases == 0 then return {} end
	table.Shuffle(bases)

	local output = {}
	local seen = {}
	local function AddPosition(pos)
		if not isvector(pos) then return false end
		local key = math.Round(pos.x / 96) .. ":" .. math.Round(pos.y / 96) .. ":" .. math.Round(pos.z / 64)
		if seen[key] then return false end
		seen[key] = true
		output[#output + 1] = pos
		return true
	end

	for _, base in ipairs(bases) do
		AddPosition(FindFieldLootPosition(base))
		if #output >= count then return output end
	end

	-- Maps without a navmesh may expose only a handful of spawn entities. Fill
	-- the remaining slots around those known-good areas and validate the floor.
	local attempts = 0
	while #output < count and attempts < count * 12 do
		attempts = attempts + 1
		local base = table.Random(bases)
		local angle = math.Rand(0, math.pi * 2)
		local distance = math.Rand(96, 640)
		local candidate = base + Vector(math.cos(angle) * distance, math.sin(angle) * distance, 0)
		AddPosition(FindFieldLootPosition(candidate))
	end

	return output
end

local function SpawnCompatibleAmmo(mode, weaponClass, weaponPos)
	local weaponData = weapons.Get(weaponClass)
	local primary = weaponData and weaponData.Primary
	local clipSize = primary and tonumber(primary.ClipSize) or 0
	local ammoData = primary and hg.ammotypeshuy and hg.ammotypeshuy[primary.Ammo]
	local ammoKey = ammoData and ammoData.name
	if clipSize <= 0 or not isstring(ammoKey) or not (hg.ammoents and hg.ammoents[ammoKey]) then return end

	local ammo = ents.Create("ent_ammo_" .. ammoKey)
	if not IsValid(ammo) then return end

	local angle = math.Rand(0, math.pi * 2)
	local nearby = weaponPos + Vector(math.cos(angle) * 28, math.sin(angle) * 28, 0)
	local ammoPos = FindFieldLootPosition(nearby) or nearby + Vector(0, 0, 4)
	local magazineCount = math.random(1, 5)
	local reserveAmmoCount = clipSize * magazineCount

	ammo.ZCityBattlegroundsFieldLoot = true
	ammo.ZCityBattlegroundsMagazineCount = magazineCount
	ammo.IsSpawned = true
	ammo.AmmoCount = reserveAmmoCount
	ammo:SetPos(ammoPos)
	ammo:SetAngles(Angle(0, math.random(0, 359), 0))
	ammo:Spawn()
	ammo:Activate()
	ammo.init = true
	ammo.AmmoCount = reserveAmmoCount

	mode.saved.FieldLoot[#mode.saved.FieldLoot + 1] = ammo
end

local function SpawnFieldLootEntity(mode, pos)
	if not hg or not hg.GenerateLoot then return false end

	for _ = 1, 6 do
		local class, ammoCount = hg.GenerateLoot()
		if isstring(class) and class ~= "" then
			local ent = ents.Create(class)
			if IsValid(ent) then
				ent.ZCityBattlegroundsFieldLoot = true
				ent.IsSpawned = true
				ent:SetPos(pos)
				ent:SetAngles(Angle(0, math.random(0, 359), 0))
				if ammoCount then ent.AmmoCount = ammoCount end
				ent:Spawn()
				ent:Activate()
				ent.init = true
				if ammoCount then ent.AmmoCount = ammoCount end

				mode.saved.FieldLoot[#mode.saved.FieldLoot + 1] = ent
				SpawnCompatibleAmmo(mode, class, pos)
				return true
			end
		end
	end

	return false
end

local function RemoveTrackedFieldLoot(mode)
	timer.Remove(fieldLootTimerName)
	for _, ent in ipairs(mode.saved.FieldLoot or {}) do
		if IsValid(ent) then ent:Remove() end
	end
	mode.saved.FieldLoot = {}
end

local function StartFieldLootSpawn(mode)
	RemoveTrackedFieldLoot(mode)

	local playerCount = math.max(zb.GetActivePlayerCount(), 1)
	local desired = math.Clamp(
		playerCount * mode.InitialFieldLootPerPlayer,
		mode.InitialFieldLootMinimum,
		mode.InitialFieldLootMaximum
	)
	local positions = BuildFieldLootPositions(desired)
	local nextPosition = 1

	local function SpawnBatch()
		if not IsBattlegroundsActive() then
			timer.Remove(fieldLootTimerName)
			return
		end

		local spawnedThisBatch = 0
		while nextPosition <= #positions and spawnedThisBatch < 6 do
			if SpawnFieldLootEntity(mode, positions[nextPosition]) then
				spawnedThisBatch = spawnedThisBatch + 1
			end
			nextPosition = nextPosition + 1
		end

		if nextPosition > #positions then
			timer.Remove(fieldLootTimerName)
		end
	end

	-- Put the first items down immediately, then spread the remaining entity
	-- creation over a few ticks to avoid a round-start hitch.
	SpawnBatch()
	if nextPosition <= #positions then
		timer.Create(fieldLootTimerName, 0.12, 0, SpawnBatch)
	end
end

local function PickPositionInsideZone(zone, edgeScale)
	local positions = BuildMapPositionCache()
	local candidates = {}
	local allowedRadius = zone.Radius * (edgeScale or 0.8)
	local allowedRadiusSqr = allowedRadius * allowedRadius

	for _, pos in ipairs(positions) do
		if HorizontalDistanceSqr(pos, zone.Center) <= allowedRadiusSqr then
			candidates[#candidates + 1] = pos
		end
	end

	if #candidates > 0 then return table.Random(candidates) end
	local angle = math.Rand(0, math.pi * 2)
	local distance = math.sqrt(math.Rand(0, 1)) * allowedRadius
	return FindGround(zone.Center + Vector(math.cos(angle) * distance, math.sin(angle) * distance, 0))
end

local function BuildAirdropContents()
	local contents = {
		table.Random(airdropWeapons),
		"ent_ammo_5.56x45mm",
		"ent_ammo_7.62x39mm",
		"weapon_medkit_sh",
		"weapon_bigbandage_sh",
		"weapon_tourniquet",
		"weapon_morphine",
		"ent_armor_vest4",
		table.Random(airdropAttachments),
		table.Random(airdropAttachments)
	}

	if math.random(100) <= 35 then contents[#contents + 1] = "ent_armor_helmet7" end
	if math.random(100) <= 30 then contents[#contents + 1] = "weapon_hg_grenade_tpik" end
	return contents
end

local function SpawnAirdrop(mode)
	local zone = mode.saved.Zone
	if not zone then return end

	local target = FindGround(PickPositionInsideZone(zone, 0.72))
	local upward = util.TraceLine({
		start = target + Vector(0, 0, 32),
		endpos = target + Vector(0, 0, 1000),
		mask = MASK_SOLID_BRUSHONLY
	})
	local spawnPos = target + Vector(0, 0, 800)
	if upward.Hit and not upward.HitSky then
		spawnPos = upward.HitPos - Vector(0, 0, 56)
	end

	local crate = ents.Create("ent_airdrop")
	if not IsValid(crate) then return end
	crate.ZCityBattlegroundsSupply = true
	crate:SetPos(spawnPos)
	crate:SetNWString("Contents", table.concat(BuildAirdropContents(), ","))
	crate:Spawn()
	crate:Activate()

	mode.saved.Airdrops = mode.saved.Airdrops or {}
	mode.saved.Airdrops[#mode.saved.Airdrops + 1] = crate
	PrintMessage(HUD_PRINTTALK, "[배틀그라운드] 안전 구역 안에 공중 보급이 투하되었습니다.")
end

local function ChooseNextZone(zone, scale)
	local targetRadius = math.max(zone.Radius * scale, minimumZoneRadius)
	local maximumOffset = math.max(zone.Radius - targetRadius, 0)
	local angle = math.Rand(0, math.pi * 2)
	local distance = math.sqrt(math.Rand(0, 1)) * maximumOffset
	local targetCenter = zone.Center + Vector(math.cos(angle) * distance, math.sin(angle) * distance, 0)
	return targetCenter, targetRadius
end

local function StartRedZone(mode)
	local zone = mode.saved.Zone
	if not zone then return end

	local red = {
		Center = PickPositionInsideZone(zone, 0.72),
		Radius = math.Clamp(zone.Radius * 0.18, 280, 650),
		EndTime = CurTime() + mode.RedZoneDuration,
		BombardStart = CurTime() + mode.RedZoneWarningDelay,
		NextExplosion = CurTime() + mode.RedZoneWarningDelay
	}
	mode.saved.RedZone = red

	SetGlobalBool(GLOBAL_PREFIX .. "RedActive", true)
	SetGlobalVector(GLOBAL_PREFIX .. "RedCenter", red.Center)
	SetGlobalFloat(GLOBAL_PREFIX .. "RedRadius", red.Radius)
	SetGlobalFloat(GLOBAL_PREFIX .. "RedEnd", red.EndTime)
	SetGlobalFloat(GLOBAL_PREFIX .. "RedBombardStart", red.BombardStart)
	PrintMessage(HUD_PRINTTALK, "[배틀그라운드] 레드존이 지정되었습니다. 폭격에 주의하십시오.")
end

local function ExplodeInRedZone(red)
	local angle = math.Rand(0, math.pi * 2)
	local distance = math.sqrt(math.Rand(0, 1)) * red.Radius
	local position = FindGround(red.Center + Vector(math.cos(angle) * distance, math.sin(angle) * distance, 0)) + Vector(0, 0, 12)

	local effect = EffectData()
	effect:SetOrigin(position)
	util.Effect("Explosion", effect, true, true)
	util.BlastDamage(game.GetWorld(), game.GetWorld(), position, 260, math.random(80, 135))
	sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", position, 105, math.random(90, 110))
end

local function RemoveTrackedAirdrops(mode)
	for _, crate in ipairs(mode.saved.Airdrops or {}) do
		if IsValid(crate) then crate:Remove() end
	end
	mode.saved.Airdrops = {}
end

function MODE:Intermission()
	RemoveTrackedFieldLoot(self)
	ClearGlobalState()
	game.CleanUpMap()

	local positions = BuildMapPositionCache()
	local center, radius = CalculateInitialZone(positions)
	self.saved.Zone = {
		Center = center,
		Radius = radius,
		TargetCenter = center,
		TargetRadius = radius,
		Phase = 1,
		State = "waiting",
		StateEnd = 0
	}
	self.saved.Airdrops = {}
	self.saved.FieldLoot = {}
	self.saved.RedZone = nil
	self.saved.Winner = nil

	local spawnPool = table.Copy(positions)
	table.Shuffle(spawnPool)
	local spawnIndex = 0
	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then
			ApplyAppearance(ply)
			ply:SetupTeam(TEAM_SURVIVOR)
			if #spawnPool > 0 then
				spawnIndex = spawnIndex % #spawnPool + 1
				ply:SetPos(spawnPool[spawnIndex] + Vector(0, 0, 8))
				ply:SetLocalVelocity(vector_origin)
			end
		end
	end
end

function MODE:GiveEquipment()
	for _, ply in player.Iterator() do
		if ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
			ply:SetSuppressPickupNotices(true)
			ply.noSound = true
			ply:StripWeapons()
			ply:RemoveAllAmmo()
			ply.armors = {}
			ply:SyncArmor()
			ply:SetMaxHealth(100)
			ply:SetHealth(100)
			ply:SetArmor(0)
			ply:GodDisable()
			ply:Give("weapon_hands_sh")
			ply:Give("weapon_bandage_sh")
			ply:SelectWeapon("weapon_hands_sh")
			if ply.organism then
				ply.organism.allowholster = true
				ply.organism.godmode = false
			end
			hg.CreateInv(ply)
			ply.noSound = false
			ply:SetSuppressPickupNotices(false)
		end
	end
end

function MODE:RoundStart()
	local now = CurTime()
	local zone = self.saved.Zone
	if not zone then
		local center, radius = CalculateInitialZone(BuildMapPositionCache())
		zone = {Center = center, Radius = radius, TargetCenter = center, TargetRadius = radius, Phase = 1, State = "waiting"}
		self.saved.Zone = zone
	end

	zone.State = "waiting"
	zone.StateEnd = now + (self.ZonePhases[1].Wait or 0)
	self.saved.NextRedZone = now + self.FirstRedZoneDelay
	self.saved.NextAirdrop = now + self.FirstAirdropDelay
	SyncZone(zone)
	StartFieldLootSpawn(self)
	PrintMessage(HUD_PRINTTALK, "[배틀그라운드] 최후의 한 명이 살아남을 때까지 파밍하고 싸우십시오.")
end

function MODE:CheckAlivePlayers()
	local alive = {}
	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR and ply:Alive() and not (ply.organism and ply.organism.incapacitated) then
			alive[#alive + 1] = ply
		end
	end
	return alive
end

function MODE:ShouldRoundEnd()
	local alive = self:CheckAlivePlayers()
	if #alive <= 1 then
		self.saved.Winner = alive[1]
		return true
	end
	-- nil intentionally leaves the generic round timer enabled.
end

function MODE:BoringRoundFunction()
	local zone = self.saved.Zone
	local winner
	local bestDistance
	for _, ply in ipairs(self:CheckAlivePlayers()) do
		local distance = zone and HorizontalDistanceSqr(ply:GetPos(), zone.Center) or 0
		if not bestDistance or distance < bestDistance then
			winner = ply
			bestDistance = distance
		end
	end
	self.saved.Winner = winner
end

function MODE:RoundThink()
	if not IsBattlegroundsActive() then return end
	local now = CurTime()
	local zone = self.saved.Zone
	if not zone then return end

	local phase = self.ZonePhases[zone.Phase]
	if phase then
		if zone.State == "waiting" and now >= zone.StateEnd then
			zone.State = "shrinking"
			zone.StartCenter = zone.Center
			zone.StartRadius = zone.Radius
			zone.TargetCenter, zone.TargetRadius = ChooseNextZone(zone, phase.Scale)
			zone.StateStart = now
			zone.StateEnd = now + phase.Shrink
			PrintMessage(HUD_PRINTTALK, "[배틀그라운드] 자기장이 줄어들기 시작합니다.")
		elseif zone.State == "shrinking" then
			local fraction = math.Clamp((now - zone.StateStart) / math.max(zone.StateEnd - zone.StateStart, 0.01), 0, 1)
			zone.Center = LerpVector(fraction, zone.StartCenter, zone.TargetCenter)
			zone.Radius = Lerp(fraction, zone.StartRadius, zone.TargetRadius)

			if fraction >= 1 then
				zone.Center = zone.TargetCenter
				zone.Radius = zone.TargetRadius
				zone.Phase = zone.Phase + 1
				local nextPhase = self.ZonePhases[zone.Phase]
				if nextPhase then
					zone.State = "waiting"
					zone.StateEnd = now + nextPhase.Wait
				else
					zone.State = "final"
					zone.StateEnd = 0
				end
			end
		end
	end

	local damagePhase = self.ZonePhases[math.min(zone.Phase, #self.ZonePhases)]
	local zoneRadiusSqr = zone.Radius * zone.Radius
	for _, ply in ipairs(self:CheckAlivePlayers()) do
		if HorizontalDistanceSqr(ply:GetPos(), zone.Center) > zoneRadiusSqr then
			local damage = DamageInfo()
			damage:SetDamage((damagePhase and damagePhase.Damage) or 25)
			damage:SetDamageType(DMG_RADIATION)
			damage:SetAttacker(game.GetWorld())
			damage:SetInflictor(game.GetWorld())
			ply:TakeDamageInfo(damage)
		end
	end

	local red = self.saved.RedZone
	if red then
		if now >= red.EndTime then
			self.saved.RedZone = nil
			self.saved.NextRedZone = now + self.RedZoneInterval
			SetGlobalBool(GLOBAL_PREFIX .. "RedActive", false)
			SetGlobalFloat(GLOBAL_PREFIX .. "RedEnd", 0)
		else
			local explosions = 0
			while now >= red.NextExplosion and explosions < 2 do
				ExplodeInRedZone(red)
				red.NextExplosion = red.NextExplosion + math.Rand(0.65, 1.15)
				explosions = explosions + 1
			end
		end
	elseif now >= (self.saved.NextRedZone or math.huge) then
		StartRedZone(self)
	end

	if now >= (self.saved.NextAirdrop or math.huge) then
		SpawnAirdrop(self)
		self.saved.NextAirdrop = now + self.AirdropInterval
	end

	SyncZone(zone)
end

function MODE:EndRound()
	local winner = self.saved.Winner
	if IsValid(winner) then
		PrintMessage(HUD_PRINTTALK, "[배틀그라운드] " .. winner:GetPlayerName() .. "님이 최후의 생존자가 되었습니다.")
		winner:GiveExp(math.random(25, 40))
		winner:GiveSkill(math.Rand(0.1, 0.18))
	else
		PrintMessage(HUD_PRINTTALK, "[배틀그라운드] 생존자 없이 전투가 종료되었습니다.")
	end

	RemoveTrackedAirdrops(self)
	RemoveTrackedFieldLoot(self)
	self.saved.RedZone = nil
	ClearGlobalState()
end

function MODE:PlayerDeath(ply)
end

function MODE:CanSpawn()
end
