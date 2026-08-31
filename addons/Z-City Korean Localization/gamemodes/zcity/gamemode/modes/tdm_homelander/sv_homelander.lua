local MODE = MODE

local homelanderWeapon = "sm_weapon_homelander_lasers"
local hunterRoleColor = Color(80, 160, 255)
local homelanderRoleColor = Color(220, 40, 40)
local homelanderWaitingKey = "ZB_HomelanderWaiting"
local cleanModelColor = Vector(1, 1, 1)
local terroristRoleName = "테러조직"
local terroristModels = {
	"models/player/phoenix.mdl",
	"models/player/guerilla.mdl",
	"models/player/leet.mdl"
}
local laserArmorTicks = 3
local torsoArmorBones = {
	["valvebiped.bip01_pelvis"] = true,
	["valvebiped.bip01_spine"] = true,
	["valvebiped.bip01_spine1"] = true,
	["valvebiped.bip01_spine2"] = true,
	["valvebiped.bip01_spine4"] = true
}
local torsoArmorHitgroups = {
	[HITGROUP_CHEST] = true,
	[HITGROUP_STOMACH] = true
}

local function ChatT(ply, key, fallback)
	if ZCLang and ZCLang.ChatPrint then
		ZCLang.ChatPrint(ply, key, fallback)
	elseif IsValid(ply) then
		ply:ChatPrint(fallback or key)
	end
end

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
		if IsValid(ply) and ply:GetModel() == modelPath then
			ApplyCleanRoleModel(ply, modelPath)
		end
	end)
end

local function ApplyTerroristRole(ply)
	if not IsValid(ply) then return end

	ReapplyCleanRoleModel(ply, table.Random(terroristModels))
	zb.GiveRole(ply, terroristRoleName, hunterRoleColor)
end

local function GetAliveRoundPlayers()
	local players = {}
	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR and ply:Alive() then
			table.insert(players, ply)
		end
	end

	return players
end

local function ResetLaserArmorState(ply)
	ply.ZCityHomelanderLaserArmorName = nil
	ply.ZCityHomelanderLaserArmorTicks = nil
	ply.ZCityHomelanderLaserHitGroup = nil
	ply.ZCityHomelanderLaserHitGroupTime = nil
end

local function IsHomelanderLaserClass(ent)
	if not IsValid(ent) or not ent.GetClass then return false end

	local class = string.lower(ent:GetClass() or "")
	return class == homelanderWeapon or (string.find(class, "homelander", 1, true) and string.find(class, "laser", 1, true))
end

local function GetDamagePlayerOwner(ent)
	if not IsValid(ent) then return nil end
	if ent:IsPlayer() then return ent end

	if ent.GetOwner then
		local owner = ent:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return owner end
	end

	return nil
end

local function IsHomelanderLaserDamage(target, dmg, round)
	if target == round.saved.Homelander then return false end
	if not IsValid(target) or not target:IsPlayer() then return false end

	local attacker = dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()
	local attackerPlayer = GetDamagePlayerOwner(attacker) or GetDamagePlayerOwner(inflictor)
	local homelander = round.saved.Homelander

	if IsValid(attackerPlayer) and IsValid(homelander) and attackerPlayer ~= homelander then return false end
	if IsHomelanderLaserClass(inflictor) or IsHomelanderLaserClass(attacker) then return true end

	if IsValid(attackerPlayer) then
		local weapon = attackerPlayer:GetActiveWeapon()
		if IsHomelanderLaserClass(weapon) then return true end
	end

	return false
end

local function GetTorsoArmor(ply)
	if not ply.armors then return nil end
	local armor = ply.armors["torso"]
	if not armor or armor == "" then return nil end

	return armor
end

local function LaserHitTorsoArmor(target, dmg)
	if target.ZCityHomelanderLaserHitGroupTime and CurTime() - target.ZCityHomelanderLaserHitGroupTime <= 0.05 then
		return torsoArmorHitgroups[target.ZCityHomelanderLaserHitGroup] == true
	end

	local damagePos = dmg:GetDamagePosition()
	if not damagePos or damagePos == vector_origin then return false end
	if not target.GetBoneCount or not target.GetBoneName or not target.GetBonePosition then return false end

	local closestName
	local closestDistSqr = math.huge

	for bone = 0, target:GetBoneCount() - 1 do
		local boneName = target:GetBoneName(bone)
		if torsoArmorBones[string.lower(boneName or "")] then
			local bonePos = target:GetBonePosition(bone)
			if bonePos and bonePos ~= vector_origin then
				local distSqr = damagePos:DistToSqr(bonePos)
				if distSqr < closestDistSqr then
					closestDistSqr = distSqr
					closestName = boneName
				end
			end
		end
	end

	if not closestName then return false end

	local maxDist = 34
	return closestDistSqr <= maxDist * maxDist
end

