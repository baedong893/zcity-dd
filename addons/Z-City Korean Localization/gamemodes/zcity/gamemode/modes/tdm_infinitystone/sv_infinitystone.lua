local MODE = MODE

util.AddNetworkString("ZCityInfinityPowerStonePos")
util.AddNetworkString("ZCityInfinityStonePositions")
util.AddNetworkString("ZCityInfinityStartSound")

local infinityStartSoundPath = "sound/zcity/infinitystone/FINE-I_LL-DO-IT-MYSELF.wav"

if file.Exists(infinityStartSoundPath, "GAME") then
	resource.AddFile(infinityStartSoundPath)
else
	print("[InfinityStone] Missing start sound: " .. infinityStartSoundPath)
end

local infinityAttackStun = 1
local infinityAttackButtons = bit.bor(IN_ATTACK, IN_ATTACK2)

-- 스폰 지점 기반 배치 설정
local stonePlayerAvoidDistance = 500
local stoneSpawnMinDistance = 96
local stoneSameSpawnMinDistance = 64

local infinityStones = {
	{ id = 1, class = "ig_gem_soul", name = "soul" },
	{ id = 2, class = "ig_gem_reality", name = "reality" },
	{ id = 3, class = "ig_gem_space", name = "space" },
	{ id = 4, class = "ig_gem_power", name = "power" },
	{ id = 5, class = "ig_gem_time", name = "time" },
	{ id = 6, class = "ig_gem_mind", name = "mind" }
}

local spawnClasses = {
	"info_player_start", "info_player_deathmatch", "info_player_combine", "info_player_rebel",
	"info_player_counterterrorist", "info_player_terrorist", "info_player_axis",
	"info_player_allies", "gmod_player_start", "info_player_teamspawn",
	"ins_spawnpoint", "aoc_spawnpoint", "dys_spawn_point", "info_player_pirate",
	"info_player_viking", "info_player_knight", "diprip_start_team_blue", "diprip_start_team_red",
	"info_player_red", "info_player_blue", "info_player_coop", "info_player_human", "info_player_zombie",
	"info_player_zombiemaster", "info_player_fof", "info_player_desperado", "info_player_vigilante", "info_survivor_rescue"
}

local function IsInfinityStoneRound()
	local round = CurrentRound()
	return round and round.name == "infinitystone"
end

local function IsInfinityGauntlet(wep)
	return IsValid(wep) and wep:GetClass() == "infinitygauntlet"
end

local function StunInfinityAttack(ply)
	if not IsValid(ply) or not ply:Alive() then return end

	local stunUntil = CurTime() + infinityAttackStun
	ply.ZCityInfinityAttackStunUntil = math.max(ply.ZCityInfinityAttackStunUntil or 0, stunUntil)
	ply:SetNWFloat("ZCityInfinityAttackStunUntil", ply.ZCityInfinityAttackStunUntil)

	local wep = ply:GetActiveWeapon()
	if IsInfinityGauntlet(wep) then
		wep:SetNextPrimaryFire(stunUntil)
		wep:SetNextSecondaryFire(stunUntil)
	end
end

local function ClearInfinityAttackStun(ply)
	if not IsValid(ply) then return end

	ply.ZCityInfinityAttackStunUntil = nil
	ply:SetNWFloat("ZCityInfinityAttackStunUntil", 0)
end

local function GiveWeapon(ply, class)
	if not weapons.GetStored(class) then
		print("[InfinityStone] Missing weapon class: " .. tostring(class))
		return
	end

	local wep = ply:Give(class)

	if IsValid(wep) then
		ply:SelectWeapon(class)
	end

	return wep
end

local function GiveEmptyGauntlet(ply)
	if not weapons.GetStored("infinitygauntlet_empty") then
		print("[InfinityStone] Missing weapon class: infinitygauntlet_empty")
		return false
	end

	local holder = GiveWeapon(ply, "infinitygauntlet_empty")

	if IsValid(holder) then
		holder.noStonesCreated = true
		return true
	end

	return false
end

local function CanCreateEntity(class)
	return scripted_ents.GetStored(class) ~= nil
end

local function IsInfinityStoneClass(class)
	for _, stone in ipairs(infinityStones) do
		if stone.class == class then
			return true
		end
	end

	return false
end

