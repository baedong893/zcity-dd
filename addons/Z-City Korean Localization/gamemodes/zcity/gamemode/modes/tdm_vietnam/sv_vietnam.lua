local MODE = MODE

local usColor = Color(70, 140, 230)
local vietnamColor = Color(190, 60, 45)
local cleanModelColor = Vector(1, 1, 1)
local abilityRequestNet = "ZCityVietnamUseAbility"
local reconNet = "ZCityVietnamRecon"

util.AddNetworkString(abilityRequestNet)
util.AddNetworkString(reconNet)
local jungleModelWeights = {
	["models/rising_storm/foliage/bamboo_wall01.mdl"] = 12,
	["models/rising_storm/foliage/bamboo_wall02.mdl"] = 12,
	["models/rising_storm/foliage/jungle_bush4.mdl"] = 14,
	["models/rising_storm/foliage/jungle_tree01.mdl"] = 1,
	["models/rising_storm/foliage/jungle_tree02.mdl"] = 1,
	["models/rising_storm/foliage/jungle_tree04.mdl"] = 1
}

local function AddModelFiles(modelPath)
	local basePath = string.StripExtension(modelPath)
	local files = {
		modelPath,
		basePath .. ".dx80.vtx",
		basePath .. ".dx90.vtx",
		basePath .. ".sw.vtx",
		basePath .. ".vvd",
		basePath .. ".phy"
	}

	for _, path in ipairs(files) do
		if file.Exists(path, "GAME") then
			resource.AddFile(path)
		end
	end
end

for _, modelPath in ipairs(MODE.USModels or {}) do
	AddModelFiles(modelPath)
end

for _, modelPath in ipairs(MODE.VietnamModels or {}) do
	AddModelFiles(modelPath)
end

for _, modelPath in ipairs(MODE.JungleModels or {}) do
	AddModelFiles(modelPath)
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
		if IsValid(ply) and CurrentRound() and CurrentRound().name == "vietnam" then
			ApplyCleanRoleModel(ply, modelPath)
		end
	end)
end

local function GiveAmmoForWeapon(ply, weapon, multiplier)
	if not IsValid(ply) or not IsValid(weapon) or not weapon.GetPrimaryAmmoType then return end

	local ammoType = weapon:GetPrimaryAmmoType()
	if ammoType and ammoType >= 0 then
		local maxClip = weapon:GetMaxClip1() or 0
		if maxClip <= 0 then maxClip = 30 end
		ply:GiveAmmo(maxClip * (multiplier or 5), ammoType, true)
	end
end

local function ShufflePlayerList(players)
	local shuffled = table.Copy(players or {})
	for index = #shuffled, 2, -1 do
		local swapIndex = math.random(index)
		shuffled[index], shuffled[swapIndex] = shuffled[swapIndex], shuffled[index]
	end
	return shuffled
end

local function GetRoleQuota(roleData, playerCount)
	if not istable(roleData) or playerCount < (roleData.MinPlayers or 1) then return 0 end
	if roleData.FixedCount then return math.max(math.floor(roleData.FixedCount), 0) end
	if roleData.PerPlayers then return math.max(math.floor(playerCount / roleData.PerPlayers), 0) end
	return 0
end