local function BreakTorsoArmor(ply, armor)
	if hg and hg.DropArmor and hg.DropArmor(ply, armor) then return end

	if not ply.armors then return end
	ply.armors["torso"] = nil

	if ply.armors_health then
		ply.armors_health[armor] = nil
	end

	if ply.SyncArmor then
		ply:SyncArmor()
	end
end

local function BlockHomelanderLaserWithArmor(target, dmg)
	local armor = GetTorsoArmor(target)
	if not armor then
		ResetLaserArmorState(target)
		return false
	end
	if not LaserHitTorsoArmor(target, dmg) then return false end

	if target.ZCityHomelanderLaserArmorName ~= armor then
		target.ZCityHomelanderLaserArmorName = armor
		target.ZCityHomelanderLaserArmorTicks = laserArmorTicks
	end

	target.ZCityHomelanderLaserArmorTicks = math.max((target.ZCityHomelanderLaserArmorTicks or laserArmorTicks) - 1, 0)

	if hg and hg.ArmorEffectEx then
		hg.ArmorEffectEx(target, dmg, "Impact", 67)
	else
		target:EmitSound("physics/metal/metal_solid_impact_bullet" .. math.random(4) .. ".wav", 70, 100)
	end

	dmg:SetDamage(0)
	dmg:ScaleDamage(0)

	if target.ZCityHomelanderLaserArmorTicks <= 0 then
		BreakTorsoArmor(target, armor)
		ResetLaserArmorState(target)
	end

	return true
end

function MODE:CanLaunch()
	return #player.GetAll() >= 2
end

function MODE:RoundStart()
	self.saved.Winner = nil
	self.saved.LaserRemoveTime = nil
	self.saved.LaserRemoved = nil
	self.saved.TimeoutKilled = nil

	for _, ply in player.Iterator() do
		ResetLaserArmorState(ply)
		ply:Freeze(false)

		if ply:Alive() and ply ~= self.saved.Homelander then
			ply:Freeze(false)
			ApplyTerroristRole(ply)
			ChatT(ply, "sv_homelander_buy", "홈랜더가 도착하기 전까지 무기를 구매하십시오.")
		end
	end

	timer.Create("HomelanderRelease", self.BuyTime or 40, 1, function()
		local round = CurrentRound()
		if round ~= self then return end
		self:ReleaseHomelander()
	end)
end

function MODE:PrepareHomelander(homelander)
	if not IsValid(homelander) then return end

	self.saved.Homelander = homelander
	self.saved.HomelanderReleased = false

	homelander:SetNWBool(homelanderWaitingKey, true)
	homelander:StripWeapons()
	homelander:RemoveAllAmmo()
	homelander:SetSuppressPickupNotices(true)
	homelander.noSound = true
	homelander:Freeze(true)
	homelander:SetMoveType(MOVETYPE_NONE)
	homelander:SetNoDraw(true)
	homelander:SetNotSolid(true)
	zb.GiveRole(homelander, "Homelander", homelanderRoleColor)
	ChatT(homelander, "sv_homelander_wait", "당신은 홈랜더입니다. 40초 뒤 전장에 투입됩니다.")
end