local function IsAliveRoundPlayer(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if ply:Team() == TEAM_SPECTATOR then return false end
	if not ply:Alive() then return false end
	if ply.organism and ply.organism.incapacitated then return false end

	return true
end

local function AddUniqueSpawnPosition(positions, used, pos)
	if not isvector(pos) then return end

	local key = math.Round(pos.x) .. ":" .. math.Round(pos.y) .. ":" .. math.Round(pos.z)

	if used[key] then return end

	used[key] = true
	positions[#positions + 1] = pos
end

local function GetSpawnPositions()
	local positions = {}
	local used = {}
	local points = zb.GetMapPoints and zb.GetMapPoints("Spawnpoint") or {}

	for _, point in ipairs(points or {}) do
		AddUniqueSpawnPosition(positions, used, point.pos)
	end

	if #positions <= 0 then
		for _, class in ipairs(spawnClasses) do
			for _, ent in ipairs(ents.FindByClass(class)) do
				if IsValid(ent) then
					AddUniqueSpawnPosition(positions, used, ent:GetPos())
				end
			end
		end
	end

	if #positions <= 0 then
		for _, ply in player.Iterator() do
			if ply:Alive() then
				AddUniqueSpawnPosition(positions, used, ply:GetPos())
			end
		end
	end

	if #positions <= 0 then
		positions[1] = Vector(0, 0, 128)
	end

	return positions
end

local function ShufflePositions(positions)
	local shuffled = table.Copy(positions or {})

	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	return shuffled
end

local function IsFarFromPlayers(pos, minDistance)
	if not isvector(pos) then return false end

	local minDistSqr = minDistance * minDistance

	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
			if pos:DistToSqr(ply:GetPos()) < minDistSqr then
				return false
			end
		end
	end

	return true
end

local function IsSpawnSpotAlreadyUsed(pos, usedPositions, minDistance)
	if not isvector(pos) then return true end

	local minDistSqr = minDistance * minDistance

	for _, usedPos in ipairs(usedPositions or {}) do
		if isvector(usedPos) and pos:DistToSqr(usedPos) < minDistSqr then
			return true
		end
	end

	return false
end

local function NormalizeStoneSpawnPos(pos)
	if not isvector(pos) then return end

	-- 중요:
	-- 스폰 에디터로 찍은 좌표를 신뢰한다.
	-- TraceFloor / DropToFloor를 쓰면 2층, 철망, 좁은 방, 얇은 바닥에서 아래층으로 떨어질 수 있음.
	return pos + Vector(0, 0, 4)
end

local function IsValidStoneSpawnPos(pos)
	if not isvector(pos) then return false end

	local checkPos = NormalizeStoneSpawnPos(pos)
	if not checkPos then return false end

	-- 스톤은 작은 엔티티라 작은 Hull만 검사
	local hull = util.TraceHull({
		start = checkPos,
		endpos = checkPos,
		mins = Vector(-5, -5, 0),
		maxs = Vector(5, 5, 10),
		mask = MASK_SOLID
	})

	if hull.Hit or hull.StartedSolid then
		return false
	end

	return true
end

local function BuildEmergencyStonePosition(index, usedPositions)
	local spawns = GetSpawnPositions()
	local base = spawns[((index - 1) % math.max(#spawns, 1)) + 1] or Vector(0, 0, 128)

	for attempt = 1, 32 do
		local angle = math.rad((index * 137) + attempt * 37)
		local dist = 80 + attempt * 24

		local candidate = base + Vector(
			math.cos(angle) * dist,
			math.sin(angle) * dist,
			16
		)

		local finalPos = NormalizeStoneSpawnPos(candidate)

		if finalPos
			and not IsSpawnSpotAlreadyUsed(finalPos, usedPositions, stoneSameSpawnMinDistance)
			and IsValidStoneSpawnPos(finalPos)
		then
			print("[InfinityStone] Emergency stone spawn position used.")
			return finalPos
		end
	end

	-- 정말 아무 데도 못 찾았을 때만 최후 fallback
	print("[InfinityStone] Forced fallback stone position used.")
	return Vector(0, 0, 128 + index * 32)
end

local function BuildStoneSpawnPositions(count)
	local positions = {}
	local spawns = ShufflePositions(GetSpawnPositions())

	-- 1차: 플레이어와 멀고, 유효하고, 아직 스톤이 없는 스폰 지점
	for _, spawnPos in ipairs(spawns) do
		if #positions >= count then break end

		local finalPos = NormalizeStoneSpawnPos(spawnPos)

		if finalPos
			and IsValidStoneSpawnPos(spawnPos)
			and IsFarFromPlayers(finalPos, stonePlayerAvoidDistance)
			and not IsSpawnSpotAlreadyUsed(finalPos, positions, stoneSpawnMinDistance)
		then
			positions[#positions + 1] = finalPos
		end
	end

	-- 2차: 플레이어 거리 조건 무시
	if #positions < count then
		for _, spawnPos in ipairs(spawns) do
			if #positions >= count then break end

			local finalPos = NormalizeStoneSpawnPos(spawnPos)

			if finalPos
				and IsValidStoneSpawnPos(spawnPos)
				and not IsSpawnSpotAlreadyUsed(finalPos, positions, stoneSpawnMinDistance)
			then
				positions[#positions + 1] = finalPos
			end
		end
	end

	-- 3차: 좁은 맵 대응. 같은 위치만 아니면 허용
	if #positions < count then
		for _, spawnPos in ipairs(spawns) do
			if #positions >= count then break end

			local finalPos = NormalizeStoneSpawnPos(spawnPos)

			if finalPos
				and IsValidStoneSpawnPos(spawnPos)
				and not IsSpawnSpotAlreadyUsed(finalPos, positions, stoneSameSpawnMinDistance)
			then
				positions[#positions + 1] = finalPos
			end
		end
	end

	-- 4차: 6개 무조건 생성 보장
	-- 스폰 지점이 정말 부족하거나 전부 막혀 있을 때만 emergency 위치 사용
	while #positions < count do
		local emergencyPos = BuildEmergencyStonePosition(#positions + 1, positions)
		positions[#positions + 1] = emergencyPos
	end

	return positions
end

local function ScatterPosition(basePos, index)
	if not isvector(basePos) then
		return Vector(0, 0, 128)
	end

	local angle = math.rad((index - 1) * 60 + math.Rand(-20, 20))
	local dist = math.Rand(80, 180)

	return basePos + Vector(
		math.cos(angle) * dist,
		math.sin(angle) * dist,
		12
	)
end

local function SpawnStone(stone, pos)
	if not stone or not stone.class then return end

	if not CanCreateEntity(stone.class) then
		print("[InfinityStone] Missing entity class: " .. tostring(stone.class))
		return
	end

	local safePos = NormalizeStoneSpawnPos(pos)

	if not safePos then
		safePos = BuildEmergencyStonePosition(stone.id or 1, {})
	end

	local gem = ents.Create(stone.class)
	if not IsValid(gem) then return end

	gem.ZCityInfinityStone = true
	gem.ZCityInfinityStoneID = stone.id
	gem:SetNWBool("ZCityInfinityStone", true)
	gem:SetNWInt("ZCityInfinityStoneID", stone.id)

	-- 중요:
	-- DropToFloor 사용 금지.
	-- 스폰 에디터 좌표를 그대로 사용한다.
	gem:SetPos(safePos)
	gem:Spawn()
	gem:Activate()

	local phys = gem:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:SetVelocity(Vector(0, 0, 0))
		phys:SetAngleVelocity(Vector(0, 0, 0))

		-- 스톤이 굴러가거나 튀지 않게 고정
		phys:EnableMotion(false)
	end

	return gem
end

local function RemoveWorldStones()
	for _, stone in ipairs(infinityStones) do
		for _, ent in ipairs(ents.FindByClass(stone.class)) do
			if IsValid(ent) then
				ent:Remove()
			end
		end
	end
end

local function BroadcastPowerStonePosition(pos)
	net.Start("ZCityInfinityPowerStonePos")
		net.WriteBool(isvector(pos))

		if isvector(pos) then
			net.WriteVector(pos)
		end
	net.Broadcast()
end

local function BroadcastStonePositions()
	local found = {}

	for _, stone in ipairs(infinityStones) do
		for _, ent in ipairs(ents.FindByClass(stone.class)) do
			if IsValid(ent) then
				found[#found + 1] = { id = stone.id, pos = ent:GetPos() }
				break
			end
		end
	end

	net.Start("ZCityInfinityStonePositions")
		net.WriteUInt(#found, 4)

		for _, data in ipairs(found) do
			net.WriteUInt(data.id, 4)
			net.WriteVector(data.pos)
		end
	net.Broadcast()
end

local function FindPowerStone()
	for _, ent in ipairs(ents.FindByClass("ig_gem_power")) do
		if IsValid(ent) then
			return ent
		end
	end
end

local function GetHeldStones(ply)
	local held = {}

	if not IsValid(ply) then return held end

	local gauntlet = ply:GetWeapon("infinitygauntlet")

	if not IsValid(gauntlet) or not gauntlet.HasStone then
		return held
	end

	for _, stone in ipairs(infinityStones) do
		if gauntlet:HasStone(stone.id) then
			held[#held + 1] = stone
		end
	end

	return held, gauntlet
end

local function DropHeldStones(ply)
	local held, gauntlet = GetHeldStones(ply)

	if #held <= 0 then return end

	local basePos = IsValid(ply) and ply:GetPos() or Vector(0, 0, 128)

	for index, stone in ipairs(held) do
		if IsValid(gauntlet) and gauntlet.SetHasStone then
			gauntlet:SetHasStone(stone.id, false)
		end

		SpawnStone(stone, ScatterPosition(basePos, index))
	end

	local power = FindPowerStone()
	BroadcastPowerStonePosition(IsValid(power) and power:GetPos() or nil)
	BroadcastStonePositions()
end

local function CountAliveRoundPlayers()
	local aliveCount = 0

	for _, ply in player.Iterator() do
		if IsAliveRoundPlayer(ply) then
			aliveCount = aliveCount + 1
		end
	end

	return aliveCount
end

function MODE:CanLaunch()
	return true
end

function MODE:Intermission()
	game.CleanUpMap()

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		ApplyAppearance(ply)
		ply:SetupTeam(0)
		ClearInfinityAttackStun(ply)
	end
end

function MODE:ShouldRoundEnd()
	return CountAliveRoundPlayers() <= 1
end

function MODE:RoundStart()
	timer.Simple(0.2, function()
		local round = CurrentRound()

		if not round or round.name ~= "infinitystone" then return end

		net.Start("ZCityInfinityStartSound")
		net.Broadcast()
	end)

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end

		ply:StripWeapons()
		ply:RemoveAllAmmo()
		ClearInfinityAttackStun(ply)
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true

		local gauntletGiven = GiveEmptyGauntlet(ply)

		if not gauntletGiven then
			GiveWeapon(ply, "weapon_hands_sh")
		end

		zb.GiveRole(ply, "Gauntlet", Color(170, 80, 255))

		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply.noSound = false
				ply:SetSuppressPickupNotices(false)
			end
		end)
	end

	timer.Simple(1, function()
		local round = CurrentRound()

		if not round or round.name ~= "infinitystone" then return end

		RemoveWorldStones()

		local positions = BuildStoneSpawnPositions(#infinityStones)

		for index, stone in ipairs(infinityStones) do
			SpawnStone(stone, positions[index])
		end

		local power = FindPowerStone()
		BroadcastPowerStonePosition(IsValid(power) and power:GetPos() or nil)
		BroadcastStonePositions()
	end)
end

function MODE:GiveEquipment()
end

hook.Add("Think", "ZCityInfinityPowerStonePos", function()
	local round = CurrentRound()

	if not round or round.name ~= "infinitystone" then return end

	if (MODE.NextPowerStonePosSend or 0) > CurTime() then return end

	MODE.NextPowerStonePosSend = CurTime() + 1

	local gem = FindPowerStone()

	BroadcastPowerStonePosition(IsValid(gem) and gem:GetPos() or nil)
	BroadcastStonePositions()
end)

hook.Add("EntityRemoved", "ZCityInfinityPowerStonePickedUp", function(ent)
	if not ent or not IsInfinityStoneClass(ent:GetClass()) then return end

	local round = CurrentRound()

	if not round or round.name ~= "infinitystone" then return end

	timer.Simple(0, function()
		local currentRound = CurrentRound()

		if not currentRound or currentRound.name ~= "infinitystone" then return end

		local power = FindPowerStone()

		BroadcastPowerStonePosition(IsValid(power) and power:GetPos() or nil)
		BroadcastStonePositions()
	end)
end)

hook.Add("PlayerDeath", "ZCityInfinityDropHeldStones", function(ply)
	if not IsInfinityStoneRound() then return end

	DropHeldStones(ply)
end)

hook.Add("Think", "ZCityInfinityForceRoundEnd", function()
	local round = CurrentRound()

	if not round or round.name ~= "infinitystone" then return end
	if not zb or zb.ROUND_STATE ~= 1 then return end

	if (MODE.NextForceEndCheck or 0) > CurTime() then return end

	MODE.NextForceEndCheck = CurTime() + 0.5

	if CountAliveRoundPlayers() <= 1 then
		zb:EndRound()
	end
end)

hook.Add("KeyPress", "ZCityInfinityAttackStun", function(ply, key)
	if not IsInfinityStoneRound() then return end
	if key ~= IN_ATTACK and key ~= IN_ATTACK2 then return end
	if not IsInfinityGauntlet(ply:GetActiveWeapon()) then return end
	if (ply.ZCityInfinityAttackStunUntil or 0) > CurTime() then return end

	timer.Simple(0, function()
		if not IsInfinityStoneRound() then return end
		if not IsValid(ply) then return end
		if not IsInfinityGauntlet(ply:GetActiveWeapon()) then return end

		StunInfinityAttack(ply)
	end)
end)

hook.Add("StartCommand", "ZCityInfinityAttackStun", function(ply, cmd)
	if not IsInfinityStoneRound() then return end
	if (ply.ZCityInfinityAttackStunUntil or 0) <= CurTime() then return end

	cmd:RemoveKey(infinityAttackButtons)
	cmd:SetForwardMove(0)
	cmd:SetSideMove(0)
	cmd:SetUpMove(0)
end)

hook.Add("ZB_PreRoundStart", "ZCityInfinityClearAttackStun", function()
	for _, ply in player.Iterator() do
		ClearInfinityAttackStun(ply)
	end
end)