local function AssignTeamRoles(players, teamId)
	local shuffled = ShufflePlayerList(players)
	local assignments = {}
	local roleDefinitions = MODE.RoleDefinitions and MODE.RoleDefinitions[teamId] or {}
	local specialOrder = MODE.RoleSpecialOrder and MODE.RoleSpecialOrder[teamId] or {}
	local fallbackOrder = MODE.RoleFallbackOrder and MODE.RoleFallbackOrder[teamId] or {}
	local reserveCount = math.min(MODE.RoleMinimumBasePlayers or 2, #shuffled)
	local specialSlots = math.max(#shuffled - reserveCount, 0)
	local playerIndex = 1

	for _, roleId in ipairs(specialOrder) do
		local quota = math.min(GetRoleQuota(roleDefinitions[roleId], #shuffled), specialSlots)
		for _ = 1, quota do
			local ply = shuffled[playerIndex]
			if not IsValid(ply) then break end
			assignments[ply] = roleId
			playerIndex = playerIndex + 1
			specialSlots = specialSlots - 1
		end
		if specialSlots <= 0 then break end
	end

	if #fallbackOrder <= 0 then return assignments end
	local fallbackIndex = 1
	while playerIndex <= #shuffled do
		local ply = shuffled[playerIndex]
		if IsValid(ply) then assignments[ply] = fallbackOrder[fallbackIndex] end
		fallbackIndex = fallbackIndex % #fallbackOrder + 1
		playerIndex = playerIndex + 1
	end

	return assignments
end

local function ResolveRoleClass(entry)
	if isstring(entry) then return entry end
	if not istable(entry) then return end
	if isstring(entry.Class) then return entry.Class end
	if istable(entry.Classes) and #entry.Classes > 0 then return table.Random(entry.Classes) end
end

local function GiveRoleWeapon(ply, weaponData)
	local class = ResolveRoleClass(weaponData)
	if not class then return end

	local weapon = ply:Give(class)
	if not IsValid(weapon) then
		print("[Vietnam] Missing role weapon class: " .. class)
		return
	end

	if istable(weaponData) and weaponData.Clips then
		GiveAmmoForWeapon(ply, weapon, weaponData.Clips)
	end

	return class, istable(weaponData) and weaponData.Select == true
end

local function GiveRoleLoadout(ply, roleData, isUS)
	for _, class in ipairs({"weapon_hands_sh", "weapon_melee", "weapon_bandage_sh", "weapon_tourniquet"}) do
		ply:Give(class)
	end

	local radio = ply:Give("weapon_walkie_talkie")
	if IsValid(radio) then radio.Frequency = isUS and 91.1 or 104.8 end

	local selectedClass = "weapon_hands_sh"
	for _, weaponData in ipairs(roleData.Weapons or {}) do
		local class, shouldSelect = GiveRoleWeapon(ply, weaponData)
		if class and shouldSelect then selectedClass = class end
	end

	for _, itemData in ipairs(roleData.Items or {}) do
		local class = ResolveRoleClass(itemData)
		if class then ply:Give(class) end
	end

	ply:SelectWeapon(selectedClass)
end

function MODE:CleanupRoleState()
	local roleKey = self.RoleNWKey or "ZCityVietnamRole"
	for _, ply in player.Iterator() do
		ply:SetNWString(roleKey, "")
		if zb and zb.GiveRole then zb.GiveRole(ply, "", color_white) end
	end
end

local function GetTeamPlayers(teamId)
	local players = {}

	for _, ply in player.Iterator() do
		if ply:Team() == teamId and ply:Alive() then
			players[#players + 1] = ply
		end
	end

	return players
end

local function IsVietnamRoundActive()
	return zb and zb.ROUND_STATE == 1 and (zb.CROUND_MAIN == MODE.name or zb.CROUND == MODE.name)
end

local activeAmbushPlayers = {}
local activeTunnelPlayers = {}

local function GetCooldownKey(abilityId)
	return "ZCityVietnamCooldown_" .. abilityId
end

local function GetTeamCooldownKey(teamId, abilityId)
	return "ZCityVietnamTeamCooldown_" .. teamId .. "_" .. abilityId
end

local function SetAbilityCooldown(ply, abilityId, ability)
	local cooldownEnd = CurTime() + (ability.Cooldown or 0)
	if ability.SharedTeamCooldown then
		SetGlobalFloat(GetTeamCooldownKey(ply:Team(), abilityId), cooldownEnd)
		return
	end

	ply.ZCityVietnamCooldowns = ply.ZCityVietnamCooldowns or {}
	ply.ZCityVietnamCooldowns[abilityId] = cooldownEnd
	ply:SetNWFloat(GetCooldownKey(abilityId), cooldownEnd)
end

local function GetAbilityCooldown(ply, abilityId, ability)
	if ability.SharedTeamCooldown then
		return math.max(GetGlobalFloat(GetTeamCooldownKey(ply:Team(), abilityId), 0) - CurTime(), 0)
	end

	return math.max(((ply.ZCityVietnamCooldowns or {})[abilityId] or 0) - CurTime(), 0)
end

local function EndAmbush(ply)
	if not IsValid(ply) then
		activeAmbushPlayers[ply] = nil
		return
	end
	if not ply.ZCityVietnamAmbushEnd and not ply:GetNWBool("ZCityVietnamAmbush", false) then return end

	local oldColor = ply.ZCityVietnamAmbushColor
	if IsColor(oldColor) then ply:SetColor(oldColor) end
	ply:SetRenderMode(ply.ZCityVietnamAmbushRenderMode or RENDERMODE_NORMAL)
	ply:SetNWBool("ZCityVietnamAmbush", false)
	ply:SetNWFloat("ZCityVietnamAmbushEnd", 0)
	ply.ZCityVietnamAmbushEnd = nil
	ply.ZCityVietnamAmbushColor = nil
	ply.ZCityVietnamAmbushRenderMode = nil
	activeAmbushPlayers[ply] = nil
end

local function StartAmbush(ply, ability)
	if ply.ZCityVietnamAmbushEnd then
		ply:ChatPrint("이미 매복 중입니다.")
		return false
	end

	local duration = istable(ability.Duration) and ability.Duration[ply:Team()] or ability.Duration
	if not isnumber(duration) or duration <= 0 then return false end

	local oldColor = ply:GetColor()
	ply.ZCityVietnamAmbushColor = Color(oldColor.r, oldColor.g, oldColor.b, oldColor.a)
	ply.ZCityVietnamAmbushRenderMode = ply:GetRenderMode()
	ply.ZCityVietnamAmbushEnd = CurTime() + duration
	activeAmbushPlayers[ply] = true
	ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	ply:SetColor(Color(oldColor.r, oldColor.g, oldColor.b, 90))
	ply:SetNWBool("ZCityVietnamAmbush", true)
	ply:SetNWFloat("ZCityVietnamAmbushEnd", ply.ZCityVietnamAmbushEnd)
	ply:ChatPrint("매복을 시작했습니다. 달리면 즉시 해제됩니다.")
	return true
end

local function IsPositionClear(ply, pos)
	local mins, maxs = ply:GetHull()
	local tr = util.TraceHull({
		start = pos,
		endpos = pos,
		mins = mins,
		maxs = maxs,
		mask = MASK_PLAYERSOLID,
		filter = ply
	})

	return not tr.StartSolid and not tr.AllSolid and not tr.Hit
end

local tunnelOffsets = {
	Vector(0, 0, 0),
	Vector(0, 0, 24),
	Vector(32, 0, 8),
	Vector(-32, 0, 8),
	Vector(0, 32, 8),
	Vector(0, -32, 8)
}

local function FindClearPosition(ply, origin)
	if not isvector(origin) then return end

	for _, offset in ipairs(tunnelOffsets) do
		local candidate = origin + offset
		if IsPositionClear(ply, candidate) then return candidate end
	end
end

local function GetAimedGroundPosition(ply, maxDistance)
	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:GetAimVector() * maxDistance,
		mask = MASK_SOLID,
		filter = ply
	})

	if not tr.Hit or tr.HitSky or tr.HitNormal.z < 0.5 then return end
	return tr.HitPos + tr.HitNormal * 4, tr.HitNormal
end

local function GetTunnelEntrancePosition(ply)
	local tr = util.TraceLine({
		start = ply:GetPos() + Vector(0, 0, 24),
		endpos = ply:GetPos() - Vector(0, 0, 128),
		mask = MASK_SOLID_BRUSHONLY,
		filter = ply
	})

	if tr.Hit and not tr.HitSky then return tr.HitPos + tr.HitNormal * 2 end
	return ply:GetPos()
end

local function GetTunnelNetworks()
	MODE.saved = MODE.saved or {}
	MODE.saved.VietnamTunnelNetworks = MODE.saved.VietnamTunnelNetworks or {}
	return MODE.saved.VietnamTunnelNetworks
end

local function RemoveTunnelNetwork(network)
	if not istable(network) or network.Removed then return end
	network.Removed = true

	if IsValid(network.Entrance) then network.Entrance:Remove() end
	if IsValid(network.Exit) then network.Exit:Remove() end

	local networks = GetTunnelNetworks()
	for index = #networks, 1, -1 do
		if networks[index] == network then
			table.remove(networks, index)
			break
		end
	end
end

local function PruneTunnelNetworks()
	local networks = GetTunnelNetworks()
	for index = #networks, 1, -1 do
		local network = networks[index]
		if not istable(network) or network.Removed or not IsValid(network.Entrance) or not IsValid(network.Exit) then
			if istable(network) then
				if IsValid(network.Entrance) then network.Entrance:Remove() end
				if IsValid(network.Exit) then network.Exit:Remove() end
			end
			table.remove(networks, index)
		end
	end
	return networks
end

local function RemoveTunnelDoors(ply)
	if not IsValid(ply) then return end

	local networks = GetTunnelNetworks()
	for index = #networks, 1, -1 do
		if networks[index].Owner == ply then RemoveTunnelNetwork(networks[index]) end
	end
end

local function SpawnTunnelDoor(ply, pos, yaw, doorType)
	local door = ents.Create("prop_physics")
	if not IsValid(door) then return end

	door:SetModel(MODE.TunnelDoorModel)
	door:SetPos(pos)
	door:SetAngles(Angle(0, yaw, 0))
	door:PhysicsInit(SOLID_VPHYSICS)
	door:SetMoveType(MOVETYPE_VPHYSICS)
	door:SetSolid(SOLID_VPHYSICS)
	door.ZCityVietnamTunnelDoor = true
	door:SetNWBool("ZCityVietnamTunnelDoor", true)
	door:SetNWString("ZCityVietnamTunnelDoorType", doorType)
	door:Spawn()
	door:Activate()
	door:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	door:SetHealth(MODE.TunnelDoorHealth or 100)
	door:SetMaxHealth(MODE.TunnelDoorHealth or 100)

	local physics = door:GetPhysicsObject()
	if IsValid(physics) then physics:EnableMotion(false) end
	door:DrawShadow(true)

	return door
end

local function MakeRoomForTunnelNetwork()
	local networks = PruneTunnelNetworks()
	if #networks < (MODE.MaxTunnelNetworks or 8) then return true end

	local oldestIndex
	for index, network in ipairs(networks) do
		if network.Ready and (not oldestIndex or network.CreatedAt < networks[oldestIndex].CreatedAt) then
			oldestIndex = index
		end
	end
	if not oldestIndex then return false end

	RemoveTunnelNetwork(networks[oldestIndex])
	return true
end

local function LinkTunnelDoors(ply, entranceDoor, exitDoor)
	local network = {
		Owner = ply,
		Entrance = entranceDoor,
		Exit = exitDoor,
		CreatedAt = CurTime(),
		CooldownEnd = 0,
		Ready = false
	}

	entranceDoor.ZCityVietnamTunnelPartner = exitDoor
	exitDoor.ZCityVietnamTunnelPartner = entranceDoor
	entranceDoor.ZCityVietnamTunnelNetwork = network
	exitDoor.ZCityVietnamTunnelNetwork = network
	entranceDoor:SetNWBool("ZCityVietnamTunnelReady", false)
	exitDoor:SetNWBool("ZCityVietnamTunnelReady", false)
	local networks = GetTunnelNetworks()
	networks[#networks + 1] = network
	return network
end

local function SetTunnelReady(network, ready)
	if not istable(network) then return end
	network.Ready = ready
	for _, door in ipairs({network.Entrance, network.Exit}) do
		if not IsValid(door) then continue end
		door.ZCityVietnamTunnelReady = ready
		door:SetNWBool("ZCityVietnamTunnelReady", ready)
	end
end

local function SetTunnelCooldown(network, duration)
	if not istable(network) then return end
	network.CooldownEnd = CurTime() + duration
	for _, door in ipairs({network.Entrance, network.Exit}) do
		if IsValid(door) then door:SetNWFloat("ZCityVietnamTunnelCooldownEnd", network.CooldownEnd) end
	end
end

local function CancelTunnel(ply)
	if not IsValid(ply) then
		activeTunnelPlayers[ply] = nil
		return
	end
	if not ply.ZCityVietnamTunnelEnd then return end

	local wasFrozen = ply.ZCityVietnamTunnelWasFrozen
	local network = ply.ZCityVietnamBuildingTunnelNetwork
	ply.ZCityVietnamTunnelEnd = nil
	ply.ZCityVietnamTunnelTarget = nil
	ply.ZCityVietnamTunnelWasFrozen = nil
	ply.ZCityVietnamBuildingTunnelNetwork = nil
	ply:SetNWFloat("ZCityVietnamTunnelEnd", 0)
	ply:Freeze(wasFrozen == true)
	activeTunnelPlayers[ply] = nil
	RemoveTunnelNetwork(network)
end

local function StartTunnel(ply, ability)
	if ply.ZCityVietnamTunnelEnd then
		ply:ChatPrint("이미 땅굴망을 건설 중입니다.")
		return false
	end

	local target = GetAimedGroundPosition(ply, 2200)
	if not target then
		ply:ChatPrint("이동할 바닥을 2,200 유닛 안에서 조준해야 합니다.")
		return false
	end

	target = FindClearPosition(ply, target)
	if not target then
		ply:ChatPrint("조준한 지점에는 나올 공간이 없습니다.")
		return false
	end

	local yaw = ply:EyeAngles().y
	local entranceDoor = SpawnTunnelDoor(ply, GetTunnelEntrancePosition(ply), yaw, "entrance")
	local exitDoor = SpawnTunnelDoor(ply, target - Vector(0, 0, 2), yaw, "exit")
	if not IsValid(entranceDoor) or not IsValid(exitDoor) then
		if IsValid(entranceDoor) then entranceDoor:Remove() end
		if IsValid(exitDoor) then exitDoor:Remove() end
		ply:ChatPrint("땅굴 트랩도어를 생성하지 못했습니다.")
		return false
	end
	if not MakeRoomForTunnelNetwork() then
		entranceDoor:Remove()
		exitDoor:Remove()
		ply:ChatPrint("동시에 건설 중인 땅굴이 너무 많습니다. 잠시 후 다시 시도하세요.")
		return false
	end
	local network = LinkTunnelDoors(ply, entranceDoor, exitDoor)

	ply.ZCityVietnamTunnelTarget = target
	ply.ZCityVietnamTunnelWasFrozen = ply:IsFrozen()
	ply.ZCityVietnamBuildingTunnelNetwork = network
	ply.ZCityVietnamTunnelEnd = CurTime() + (ability.Duration or 5)
	activeTunnelPlayers[ply] = true
	ply:SetNWFloat("ZCityVietnamTunnelEnd", ply.ZCityVietnamTunnelEnd)
	ply:Freeze(true)
	ply:ChatPrint("땅굴망을 건설합니다. 5초 후 양쪽 트랩도어가 활성화됩니다.")
	return true
end

local function FinishTunnel(ply)
	if not IsValid(ply) then
		activeTunnelPlayers[ply] = nil
		return
	end
	if not ply.ZCityVietnamTunnelEnd then return end

	local target = FindClearPosition(ply, ply.ZCityVietnamTunnelTarget)
	local wasFrozen = ply.ZCityVietnamTunnelWasFrozen
	local network = ply.ZCityVietnamBuildingTunnelNetwork
	ply.ZCityVietnamTunnelEnd = nil
	ply.ZCityVietnamTunnelTarget = nil
	ply.ZCityVietnamTunnelWasFrozen = nil
	ply.ZCityVietnamBuildingTunnelNetwork = nil
	ply:SetNWFloat("ZCityVietnamTunnelEnd", 0)
	ply:Freeze(wasFrozen == true)
	activeTunnelPlayers[ply] = nil

	if not target or not istable(network) or not IsValid(network.Entrance) or not IsValid(network.Exit) then
		RemoveTunnelNetwork(network)
		ply:ChatPrint("땅굴 입구 또는 출구가 막혀 건설이 취소되었습니다.")
		return
	end

	SetTunnelReady(network, true)
	ply:ChatPrint("땅굴망이 완성되었습니다. 트랩도어 위에서 E를 눌러 왕복할 수 있습니다.")
end

local tunnelTrapInjuries = {
	{Name = "왼팔", Bone = "ValveBiped.Bip01_L_UpperArm"},
	{Name = "오른팔", Bone = "ValveBiped.Bip01_R_UpperArm"},
	{Name = "왼쪽 다리", Bone = "ValveBiped.Bip01_L_Calf"},
	{Name = "오른쪽 다리", Bone = "ValveBiped.Bip01_R_Calf"},
	{Name = "가슴", Bone = "ValveBiped.Bip01_Spine2"},
	{Name = "복부", Bone = "ValveBiped.Bip01_Spine"}
}

local function ApplyTunnelTrapDamage(ply, door, damageRange, severe)
	local injury = table.Random(tunnelTrapInjuries)
	local damage = math.Rand(damageRange[1] or 8, damageRange[2] or 16)
	local damagePosition = ply:WorldSpaceCenter()
	local bone = ply:LookupBone(injury.Bone)
	if isnumber(bone) then
		local bonePosition = ply:GetBonePosition(bone)
		if isvector(bonePosition) and bonePosition ~= vector_origin then damagePosition = bonePosition end
	end

	local direction = VectorRand()
	if direction:LengthSqr() <= 0 then direction = vector_up end
	direction:Normalize()

	local damageInfo = DamageInfo()
	damageInfo:SetDamage(damage)
	damageInfo:SetDamageType(DMG_SLASH)
	damageInfo:SetDamagePosition(damagePosition)
	damageInfo:SetDamageForce(direction * damage * 30)
	damageInfo:SetAttacker(game.GetWorld())
	damageInfo:SetInflictor(IsValid(door) and door or game.GetWorld())
	ply:TakeDamageInfo(damageInfo)
	ply:EmitSound("beartrap.wav", 75, 100)
	ply:ChatPrint("땅굴 속 덫에 걸려 " .. injury.Name .. (severe and "에 중상을 입었습니다." or "에 부상을 입었습니다."))
end

local function ApplyTunnelTrapOutcome(ply, door)
	if ply:Team() ~= 1 then return end

	local fatalChance = MODE.TunnelUSFatalChance or 0.05
	local severeChance = MODE.TunnelUSSevereInjuryChance or 0.1
	local injuryChance = MODE.TunnelUSInjuryChance or 0.35
	local roll = math.Rand(0, 1)

	if roll < fatalChance then
		ply:EmitSound("beartrap.wav", 75, 85)
		ply:ChatPrint("땅굴 속 치명적인 덫에 걸려 즉사했습니다.")
		ply:Kill()
		return
	end

	if roll < fatalChance + severeChance then
		ApplyTunnelTrapDamage(ply, door, MODE.TunnelUSSevereInjuryDamage or {35, 55}, true)
		return
	end

	if roll < fatalChance + severeChance + injuryChance then
		ApplyTunnelTrapDamage(ply, door, MODE.TunnelUSInjuryDamage or {8, 16}, false)
	end
end

local function GetTunnelDoorAttacker(damageInfo)
	local attacker = damageInfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() then return attacker end
	if not IsValid(attacker) or not attacker.GetOwner then return end

	local owner = attacker:GetOwner()
	if IsValid(owner) and owner:IsPlayer() then return owner end
end

function MODE:EntityTakeDamage(ent, damageInfo)
	if not IsValid(ent) or not ent.ZCityVietnamTunnelDoor then return end

	local network = ent.ZCityVietnamTunnelNetwork
	if not IsVietnamRoundActive() or not istable(network) or network.Removed then return true end
	if not damageInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then return true end

	local attacker = GetTunnelDoorAttacker(damageInfo)
	if not IsValid(attacker) or attacker:Team() ~= 1 then return true end

	local health = ent:Health() - math.max(damageInfo:GetDamage(), 0)
	ent:SetHealth(health)
	if health > 0 then
		ent:EmitSound("physics/wood/wood_box_impact_hard" .. math.random(1, 3) .. ".wav", 60, 100)
		return true
	end

	local destroyedPosition = ent:GetPos()
	local builder = network.Owner
	if IsValid(builder) and builder.ZCityVietnamBuildingTunnelNetwork == network then
		CancelTunnel(builder)
	else
		RemoveTunnelNetwork(network)
	end

	sound.Play("physics/wood/wood_box_break1.wav", destroyedPosition, 75, 100)
	attacker:ChatPrint("베트콩 땅굴망을 파괴했습니다.")
	return true
end

local function FindNearbyTunnelDoor(ply)
	local nearest, nearestDistance
	for _, network in ipairs(PruneTunnelNetworks()) do
		if not network.Ready then continue end
		for _, door in ipairs({network.Entrance, network.Exit}) do
			if not IsValid(door) or not door.ZCityVietnamTunnelReady then continue end

			local offset = ply:GetPos() - door:GetPos()
			local horizontalDistance = offset.x * offset.x + offset.y * offset.y
			if horizontalDistance > 72 * 72 or offset.z < -24 or offset.z > 80 then continue end

			if not nearestDistance or horizontalDistance < nearestDistance then
				nearest = door
				nearestDistance = horizontalDistance
			end
		end
	end

	return nearest
end

local function UseTunnelDoor(ply, door)
	local partner = door.ZCityVietnamTunnelPartner
	local network = door.ZCityVietnamTunnelNetwork
	if not IsValid(partner) or not partner.ZCityVietnamTunnelReady or not istable(network) or not network.Ready then return end

	local cooldown = math.max((network.CooldownEnd or 0) - CurTime(), 0)
	if cooldown > 0 then
		ply:ChatPrint("이 땅굴은 재사용까지 " .. math.ceil(cooldown) .. "초 남았습니다.")
		return
	end

	local target = FindClearPosition(ply, partner:GetPos() + Vector(0, 0, 4))
	if not target then
		ply:ChatPrint("반대편 땅굴 출구가 막혀 있습니다.")
		return
	end

	SetTunnelCooldown(network, MODE.TunnelTravelCooldown or 5)
	ply:SetPos(target)
	ply:SetVelocity(-ply:GetVelocity())
	ply:EmitSound("doors/door_latch3.wav", 60, 85)
	ApplyTunnelTrapOutcome(ply, partner)
end

function MODE:KeyPress(ply, key)
	if key ~= IN_USE or not IsVietnamRoundActive() then return end
	if not IsValid(ply) or not ply:Alive() or (ply:Team() ~= 0 and ply:Team() ~= 1) then return end
	if ply.organism and ply.organism.otrub then return end

	local door = FindNearbyTunnelDoor(ply)
	if IsValid(door) then UseTunnelDoor(ply, door) end
end

local guaranteedSupplyContents = {
	"ent_ammo_5.56x45mm",
	"ent_ammo_5.56x45mm",
	"ent_ammo_7.62x51mm",
	"weapon_bandage_sh",
	"weapon_bandage_sh",
	"weapon_bigbandage_sh",
	"weapon_tourniquet",
	"weapon_morphine",
	"weapon_medkit_sh",
	"weapon_hg_smokenade_tpik",
	"weapon_hg_smokenade_tpik",
	"weapon_adrenaline"
}

local supplyBonusPool = {
	{Class = "weapon_bloodbag", Weight = 35},
	{Class = "ent_ammo_5.56x45mm", Weight = 30},
	{Class = "weapon_hg_grenade_tpik", Weight = 20},
	{Class = "ent_armor_vest3", Weight = 15}
}

local function BuildSupplyContents()
	local contents = table.Copy(guaranteedSupplyContents)
	local totalWeight = 0
	for _, item in ipairs(supplyBonusPool) do
		totalWeight = totalWeight + item.Weight
	end

	local roll = math.Rand(0, totalWeight)
	for _, item in ipairs(supplyBonusPool) do
		roll = roll - item.Weight
		if roll <= 0 then
			contents[#contents + 1] = item.Class
			break
		end
	end

	return contents
end

local function SpawnSupplyDrop(ply)
	local target = GetAimedGroundPosition(ply, 2400)
	if not target then
		ply:ChatPrint("보급품을 투하할 바닥을 2,400 유닛 안에서 조준해야 합니다.")
		return false
	end

	local upTrace = util.TraceLine({
		start = target + Vector(0, 0, 48),
		endpos = target + Vector(0, 0, 900),
		mask = MASK_SOLID_BRUSHONLY
	})
	local spawnPos = target + Vector(0, 0, 700)
	if upTrace.Hit and not upTrace.HitSky then
		spawnPos = upTrace.HitPos - Vector(0, 0, 56)
	end

	local crate = ents.Create("ent_airdrop")
	if not IsValid(crate) then
		ply:ChatPrint("보급 상자를 생성하지 못했습니다.")
		return false
	end

	crate:SetPos(spawnPos)
	crate:SetNWString("Contents", table.concat(BuildSupplyContents(), ","))
	crate:Spawn()
	crate:Activate()
	crate.ZCityVietnamSupply = true

	MODE.saved = MODE.saved or {}
	MODE.saved.VietnamSupplyCrates = MODE.saved.VietnamSupplyCrates or {}
	MODE.saved.VietnamSupplyCrates[#MODE.saved.VietnamSupplyCrates + 1] = crate

	for _, teammate in player.Iterator() do
		if teammate:Team() == 1 and teammate:Alive() then
			teammate:ChatPrint(ply:GetPlayerName() .. "님이 공중 보급을 요청했습니다.")
		end
	end

	return true
end

local function ResetPlayerAbilityState(ply, resetCooldowns)
	if not IsValid(ply) then return end

	EndAmbush(ply)
	CancelTunnel(ply)
	RemoveTunnelDoors(ply)

	if resetCooldowns then
		ply.ZCityVietnamCooldowns = {}
		for abilityId, ability in pairs(MODE.Abilities or {}) do
			if not ability.SharedTeamCooldown then ply:SetNWFloat(GetCooldownKey(abilityId), 0) end
		end
	end
end

local function ResetSharedAbilityCooldowns()
	for abilityId, ability in pairs(MODE.Abilities or {}) do
		if not ability.SharedTeamCooldown then continue end
		for teamId in pairs(ability.Teams or {}) do
			SetGlobalFloat(GetTeamCooldownKey(teamId, abilityId), 0)
		end
	end
end

function MODE:CleanupAbilityState()
	for _, ply in player.Iterator() do
		ResetPlayerAbilityState(ply, true)
	end
	ResetSharedAbilityCooldowns()

	self.saved = self.saved or {}
	for _, crate in ipairs(self.saved.VietnamSupplyCrates or {}) do
		if IsValid(crate) then crate:Remove() end
	end
	self.saved.VietnamSupplyCrates = {}
	local networks = self.saved.VietnamTunnelNetworks or {}
	for index = #networks, 1, -1 do
		RemoveTunnelNetwork(networks[index])
	end
	self.saved.VietnamTunnelNetworks = {}
	-- Remove props left by the previous flat-list implementation after Lua refresh.
	for _, door in ipairs(self.saved.VietnamTunnelDoors or {}) do
		if IsValid(door) then door:Remove() end
	end
	self.saved.VietnamTunnelDoors = nil
	table.Empty(activeAmbushPlayers)
	table.Empty(activeTunnelPlayers)
end

local abilityHandlers = {
	["recon"] = function(ply, ability)
		net.Start(reconNet)
			net.WriteFloat(ability.Duration or 2)
		net.Send(ply)
		ply:ChatPrint("공중 정찰이 적의 위치를 포착했습니다.")
		return true
	end,
	["tunnel"] = StartTunnel,
	["ambush"] = StartAmbush,
	["supply"] = function(ply)
		return SpawnSupplyDrop(ply)
	end
}

net.Receive(abilityRequestNet, function(_, ply)
	local abilityId = net.ReadString()
	if not IsVietnamRoundActive() or not IsValid(ply) or not ply:Alive() or ply:Team() == TEAM_SPECTATOR then return end
	if ply.organism and ply.organism.otrub then return end

	local ability = MODE.Abilities and MODE.Abilities[abilityId]
	local handler = abilityHandlers[abilityId]
	if not ability or not handler or not ability.Teams or not ability.Teams[ply:Team()] then return end

	local cooldown = GetAbilityCooldown(ply, abilityId, ability)
	if cooldown > 0 then
		ply:ChatPrint(ability.Name .. " 재사용까지 " .. math.ceil(cooldown) .. "초 남았습니다.")
		return
	end

	if handler(ply, ability) then
		SetAbilityCooldown(ply, abilityId, ability)
	end
end)

local function GetAmbushSoundOwner(ent)
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return ent end
	if not ent.GetOwner then return end

	local owner = ent:GetOwner()
	return IsValid(owner) and owner:IsPlayer() and owner or nil
end

function MODE:EntityEmitSound(soundData)
	if not next(activeAmbushPlayers) or not IsVietnamRoundActive() then return end

	local owner = GetAmbushSoundOwner(soundData.Entity)
	if IsValid(owner) and owner.ZCityVietnamAmbushEnd then return false end
end

function MODE:PlayerCanHearPlayersVoice(_, talker)
	if IsVietnamRoundActive() and IsValid(talker) and talker.ZCityVietnamAmbushEnd then return false, false end
end

local nextAbilityThink = 0
function MODE:Think()
	if not next(activeAmbushPlayers) and not next(activeTunnelPlayers) then return end
	if nextAbilityThink > CurTime() then return end
	nextAbilityThink = CurTime() + 0.05

	local activeRound = IsVietnamRoundActive()
	for ply in pairs(activeAmbushPlayers) do
		if IsValid(ply) and ply.ZCityVietnamAmbushEnd then
			local velocity = ply:GetVelocity()
			local running = ply:KeyDown(IN_SPEED) and (velocity.x * velocity.x + velocity.y * velocity.y) > 14400
			if not activeRound or not ply:Alive() or (ply.organism and ply.organism.otrub) or running or ply.ZCityVietnamAmbushEnd <= CurTime() then
				EndAmbush(ply)
			end
		else
			activeAmbushPlayers[ply] = nil
		end
	end

	for ply in pairs(activeTunnelPlayers) do
		if IsValid(ply) and ply.ZCityVietnamTunnelEnd then
			if not activeRound or not ply:Alive() or (ply.organism and ply.organism.otrub) then
				CancelTunnel(ply)
			elseif ply.ZCityVietnamTunnelEnd <= CurTime() then
				FinishTunnel(ply)
			end
		else
			activeTunnelPlayers[ply] = nil
		end
	end
end

local function ChooseJungleModel(models)
	local totalWeight = 0

	for _, modelPath in ipairs(models or {}) do
		totalWeight = totalWeight + (jungleModelWeights[modelPath] or 1)
	end

	if totalWeight <= 0 then return table.Random(models or {}) end

	local pick = math.Rand(0, totalWeight)
	for _, modelPath in ipairs(models) do
		pick = pick - (jungleModelWeights[modelPath] or 1)
		if pick <= 0 then
			return modelPath
		end
	end

	return table.Random(models)
end

function MODE:CanLaunch()
	return #player.GetAll() >= 2
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_T")), zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_CT"))
end

function MODE:CleanupJungleProps()
	self.saved = self.saved or {}

	for _, ent in ipairs(self.saved.JungleProps or {}) do
		if IsValid(ent) then
			ent:Remove()
		end
	end

	self.saved.JungleProps = {}
end

function MODE:GetJungleAnchorPositions()
	local anchors = {}
	local pointGroups = {
		zb.GetMapPoints("RandomSpawns") or {},
		zb.GetMapPoints("Spawnpoint") or {},
		zb.GetMapPoints("HMCD_TDM_T") or {},
		zb.GetMapPoints("HMCD_TDM_CT") or {}
	}

	for _, points in ipairs(pointGroups) do
		for _, point in ipairs(points) do
			local pos = point.pos or point[1]
			if isvector(pos) then
				anchors[#anchors + 1] = pos
			end
		end
	end

	if #anchors <= 0 then
		for _, ply in player.Iterator() do
			if ply:Team() ~= TEAM_SPECTATOR then
				anchors[#anchors + 1] = ply:GetPos()
			end
		end
	end

	return anchors
end

function MODE:FindJunglePropPosition(anchors)
	if #anchors <= 0 then return end

	for _ = 1, 28 do
		local anchor = table.Random(anchors)
		if not isvector(anchor) then continue end

		local offset = Vector(math.Rand(-1600, 1600), math.Rand(-1600, 1600), 512)
		local startPos = anchor + offset
		local tr = util.TraceLine({
			start = startPos,
			endpos = startPos - Vector(0, 0, 2048),
			mask = MASK_SOLID_BRUSHONLY
		})

		if tr.Hit and not tr.HitSky then
			return tr.HitPos + tr.HitNormal * 2, tr.HitNormal
		end
	end
end

function MODE:SpawnJungleProps()
	self:CleanupJungleProps()

	local anchors = self:GetJungleAnchorPositions()
	local models = self.JungleModels or {}
	if #anchors <= 0 or #models <= 0 then return end

	self.saved.JungleProps = {}

	for _ = 1, self.JunglePropCount or 220 do
		local pos = self:FindJunglePropPosition(anchors)
		if not pos then continue end

		local ent = ents.Create("prop_dynamic")
		if not IsValid(ent) then continue end

		ent:SetModel(ChooseJungleModel(models))
		ent:SetPos(pos)
		ent:SetAngles(Angle(0, math.Rand(0, 360), 0))
		ent:SetSolid(SOLID_NONE)
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent:Spawn()
		ent:Activate()
		ent:SetNWBool("ZCityVietnamJungleProp", true)

		self.saved.JungleProps[#self.saved.JungleProps + 1] = ent
	end
end

function MODE:Intermission()
	self:CleanupAbilityState()
	game.CleanUpMap()
	self.saved.USMachineGunner = nil
	self.saved.VietnamMachineGunner = nil
	self.saved.JungleProps = {}

	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then
			ply:SetupTeam(ply:Team())
			ply:SetNWInt("TDM_Money", 0)
		end
	end

	timer.Simple(0.5, function()
		if CurrentRound() == self then
			self:SpawnJungleProps()
		end
	end)

	net.Start("tdm_start")
		net.WriteString("vietnam")
	net.Broadcast()
end

function MODE:RoundStart()
	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then
			ply:Freeze(false)
			ply:SetMoveType(MOVETYPE_WALK)
		end
	end
end

function MODE:GiveEquipment()
	timer.Simple(0.1, function()
		if CurrentRound() ~= self then return end

		local usPlayers = GetTeamPlayers(1)
		local vietnamPlayers = GetTeamPlayers(0)

		self.saved.USMachineGunner = #usPlayers >= 3 and table.Random(usPlayers) or nil
		self.saved.VietnamMachineGunner = #vietnamPlayers >= 3 and table.Random(vietnamPlayers) or nil

		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then continue end
			ResetPlayerAbilityState(ply, true)

			local isUS = ply:Team() == 1
			local machineGunner = isUS and ply == self.saved.USMachineGunner or ply == self.saved.VietnamMachineGunner
			local modelPath = table.Random(isUS and self.USModels or self.VietnamModels)
			local weaponClass = machineGunner and (isUS and self.USMachineGun or self.VietnamMachineGun) or (isUS and self.USWeapon or self.VietnamWeapon)
			local roleName = isUS and (machineGunner and "US Machine Gunner" or "US Army") or (machineGunner and "VC Machine Gunner" or "Viet Cong")
			local roleColor = isUS and usColor or vietnamColor

			ply:SetSuppressPickupNotices(true)
			ply.noSound = true
			ply:Freeze(false)
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetNoDraw(false)
			ply:SetNotSolid(false)
			ply:StripWeapons()
			ply:RemoveAllAmmo()
			ply:SetNWInt("TDM_Money", 0)
			ply:SetNetVar("CurPluv", isUS and "pluvberet" or "pluvboss")
			ply.organism.allowholster = true

			ReapplyCleanRoleModel(ply, modelPath)
			zb.GiveRole(ply, roleName, roleColor)

			ply:Give("weapon_hands_sh")
			ply:Give("weapon_melee")
			ply:Give("weapon_bandage_sh")
			ply:Give("weapon_tourniquet")
			ply:Give(isUS and self.USMine or self.VietnamMine)
			ply:Give(isUS and self.USExplosive or self.VietnamExplosive)

			local radio = ply:Give("weapon_walkie_talkie")
			if IsValid(radio) then
				radio.Frequency = isUS and 91.1 or 104.8
			end

			local weapon = ply:Give(weaponClass)
			if IsValid(weapon) then
				GiveAmmoForWeapon(ply, weapon, machineGunner and 6 or 5)
				ply:SelectWeapon(weaponClass)
			else
				ply:SelectWeapon("weapon_hands_sh")
			end

			if hg and hg.AddArmor then
				hg.AddArmor(ply, "vest3")
				hg.AddArmor(ply, "helmet1")
			end

			timer.Simple(0.1, function()
				if IsValid(ply) then
					ply.noSound = false
					ply:SetSuppressPickupNotices(false)
				end
			end)
		end
	end)
end

function MODE:EndRound()
	self:CleanupAbilityState()
	self:CleanupJungleProps()

	timer.Simple(2, function()
		net.Start("tdm_roundend")
		net.Broadcast()
	end)

	local _, winner = zb:CheckWinner(self:CheckAlivePlayers())
	for _, ply in player.Iterator() do
		if ply:Team() == winner then
			ply:GiveExp(math.random(15, 30))
			ply:GiveSkill(math.Rand(0.1, 0.15))
		else
			ply:GiveSkill(-math.Rand(0.05, 0.1))
		end
	end
end

hook.Add("ZB_PreRoundStart", "ZCityVietnamCleanupJungleProps", function()
	local round = zb and zb.modes and zb.modes.vietnam
	if round and round.CleanupJungleProps then
		round:CleanupJungleProps()
	end
	if round and round.CleanupAbilityState then
		round:CleanupAbilityState()
	end
end)
