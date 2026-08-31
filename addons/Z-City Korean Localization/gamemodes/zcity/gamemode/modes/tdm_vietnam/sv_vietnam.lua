local MODE = MODE

local usColor = Color(70, 140, 230)
local vietnamColor = Color(190, 60, 45)
local cleanModelColor = Vector(1, 1, 1)
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
		local maxClip = math.max(weapon:GetMaxClip1() or 30, 30)
		ply:GiveAmmo(maxClip * (multiplier or 5), ammoType, true)
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
end)