function MODE:GiveEquipment()
	timer.Simple(0.1, function()
		if CurrentRound() ~= self then return end

		local homelander = table.Random(GetAliveRoundPlayers())
		self:PrepareHomelander(homelander)

		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then continue end
			if ply == homelander then continue end

			ply:StripWeapons()
			ply:RemoveAllAmmo()
			ply:SetSuppressPickupNotices(true)
			ply.noSound = true
			ply:SetNWInt("TDM_Money", self.StartMoney or 6500)
			ply:SetNetVar("CurPluv", "pluvberet")
			ApplyTerroristRole(ply)

			local hands = ply:Give("weapon_hands_sh")
			if IsValid(hands) then
				ply:SelectWeapon("weapon_hands_sh")
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

function MODE:GetAliveHunters()
	local hunters = {}
	local homelander = self.saved.Homelander

	for _, ply in player.Iterator() do
		if ply ~= homelander and ply:Team() ~= TEAM_SPECTATOR and ply:Alive() then
			table.insert(hunters, ply)
		end
	end

	return hunters
end

function MODE:GetHomelanderHealth()
	local aliveCount = 0
	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR and (ply:Alive() or ply == self.saved.Homelander) then
			aliveCount = aliveCount + 1
		end
	end

	return 100 + math.max(aliveCount - 1, 0) * 25
end

function MODE:ReleaseHomelander()
	if self.saved.HomelanderReleased then return end
	self.saved.HomelanderReleased = true

	local homelander = self.saved.Homelander
	if not IsValid(homelander) then
		homelander = table.Random(GetAliveRoundPlayers())
	end
	if not IsValid(homelander) then return end

	self.saved.Homelander = homelander
	self.saved.LaserRemoveTime = CurTime() + (self.LaserTime or 180)
	self.saved.LaserRemoved = false

	homelander:SetNWBool(homelanderWaitingKey, false)
	homelander:Freeze(false)
	homelander:SetMoveType(MOVETYPE_WALK)
	homelander:SetNoDraw(false)
	homelander:SetNotSolid(false)
	if not homelander:Alive() then
		homelander:Spawn()
	end
	homelander:SetTeam(1)
	if homelander.GetRandomSpawn then
		homelander:GetRandomSpawn()
	end

	homelander:StripWeapons()
	homelander:RemoveAllAmmo()
	homelander:SetSuppressPickupNotices(false)
	homelander.noSound = false
	ReapplyCleanRoleModel(homelander, self.HomelanderModel)
	local health = self:GetHomelanderHealth()
	homelander:SetMaxHealth(health)
	homelander:SetHealth(health)

	local laser = homelander:Give(homelanderWeapon)
	if IsValid(laser) then
		homelander:SelectWeapon(homelanderWeapon)
	end

	zb.GiveRole(homelander, "Homelander", homelanderRoleColor)
	ChatT(homelander, "sv_homelander_hunt", "당신은 홈랜더입니다. 3분 동안 사냥하십시오.")

	for _, ply in player.Iterator() do
		if ply ~= homelander and ply:Team() ~= TEAM_SPECTATOR and ply:Alive() then
			ApplyTerroristRole(ply)
			ChatT(ply, "sv_homelander_kill_after_laser", "홈랜더의 레이저가 사라지면 그를 처치하십시오.")
		end
	end

	BroadcastT("sv_homelander_arrived", "홈랜더가 등장했습니다.")
end

hook.Add("EntityTakeDamage", "HomelanderWaitingNoDamage", function(target, dmg)
	local round = CurrentRound and CurrentRound()
	if not round or round.name ~= "homelander" then return end
	if not IsValid(target) or not target:IsPlayer() then return end
	if target:GetNWBool(homelanderWaitingKey, false) then return true end
	if IsHomelanderLaserDamage(target, dmg, round) and BlockHomelanderLaserWithArmor(target, dmg) then return true end
end)

hook.Add("ScalePlayerDamage", "HomelanderLaserArmorHitgroup", function(target, hitgroup, dmg)
	local round = CurrentRound and CurrentRound()
	if not round or round.name ~= "homelander" then return end
	if not IsValid(target) or not target:IsPlayer() then return end
	if not IsHomelanderLaserDamage(target, dmg, round) then return end

	target.ZCityHomelanderLaserHitGroup = hitgroup
	target.ZCityHomelanderLaserHitGroupTime = CurTime()
end)

function MODE:RoundThink()
	local homelander = self.saved.Homelander
	if not IsValid(homelander) then return end

	if not self.saved.TimeoutKilled and CurTime() >= (zb.ROUND_START or 0) + (self.ROUND_TIME or 300) then
		self.saved.TimeoutKilled = true
		self.saved.Winner = "hunters"

		if homelander:Alive() then
			BroadcastT("sv_homelander_compound_death", "컴파운드 V 부작용으로 사망했습니다.")
			homelander:Kill()
		end

		return
	end

	if not self.saved.LaserRemoved and CurTime() >= (self.saved.LaserRemoveTime or math.huge) then
		homelander:StripWeapon(homelanderWeapon)
		homelander:Give("weapon_hands_sh")
		homelander:SelectWeapon("weapon_hands_sh")
		self.saved.LaserRemoved = true
		BroadcastT("sv_homelander_laser_gone", "홈랜더의 레이저가 사라졌습니다. 지금 처치하십시오.")
	end
end

function MODE:ShouldRoundEnd()
	local homelander = self.saved.Homelander
	if not homelander then return false end
	if not self.saved.HomelanderReleased then return false end

	if not IsValid(homelander) or not homelander:Alive() then
		self.saved.Winner = self.saved.Winner or "hunters"
		return true
	end

	if #self:GetAliveHunters() == 0 then
		self.saved.Winner = "homelander"
		return true
	end

	return nil
end

function MODE:EndRound()
	for _, ply in player.Iterator() do
		ResetLaserArmorState(ply)
		ply:SetNWBool(homelanderWaitingKey, false)
		ply:SetNoDraw(false)
		ply:SetNotSolid(false)
		ply:Freeze(false)
	end

	timer.Simple(2, function()
		net.Start("tdm_roundend")
		net.Broadcast()
	end)

	if self.saved.Winner == "homelander" then
		BroadcastT("sv_homelander_wins", "홈랜더가 살아남았습니다.")
	elseif self.saved.Winner == "hunters" then
		BroadcastT("sv_homelander_hunters_win", "사냥꾼들이 홈랜더를 처치했습니다.")
	end
end
