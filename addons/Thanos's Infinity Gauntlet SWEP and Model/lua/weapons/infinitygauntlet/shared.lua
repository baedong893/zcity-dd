if !ConVarExists("ig_particlescale") then
	CreateConVar("ig_particlescale","1",FCVAR_ARCHIVE)
end
if !ConVarExists("ig_enable_timestone") then
	CreateConVar("ig_enable_timestone","1",FCVAR_ARCHIVE)
end
if !ConVarExists("ig_enable_soulstone") then
	CreateConVar("ig_enable_soulstone","1",FCVAR_ARCHIVE)
end
if !ConVarExists("ig_enable_powerstone") then
	CreateConVar("ig_enable_powerstone","1",FCVAR_ARCHIVE)
end
if !ConVarExists("ig_enable_realitystone") then
	CreateConVar("ig_enable_realitystone","1",FCVAR_ARCHIVE)
end
if !ConVarExists("ig_enable_spacestone") then
	CreateConVar("ig_enable_spacestone","1",FCVAR_ARCHIVE)
end
if !ConVarExists("ig_enable_mindstone") then
	CreateConVar("ig_enable_mindstone","1",FCVAR_ARCHIVE)
end
if !ConVarExists("ig_enable_infinity") then
	CreateConVar("ig_enable_infinity","1",FCVAR_ARCHIVE)
end

SWEP.PrintName = "Infinity Gauntlet"
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.Weight = 999
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.HoldType = "fist"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local function SetModelVersion(useOld)
	SWEP = SWEP or weapons.GetStored("infinitygauntlet")
	if useOld then
		SWEP.UseHands = true
		SWEP.ViewModel = "models/weapons/c_arms.mdl"
		SWEP.WorldModel = "models/xyz/props/infinity_gauntlet.mdl"
		SWEP.ViewModelFOV = 54
		SWEP.BobScale = 1
		SWEP.SwayScale = 1
		SWEP.ViewModelBoneMods = {
			["ValveBiped.square"] = { scale = Vector(0, 0, 0), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
			["ValveBiped.eject"] = { scale = Vector(0, 0, 0), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
			["ValveBiped.clip"] = { scale = Vector(0, 0, 0), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
			["ValveBiped.hammer"] = { scale = Vector(0, 0, 0), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
			["ValveBiped.base"] = { scale = Vector(0, 0, 0), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
			
			--["ValveBiped.Bip01_L_Forearm"] = { scale = Vector(0.813, 0.813, 0.813), pos = Vector(5, -3,0), angle = Angle(5,30,40) },
			["ValveBiped.Bip01_L_Forearm"] = { scale = Vector(0.713, 0.713, 0.713), pos = Vector(5, -3,0), angle = Angle(5,30,40) },
			["ValveBiped.Bip01_L_Hand"] = { scale = Vector(0.189, 0.189, 0.189), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		}
		SWEP.VElements = {
			["gauntlet"] = { type = "Model", model = "models/xyz/props/infinity_gauntlet.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(3,1,-.0), angle = Angle(280,0,0), size = Vector(1.164, 1.164, 1.164), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
			["mindstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(0.5, -2.8, -0.601), size = { x = 10, y = 10 }, color = Color(241, 144, 19, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
			["realitystone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(1.597, -1.461, 2.184), size = { x = 10, y = 10 }, color = Color(245, 6, 6, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
			["timestone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(-3.333, 1.414, -3.119), size = { x = 7.086, y = 7.086 }, color = Color(60, 168, 96, 0), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["powerstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(-1.747, -1.211, 1.723), size = { x = 10, y = 10 }, color = Color(76, 15, 116, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
			["spacestone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(-0.051, -1.477, 2.098), size = { x = 10, y = 10 }, color = Color(29, 86, 153, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
			["soulstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(2.959, -0.946, 1.777), size = { x = 10, y = 10 }, color = Color(165, 69, 0, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
		}
		SWEP.WElements = {
			["gauntlet"] = { type = "Model", model = "models/xyz/props/infinity_gauntlet.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(7.265, 2.14, 1.326), angle = Angle(-84.384, -118.263, -113.6), size = Vector(1.273, 1.273, 1.273), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
			["mindstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(0.5, -2.8, -0.601), size = { x = 10, y = 10 }, color = Color(241, 144, 19, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
			["realitystone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(1.597, -1.461, 2.184), size = { x = 10, y = 10 }, color = Color(245, 6, 6, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
			["timestone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(-3.333, 1.414, -3.119), size = { x = 10, y = 10 }, color = Color(60, 168, 96, 0), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["powerstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(-1.747, -1.211, 1.723), size = { x = 10, y = 10 }, color = Color(76, 15, 116, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
			["spacestone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(-0.051, -1.477, 2.098), size = { x = 10, y = 10 }, color = Color(29, 86, 153, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
			["soulstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01", rel = "gauntlet", pos = Vector(2.959, -0.946, 1.777), size = { x = 10, y = 10 }, color = Color(165, 69, 0, 0), nocull = true, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
		}
	else
		SWEP.ViewModel = "models/xyz/weapons/v_infinitygauntlet.mdl"
		SWEP.WorldModel = "models/xyz/props/infinity_gauntlet_new.mdl"
		SWEP.UseHands = false
		SWEP.BobScale = .1
		SWEP.SwayScale = .5
		SWEP.ViewModelFOV = 61.19
		SWEP.ViewModelBoneMods = {}
		SWEP.WElements = {
			["mindstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_R_Hand", rel = "gauntlet", pos = Vector(0.007, -2.75, 1.014), size = { x = 9.99, y = 9.99 }, color = Color(241, 144, 19, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["realitystone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "gauntlet", pos = Vector(-1.152, -2.385, -1.002), size = { x = 6.08, y = 6.08 }, color = Color(245, 6, 6, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["timestone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "gauntlet", pos = Vector(3.627, 1.56, 1.773), size = { x = 10, y = 10 }, color = Color(60, 168, 96, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["gauntlet"] = { type = "Model", model = "models/xyz/props/infinity_gauntlet_new.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(7.374, 1.042, 0.437), angle = Angle(65.76, 78.054, -90.449), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
			["spacestone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "gauntlet", pos = Vector(0.596, -2.418, -1.25), size = { x = 8.461, y = 8.461 }, color = Color(29, 86, 153, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["soulstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "gauntlet", pos = Vector(-2.6, -1.714, -0.713), size = { x = 6.314, y = 6.314 }, color = Color(165, 69, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["powerstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "gauntlet", pos = Vector(2.046, -1.52, -1.341), size = { x = 9.005, y = 9.005 }, color = Color(75, 15, 116, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false}
		}
		SWEP.VElements = {
			["mindstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(0.779, 0.158, -0.165), size = { x = 2.978, y = 2.978 }, color = Color(241, 144, 19, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["realitystone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(0.861, -0.778, 0.222), size = { x = 3, y = 3 }, color = Color(245, 6, 6, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["timestone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Finger0", rel = "", pos = Vector(-0.383, -0.806, -0.635), size = { x = 3, y = 3 }, color = Color(60, 168, 96, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["spacestone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(0.855, -0.736, -0.241), size = { x = 3, y = 3 }, color = Color(29, 86, 153, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["soulstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(0.722, -0.491, 0.62), size = { x = 3, y = 3 }, color = Color(165, 69, 0, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
			["powerstone_glow"] = { type = "Sprite", sprite = "particle/particle_glow_05", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(0.686, -0.842, -0.732), size = { x = 3, y = 3 }, color = Color(75, 15, 116, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false}
		}
	end
end

if !ConVarExists("ig_useoldmodel") then
	CreateConVar("ig_useoldmodel","0",FCVAR_ARCHIVE+FCVAR_REPLICATED)
end
/*cvars.AddChangeCallback("ig_useoldmodel",function(convar,oldValue,newValue)
	SetModelVersion(newValue == 1)
end,"IGUpdateModel")*/
SetModelVersion(GetConVar("ig_useoldmodel"):GetBool())

local function UsingOldModel()
	return GetConVar("ig_useoldmodel"):GetBool()
end

local PLY = FindMetaTable("Player")
local ENT = FindMetaTable("Entity")

function ENT:HasIG()
	return self:IsPlayer() and self:GetWeapon("infinitygauntlet"):IsValid()
end

function ENT:HasInfinityStone(stoneID)
	return self:HasIG() and self:GetWeapon("infinitygauntlet"):HasStone(stoneID)
end

sound.Add{
	name = "IG_ChannelGem1",
	channel = CHAN_STATIC,
	volume = 1,
	level = 90,
	pitch = 150,
	sound = "ambient/machines/machine6.wav"
}

local defTargetRange = 5500
local defTargetBounds = Vector(5,5,5)
local function FindTarget(self,range,bounds)
	local ply = self.Owner
	local traceData = {
		start = ply:EyePos(),
		endpos = ply:EyePos()+ply:GetAimVector()*(range or defTargetRange),
		filter = ply,
	}
	local trace = util.TraceLine(traceData)
	if !trace.Entity:IsValid() then
		bounds = bounds or defTargetBounds
		traceData.mins = -bounds
		traceData.maxs = bounds
		trace = util.TraceHull(traceData)
	end
	if trace.Entity:IsValid() and trace.Entity:GetClass() == "ig_pocketwall" then
		trace.Entity = NULL
	end
	return trace
end

function ENT:IG_RemoveMaterialEffect()
	if self.IG_Materialized then
		if self.IG_Materialized.hooks then
			for k,v in pairs(self.IG_Materialized.hooks) do
				hook.Remove(k,"IG_MaterializedEffect"..self:EntIndex())
			end
		end
		if self.IG_Materialized.Cleanup then
			self.IG_Materialized.Cleanup(self)
		end
	end
end

hook.Add("EntityRemoved","IG_CleanupMatEffects",function(ent)
	ent:IG_RemoveMaterialEffect()
end)

hook.Add("PhysgunPickup","IG_PhysPickup",function(ply,ent)
	if ent:GetClass() == "ig_pocketwall" or (SERVER and !ent:IG_MotionEnabled()) then
		return false
	end
end)

hook.Add("CanTool","IG_Toolgun",function(ply,tr)
	if tr.Entity:IsValid() and tr.Entity:GetClass() == "ig_pocketwall" then
		return false
	end
end)

hook.Add("CanProperty","IG_Property",function(ply,property,ent)
	if ent:GetClass() == "ig_pocketwall" then
		return false
	end
end)

hook.Add("PostPlayerDeath","IG_DeathTimeLoop",function(ply)
	if ply.timeAnchorDeathloop then
		local data = ply.timeAnchorDeathloop
		ply.timeAnchorDeathloop = nil
		timer.Simple(0,function()
			IG_LoadTimeSaveState(data)
			if ply:IsValid() then
				local wep = ply:GetWeapon("infinitygauntlet")
				if wep:IsValid() then
					wep.savedTimeAnchor = data
					wep.timeAnchorDeathloop = true
				end
			end
		end)
	end
end)

hook.Add("DoPlayerDeath","IG_DeathTimeLoop",function(ply)
	local wep = ply:GetWeapon("infinitygauntlet")
	if wep:IsValid() and wep.timeAnchorDeathloop then
		ply.timeAnchorDeathloop = wep.savedTimeAnchor
	end
end)

local function CreateWormhole(entrancePos,entranceFacePos,exitPos)
	local dest = ents.Create("ig_portal")
	dest:SetPos(exitPos+Vector(0,0,40))
	dest:Spawn()
	dest:Activate()
	
	local entrance = ents.Create("ig_portal")
	entrance:SetPos(entrancePos+Vector(0,0,-20))
	local entranceAngle = (entranceFacePos-entrance:GetPos()):GetNormalized():Angle()
	entranceAngle:RotateAroundAxis(entranceAngle:Up(),90)
	entranceAngle.r = 90
	entrance:SetAngles(entranceAngle)
	entrance:Spawn()
	entrance:Activate()
	
	entranceAngle:RotateAroundAxis(entranceAngle:Right(),180)
	
	dest:SetAngles(entranceAngle)
	
	dest:SetDestination(entrance)
	entrance:SetDestination(dest)
end

local function FindRandomPosition()
	local nav = table.Random(navmesh.GetAllNavAreas())
	if nav then
		return nav:GetRandomPoint()
	else
		print("Map seems to have no navmesh!")
		return Vector()
	end
end

local function MakePlayerProp(ply,mdl)
	local veh = ply:IG_SetExistant(false)
	if veh:IsValid() then
		local ent = ents.Create("prop_physics")
		ent:SetModel(mdl)
		ent:SetPos(ply:GetPos())
		ent:Spawn()
		ent:Activate()
		veh:SetPos(ent:GetPos())
		veh:SetParent(ent)
		
		timer.Simple(60,function()
			if ent:IsValid() then
				ent:Remove()
			end
		end)
		ent.IG_isActualPlayer = true
	end
end

local randomModels = {}

local function FindModelsRecursive(dir)
	local files, folders = file.Find(dir.."/*","GAME")
	for k,v in ipairs(folders) do
		FindModelsRecursive(dir.."/"..v)
	end
	for k,v in ipairs(files) do
		if v:GetExtensionFromFilename() == "mdl" then
			randomModels[#randomModels+1] = (dir.."/"..v)
		end
	end
end

timer.Simple(0,function()FindModelsRecursive("models")end)

local function GetRandomModel()
	return randomModels[math.random(1,#randomModels)]
end

local defBotHull = Vector(-16,-16,0)
local defTopHull = Vector(16,16,72)
local defTopHullDuck = Vector(16,16,36)
local function SetHullTop(ply,top,wide)
	local vec = Vector(wide or 16,wide or 16,top or 72)
	local botHullVec = Vector()
	botHullVec:Set(defBotHull)
	if wide then
		botHullVec.x = -wide
		botHullVec.y = -wide
	end
	ply:SetHull(botHullVec,vec)
	vec.z = vec.z/2
	ply:SetHullDuck(botHullVec,vec)
end

if CLIENT then
	net.Receive("IG_ScalePlayer",function()
		local ply = net.ReadEntity()
		if ply:IsValid() then
			SetHullTop(ply,net.ReadUInt(12),net.ReadUInt(12))
		end
	end)
end

local defTopHull = Vector(16,16,72)
function PLY:IG_SetScale(scale)
	self:SetViewOffset(Vector(0,0,64)*scale)
	self:SetViewOffsetDucked(Vector(0,0,28)*scale)
	self:SetModelScale(scale)
	self:SetStepSize(18*scale)
	self:SetRunSpeed(400*scale)
	self:SetWalkSpeed(200*scale)
	self:SetJumpPower(200*scale)
	self:SetCrouchedWalkSpeed(.3*scale)
	
	local hullTop = defTopHull.z*scale
	local hullWide = 16*scale
	
	--Not sending to new players, but whatevs mang
	net.Start("IG_ScalePlayer")
	net.WriteEntity(self)
	net.WriteUInt(hullTop,12)
	net.WriteUInt(hullWide,12)
	net.Broadcast()
	SetHullTop(self,hullTop,hullWide)
end

local playerBones = {
	"ValveBiped.Bip01_Head1",
	"ValveBiped.Bip01_Spine4",
	"ValveBiped.Bip01_Spine2",
	"ValveBiped.Bip01_Spine1",
	"ValveBiped.Bip01_Spine",
	"ValveBiped.Bip01_Pelvis",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_R_Thigh",
	"ValveBiped.Bip01_R_Calf",
	"ValveBiped.Bip01_R_Foot",
	"ValveBiped.Bip01_L_Thigh",
	"ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_L_Foot",
}
function ENT:IG_FindClosestBone(pos)
	local closestBone
	local closest
	for _,bone in pairs(playerBones) do
		local b = self:LookupBone(bone)
		if b then
			local distance = self:GetBonePosition(b):DistToSqr(pos)
			
			if (!closest or distance < closest) then
				closest = distance
				closestBone = b
			end
		end
	end
	return closestBone
end

local function PositionEmptyEntity(ent,pos,filter)
	return !util.TraceEntity({
		start = pos,
		endpos = pos,
		filter = filter and filter or ent,
	},ent).Hit
end

function IG_FindEmptyPositionEntity(ent,pos,distance,step,filter)
	if PositionEmptyEntity(ent,pos) then
		return pos
	end
	
	for j = step,distance,step do
		for i = -1,1,2 do
			local offset = j*i
			if PositionEmptyEntity(ent,pos + Vector(offset,0,0),filter) and PositionEmptyEntity(ent,pos + Vector(offset,0,0),filter) then
				return pos + Vector(offset,0,0)
			end
			if PositionEmptyEntity(ent,pos + Vector(0,offset,0),filter) and PositionEmptyEntity(ent,pos + Vector(0,offset,0),filter) then
				return pos + Vector(0,offset,0)
			end
			if PositionEmptyEntity(ent,pos + Vector(0,0,offset),filter) and PositionEmptyEntity(ent,pos + Vector(0,0,offset),filter) then
				return pos + Vector(0,0,offset)
			end
		end
	end
	
	return pos
end
hook.Add("EntityEmitSound","TimeWarpSounds",function(t)

	local p = t.Pitch

	if ( game.GetTimeScale() != 1 ) then
		p = p * game.GetTimeScale()
	end

	if ( GetConVarNumber( "host_timescale" ) != 1 && GetConVarNumber( "sv_cheats" ) >= 1 ) then
		p = p * GetConVarNumber( "host_timescale" )
	end

	if ( p != t.Pitch ) then
		t.Pitch = math.Clamp( p, 0, 255 )
		return true
	end

	if ( CLIENT && engine.GetDemoPlaybackTimeScale() != 1 ) then
		t.Pitch = math.Clamp( t.Pitch * engine.GetDemoPlaybackTimeScale(), 0, 255 )
		return true
	end

end )

local function Swap(array, index1, index2)
    array[index1], array[index2] = array[index2], array[index1]
end

local function Shuffle(array)
    local counter = #array
    while counter > 1 do
        local index = math.random(counter)
        Swap(array, index, counter)
        counter = counter - 1
    end
end

function IG_ExistanceWipe(target)
	if target.IG_existenceRemoving then return end
	target.IG_existenceRemoving = true
	local time = 5
	local ef = EffectData()
	ef:SetEntity(target)
	ef:SetMagnitude(time)
	util.Effect("ig_dusted",ef,true,true)

	if IG_ZCityIsInfinityStoneRound() and target:IsPlayer() then
		timer.Simple(0.25, function()
			if IsValid(target) then
				target:KillSilent()
			end
		end)

		return
	end
	
	if target.GetActiveWeapon and target:GetActiveWeapon():IsValid() then
		target:GetActiveWeapon():SetNoDraw(true)
	end
	
	timer.Simple(time-.5,function()
		if target:IsValid() then
			if target:IsPlayer() then
				target:KillSilent()
			else
				target:Remove()
			end
		end
	end)
end

local function GoreExplodeEffect(ent,dir,power,amountScaler)
	local basePos = ent:GetPos()+ent:OBBCenter()
	local ef = EffectData()
	ef:SetFlags(ent:GetBloodColor() == BLOOD_COLOR_RED and 1 or 2)
	ef:SetNormal(dir)
	ef:SetDamageType(power)
	
	for i=0,20*GetConVar("ig_particlescale"):GetFloat()*(amountScaler or 1) do
		local pos = basePos+VectorRand()*10
		ef:SetOrigin(pos)
		
		util.Effect("ig_bloodsplash",ef,true,true)
		util.Effect("ig_entrails",ef,true,true)
		sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav",pos,75,math.random(90,110),1)
	end
end

local function Particle(name,pos)
	ParticleEffect(name,pos,Angle(),nil)
end

local function CreateExplosion(pos,size,dmg,attacker,inflictor)
	for _,v in ipairs(ents.FindInSphere(pos,size/3)) do 
		if v:GetClass() == "prop_physics" then
			v:Remove()
		end
	end
	
	local ef = EffectData()
	ef:SetOrigin(pos)
	ef:SetNormal(Vector(0,0,1))
	ef:SetEntity(attacker)
	ef:SetScale(size/300)
	ef:SetRadius(67)
	ef:SetMagnitude(8)
	util.Effect("ig_bigexplosion",ef,true,true)
	util.Effect("HelicopterMegaBomb",ef,true,true)
	util.Effect("ThumperDust",ef,true,true)
	--attacker:EmitSound("ambient/explosions/explode_"..math.random(1,4)..".wav",511,35)
	sound.Play("ambient/explosions/explode_"..math.random(1,4)..".wav",inflictor:GetPos(),511,35)
	
	util.BlastDamage(inflictor,attacker,pos,size/3,dmg or 0)
	util.ScreenShake(pos,2500,255,2.25,size*2)
end
IG_CreateExplosion = CreateExplosion

function ENT:IGEffectTemp(effect,time)
	self:IG_EnableEffect(effect,true)
	timer.Create("IG_RemoveGlow"..effect..self:EntIndex(),time or 1,1,function()
		if self:IsValid() then
			self:IG_EnableEffect(effect,false)
		end
	end)
end

local function UpdateEntity(current,set,new)
	if new != current then
		set(new)
	end
end

local function WritePhysicsDataToTable(phys,tbl)
	tbl.asleep = phys:IsAsleep()
	tbl.pos = phys:GetPos()
	tbl.vel = phys:GetVelocity()
	tbl.angles = phys:GetAngles()
	tbl.angVel = phys:GetAngleVelocity()
	tbl.motionEnabled = phys:IsMotionEnabled()
	tbl.collisionsEnabled = phys:IsCollisionEnabled()
	tbl.gravityEnabled = phys:IsGravityEnabled()
end

function ENT:IG_GetInfo(ignoreFlex,ignoreBones)
	local ent = self
	local info = {
		pos = ent:GetPos(),
		model = ent:GetModel(),
		health = ent:Health(),
		velocity = ent:GetVelocity(),
		table = ent:GetTable(),
		collisionGroup = ent:GetCollisionGroup(),
		sequence = ent:GetSequence(),
		cycle = ent:GetCycle(),
		parent = ent:GetParent(),
		owner = ent:GetOwner(),
		flexScale = ent:GetFlexScale(),
		scale = ent:GetModelScale(),
		onFire = ent:IsOnFire(),
		gravity = ent:GetGravity(),
		color = ent:GetColor(),
		mat = ent:GetMaterial(),
		noDraw = ent:GetNoDraw()
	}
	
	if !ignoreFlex and ent:GetFlexNum() > 0 then
		info.flexWeights = {}
		for i=0,ent:GetFlexNum()-1 do
			info.flexWeights[i] = ent:GetFlexWeight(i)
		end
	end
	
	if !getBones and ent:GetBoneCount() > 1 then
		info.bonePositions = {}
		info.boneAngles = {}
		info.boneScales = {}
		for i=0,ent:GetBoneCount()-1 do
			info.bonePositions[i] = ent:GetManipulateBonePosition(i)
			info.boneAngles[i] = ent:GetManipulateBoneAngles(i)
			info.boneScales[i] = ent:GetManipulateBoneScale(i)
		end
	end
	
	if ent:IsNPC() or ent:IsPlayer() then
		if ent:GetActiveWeapon():IsValid() then
			info.activeWeapon = ent:GetActiveWeapon():GetClass()
		end
		if ent:IsNPC() then
			info.npcState = ent:GetNPCState()
			info.movementActivity = ent:GetMovementActivity()
			info.capabilities = ent:CapabilitiesGet()
			for c=0,100 do
				if ent:HasCondition(c) then
					info.condition = c
					break
				end
			end
		end
	end
	
	if ent:IsPlayer() then
		info.alive = ent:Alive()
		info.angles = ent:EyeAngles()
		info.vehicle = ent:GetVehicle()
		info.viewEnt = ent:GetViewEntity()
		if ent:Crouching() then
			info.crouching = true
		end
		if ent:KeyDown(IN_ZOOM) then
			info.zooming = true
		end
	else
		info.angles = ent:GetAngles()
		
		/*if recordConstraints:GetBool() then
			info.constraints = constraint.GetTable(ent)
			if #info.constraints > 0 then
				info.constraintedEnts = {}
				--CorrectEntsToIDRecursive(info.constraints)
				for k,v in pairs(info.constraints) do
					info.constraintedEnts[k] = {
						v.Ent1,
						v.Ent2
					}
				end
			end
		end*/
		
		if ent:GetPhysicsObjectCount() <= 1 then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				WritePhysicsDataToTable(phys,info)
			end
		else
			info.physObjects = {}
			for i=0,ent:GetPhysicsObjectCount()-1 do
				local curPhys = ent:GetPhysicsObjectNum(i)
				local curPhysData = {}
				WritePhysicsDataToTable(curPhys,curPhysData)
				
				info.physObjects[i] = curPhysData
			end
		end
		
		if ent:IsWeapon() then
			info.weaponActivity = ent:GetActivity()
			info.clip1 = ent:Clip1()
			info.clip2 = ent:Clip2()
		end
	end
	return info
end

function ENT:IG_SetupInfo(info)
	local ent = self
	if info.alive and ent:IsPlayer() and !ent:Alive() then
		ent:Spawn()
	end
	
	if !info.onFire and ent:IsOnFire() then
		ent:Extinguish()
	end
	
	UpdateEntity(ent:GetNoDraw(),function(val)
		ent:SetNoDraw(val)
	end,info.noDraw)
	
	UpdateEntity(ent:GetModel(),function(val)
		ent:SetModel(val)
		ent:SetModelName(val)
	end,info.model)
	
	UpdateEntity(ent:GetMaterial(),function(val)
		ent:SetMaterial(val)
	end,info.mat)
	
	UpdateEntity(ent:GetColor(),function(val)
		ent:SetColor(val)
	end,info.color)
	
	UpdateEntity(ent:GetGravity(),function(val)
		ent:SetGravity(val)
	end,info.gravity)
	
	UpdateEntity(ent:GetTable(),function(val)
		ent:SetTable(val)
	end,info.table)
	
	UpdateEntity(ent:GetCollisionGroup(),function(val)
		ent:SetCollisionGroup(val)
	end,info.collisionGroup)
	
	UpdateEntity(ent:GetModelScale(),function(val)
		ent:SetModelScale(val)
	end,info.scale)
	
	if info.owner:IsValid() then
		UpdateEntity(ent:GetOwner(),function(val)
			ent:SetOwner(val)
		end,info.owner)
	end
	
	if info.parent:IsValid() then
		UpdateEntity(ent:GetParent(),function(val)
			ent:SetParent(val)
		end,info.parent)
	end
	
	UpdateEntity(ent:Health(),function(val)
		ent:SetHealth(val)
	end,info.health)
	
	UpdateEntity(ent:GetFlexScale(),function(val)
		ent:SetFlexScale(val)
	end,info.flexScale)
	
	UpdateEntity(ent:GetSequence(),function(val)
		ent:SetSequence(val)
	end,info.sequence)
	
	UpdateEntity(ent:GetCycle(),function(val)
		ent:SetCycle(val)
	end,info.cycle)
	
	if info.flexWeights and ent:GetFlexNum() > 0 then
		for i=0,ent:GetFlexNum()-1 do
			UpdateEntity(ent:GetFlexWeight(info.flexWeights[i]),function(val)
				ent:SetFlexWeight(i,val)
			end,info.flexWeights[i])
		end
	end
	
	if info.bonePositions and ent:GetBoneCount() > 0 then
		for i=0,math.min(ent:GetBoneCount(),table.Count(info.bonePositions))-1 do
			local pos = ent:GetManipulateBonePosition(i)
			UpdateEntity(pos,function(val)ent:ManipulateBonePosition(i,val)end,info.bonePositions[i])
			UpdateEntity(ent:GetManipulateBoneAngles(i),function(val)ent:ManipulateBoneAngles(i,val)end,info.boneAngles[i])
			UpdateEntity(ent:GetManipulateBoneScale(i),function(val)ent:ManipulateBoneScale(i,val)end,info.boneScales[i])
		end
	end
	
	ent:SetLocalVelocity(info.velocity)
	
	if ent:IsNPC() or ent:IsPlayer() then
		if info.activeWeapon then
			UpdateEntity(ent:GetActiveWeapon():IsValid() and ent:GetActiveWeapon():GetClass(),function(val)
				if ent:IsPlayer() and ent:GetWeapon(val):IsValid() then
					ent:SelectWeapon(val)
				else
					ent:Give(val)
				end
			end,info.activeWeapon)
		end
	end
	
	if ent:IsPlayer() then
		ent:SetEyeAngles(info.angles)
		if info.viewEnt >= 0 then
			UpdateEntity(ent:GetViewEntity(),function(val)
				ent:SetViewEntity(val)
			end,info.viewEnt)
		end
		
		if info.vehicle >= 0 then
			UpdateEntity(ent:GetVehicle(),function(val)
				if ent:InVehicle() then
					ent:ExitVehicle()
				end
				ent:EnterVehicle(val)
			end,info.parent)
		else
			if ent:InVehicle() then
				ent:ExitVehicle()
			end
		end
		if ent:InVehicle() then return end
	else
		/*if recordConstraints:GetBool() and info.constraintedEnts then
			CorrectEntIDsToEntsRecursive(info.constraints)
			for k,v in ipairs(info.constraints) do
				ConstraintsFromTable(v,{v.Ent1,v.Ent2})
			end
		end*/
		
		--ent:SetAngles(info.angles)
		
		if !ent:IsNPC() then
			ent:SetAngles(info.angles)
			if ent:GetPhysicsObjectCount() <= 1 then
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					SetPhysicsDataFromTable(phys,info)
				end
			elseif info.physObjects then
				for i,curPhysData in pairs(info.physObjects) do
					local curPhys = ent:GetPhysicsObjectNum(i)
					if curPhys:IsValid() then
						SetPhysicsDataFromTable(curPhys,curPhysData)
					end
				end
			end
			
			if ent:IsWeapon() then
				UpdateEntity(ent:Clip1(),function(val)
					ent:SetClip1(val)
				end,info.clip1)
				UpdateEntity(ent:Clip2(),function(val)
					ent:SetClip2(val)
				end,info.clip2)
				UpdateEntity(ent:GetActivity(),function(val)
					ent:SendWeaponAnim(val)
				end,info.weaponActivity)
			end
		else
			UpdateEntity(ent:GetNPCState(),function(val)
				ent:SetNPCState(val)
			end,info.npcState)
			UpdateEntity(ent:GetMovementActivity(),function(val)
				ent:SetMovementActivity(val)
			end,info.movementActivity)
			UpdateEntity(ent:CapabilitiesGet(),function(val)
				ent:CapabilitiesClear()
				ent:CapabilitiesAdd(val)
			end,info.capabilities)
			if info.condition then
				ent:SetCondition(info.condition)
			end
		end
	end
	
	ent:SetPos(info.pos)
end

IG_STONE_SOUL = 1
IG_STONE_REALITY = 2
IG_STONE_SPACE = 3
IG_STONE_POWER = 4
IG_STONE_TIME = 5
IG_STONE_MIND = 6
IG_STONE_INFINITY = 7

local zcityInfinityAllowedAbilities = {
	[IG_STONE_SOUL] = {[1] = true},
	[IG_STONE_REALITY] = {[1] = true},
	[IG_STONE_SPACE] = {[1] = true, [2] = true, [10] = true},
	[IG_STONE_TIME] = {[1] = true, [4] = true},
	[IG_STONE_MIND] = {[5] = true, [9] = true, [10] = true},
	[IG_STONE_INFINITY] = {[1] = true, [2] = true}
}

function IG_ZCityIsInfinityStoneRound()
	local round = CurrentRound and CurrentRound()
	return round and round.name == "infinitystone"
end

function IG_ZCityAbilityAllowed(stoneID, abilityID)
	local allowed = zcityInfinityAllowedAbilities[stoneID]
	if not allowed then return true end

	return allowed[abilityID] == true
end

function IG_ZCityFirstAllowedAbility(stoneID)
	local stoneData = IG_StoneData and IG_StoneData[stoneID]
	if not stoneData or not stoneData.abilities then return 1 end

	for abilityID in ipairs(stoneData.abilities) do
		if IG_ZCityAbilityAllowed(stoneID, abilityID) then
			return abilityID
		end
	end

	return 1
end

function IG_ZCityAbilityCooldownKey(stoneID, abilityID)
	return "IG_ZCityCooldown_" .. tostring(stoneID) .. "_" .. tostring(abilityID)
end

function SWEP:GetZCityAbilityCooldownEnd(stoneID, abilityID)
	return self:GetNWFloat(IG_ZCityAbilityCooldownKey(stoneID, abilityID), 0)
end

MOVETYPE_IG_PHASE = 12

local revivableNPCs = {}
local noSoulers = {
	npc_cscanner = true,
	npc_hunter = true,
	npc_strider = true,
	npc_clawscanner = true,
	npc_rollermine = true,
	npc_turret_floor = true,
	npc_combinegunship = true,
	npc_combinedropship = true,
	npc_turret_ceiling = true,
	npc_combine_camera = true,
	npc_dog = true,
	npc_manhack = true,
	npc_helicopter = true,
}
function ENT:IG_HasSoul()
	return !noSoulers[self:GetClass()]
end
hook.Add("OnNPCKilled","IG_RecordDeaths",function(npc)
	if !npc:IG_HasSoul() then return end
	revivableNPCs[npc] = {
		pos = npc:GetPos(),
		class = npc:GetClass(),
		entID = npc:EntIndex(),
		info = npc:IG_GetInfo(true,true),
		ent = npc,
	}
	revivableNPCs[npc].info.health = npc:GetMaxHealth()
end)

hook.Add("SetupMove","IG_MindStonePhase",function(ent,mv,cmd)
	if ent:GetMoveType() != MOVETYPE_IG_PHASE then return end
	mv:SetVelocity(ent:GetAbsVelocity()+(bit.band(cmd:GetButtons(),IN_JUMP) > 0 and Vector(0,0,.6) or (bit.band(cmd:GetButtons(),IN_DUCK) > 0 and Vector(0,0,-.6) or Vector())))
	return true
end)

hook.Add("FinishMove","IG_MindStonePhase",function(ent,mv)
	if ent:GetMoveType() != MOVETYPE_IG_PHASE then return end
	ent:SetPos(mv:GetOrigin())
	ent:SetAbsVelocity(mv:GetVelocity())
	ent:SetAngles(mv:GetMoveAngles())
	return true
end)

hook.Add("ShouldCollide","IG_WaterWalking",function(ent1,ent2)
	if (ent1.IG_WaterWalkEnt != ent2 and ent2.IG_IsWaterWalkEnt) or (ent2.IG_WaterWalkEnt != ent1 and ent1.IG_IsWaterWalkEnt) then
		return false
	end
end)

local function CreateWaterWalkFloor(ply,walkPos)
	if !IsValid(ply.IG_WaterWalkEnt) then
		local ent = ents.Create("prop_physics")
		ent:SetModel("models/hunter/plates/plate2x2.mdl")
		ent:SetPos(walkPos)
		ent:Spawn()
		ent:SetNoDraw(true)
		ent:SetRenderMode(RENDERMODE_TRANSALPHA)
		ent:SetColor(Color(0,0,0,0))
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
		ent:SetCustomCollisionCheck(true)
		ent:CollisionRulesChanged()
		ply.IG_WaterWalkEnt = ent
		ent.IG_IsWaterWalkEnt = true
	else
		ply.IG_WaterWalkEnt:SetPos(walkPos)
		ply.IG_WaterWalkEnt:SetAngles(Angle())
	end
end

hook.Add("Move","IG_WalkOnWater",function(ply,mv)
	if !ply.IG_WaterWalking then
		if ply.IG_WaterWalkEnt and ply.IG_WaterWalkEnt:IsValid() then
			ply.IG_WaterWalkEnt:Remove()
		end
		return
	end
	local ang,pos,vel = mv:GetMoveAngles(),mv:GetOrigin(),mv:GetVelocity()
	
	local tr = util.TraceLine{
		start = pos+Vector(0,0,9999999),
		endpos = pos-Vector(0,0,1000),
		mask = MASK_WATER,
	}
	if ply.IG_WaterWalkZ then
		CreateWaterWalkFloor(ply,Vector(pos.x,pos.y,ply.IG_WaterWalkZ))
	end
	if tr.Hit then
		if !ply.IG_WaterWalkZ and pos.z < tr.HitPos.z then --If we aren't water walking and if we are under water, do not teleport above it.
			return
		end
		local walkPos = tr.HitPos+vector_up
		if pos.z+10 < walkPos.z then
			mv:SetOrigin(walkPos+vector_up*5)
		end
		ply.IG_WaterWalkZ = walkPos.z-2
	else
		ply.IG_WaterWalkZ = nil
		if IsValid(ply.IG_WaterWalkEnt) then
			ply.IG_WaterWalkEnt:Remove()
		end
	end
end)

hook.Add("Move","IG_MindStonePhase",function(ent,mv)
	if ent:GetMoveType() != MOVETYPE_IG_PHASE then return end
	local speed = .005*FrameTime()
	local ang,pos,vel = mv:GetMoveAngles(),mv:GetOrigin(),mv:GetVelocity()
	vel = vel+ang:Forward()*mv:GetForwardSpeed()*speed
	vel = vel+ang:Right()*mv:GetSideSpeed()*speed
	vel = vel+ang:Up()*mv:GetUpSpeed()*speed
	
	if (math.abs(mv:GetForwardSpeed())+math.abs(mv:GetSideSpeed())+math.abs(mv:GetUpSpeed())) < .1 then
		vel = vel*.96
	else
		vel = vel*.99
	end
	
	pos = pos+vel
	mv:SetVelocity(vel)
	mv:SetOrigin(pos)
	ent:SetLocalVelocity(vel)
	
	return true
end)

hook.Add("StartCommand","IG_TransferInput",function(ply,cmd)
	if !ply:TransferingInput() then return end
	
	if CLIENT then
		net.Start("IG_TransferInput")
		net.WriteUInt(cmd:GetButtons(),16)
		net.SendToServer()
	end
	cmd:ClearButtons()
	cmd:ClearMovement()
end)

function PLY:TransferingInput()
	return self:GetNWBool("IG_TransferInput",false)
end

function IG_RayIntersectSphere(src,dir,pos,radius)
	local distance = pos:Distance(src)
	local range = (pos-(src+dir*distance)):Length()
	if (pos-src):Length() <= radius or range <= radius then
		return src+dir*(distance-(110*math.sqrt(1-(range/radius)^2))) --Return hit pos
	end
	return false
end

local RandF = math.Rand
local fullCircle = math.pi*2
local Sin,Cos = math.sin,math.cos
function IG_RandomPointInSphere(radius)
	local phi = RandF(0,fullCircle)
	local theta = math.acos(RandF(-1,1))
	local r = radius*(RandF(0,1)^(1/3))
	return Vector(r*Sin(theta)*Cos(phi),r*Sin(theta)*Sin(phi),r*Cos(theta))
end

function IG_IsRagdoll(mdl)
	if !mdl then return false end
	local info = util.GetModelInfo(mdl)
	if info and istable(info) and info.KeyValues then
		return info.KeyValues:find("ValveBiped") != nil or info.KeyValues:find("ragdollconstraint") != nil
	end
	return false
end

local function DoNothing(...)
	return ...
end

local function ValidConditionalData(conditionalData)
	return conditionalData and conditionalData.conditional and conditionalData.type
end

local function WriteConditional(conditionalData)
	net.WriteString(conditionalData.conditional)
	net.WriteString(conditionalData.type)
	net.WriteUInt(conditionalData.targetArgument,4)
	net.WriteBool(conditionalData.invert)
	net.WriteUInt(#conditionalData.arguments,4)
	for arg,data in pairs(conditionalData.arguments) do
		net.WriteType(data.value)
	end
end

local function ReadConditional()
	local conditionalData = {
		conditional = net.ReadString(),
		type = net.ReadString(),
		targetArgument = net.ReadUInt(4),
		invert = net.ReadBool(),
		arguments = {}
	}
	
	for k=1,net.ReadUInt(4) do --Read arguments
		conditionalData.arguments[k] = {
			value = net.ReadType()
		}
	end
	return conditionalData
end

function net.WriteIGLaw(lawName,writingLaw)
	net.WriteString(lawName)
	net.WriteString(writingLaw.event)
	net.WriteUInt(table.Count(writingLaw.actions),4)--Write number of arguments
	for argID,actionsList in pairs(writingLaw.actions) do
		net.WriteUInt(argID,4) --Write the argument we're on
		net.WriteUInt(#actionsList,4) --Write number of actions for current argument
		for k,actionData in ipairs(actionsList) do --Write the action
			net.WriteString(actionData.action)
			net.WriteString(actionData.type)
			net.WriteUInt(#actionData.arguments,4)
			for arg,data in pairs(actionData.arguments) do
				net.WriteType(data.value)
			end
			
			if ValidConditionalData(actionData.conditional) then --Write conditional
				net.WriteBool(true)
				WriteConditional(actionData.conditional)
			else
				net.WriteBool(false)
			end
		end
	end
	if writingLaw.returns then
		net.WriteBool(true)
		local conditionalData = writingLaw.returns.conditional
		if ValidConditionalData(conditionalData) then
			net.WriteBool(true)--Writing conditional.
			WriteConditional(conditionalData)
		else
			net.WriteBool(false)--Not writing conditional
			net.WriteType(writingLaw.returns.value)
		end
	else
		net.WriteBool(false)
	end
end

function net.ReadIGLaw()
	local lawName = net.ReadString()
	local law = {
		event = net.ReadString(),
	}
	local actions = {}
	law.actions = actions
	for i=1,net.ReadUInt(4) do --Read number of arguments for event
		local actionsList = {}
		actions[net.ReadUInt(4)] = actionsList --Make table of actions for the current argument
		for k=1,net.ReadUInt(4) do --Read number of actions for current argument
			local action = { --Read the action
				action = net.ReadString(),
				type = net.ReadString(),
				arguments = {}
			}
			actionsList[#actionsList+1] = action
			for k=1,net.ReadUInt(4) do --Read arguments
				action.arguments[k] = {
					value = net.ReadType()
				}
			end
			if net.ReadBool() then --Read conditional
				action.conditional = ReadConditional()
			end
		end
	end
	
	if net.ReadBool() then--Read returning
		if net.ReadBool() then --Conditional return
			law.returns = {
				conditional = ReadConditional()
			}
		else
			law.returns = {
				value = net.ReadType()
			}
		end
	end
	
	return lawName,law
end

local function RecursiveSoulBonding(self,ent)
	if !ent.IG_soulBonds then
		ent.IG_soulBonds = {}
	end
	for k,v in pairs(self.IG_soulBonds) do
		if k != ent and ent.IG_soulBonds and !ent.IG_soulBonds[k] then
			ent.IG_soulBonds[k] = true
			if k.IG_soulBonds then
				RecursiveSoulBonding(k,ent)
			end
		end
	end
end

function ENT:IG_SoulBondTo(target)
	if target == self or !target then return end
	
	if !self.IG_soulBonds then
		self.IG_soulBonds = {}
	end
	
	if !self.IG_soulBonds or self.IG_soulBonds[target] then --Idk why IG_soulBonds can be nil here, but it can be.
		return
	end
	
	self.IG_soulBonds[target] = true
	for ent,_ in pairs(self.IG_soulBonds) do
		ent:IG_SoulBondTo(self)
		RecursiveSoulBonding(self,ent)
		ent:IG_EnableEffect("soulbond",ent.IG_soulBonds)
	end
	self:IG_EnableEffect("soulbond",self.IG_soulBonds)
end

local function GetPlayerPocketDimension(ply)
	if IsValid(ply.IG_pocketDimension) then
		return ply.IG_pocketDimension
	end
	local pocketWidth = 2000
	local pocketLength = 2000
	local pocketHeight = 2000
	
	local pocketBounds = Vector(-pocketWidth/2,-pocketLength/2,-pocketHeight/2)
	local maxs = -pocketBounds
	
	--16384 is the "bounds" for the max map size, so we search between it, taking into account pocket dimensions.
	local worldBounds = Vector(-16384+pocketWidth,-16384+pocketLength,-16384+pocketHeight)
	local pocketPos = Vector(0,0,-worldBounds.z)
	local tr = {
		mins = pocketBounds,
		maxs = maxs,
	}
	
	while tr != nil and pocketWidth > 500 and pocketLength > 500 and pocketHeight > 500 do
		while pocketPos.z > -16384 do
			tr.start = Vector(math.random(worldBounds.x,-worldBounds.x),math.random(worldBounds.x,-worldBounds.x),pocketPos.z)
			tr.endpos = tr.start
			if util.IsInWorld(tr.start) and !util.TraceHull(tr).Hit then
				pocketPos = tr.start
				tr = nil
				break
			end
			pocketPos.z = pocketPos.z - 1
		end
		pocketWidth = pocketWidth-100
		pocketLength = pocketLength-100
		pocketHeight = pocketHeight-100
	end
	if tr then --Failed to find a pocket position.
		return NULL
	end
	
	local floor = ents.Create("ig_pocketwall")
	floor:SetWidth(pocketWidth)
	floor:SetLength(pocketLength)
	floor:SetHeight(100)
	floor:SetPos(pocketPos+vector_up*-(pocketHeight/2+floor:GetHeight()/2))
	floor:Spawn()
	floor:Activate()
	
	local ceiling = ents.Create("ig_pocketwall")
	ceiling:SetWidth(pocketWidth)
	ceiling:SetLength(pocketLength)
	ceiling:SetHeight(100)
	ceiling:SetPos(pocketPos+vector_up*(pocketHeight/2+ceiling:GetHeight()/2))
	ceiling:SetAngles(Angle(0,0,180))
	ceiling:Spawn()
	ceiling:Activate()
	
	local wallRight = ents.Create("ig_pocketwall")
	wallRight:SetWidth(pocketWidth)
	wallRight:SetLength(pocketHeight)
	wallRight:SetHeight(100)
	wallRight:SetPos(pocketPos+Vector(-pocketWidth/2-wallRight:GetHeight()/2,0,0))
	wallRight:SetAngles(Angle(0,90,90))
	wallRight:Spawn()
	wallRight:Activate()
	
	local wallLeft = ents.Create("ig_pocketwall")
	wallLeft:SetWidth(pocketWidth)
	wallLeft:SetLength(pocketHeight)
	wallLeft:SetHeight(100)
	wallLeft:SetPos(pocketPos+Vector(pocketWidth/2+wallLeft:GetHeight()/2,0,0))
	wallLeft:SetAngles(Angle(0,270,90))
	wallLeft:Spawn()
	wallLeft:Activate()
	
	local wallBack = ents.Create("ig_pocketwall")
	wallBack:SetWidth(pocketWidth)
	wallBack:SetLength(pocketHeight)
	wallBack:SetHeight(100)
	wallBack:SetPos(pocketPos+Vector(0,pocketLength/2+wallBack:GetHeight()/2,0))
	wallBack:SetAngles(Angle(0,0,90))
	wallBack:Spawn()
	wallBack:Activate()
	
	local wallFront = ents.Create("ig_pocketwall")
	wallFront:SetWidth(pocketWidth)
	wallFront:SetLength(pocketHeight)
	wallFront:SetHeight(100)
	wallFront:SetPos(pocketPos+Vector(0,-pocketLength/2-wallFront:GetHeight()/2,0))
	wallFront:SetAngles(Angle(0,180,90))
	wallFront:Spawn()
	wallFront:Activate()
	
	local pocketDimension = ents.Create("ig_pocketdimension")
	pocketDimension:SetWidth(pocketWidth)
	pocketDimension:SetLength(pocketLength)
	pocketDimension:SetHeight(pocketHeight)
	pocketDimension:SetPos(pocketPos)
	pocketDimension:Spawn()
	pocketDimension:Activate()
	pocketDimension:AddWall(ceiling)
	pocketDimension:AddWall(floor)
	pocketDimension:AddWall(wallLeft)
	pocketDimension:AddWall(wallRight)
	pocketDimension:AddWall(wallFront)
	pocketDimension:AddWall(wallBack)
	
	ply.IG_pocketDimension = pocketDimension
	return pocketDimension
end

local nextSnap = 0
IG_StoneData = {
	[1] = { --Soul Stone [FAR LEFT]
		name = "Soul",
		element = "soulstone_glow",
		color = Color(165,69,0),
		worldModel = "models/xyz/props/infinity_gem_soul.mdl",
		icon = Material("xyz/gui/infinitygauntlet/soulstone"),
		abilities = {
			{
				name = "See All",
				description = "Ignore obstructions and see all living things.",
				isChanneled = true,
				Use = function(self,data,ability)
					self.Owner:SetNWBool("IG_SoulVision",true)
				end,
				FinishChannel = function(self,data,ability)
					self.Owner:SetNWBool("IG_SoulVision",false)
				end,
			},
			{
				name = "Vampiric Beam",
				description = "Steal life from a target while channeled.",
				isChanneled = true,
				setBeamPos = function(self,data)
					local beam = data.beam
					if beam:IsValid() then
						local ang = self.Owner:EyeAngles()
						beam:SetPos(self.Owner:EyePos()+self.Owner:GetAimVector()*10-ang:Right()*5-ang:Up()*3)
						beam:SetAngles(self.Owner:GetAimVector():Angle())
					end
				end,
				Use = function(self,data,ability)
					local beam = ents.Create("ig_vampbeam")
					beam:Spawn()
					beam:Activate()
					beam:SetOwner(self.Owner)
					data.beam = beam
					ability.setBeamPos(self,data)
				end,
				Channel = function(self,data,ability)
					ability.setBeamPos(self,data)
				end,
			},
			{
				name = "Trap Soul",
				description = "Trap a living target within the Soul Stone.",
				Use = function(self,data,ability)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						if target:IsPlayer() then
							local veh = target:IG_SetExistant(false)
							veh:SetParent(self.Owner)
							self.Owner.IG_TrappedSouls = self.Owner.IG_TrappedSouls or {}
							self.Owner.IG_TrappedSouls[target] = true
						elseif target:IsNPC() then
							target:IG_SetExistant(false)
							target:SetPos(Vector())
							self.Owner.IG_TrappedSouls[target] = true
						end
					end
				end,
			},
			{
				name = "Free Souls",
				description = "Frees all souls stored within the stone.",
				Use = function(self,data,ability)
					for ent,v in pairs(self.Owner.IG_TrappedSouls or {}) do
						if ent:IsValid() and (ent:IsNPC() or ent:GetVehicle():IsValid()) and ent:Health() > 0 then
							ent:IG_SetExistant(true)
							ent:SetPos(IG_FindEmptyPositionEntity(ent,self.Owner:EyePos()+self.Owner:GetAimVector()*150,500,10,ent))
						end
					end
					self.Owner.IG_TrappedSouls = {}
				end,
			},
			{
				name = "Revive",
				description = "Bring a target back to life.",
				Use = function(self,data,ability)
					local checkPos = FindTarget(self).HitPos
					local distanceCheck = 300^2
					for npc,data in pairs(revivableNPCs) do
						if data.pos:DistToSqr(checkPos) < distanceCheck then
							local ent = ents.Create(data.class)
							ent:SetPos(data.pos)
							ent:Spawn()
							ent:Activate()
							revivableNPCs[npc] = nil
							ent:IGEffectTemp("soulstone_glow")
							if data.ent:IsValid() then
								data.ent:Remove()
							end
							net.Start("IG_NPCCorpseRemoved")
							net.WriteUInt(data.entID,16)
							net.Broadcast()
							ent:IG_SetupInfo(data.info)
							break
						end
					end
					for k,v in ipairs(player.GetAll()) do
						if !v:Alive() and v:GetPos():DistToSqr(checkPos) < distanceCheck then
							local pos = v:GetPos()+vector_up*30
							v:Spawn()
							v:SetPos(pos)
						end
					end
				end,
			},
			{
				name = "Soul Bond",
				description = "Link souls together, causing damage to be split between them. [SHIFT] to target yourself.",
				Use = function(self,data,ability)
					local target = self.Owner:KeyDown(IN_SPEED) and self.Owner or FindTarget(self).Entity
					if target:IsValid() and (target:IsPlayer() or target:IsNPC()) then
						local linkingTo = self.soulBondingEnt
						if IsValid(linkingTo) and linkingTo != target then
							self.soulBondingEnt = NULL
							target:IG_SoulBondTo(linkingTo)
						else
							self.soulBondingEnt = target
						end
					end
				end,
			},
			{
				name = "Soul Missile",
				description = "Fire a controllable missile from the soul stone.",
				Use = function(self,data,ability)
					local ent = ents.Create("ig_soulmissile")
					ent:SetPos(self.Owner:EyePos()+self.Owner:GetAimVector()*100)
					ent:SetAngles(self.Owner:EyeAngles())
					ent.isKeyDown = self.Owner:TransferInput(true)
					ent:Spawn()
					ent:SetDriver(self.Owner)
				end,
			},
			{
				name = "Soul Sentry",
				description = "Create a sentry that will attack nearby targets.",
				Use = function(self,data,ability)
					local ent = ents.Create("ig_soulsentry")
					ent:SetPos(self.Owner:EyePos()+self.Owner:GetAimVector()*100)
					ent:Spawn()
				end,
			},
			{
				name = "Soul Medic",
				description = "Create a medic that will heal you.",
				Use = function(self,data,ability)
					local ent = ents.Create("ig_soulmedic")
					ent:SetPos(self.Owner:EyePos()+self.Owner:GetAimVector()*100)
					ent:Spawn()
				end,
			},
			{
				name = "Dismiss Minion",
				description = "Dismisses a minion created by the soul stone.",
				Use = function(self,data,ability)
					local target = FindTarget(self).Entity
					if target:IsValid() and target.isSoulStoneMinion then
						target:Remove()
					end
				end,
			},
		},
	},
	[2] = { --Reality Stone
		name = "Reality",
		element = "realitystone_glow",
		worldModel = "models/xyz/props/infinity_gem_reality.mdl",
		color = Color(245,6,6),
		icon = Material("xyz/gui/infinitygauntlet/realitystone"),
		abilities = {
			{
				name = "Wipe",
				description = "Wipe the target's existence.",
				Use = function(self)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						IG_ExistanceWipe(target)
					end
				end
			},
			{
				name = "Transform",
				description = "Transform a target into something inanimate. Also reverts players.",
				Use = function(self)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						if target.IG_isActualPlayer then
							target:Remove()
						else
							if target:IsPlayer() then
								MakePlayerProp(target,GetRandomModel())
							elseif !target.IG_hasRealityTransformed then
								target.IG_hasRealityTransformed = true
								local prevModel = target:GetModel()
								target:SetModel(GetRandomModel())
								target:PhysicsInit(SOLID_VPHYSICS)
								target:Activate()
								timer.Simple(60,function()
									if target:IsValid() then
										if target:IsNPC() then
											target:Remove()
										else
											target:SetModel(prevModel)
										end
									end
								end)
								if target:GetPhysicsObject():IsValid() then
									target:GetPhysicsObject():Wake()
								end
							end
						end
					end
				end
			},
			{
				name = "Gravity",
				description = "Lower gravity in a local area around you.",
				isChanneled = true,
				Channel = function(self)
					for k,v in ipairs(ents.FindInSphere(self.Owner:GetPos(),750)) do
						if v == self.Owner then continue end
						if v:IsPlayer() and v:Alive() then
							v:IG_EnableEffect("realitytone_glow",true)
							v:SetLocalVelocity(Vector(0,0,260))
							v:SetGravity(.001)
							timer.Create("IG_GravityRevert"..v:EntIndex(),1,1,function()
								if v:IsValid() then
									v:SetGravity(1)
									v:IG_EnableEffect("realitytone_glow",false)
								end
							end)
						elseif v:GetPhysicsObject():IsValid() then
							v:IG_EnableEffect("realitytone_glow",true)
							local phys = v:GetPhysicsObject()
							phys:AddVelocity(Vector(0,0,1))
							phys:EnableGravity(false)
							timer.Create("IG_GravityRevert"..v:EntIndex(),1,1,function()
								if phys:IsValid() then
									phys:EnableGravity(true)
									v:IG_EnableEffect("realitytone_glow",false)
								end
							end)
						end
					end
				end
			},
			{
				name = "Unbind",
				description = "Removes all constraints near target location.",
				Use = function(self)
					for k,v in ipairs(ents.FindInSphere(util.TraceLine{
						start = self.Owner:EyePos(),
						endpos = self.Owner:EyePos()+self.Owner:GetAimVector()*1500,
						filter = self.Owner
					}.HitPos,350)) do
						if !v:IsPlayer() and !v:IsNPC() and v:GetPhysicsObject():IsValid() then
							v:GetPhysicsObject():EnableMotion(true)
							constraint.RemoveAll(v)
							v:IG_EnableEffect("realitytone_glow",true)
							timer.Create("IG_RemoveRealityStoneGlow"..v:EntIndex(),1,1,function()
								if v:IsValid() then
									v:IG_EnableEffect("realitytone_glow",false)
								end
							end)
						end
					end
				end
			},
			{
				name = "Shrink",
				description = "Shrink a target. [SHIFT] to shrink yourself.",
				isChanneled = true,
				Channel = function(self)
					local target = self.Owner:KeyDown(IN_SPEED) and self.Owner or FindTarget(self).Entity
					if IsValid(target) and target:GetModelScale() then
						target:IG_SetScale(math.max(.1,target:GetModelScale()-.05))
						
						target:IG_EnableEffect("realitytone_glow",true)
						timer.Create("IG_RemoveRealityStoneGlow"..target:EntIndex(),1,1,function()
							if target:IsValid() then
								target:IG_EnableEffect("realitytone_glow",false)
							end
						end)
					end
				end
			},
			{
				name = "Enlarge",
				description = "Enlarge a target. [SHIFT] to enlarge yourself.",
				isChanneled = true,
				Channel = function(self)
					local target = self.Owner:KeyDown(IN_SPEED) and self.Owner or FindTarget(self).Entity
					if IsValid(target) and target:GetModelScale() then
						target:IG_SetScale(math.min(5,target:GetModelScale()+.05))
						
						target:IG_EnableEffect("realitytone_glow",true)
						timer.Create("IG_RemoveRealityStoneGlow"..target:EntIndex(),1,1,function()
							if target:IsValid() then
								target:IG_EnableEffect("realitytone_glow",false)
							end
						end)
					end
				end
			},
			{
				name = "Manipulate Body",
				description = "Manipulate a target's bones.",
				isChanneled = true,
				findTarget = function(self,data)
					local target = FindTarget(self)
					if IsValid(target.Entity) and (target.Entity:IsPlayer() or target.Entity:IsNPC()) then
						data.target = target.Entity
						data.targetBone = target.Entity:IG_FindClosestBone(target.HitPos)
						if !data.targetBone or data.targetBone <= 0 then return end
						data.distance = target.HitPos:Distance(self.Owner:EyePos())
						
						local bonePos,boneAngle = target.Entity:GetBonePosition(data.targetBone)
						local manipPos,manipAngles = self.Owner:EyePos()+self.Owner:GetAimVector()*data.distance,self.Owner:EyeAngles()
						data.startManipulation = target.Entity:GetManipulateBonePosition(data.targetBone)
						data.boneAngle = boneAngle
						data.boneStartPos,data.boneStartAngle = LocalToWorld(Vector(),boneAngle,manipPos,manipAngles)
					end
				end,
				Use = function(self,data,ability)
					data.target = NULL
					ability.findTarget(self,data)
				end,
				Channel = function(self,data,ability)
					if !data.targetBone then return end
					if !data.target:IsValid() then
						ability.findTarget(self,data)
					end
					local target = data.target
					if target:IsValid() and data.distance then
						local manipPos,manipAngles = self.Owner:EyePos()+self.Owner:GetAimVector()*data.distance,self.Owner:EyeAngles()
						local pos,ang = WorldToLocal(manipPos,manipAngles,data.boneStartPos,data.boneAngle)
						pos:Add(data.startManipulation)
						
						target:ManipulateBonePosition(data.targetBone,pos)
						
						target:IG_EnableEffect("realitytone_glow",true)
						timer.Create("IG_RemoveRealityStoneGlow"..target:EntIndex(),1,1,function()
							if target:IsValid() then
								target:IG_EnableEffect("realitytone_glow",false)
							end
						end)
					end
				end,
			},
			{
				name = "Body Copy",
				description = "Attempt to copy the shape of one creature to another.",
				Use = function(self)
					local targetTr = FindTarget(self)
					local hitEnt = targetTr.Entity
					if hitEnt:IsValid() and (hitEnt:IsNPC() or hitEnt:IsPlayer()) and hitEnt:GetBoneCount() > 1 then
						if !IsValid(self.boneCopySource) then
							self.boneCopySource = hitEnt
						elseif self.boneCopySource:GetModel() != hitEnt:GetModel() then
							local source = self.boneCopySource
							self.boneCopySource = nil
							local effectBoneTable = {}
							
							local usedBones = {}
							for i=0,hitEnt:GetBoneCount()-1 do
								local targetPos,targetAngle = hitEnt:GetBonePosition(i)
								local targetLocalPos,targetLocalAngle = hitEnt:WorldToLocal(targetPos),hitEnt:WorldToLocalAngles(targetAngle)
								
								local closestBone,closestDist
								for b=0,source:GetBoneCount()-1 do
									if usedBones[b] then continue end
									local distance = source:WorldToLocal(source:GetBonePosition(b)):DistToSqr(targetLocalPos)
									if (!closestDist or distance < closestDist) then
										closestDist = distance
										closestBone = b
									end
								end
								
								if closestBone then
									usedBones[closestBone] = true
									if table.Count(usedBones) == source:GetBoneCount()-1 then usedBones = {} end
									local closestBonePos,closestBoneAng = source:GetBonePosition(closestBone)
									effectBoneTable[i] = {
										source:WorldToLocal(closestBonePos),
										source:WorldToLocalAngles(closestBoneAng)
									}
								end
							end
							
							hitEnt:IG_EnableEffect("copyBoneStruct",{
								bones = effectBoneTable
							})
						end
					end
				end
			},
			{
				name = "Heal",
				description = "Heals a target while channeled. [SHIFT] for yourself.",
				isChanneled = true,
				Channel = function(self,data)
					local target = self.Owner:KeyDown(IN_SPEED) and self.Owner or FindTarget(self).Entity
					if IsValid(target) and (target:IsPlayer() or target:IsNPC()) then
						target:SetHealth(math.min(3000,target:Health()+10))
						
						target:IG_EnableEffect("realitytone_glow",true)
						timer.Create("IG_RemoveRealityStoneGlow"..target:EntIndex(),1,1,function()
							if target:IsValid() then
								target:IG_EnableEffect("realitytone_glow",false)
							end
						end)
					end
				end,
			},
			{
				name = "Reset Size",
				description = "Reset a target's size. [SHIFT] to reset yourself.",
				isChanneled = true,
				Channel = function(self)
					local target = self.Owner:KeyDown(IN_SPEED) and self.Owner or FindTarget(self).Entity
					if IsValid(target) and target:GetModelScale() then
						target:IG_SetScale(1)
						
						target:IG_EnableEffect("realitytone_glow",true)
						timer.Create("IG_RemoveRealityStoneGlow"..target:EntIndex(),1,1,function()
							if target:IsValid() then
								target:IG_EnableEffect("realitytone_glow",false)
							end
						end)
					end
				end
			},
			{
				name = "Disarm",
				description = "Remove a target's weapon.",
				Use = function(self)
					local target = FindTarget(self).Entity
					if IsValid(target) and (target:IsPlayer() or target:IsNPC()) then
						local wep = target:GetActiveWeapon()
						if wep:IsValid() then
							local bone = target:LookupBone("ValveBiped.Bip01_R_Hand")
							local pos
							if bone then
								pos = target:GetBonePosition(bone)
							else
								pos = target:GetPos()+target:OBBCenter()
							end
							local ef = EffectData()
							ef:SetOrigin(pos)
							util.Effect("ig_bubbles",ef,true,true)
							wep:Remove()
						end
					end
				end
			},
			{
				name = "Bubble Bullets",
				description = "Turns bullets into bubbles while channeled.",
				isChanneled = true,
				radius = 750^2,
				Use = function(self,data,ability)
					local hookName = "IG_PreventBullets"..self:EntIndex()
					hook.Add("EntityFireBullets",hookName,function(ent,data)
						if !self:IsValid() then
							hook.Remove("EntityFireBullets",hookName)
							return
						end
						if data.Src:DistToSqr(self.Owner:GetPos()) <= ability.radius then
							local ef = EffectData()
							ef:SetOrigin(data.Src+data.Dir*30)
							util.Effect("ig_bubbles",ef,true,true)
							return false
						end
					end)
				end,
				FinishChannel = function(self)
					hook.Remove("EntityFireBullets","IG_PreventBullets"..self:EntIndex())
				end
			},
			{
				name = "Invisibility",
				description = "Turn yourself invisible while channeled.",
				isChanneled = true,
				noSound = true,
				Use = function(self,data,ability)
					local ply = self.Owner
					data.prevNoDraw = ply:GetNoDraw()
					ply:SetNoDraw(true)
					ply:SetNWBool("IG_Invis",true)
				end,
				Channel = function(self)
					local ply = self.Owner
					for k,v in ipairs(ents.GetAll()) do
						if v:IsNPC() and !v.IGSlaved then
							v:AddEntityRelationship(ply,D_NU,10)
						end
					end
				end,
				FinishChannel = function(self,data)
					local ply = self.Owner
					ply:SetNoDraw(data.prevNoDraw)
					ply:SetNWBool("IG_Invis",false)
					for k,v in ipairs(ents.GetAll()) do
						if v:IsNPC() and !v.IGSlaved then
							v:AddEntityRelationship(ply,D_HT,20)
						end
					end
				end
			},
			{
				name = "Water Walking",
				description = "Walk on water while channeled.",
				isChanneled = true,
				Use = function(self,data,ability)
					self.Owner.IG_WaterWalking = true
				end,
				FinishChannel = function(self,data)
					self.Owner.IG_WaterWalking = false
					self.Owner.IG_WaterWalkZ = nil
				end
			},
			{
				name = "Toggle Ignition",
				description = "Extinguishes or ignites a target. [SHIFT] to target yourself.",
				Use = function(self)
					local target = self.Owner:KeyDown(IN_SPEED) and self.Owner or FindTarget(self).Entity
					if IsValid(target) then
						if target:IsOnFire() then
							target:Extinguish()
						else
							target:Ignite(9999999)
						end
					end
				end
			},
			{
				name = "Animate",
				description = "Animate an inanimate object that will attack nearby enemies.",
				jumpSounds = {
					"NPC_CombineGunship.Pain",
					"NPC_CScanner.Pain",
					"NPC_dog.Pain_1",
					"NPC_dog.Pain_2",
					"NPC_FastZombie.Pain",
					"NPC_Seagull.Pain",
					"NPC_Strider.Pain",
					"Streetwar.d3_c17_10b_gunship_pain",
				},
				Use = function(self,_,ability)
					local target = FindTarget(self).Entity
					if IsValid(target) and !target:IsNPC() and !target:IsPlayer() and  target:GetPhysicsObject():IsValid() then
						local owner = self.Owner
						local hookName = "IG_AnimateThink"..target:EntIndex()
						local nextJump = 0
						local jumpSounds = ability.jumpSounds
						hook.Add("Think",hookName,function()
							if nextJump > CurTime() then return end
							if !target:IsValid() or !target:GetPhysicsObject():IsValid() then
								hook.Remove("Think",hookName)
								return
							end
							nextJump = CurTime()+1.5
							local closestRange
							local closestEnt = NULL
							for k,v in ipairs(ents.FindInSphere(target:GetPos(),5500)) do
								if v != owner and ((v:IsPlayer() and v:Alive()) or (v:IsNPC() and v:Health() > 0)) then
									local dist = v:GetPos():DistToSqr(target:GetPos()) 
									if closestRange == nil or dist < closestRange then
										closestRange = dist
										closestEnt = v
									end
								end
							end
							
							local vel = closestEnt:IsValid() and (closestEnt:LocalToWorld(closestEnt:OBBCenter())-target:GetPos()):GetNormalized()*100*target:GetPhysicsObject():GetMass() or VectorRand()*220
							if closestEnt:IsValid() then
								target:EmitSound(jumpSounds[math.random(1,#jumpSounds)])
							end
							
							for i=0,target:GetPhysicsObjectCount()-1 do
								local phys = target:GetPhysicsObjectNum(i)
								if phys:IsValid() then
									phys:SetVelocity(vel)
									phys:AddAngleVelocity(VectorRand()*20)
								end
							end
						end)
					end
				end
			},
			{
				name = "Statuize",
				description = "Turn the target into a statue.",
				Use = function(self)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						target:IG_MakeStatue()
					end
				end
			},
			{
				name = "Warp Composition",
				description = "Give the target a random material with attributes.",
				mats = {
					{
						mat = "models/props_c17/oil_drum001h",
						Physics = function(self,ent)
							ent.IG_PhysCallback = ent:AddCallback("PhysicsCollide",function(e,data)
								if data.Speed < 100 or ent.ig_blewup or data.HitEntity == ent then return end
								timer.Simple(0,function()
									if ent:IsValid() then
										CreateExplosion(ent:GetPos(),500,600,self:IsValid() and self.Owner or ent,ent)
										ent:Remove()
									end
								end)
								ent.ig_blewup = true
							end)
						end,
						hooks = {
							EntityTakeDamage = function(self,target,data,ent,dmg)
								if ent == target and !ent.ig_blewup then
									ent.ig_blewup = true
									CreateExplosion(ent:GetPos(),500,600,self:IsValid() and self.Owner or ent,ent)
									ent:Remove()
								end
							end,
							GetFallDamage = function(self,target,data,ply,speed)
								if target == ply then
									CreateExplosion(ply:GetPos(),500,600,self:IsValid() and self.Owner or ent,ply)
								end
							end,
							PostPlayerDeath = function(self,target,data,ply)
								if target == ply and !ply.ig_blewup then
									ply.ig_blewup = true
									CreateExplosion(ply:GetPos(),500,600,self:IsValid() and self.Owner or ent,ply)
								end
							end,
						}
					},
					{
						mat = "phoenix_storms/egg",
						Physics = function(self,ent)
							ent.IG_PhysCallback = ent:AddCallback("PhysicsCollide",function(e,data)
								if data.Speed < 100 or ent.ig_blewup or data.HitEntity == ent then return end
								timer.Simple(0,function()
									if ent:IsValid() then
										ent:EmitSound("phx/eggcrack.wav")
										ent:Remove()
									end
								end)
								ent.ig_blewup = true
							end)
						end,
						hooks = {
							EntityTakeDamage = function(self,target,data,ent,dmg)
								if ent == target and !ent.ig_blewup then
									ent.ig_blewup = true
									ent:EmitSound("phx/eggcrack.wav")
									if ent:IsPlayer() then
										ent:KillSilent()
									else
										ent:Remove()
									end
								end
							end,
							GetFallDamage = function(self,target,data,ply,speed)
								if target == ply then
									ply:EmitSound("phx/eggcrack.wav")
									ply:TakeDamage(99999,self:IsValid() and self.Owner or ply,self:IsValid() and self or ply)
								end
							end,
						}
					},
					{
						mat = "models/noesis/donut",
						Physics = function(self,ent)
							ent.IG_PhysCallback = ent:AddCallback("PhysicsCollide",function(e,data)
								if data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() then
									data.HitEntity:SetHealth(math.min(5000,data.HitEntity:Health()+10))
								end
							end)
						end,
						hooks = {
							Think = function(self,target,data,ent,dmg)
								if data.nextHealth and data.nextHealth > CurTime() then return end
								target:SetHealth(target:Health()+1)
								data.nextHealth = CurTime()+.1
							end,
						}
					},
					{
						mat = "models/brokenglass/glassbroken_piece1",
						hooks = {
							EntityTakeDamage = function(self,target,data,ent,dmg)
								if ent == target and !ent.ig_blewup then
									ent.ig_blewup = true
									ent:EmitSound("impacts/glass_impact.wav")
									if ent:IsPlayer() then
										ent:KillSilent()
									else
										ent:Remove()
									end
								end
							end,
						}
					},
					{
						mat = "models/props_junk/phys_objects01a",
						Cleanup = function(target)
							if target.ig_whirlSound and IsValid(target.ig_whirlSound) then
								target.ig_whirlSound:Stop()
							end
						end,
						hooks = {
							Think = function(self,target,data,ent,dmg)
								if !target:IsPlayer() then
									if target:GetPhysicsObjectCount() > 1 then
										for i=0,target:GetPhysicsObjectCount()-1 do
											local phys = target:GetPhysicsObjectNum(i)
											if phys:IsValid() then
												local ang = phys:GetAngles()
												ang:RotateAroundAxis(phys:GetAngles():Up(),50)
												phys:SetAngles(ang)
											end
										end
									else
										local ang = target:GetAngles()
										ang:RotateAroundAxis(target:GetAngles():Up(),50)
										target:SetAngles(ang)
									end
									target.ig_whirlSound = CreateSound(target,"Town.d1_town_01_spin_loop")
									target.ig_whirlSound:Play()
									target.ig_whirlSound:ChangePitch(255)
									target.ig_whirlSound:SetSoundLevel(170)
								end
								if data.nextDamage and data.nextDamage > CurTime() then return end
								for k,v in ipairs(ents.FindInSphere(target:GetPos(),100)) do
									if v:IsValid() and v != target and v:Health() > 0 then
										local info = DamageInfo()
										info:SetDamageType(DMG_SLASH)
										info:SetDamage(5)
										info:SetAttacker(target)
										info:SetInflictor(target)
										v:TakeDamageInfo(info)
									end
								end
								data.nextDamage = CurTime()+.1
							end,
						}
					},
					{
						mat = "models/humans/male/group01/sandro_facemap",
						hooks = {
							Think = function(self,target,data,ent,dmg)
								if data.nextScream and data.nextScream > CurTime() then return end
								
								target:EmitSound("npc_citizen.help01",511,math.random(60,150))
								
								data.nextScream = CurTime()+math.Rand(.2,.4)
								if data.nextLaunch and data.nextLaunch > CurTime() then return end
								
								if target:IsPlayer() or target:IsNPC() then
									target:SetLocalVelocity(Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-.01,1))*500)
								else
									for i=0,target:GetPhysicsObjectCount()-1 do
										local phys = target:GetPhysicsObjectNum(i)
										if phys:IsValid() then
											phys:SetVelocity(VectorRand()*500*phys:GetMass())
										end
									end
								end
								
								data.nextLaunch = CurTime()+.5
							end,
						}
					},
					{
						mat = "models/props_c17/furnituretoletsink001a",
						hooks = {
							Think = function(self,target,data,ent,dmg)
								if data.nextPoop and data.nextPoop > CurTime() then return end
								
								local poop = ents.Create("prop_physics")
								poop:SetModel("models/props_junk/PopCan01a.mdl")
								poop:SetColor(Color(43,33,10))
								poop:SetPos(target:GetPos()+target:OBBCenter())
								poop:Spawn()
								poop:Activate()
								timer.Simple(30,function()
									if poop:IsValid() then poop:Remove() end
								end)
								
								data.nextPoop = CurTime()+math.Rand(3,10)
							end,
						}
					},
					{
						mat = "models/props_wasteland/concretewall066a",
						Cleanup = function(ent)
							ent:SetHealth(math.max(100,ent:Health()-9000))
						end,
						Player = function(self,ent)
							ent:SetHealth(ent:Health()+9000)
						end,
						NPC = function(self,ent)
							ent:SetHealth(ent:Health()+9000)
						end,
						Physics = function(self,ent)
							ent:GetPhysicsObject():SetMass(9999)
							
							ent.IG_PhysCallback = ent:AddCallback("PhysicsCollide",function(e,data)
								util.ScreenShake(ent:GetPos(),500,.1,1,(200/data.Speed)*500)
							end)
						end,
						hooks = {
							PlayerFootstep = function(self,target,data,ply,pos)
								if target == ply then
									util.ScreenShake(ply:GetPos(),500,.1,1,1500)
								end
							end,
							EntityTakeDamage = function(self,target,data,ent,dmg)
								if dmg:GetAttacker() == target and dmg:IsDamageType(DMG_CRUSH+DMG_SLASH+DMG_CLUB) then
									dmg:ScaleDamage(5)
								end
							end,
							Move = function(self,target,data,ply,mv)
								if target == ply then
									mv:SetMaxClientSpeed(mv:GetMaxClientSpeed()*.5)
									mv:SetMaxSpeed(mv:GetMaxSpeed()*.5)
								end
							end,
						}
					},
					{
						mat = "models/props_combine//breenglobe_sheet",
						hooks = {
							Think = function(self,target,data,ent,dmg)
								for k,v in ipairs(ents.FindInSphere(target:GetPos(),1200)) do
									if v != target and (v:IsPlayer() or v:GetPhysicsObject():IsValid()) and v:IsValid() then
										local vel = ((target:GetPos()-v:GetPos()):GetNormalized()*800)
										
										if v:IsPlayer() and !v:HasInfinityStone(IG_STONE_SPACE) then
											v:SetLocalVelocity(vel)
										else
											if v:IsNPC() then
												v:SetLocalVelocity(vel)
											else
												v:GetPhysicsObject():AddVelocity(vel)
											end
										end
									end
								end
							end,
						}
					},
					{
						mat = "models/props_junk/gascan001a.mdl",
						hooks = {
							Think = function(self,target,data)
								for k,v in ipairs(ents.FindInSphere(target:GetPos(),1200)) do
									if v:IsValid() and v != target and !v:IsWeapon() and (v:GetPhysicsObject():IsValid() or v:IsNPC() or (v:IsPlayer() and v:Alive())) then
										v:Ignite(50)
									end
								end
							end,
						}
					},
					{
						mat = "models/props_lab/tpplug_plug",
						hooks = {
							Think = function(self,target,data)
								if data.nextTeslaZapUpdate and data.nextTeslaZapUpdate > CurTime() then return end
								data.nextTeslaZapUpdate = CurTime()+.5
								local ef = EffectData()
								ef:SetOrigin(target:GetPos())
								ef:SetEntity(target)
								ef:SetMagnitude(60)
								util.Effect("TeslaHitboxes",ef,false,true)
								target:EmitSound("ambient.electrical_zap_"..math.random(1,3))
								
								for k,v in ipairs(ents.FindInSphere(target:GetPos(),100)) do
									if v:IsPlayer() or v:IsNPC() then
										local dmg = DamageInfo()
										dmg:SetInflictor(target)
										dmg:SetAttacker(target)
										dmg:SetDamage(10)
										dmg:SetDamageType(DMG_SHOCK)
										v:TakeDamageInfo(dmg)
									end
								end
							end,
						}
					},
					{
						mat = "models/props_junk/cardboard_boxes001a",
						hooks = {
							Think = function(self,target,data)
								if data.nextEggOutput and data.nextEggOutput > CurTime() then return end
								data.nextEggOutput = CurTime()+.1
								local pos = target:LocalToWorld(Vector(0,0,target:GetModelRadius()))
								if !util.IsInWorld(pos) then return end
								local egg = ents.Create("prop_physics")
								egg:SetModel("models/props_phx/misc/egg.mdl")
								egg:SetPos(pos)
								egg:Spawn()
								egg:Activate()
								egg:AddCallback("PhysicsCollide",function(prop,data)
									if data.HitEntity:IsValid() then
										data.HitEntity:TakeDamage(99999999,prop,prop)
									end
								end)
								timer.Simple(10,function()
									if IsValid(egg) then egg:Remove() end
								end)
								egg:GetPhysicsObject():SetVelocity((Vector(math.Rand(-.5,.5),math.Rand(-.5,.5),target:GetAngles():Up().z)*900))
							end,
						}
					},
				},
				Use = function(self,data,ability)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						local chosen = table.Random(ability.mats)
						if target.IG_PhysCallback then
							target:RemoveCallback("PhysicsCollide",target.IG_PhysCallback)
							target.IG_PhysCallback = nil
						end
						
						target:IG_RemoveMaterialEffect()
						
						target.IG_Materialized = chosen
						target:SetMaterial(chosen.mat)
						if chosen.NPC and target:IsNPC() then
							chosen.NPC(self,target)
						elseif chosen.Player and target:IsPlayer() then
							chosen.Player(self,target)
						elseif chosen.Physics and target:GetPhysicsObject():IsValid() then
							chosen.Physics(self,target,target:GetPhysicsObject())
						end
						
						if chosen.hooks then
							for k,v in pairs(chosen.hooks) do
							local data = {}
								hook.Add(k,"IG_MaterializedEffect"..target:EntIndex(),function(...)
									return v(self,target,data,...)
								end)
							end
						end
					end
				end
			},
			{
				name = "Illusion",
				description = "Create an illusion of yourself on targetted surface.",
				Use = function(self)
					local targetTr = FindTarget(self)
					local hitEnt = targetTr.Entity
					if hitEnt == NULL or hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:GetClass() == "ig_playerillusion" then return end
					local ent = ents.Create("ig_playerillusion")
					local eyeAngles = self.Owner:EyeAngles()
					
					local hitAngle = targetTr.HitNormal:Angle()
					hitAngle:RotateAroundAxis(hitAngle:Right(),270)
					hitAngle:RotateAroundAxis(hitAngle:Up(),eyeAngles.y)
					
					ent:SetModelScale(self.Owner:GetModelScale())
					ent:SetAngles(hitAngle)
					ent.owner = self.Owner
					ent:SetPos(targetTr.HitPos)
					ent:Spawn()
				end
			},
			{
				name = "Pocket Dimension",
				description = "Send a target to/from your pocket dimension. [SHIFT] to target yourself.",
				Use = function(self)
					local hitEnt = self.Owner:KeyDown(IN_SPEED) and self.Owner or FindTarget(self).Entity
					
					local pocketDimension = GetPlayerPocketDimension(self.Owner)
					if !pocketDimension:IsValid() then
						self.Owner:ChatPrint("Map is too small for pocket dimension!")
						return
					end
					
					if hitEnt:IsValid() then
						local sendPos
						
						local pocketSize = pocketDimension:GetPocketBounds().x
						if pocketDimension:PositionInside(hitEnt:GetPos()) then
							sendPos = self.Owner.IG_pocketDimensionEnterPos
						else
							if hitEnt == self.Owner then
								self.Owner.IG_pocketDimensionEnterPos = self.Owner:GetPos()
							end
							local targetPos = pocketDimension:GetPos()+Vector(math.random(-pocketSize/2,pocketSize/2),math.random(-pocketSize/2,pocketSize/2),0)
							sendPos = util.TraceEntity({
								start = targetPos,
								endpos = targetPos+vector_up*-9999,
								filter = pocketDimension
							},hitEnt).HitPos
						end
						
						local ef = EffectData()
						local mins,maxs = hitEnt:OBBMins(),hitEnt:OBBMaxs()
						mins:Rotate(hitEnt:GetAngles())
						maxs:Rotate(hitEnt:GetAngles())
						ef:SetOrigin(hitEnt:GetPos()+mins)
						ef:SetStart(hitEnt:GetPos()+maxs)
						ef:SetRadius(hitEnt:GetModelRadius())
						util.Effect("ig_pocketed",ef,true,true)
						
						local newPos = IG_FindEmptyPositionEntity(hitEnt,sendPos,pocketSize,100,{pocketDimension})
						if hitEnt:GetPhysicsObjectCount() > 1 then
							for id=0,hitEnt:GetPhysicsObjectCount()-1 do
								local phys = hitEnt:GetPhysicsObjectNum(id)
								if phys:IsValid() then
									local offset = hitEnt:WorldToLocal(phys:GetPos())
									phys:SetPos(newPos+offset)
									phys:Wake()
								end
							end
						else
							hitEnt:SetPos(newPos)
						end
						if !hitEnt:IsPlayer() and hitEnt:GetPhysicsObject():IsValid() then
							hitEnt:GetPhysicsObject():Wake()
						end
					end
				end
			},
			{
				name = "Destroy Pocket Dimension",
				description = "Destroy your pocket dimension and everything in it.",
				Use = function(self)
					local pocketDimension = self.Owner.IG_pocketDimension
					if pocketDimension:IsValid() then
						pocketDimension:Remove()
					end
				end
			},
		},
	},
	[3] = { --Space Stone
		name = "Space",
		element = "spacestone_glow",
		worldModel = "models/xyz/props/infinity_gem_space.mdl",
		color = Color(29,86,153),
		icon = Material("xyz/gui/infinitygauntlet/spacestone"),
		abilities = {
			{
				name = "Freeze",
				description = "Toggle an object's motion.",
				Use = function(self)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						local isFrozen = target.IG_Frozen
						for id=0,target:GetPhysicsObjectCount()-1 do
							local phys = target:GetPhysicsObjectNum(id)
							if phys:IsValid() then
								if !phys:IsMotionEnabled() then
									isFrozen = true
									break
								end
							end
						end
						if isFrozen then
							target:IG_EnableMotion(true)
							target:IG_EnableEffect("spacestone_glow",false)
							target.IG_Frozen = false
						else
							target:IG_EnableMotion(false)
							target:IG_EnableEffect("spacestone_glow",true)
							target.IG_Frozen = true
						end
						
					end
				end
			},
			{
				name = "Telekenisis",
				description = "Push or pull objects. Hold [SHIFT] to pull.",
				isChanneled = true,
				Channel = function(self)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						local velocity = self.Owner:GetAimVector()*(self.Owner:KeyDown(IN_SPEED) and -100 or 5000)
						if self.Owner:KeyDown(IN_SPEED) and target:GetPos():Distance(self.Owner:GetPos()) < target:GetModelRadius()+50 then
							if target:IsPlayer() then
								target:SetLocalVelocity(Vector())
							elseif target:GetPhysicsObject():IsValid() then
								target:GetPhysicsObject():SetVelocity(Vector())
							end
							return
						end
						
						target:IG_EnableMotion(true)
						target:IG_EnableEffect("spacestone_glow",true)
						timer.Create("IG_RemoveSpaceStoneGlow"..target:EntIndex(),1,1,function()
							if target:IsValid() then
								target:IG_EnableEffect("spacestone_glow",false)
							end
						end)
						
						if target:IsPlayer() then
							target:SetLocalVelocity(velocity+Vector(0,0,10))
						elseif target:IsNPC() then
							target:SetLocalVelocity(velocity+Vector(0,0,10))
						elseif target:GetPhysicsObject():IsValid() then
							local phys = target:GetPhysicsObject()
							phys:EnableMotion(true)
							phys:AddVelocity(velocity)
							local hookName = "IG_PreventSelfPropKill"..target:EntIndex()
							hook.Add("Think",hookName,function()
								if !self:IsValid() or !self.Owner:IsValid() or !target:IsValid() or !target:GetPhysicsObject():IsValid() then
									hook.Remove("Think",hookName)
									return
								end
								if self.Owner:KeyDown(IN_SPEED) and target:GetPos():Distance(self.Owner:GetPos()) < 200 then
									target:GetPhysicsObject():SetVelocity(Vector())
									hook.Remove("Think",hookName)
								end
							end)
						end
					end
				end,
			},
			{
				name = "Manipulate",
				description = "Move anything to an absolute.",
				isChanneled = true,
				findTarget = function(self,data,ability)
					local target = FindTarget(self)
					if IsValid(target.Entity) then
						data.distance = self.Owner:EyePos():Distance(target.Entity:GetPos())
						data.angles = target.Entity:GetAngles()
						data.target = target.Entity
						data.target:IG_EnableEffect("spacestone_glow",true)
						data.physData = {}
						if data.target:IsPlayer() then
							data.target:Lock()
						end
						
						data.offset = target.Entity:GetPos()-ability.getNewPos(self,data)
						local pos,ang = WorldToLocal(target.Entity:GetPos(),target.Entity:GetAngles(),self.Owner:EyePos(),self.Owner:EyeAngles())
						data.offsetAngle = ang
					end
				end,
				getNewPos = function(self,data)
					return self.Owner:EyePos()+self.Owner:GetAimVector()*data.distance
				end,
				OnWheeled = function(self,data,ability,amount)
					data.distance = math.max(70,data.distance+amount*10)
				end,
				Use = function(self,data,ability)
					data.target = NULL
					ability.findTarget(self,data,ability)
				end,
				Channel = function(self,data,ability)
					if !data.target:IsValid() then
						ability.findTarget(self,data,ability)
					end
					local target = data.target
					if target:IsValid() then
						local pos = ability.getNewPos(self,data)+data.offset
						target:SetAngles(data.angles)
						local _,rotAng = LocalToWorld(target:GetPos(),data.offsetAngle,self.Owner:EyePos(),self.Owner:EyeAngles())
						if target:GetPhysicsObjectCount() <= 1 then
							target:SetPos(pos)
							if !(target:IsNPC() or target:IsPlayer()) then
								target:SetAngles(rotAng)
							end
						else
							for id=0,target:GetPhysicsObjectCount()-1 do
								local phys = target:GetPhysicsObjectNum(id)
								if phys:IsValid() then
									local physData
									if !data.physData[id] then
										physData = {
											phys:IsCollisionEnabled(),
											target:WorldToLocal(phys:GetPos()),
											phys:GetAngles()
										}
										
										data.physData[id] = physData
										phys:EnableCollisions(false)
										phys:EnableMotion(true)
									else
										physData = data.physData[id]
									end
									local offset = Vector(physData[2])
									offset:Rotate(rotAng)
									phys:SetPos(pos+offset)
									phys:Wake()
								end
							end
						end
					end
				end,
				FinishChannel = function(self,data)
					local target = data.target
					if target:IsValid() then
						target:IG_EnableEffect("spacestone_glow",false)
						if target:IsPlayer() then
							target:UnLock()
						elseif target:GetPhysicsObject():IsValid() then
							for id=0,target:GetPhysicsObjectCount()-1 do
								local phys = target:GetPhysicsObjectNum(id)
								if phys:IsValid() then
									local physData = data.physData[id]
									if physData then
										phys:EnableCollisions(physData[1])
									end
									phys:EnableMotion(false)
								end
							end
						end
					end
				end
			},
			{
				name = "Gravity Well",
				description = "Pull nearby entities to target area.",
				isChanneled = true,
				Use = function(self,data)
					data.distance = 1500
				end,
				OnWheeled = function(self,data,ability,amount)
					data.distance = math.min(2000,math.max(70,data.distance+amount*10))
				end,
				Channel = function(self,data,ability)
					local pullPos = util.TraceLine{
						start = self.Owner:EyePos(),
						endpos = self.Owner:EyePos()+self.Owner:GetAimVector()*data.distance,
						filter = self.Owner,
						mask = MASK_SOLID_BRUSHONLY,
					}.HitPos
					for k,v in ipairs(ents.FindInSphere(pullPos,1500)) do
						if v != self.Owner and (v:IsPlayer() or v:GetPhysicsObject():IsValid()) then
							local dir = ((pullPos-v:GetPos()):GetNormal()*500)
							if v:IsPlayer() or v:IsNPC() then
								v:SetLocalVelocity(dir*5)
							else
								v:GetPhysicsObject():SetVelocity(dir)
							end
						end
					end
				end,
			},
			{
				name = "Discombobulate",
				description = "Launch nearby entities away from target location.",
				Use = function(self,data,ability)
					local targetPos = util.TraceLine{
						start = self.Owner:EyePos(),
						endpos = self.Owner:EyePos()+self.Owner:GetAimVector()*1500,
						filter = self.Owner
					}.HitPos
					for k,v in ipairs(ents.FindInSphere(targetPos,1500)) do
						if v != self.Owner and (v:IsPlayer() or v:GetPhysicsObject():IsValid()) and v:IG_MotionEnabled() then
							local dir = ((targetPos-v:GetPos()):GetNormal()*-1500)
							
							if v:IsPlayer() or v:IsNPC() then
								v:SetLocalVelocity(dir+Vector(0,0,500))
							else
								v:GetPhysicsObject():EnableMotion(true)
								v:GetPhysicsObject():SetVelocity(dir)
							end
							/*v:IG_EnableEffect("spacestone_glow",true)
							timer.Create("IG_RemoveSpaceStoneGlow"..v:EntIndex(),1,1,function()
								if v:IsValid() then
									v:IG_EnableEffect("spacestone_glow",false)
								end
							end)*/
						end
					end
				end,
			},
			{
				name = "Launch",
				description = "Propel yourself into the air and remain stationary after a moment while channeled, launching yourself on release.",
				isChanneled = true,
				Use = function(self,data)
					local target = self.Owner
					target:SetLocalVelocity(target:GetAimVector()*2500)
					target:IG_EnableEffect("spacestone_glow",true)
					data.stationTime = CurTime()+1
				end,
				Channel = function(self,data)
					if CurTime() >= data.stationTime and !self.Owner:IsOnGround() then
						self.Owner:SetMoveType(MOVETYPE_NONE)
					end
				end,
				FinishChannel = function(self,data)
					if CurTime() >= data.stationTime then
						self.Owner:SetMoveType(MOVETYPE_WALK)
					end
					self.Owner:SetLocalVelocity(self.Owner:GetAimVector()*2500)
					self.Owner:IG_EnableEffect("spacestone_glow",false)
				end
			},
			{
				name = "Spacetime Tunnel",
				description = "Teleport.",
				Use = function(self,data)
					local ply = self.Owner
					local target = FindTarget(self,999999).HitPos
					local emptySpaceCheckTr = util.TraceEntity({
						start = target,
						endpos = target,
						filter = ply,
					},ply)
					if emptySpaceCheckTr.Hit then
						target = IG_FindEmptyPositionEntity(ply,target,5000,5)
					end
					target = util.TraceEntity({
						start = target,
						endpos = target-vector_up*150,
						filter = ply,
					},ply).HitPos
					local ef = EffectData()
					local mins,maxs = ply:OBBMins(),ply:OBBMaxs()
					ef:SetOrigin(ply:GetPos()+mins)
					ef:SetStart(ply:GetPos()+maxs)
					ef:SetRadius(ply:GetModelRadius())
					util.Effect("ig_teleport",ef,true,true)
					
					ply:SetPos(target)
					
					local ef = EffectData()
					local mins,maxs = ply:OBBMins(),ply:OBBMaxs()
					ef:SetOrigin(ply:GetPos()+mins)
					ef:SetStart(ply:GetPos()+maxs)
					ef:SetRadius(ply:GetModelRadius())
					util.Effect("ig_teleport",ef,true,true)
				end,
			},
			{
				name = "Waypoint",
				description = "Set waypoint for wormhole.",
				Use = function(self)
					self.ss_waypoint = self.Owner:GetPos()
				end
			},
			{
				name = "Waypoint Wormhole",
				description = "Create a wormhole to your waypoint.",
				Use = function(self)
					if self.ss_waypoint then
						local creationDir = self.Owner:GetAimVector()
						creationDir.z = 0
						CreateWormhole(self.Owner:EyePos()+creationDir*100,self.Owner:GetPos(),self.ss_waypoint)
					else
						self.Owner:ChatPrint("No waypoint.")
					end
				end
			},
			{
				name = "Wormhole",
				description = "Create a wormhole to target location.",
				Use = function(self)
					local creationDir = self.Owner:GetAimVector()
					creationDir.z = 0
					local destination = util.TraceLine{
						start = self.Owner:EyePos(),
						endpos = self.Owner:EyePos()+self.Owner:GetAimVector()*2500,
						filter = self.Owner
					}.HitPos
					CreateWormhole(self.Owner:EyePos()+creationDir*100,self.Owner:GetPos(),util.TraceLine{
						start = destination,
						endpos = destination-Vector(0,0,50000),
						filter = self.Owner
					}.HitPos)
				end
			},
			{
				name = "Random Wormhole",
				description = "Create a wormhole to random location.",
				Use = function(self)
					local creationDir = self.Owner:GetAimVector()
					creationDir.z = 0
					local destination = FindRandomPosition()
					if destination == Vector() then
						self.Owner:ChatPrint("Map has no navmesh!")
						return
					end
					CreateWormhole(self.Owner:EyePos()+creationDir*100,self.Owner:GetPos(),util.TraceLine{
						start = destination,
						endpos = destination-Vector(0,0,50000),
						filter = self.Owner
					}.HitPos)
				end
			},
			{
				name = "Singularity",
				description = "Compress spacetime at a location, creating a black hole. Expands a targetted black hole while channeled.",
				isChanneled = true,
				Use = function(self,data,ability)
					local ball = NULL
					local src,dir = self.Owner:EyePos(),self.Owner:GetAimVector()
					for k,v in ipairs(ents.FindByClass("ig_blackhole")) do
						if IG_RayIntersectSphere(src,dir,v:GetPos(),v:GetRadius()) then
							ball = v
							break
						end
					end
					
					if !ball:IsValid() then
						ball = ents.Create("ig_blackhole")
						ball:SetPos(self.Owner:EyePos()+self.Owner:GetAimVector()*150)
						ball:Spawn()
						ball:Activate()
						ball:SetOwner(self.Owner)
						local velocity = self.Owner:GetAimVector()*50
						ball.velocity = velocity
						local phys = ball:GetPhysicsObject()
						if phys:IsValid() then
							phys:SetVelocity(velocity)
						end
					end
					data.ball = ball
				end,
				Channel = function(self,data,ability)
					if data.ball and data.ball:IsValid() then
						data.ball:SetRadius(data.ball:GetRadius()+1)
					end
				end
			},
			{
				name = "Normalize Spacetime",
				description = "Downsizes black holes.",
				isChanneled = true,
				Channel = function(self,data,ability)
					local ball = NULL
					local src,dir = self.Owner:EyePos(),self.Owner:GetAimVector()
					for k,v in ipairs(ents.FindByClass("ig_blackhole")) do
						if IG_RayIntersectSphere(src,dir,v:GetPos(),v:GetRadius()) then
							ball = v
							break
						end
					end
					if ball:IsValid() then
						ball:SetRadius(ball:GetRadius()-5)
						if ball:GetRadius() <= 0 then
							ball:Remove()
						end
					end
				end,
			},
			{
				name = "Summon Meteorites",
				description = "Pull rocks down from space to pelt the world.",
				Use = function(self,data,ability)
					local desiredLocation = util.TraceLine{
						start = self.Owner:EyePos(),
						endpos = self.Owner:EyePos()+self.Owner:GetAimVector()*9500,
						filter = self.Owner
					}.HitPos
					
					local groundTargetPos = util.TraceLine{
						start = desiredLocation,
						endpos = desiredLocation-Vector(0,0,50000),
						filter = self.Owner
					}.HitPos
					
					local offset = Vector(0,0,5000)
					local summonPos = groundTargetPos+offset
					while !util.IsInWorld(summonPos) and offset.z > 0 do --While we're inside world or the offset can be lowered more, try to find a lower position to summon stuff.
						offset.z = offset.z - 500
						summonPos = groundTargetPos+offset
					end
					
					for i=0,2 do
						local pos = summonPos+VectorRand()*1200
						if !util.IsInWorld(pos) then continue end
						
						local ent = ents.Create("ig_meteorite")
						ent:SetPos(IG_FindEmptyPositionEntity(ent,pos,1000,100))
						ent:SetOwner(self.Owner)
						ent:Spawn()
						local phys = ent:GetPhysicsObject()
						if phys:IsValid() then
							phys:AddAngleVelocity(VectorRand()*500)
							phys:SetVelocity(((desiredLocation+VectorRand()*500)-ent:GetPos()):GetNormalized()*phys:GetMass()*50000)
						end
					end
				end,
			},
		}
	},
	[4] = { --Power Stone
		name = "Power",
		element = "powerstone_glow",
		worldModel = "models/xyz/props/infinity_gem_power.mdl",
		color = Color(76,15,116),
		icon = Material("xyz/gui/infinitygauntlet/powerstone"),
		abilities = {
			{
				name = "Punch",
				description = "Punch with a fraction of the power stone's energy.",
				Use = function(self)
					self:DoPunch(999999999)
				end,
			},
			{
				name = "Launch",
				description = "Launch yourself in a direction from the ground.",
				Use = function(self)
					local target = self.Owner
					if target:IsOnGround() then
						target:SetLocalVelocity(target:GetAimVector()*2500)
						target:IG_EnableEffect("powerstone_glow",true)
						timer.Create("IG_RemovePowerStoneGlow"..target:EntIndex(),1,1,function()
							if target:IsValid() then
								target:IG_EnableEffect("powerstone_glow",false)
							end
						end)
					end
				end
			},
			{
				name = "Enhance Physique",
				description = "Enhances physical abilities while channeled.Mousewheel to modulate effect.",
				isChanneled = true,
				Use = function(self,data)
					data.boostAmount = 1
					data.startJumpPower = self.Owner:GetJumpPower()
					data.startRunSpeed = self.Owner:GetRunSpeed()
					data.startWalkSpeed = self.Owner:GetWalkSpeed()
					data.startHealth = self.Owner:Health()
					self.Owner:SetHealth(self.Owner:Health()+1000)
					self.Owner:IG_EnableEffect("powerstone_glow",true)
					
					data.hookName = "IG_PlayerQuakeStep"..self:EntIndex()
					hook.Add("PlayerFootstep",data.hookName,function(ply,pos)
						if !self:IsValid() or !self.Owner:IsValid() then
							hook.Remove("PlayerFootstep",data.hookName)
							return
						end
						if ply == self.Owner then
							ply:EmitSound("xyz/infinitygauntlet/loudwalk.wav")
							util.ScreenShake(pos,10,.5,.5,2500)
							for k,v in ipairs(ents.FindInSphere(pos,700)) do
								if v:IsPlayer() or v:IsNPC() then
									if !v:HasInfinityStone(IG_STONE_POWER) then
										v:SetLocalVelocity(vector_up*500+VectorRand()*100)
									end
								elseif v:GetPhysicsObject():IsValid() then
									constraint.RemoveAll(v)
									v:IG_EnableMotion(true)
									if util.TraceEntity({
										start = v:GetPos(),
										endpos = v:GetPos()-vector_up*15,
										filter = v,
										mask = MASK_SOLID_BRUSHONLY,
									},v).Hit then
										v:GetPhysicsObject():AddVelocity(vector_up*500+VectorRand()*100)
									end
								end
							end
						end
					end)
				end,
				OnWheeled = function(self,data,ability,amount)
					data.boostAmount = math.Clamp(data.boostAmount+amount,.1,15)
				end,
				Channel = function(self,data)
					local ducking = self.Owner:KeyDown(IN_DUCK)
					self.Owner:SetJumpPower((ducking and 1500 or 500)*data.boostAmount)
					self.Owner:SetWalkSpeed(300*data.boostAmount)
					self.Owner:SetRunSpeed(700*data.boostAmount)
				end,
				FinishChannel = function(self,data)
					self.Owner:SetJumpPower(data.startJumpPower)
					self.Owner:SetRunSpeed(data.startRunSpeed)
					self.Owner:SetWalkSpeed(data.startWalkSpeed)
					self.Owner:SetHealth(data.startHealth)
					self.Owner:IG_EnableEffect("powerstone_glow",false)
					hook.Remove("PlayerFootstep",data.hookName)
				end
			},
			{
				name = "Energy Beam",
				description = "Fire a beam of energy.",
				isChanneled = true,
				setBeamPos = function(self,data)
					local beam = data.beam
					if beam:IsValid() then
						local ang = self.Owner:EyeAngles()
						beam:SetPos(self.Owner:EyePos()+self.Owner:GetAimVector()*10-ang:Right()*5-ang:Up()*3)
						beam:SetAngles(self.Owner:GetAimVector():Angle())
					end
				end,
				Use = function(self,data,ability)
					local beam = ents.Create("ig_powerbeam")
					beam:Spawn()
					beam:Activate()
					beam:SetOwner(self.Owner)
					--beam:SetParent(self.Owner)
					data.beam = beam
					ability.setBeamPos(self,data)
				end,
				Channel = function(self,data,ability)
					ability.setBeamPos(self,data)
				end,
				FinishChannel = function(self,data)
					if data.beam:IsValid() then
						data.beam:Remove()
					end
				end
			},
			{
				name = "Power Ball",
				description = "Launch a sphere of energy. Channel to influence it.",
				isChanneled = true,
				Use = function(self,data,ability)
					local ball = ents.Create("ig_powerbomb")
					ball:SetPos(self.Owner:EyePos()+self.Owner:GetAimVector()*50)
					ball:Spawn()
					ball:Activate()
					ball:SetOwner(self.Owner)
					local velocity = self.Owner:GetAimVector()*1200
					ball.velocity = velocity
					local phys = ball:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocity(velocity)
					end
					data.ball = ball
				end,
				Channel = function(self,data,ability)
					if data.ball:IsValid() then
						local velocity = (self.Owner:GetEyeTrace().HitPos-data.ball:GetPos()):GetNormalized()*1200--self.Owner:GetAimVector()*1200
						local phys = data.ball:GetPhysicsObject()
						data.ball.velocity = velocity
						if phys:IsValid() then
							phys:SetVelocity(velocity)
						end
					end
				end
			},
			{
				name = "Conflagration",
				description = "Create an explosion of fire.",
				fireSound = {
					"ambient/fire/fire_small_loop1",
					"ambient/fire/fire_small_loop2"
				},
				Use = function(self,_,ability)
					local ply = self.Owner
					CreateExplosion(ply:GetPos(),220,500,self,ply)
					local ef = EffectData()
					ef:SetOrigin(ply:GetPos()+ply:OBBCenter())
					ef:SetScale(300)
					util.Effect("ig_conflagrate",ef,true,true)
					util.Effect("ig_explosion",ef,true,true)
					local radius = 900
					util.BlastDamage(self,ply,ply:GetPos(),1200,50)
					for k,v in pairs(ents.FindInSphere(ply:GetPos(),radius)) do
						if v:IsValid() and v != ply and !v:IsWeapon() and (v:GetPhysicsObject():IsValid() or v:IsNPC() or (v:IsPlayer() and v:Alive())) then
							v:Ignite(99999)
						end
					end
					radius = radius/2
					for i=0,3 do
						local fire = ents.Create("env_fire")
						if IsValid(fire) then
							local p = ply:GetPos()
							p = util.TraceLine({
								start = p,
								endpos = Vector(p.x+math.random(-radius,radius),p.y+math.random(-radius,radius),p.z),
								filter = ply
							}).HitPos
							fire:SetPos(p)
							fire:SetKeyValue("firesize",tostring(math.random(100,150)))
							fire:SetKeyValue("damagescale",tostring(.5))
							fire:SetKeyValue("spawnflags","4")
							local sound = CreateSound(fire,ability.fireSound[math.random(1,2)].. ".wav")
							sound:PlayEx(0.82,100)
							fire:Spawn()
							fire:Activate()
							timer.Simple(math.random(10,20),function() 
								if !IsValid(fire) then return end
								fire:Remove()
								sound:Stop()
							end)
						end
					end
				end
			},
			{
				name = "World Sunder",
				description = "Directly touch the power stone against a target, causing annihilation on collision.",
				Use = function(self)
					self:DoPunch(50,"fists_left",function(tr)
						if tr.Hit then
							CreateExplosion(tr.HitPos,50,500,self.Owner,self)
							local ef = EffectData()
							ef:SetOrigin(self.Owner:GetPos())
							ef:SetScale(600)
							util.Effect("ig_explosion",ef,true,true)
							local sunder = ents.Create("ig_worldsunder")
							sunder:SetPos(tr.HitPos)
							sunder:Spawn()
							sunder:Activate()
							sunder:SetOwner(self.Owner)
						end
					end)
				end,
			},
			{
				name = "Energy Storm",
				description = "Conjure a storm of energy around yourself while channeled.",
				isChanneled = true,
				setStormPos = function(self,data)
					local storm = data.storm
					if storm:IsValid() then
						storm:SetPos(self.Owner:EyePos())
					end
				end,
				Use = function(self,data,ability)
					local storm = ents.Create("ig_energystorm")
					storm:Spawn()
					storm:Activate()
					storm:SetOwner(self.Owner)
					data.storm = storm
					ability.setStormPos(self,data)
				end,
				Channel = function(self,data,ability)
					ability.setStormPos(self,data)
				end,
				FinishChannel = function(self,data)
					if data.storm:IsValid() then
						data.storm:Remove()
					end
				end
			},
		},
	},
	[5] = { --Time Stone [FAR RIGHT]
		name = "Time",
		element = "timestone_glow",
		worldModel = "models/xyz/props/infinity_gem_time.mdl",
		color = Color(60,168,96),
		icon = Material("xyz/gui/infinitygauntlet/timestone"),
		abilities = {
			{
				name = "Stop Time",
				description = "Stop time for 5 seconds. Reusable when time resumes.",
				zcityDuration = 5,
				zcityCooldown = 5,
				Use = function(self,data,ability)
					if IG_ZCityIsInfinityStoneRound() then
						local timerName = "IG_ZCityTimeStop_" .. self:EntIndex()
						IG_SetTimeFlow(false)
						timer.Create(timerName, ability.zcityDuration, 1, function()
							IG_SetTimeFlow(true)
						end)
						return
					end

					IG_SetTimeFlow(!IG_IsTimeFlowing())
				end,
			},
			{
				name = "Slow Time",
				description = "Slow down all time while channeled.",
				isChanneled = true,
				Use = function(self,data)
					data.speed = .25
				end,
				Channel = function(self,data,ability)
					game.SetTimeScale(data.speed)
					self.Owner:SetLaggedMovementValue(1/data.speed)
				end,
				FinishChannel = function(self,data,ability)
					game.SetTimeScale(1)
					self.Owner:SetLaggedMovementValue(1)
				end,
				OnWheeled = function(self,data,ability,amount)
					data.speed = math.Clamp(data.speed+amount/10,.05,.7)
				end,
			},
			{
				name = "Speed Time",
				description = "Speed up all time while channeled.",
				isChanneled = true,
				Use = function(self,data)
					data.speed = .75
				end,
				Channel = function(self,data,ability)
					game.SetTimeScale(1+data.speed)
				end,
				FinishChannel = function(self,data,ability)
					game.SetTimeScale(1)
				end,
				OnWheeled = function(self,data,ability,amount)
					data.speed = math.Clamp(data.speed+amount/10,.5,1)
				end,
			},
			{
				name = "Reverse Time",
				description = "Reverses time while channeled.",
				isChanneled = true,
				Use = function(self,data,ability)
					IG_StartTimeRewind()
				end,
				FinishChannel = function(self,data,ability)
					IG_StopTimeRewind()
				end,
			},
			{
				name = "Place Time Anchor",
				description = "Save your position in the timeline for later returning.",
				Use = function(self,data,ability)
					self.savedTimeAnchor = IG_GetTimeSaveState()
				end,
			},
			{
				name = "Return To Time Anchor",
				description = "Return to the saved timeline position.",
				Use = function(self,data,ability)
					if self.savedTimeAnchor then
						IG_LoadTimeSaveState(self.savedTimeAnchor)
					else
						self.Owner:ChatPrint("No anchor placed!")
					end
				end,
			},
			{
				name = "Toggle Anchor Deathloop",
				description = "Return to the saved timeline position on your death.",
				Use = function(self,data,ability)
					if !self.savedTimeAnchor then
						self.Owner:ChatPrint("No anchor placed!")
						return
					end
					self.timeAnchorDeathloop = !self.timeAnchorDeathloop
					self.Owner:ChatPrint(self.timeAnchorDeathloop and "Loop Enabled" or "Loop Disabled")
				end,
			},
		},
	},
	[6] = { --Mind Stone [CENTER LARGE]
		name = "Mind",
		element = "mindstone_glow",
		worldModel = "models/xyz/props/infinity_gem_mind.mdl",
		color = Color(241,144,19),
		icon = Material("xyz/gui/infinitygauntlet/mindstone"),
		abilities = {
			{
				name = "Mindslave",
				description = "Make a creature fight for you.",
				Use = function(self)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						if target:IsNPC() then
							target.IGSlaved = self.Owner
							for k,v in pairs(ents.GetAll()) do
								if v == target then continue end
								if v == self.Owner or v.IGSlaved == self.Owner then
									target:AddEntityRelationship(v,D_LI,10)
									if v.AddEntityRelationship then
										v:AddEntityRelationship(target,D_LI,10)
									end
								else
									target:AddEntityRelationship(v,D_HT,99)
									if v.AddEntityRelationship then
										v:AddEntityRelationship(target,D_HT,99)
									end
								end
							end
							
							target:IG_EnableEffect("mindstone_glow",true)
							timer.Create("IG_RemoveMindStoneGlow"..target:EntIndex(),1,1,function()
								if target:IsValid() then
									target:IG_EnableEffect("mindstone_glow",false)
								end
							end)
							
							local hookName = "IG_MindStoneSlaved"..target:EntIndex()
							hook.Add("OnEntityCreated",hookName,function(ent)
								if !target:IsValid() then
									hook.Remove("OnEntityCreated",hookName)
									return
								end
								target:AddEntityRelationship(ent,D_HT,99)
								if ent.AddEntityRelationship then
									ent:AddEntityRelationship(target,D_HT,99)
								end
							end)
						end
					end
				end
			},
			{
				name = "Fear",
				description = "Cause a creature to fear you.",
				Use = function(self,data,ability)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						if target:IsNPC() then
							target:AddEntityRelationship(self.Owner,D_FR,99)
							target:IGEffectTemp("mindstone_glow")
						end
					end
				end,
			},
			{
				name = "Confuse",
				description = "Cause a creature forget their allegiances.",
				Use = function(self,data,ability)
					local target = FindTarget(self).Entity
					if IsValid(target) then
						if target:IsNPC() then
							target:IGEffectTemp("mindstone_glow")
							for k,v in ipairs(ents.GetAll()) do
								if v != target and (v:IsPlayer() or v:IsNPC()) then
									target:AddEntityRelationship(v,D_HT,99)
									if v:IsNPC() then
										v:AddEntityRelationship(target,D_HT,99)
									end
								end
							end
							
							local hookName = "IG_MindStoneConfused"..target:EntIndex()
							hook.Add("OnEntityCreated",hookName,function(ent)
								if !target:IsValid() then
									hook.Remove("OnEntityCreated",hookName)
									return
								end
								target:AddEntityRelationship(ent,D_HT,99)
								if ent.AddEntityRelationship then
									ent:AddEntityRelationship(target,D_HT,99)
								end
							end)
						end
					end
				end,
			},
			{
				name = "Forgetfulness",
				description = "Makes a creature forget their task periodically. [SHIFT] to make them forget only once.",
				Use = function(self,data,ability)
					local target = FindTarget(self).Entity
					if IsValid(target) and (target:IsNPC() or target:IsPlayer()) then
						local function Forget()
							target:ClearExpression()
							target:ClearEnemyMemory()
							target:ClearGoal()
							target:ClearSchedule()
							target:IGEffectTemp("mindstone_glow")
						end
						
						if self.Owner:KeyDown(IN_SPEED) then
							Forget()
							return
						end
						
						local nextForget = 0
						hook.Add("Think",target,function()
							if nextForget > CurTime() then return end
							nextForget = CurTime()+math.random(2,3)
							Forget()
						end)
					end
				end,
			},
			{
				name = "Barrier",
				description = "Create a shield around yourself while channeled.",
				isChanneled = true,
				setpos = function(self,data)
					local ent = data.ent
					if ent:IsValid() then
						ent:SetPos(self.Owner:GetPos()+self.Owner:OBBCenter())
					end
				end,
				Use = function(self,data,ability)
					local ent = ents.Create("ig_mindbarrier")
					ent:Spawn()
					ent:Activate()
					ent:SetOwner(self.Owner)
					data.ent = ent
					ability.setpos(self,data)
				end,
				OnWheeled = function(self,data,ability,amount)
					if data.ent:IsValid() then
						data.ent:SetRadius(math.Clamp(data.ent:GetRadius()+amount*10,75,500))
					end
				end,
				Channel = function(self,data,ability)
					ability.setpos(self,data)
				end,
				FinishChannel = function(self,data)
					if data.ent:IsValid() then
						data.ent:Remove()
					end
				end
			},
			{
				name = "Sleep",
				description = "Cause a creature to sleep.",
				Use = function(self,data,ability)
					local target = FindTarget(self).Entity
					if IsValid(target) and (target:IsNPC() or target:IsPlayer()) then
						local ragdoll = target:IG_StartRagdoll()
						if IsValid(ragdoll) then
							ragdoll.IG_Sleep = true
						end
					end
				end,
			},
			{
				name = "Wakeup",
				description = "Cause a creature to wake up.",
				Use = function(self,data,ability)
					local target = FindTarget(self).Entity
					if IsValid(target) and IsValid(target.ig_entity) and target.IG_Sleep then
						target.ig_entity:IG_StopRagdoll()
					end
				end,
			},
			{
				name = "Phase",
				description = "Gain flight and the ability to phase through matter while channeled.",
				isChanneled = true,
				Use = function(self,data,ability)
					self.Owner:SetLocalVelocity(Vector())
					self.Owner:SetMoveType(MOVETYPE_IG_PHASE)
					data.hadGod = self.Owner:HasGodMode()
					self.Owner:GodEnable()
				end,
				FinishChannel = function(self,data,ability)
					self.Owner:SetMoveType(MOVETYPE_WALK)
					if !data.hadGod then
						self.Owner:GodDisable()
					end
				end,
			},
			{
				name = "Mind Beam",
				description = "Channel a beam of energy.",
				isChanneled = true,
				setBeamPos = function(self,data)
					local beam = data.beam
					if beam:IsValid() then
						local ang = self.Owner:EyeAngles()
						beam:SetPos(self.Owner:EyePos()+self.Owner:GetAimVector()*10-ang:Right()*5-ang:Up()*3)
						beam:SetAngles(self.Owner:GetAimVector():Angle())
					end
				end,
				Use = function(self,data,ability)
					local beam = ents.Create("ig_mindbeam")
					beam:Spawn()
					beam:Activate()
					beam:SetOwner(self.Owner)
					data.beam = beam
					ability.setBeamPos(self,data)
				end,
				Channel = function(self,data,ability)
					ability.setBeamPos(self,data)
				end,
			},
			{
				name = "Mind Annihilation",
				description = "Makes the target braindead.",
				Use = function(self,data,ability)
					local target = FindTarget(self).Entity
					if IsValid(target) and ((target:IsNPC() and target:IG_HasSoul()) or target:IsPlayer()) then
						target:IG_MakeBodyRagdoll()
						if target:IsPlayer() then
							target:KillSilent()
						else
							target:Remove()
						end
					end
				end,
			},
			{
				name = "Copy Appearence",
				description = "Copy the target's appearence. [SHIFT] to reset appearence.",
				playerModelFixes = {
					["models/monk.mdl"] = "models/player/monk.mdl",
					["models/mossman.mdl"] = "models/player/mossman.mdl",
					["models/alyx.mdl"] = "models/player/alyx.mdl",
					["models/barney.mdl"] = "models/player/barney.mdl",
					["models/breen.mdl"] = "models/player/breen.mdl",
					["models/eli.mdl"] = "models/player/eli.mdl",
					["models/gman_high.mdl"] = "models/player/gman_high.mdl",
					["models/kleiner.mdl"] = "models/player/kleiner.mdl",
					["models/odessa.mdl"] = "models/player/odessa.mdl",
					["models/humans/charple01.mdl"] = "models/player/charple.mdl",
					["models/zombie/classic.mdl"] = "models/player/zombie_classic.mdl",
					["models/zombie/fast.mdl"] = "models/player/zombie_fast.mdl",
					["models/combine_soldier_prisonguard.mdl"] = "models/player/combine_soldier_prisonguard.mdl",
					["models/combine_soldier.mdl"] = "models/player/combine_soldier.mdl",
					["models/police.mdl"] = "models/player/police.mdl",
					["models/combine_super_soldier.mdl"] = "models/player/combine_super_soldier.mdl",
				},
				Use = function(self,data,ability)
					local ply = self.Owner
					if ply:KeyDown(IN_SPEED) then
						if ply.IG_MindOriginalAppearence then
							local data = ply.IG_MindOriginalAppearence
							ply:SetModel(data.mdl)
							ply:SetColor(data.color)
							ply:SetSkin(data.skin)
							ply:SetMaterial(data.mat)
							ply:SetRenderFX(data.fx)
							ply:SetRenderMode(data.mode)
							for k,v in pairs(data.boneData) do
								ply:ManipulateBoneScale(k,v[1])
								ply:ManipulateBoneAngles(k,v[2])
								ply:ManipulateBoneJiggle(k,v[3])
								ply:ManipulateBonePosition(k,v[4])
							end
							for k,v in pairs(data.bodyGroups) do
								ply:SetBodygroup(k,v)
							end
						end
						return
					end
					
					local ent = FindTarget(self).Entity
					if IsValid(ent) then
						local mdl = ent:GetModel():lower():Replace("\\","/")
						if ability.playerModelFixes[mdl] then
							mdl = ability.playerModelFixes[mdl]
						else
							if mdl:find("/humans/") then
								mdl = mdl:Replace("humans","player")
								mdl = mdl:Replace("group02","group01")
							end
						end
						if !ply.IG_MindOriginalAppearence then
							ply.IG_MindOriginalAppearence = {
								mdl = ply:GetModel(),
								color = ply:GetColor(),
								skin = ply:GetSkin(),
								mat = ply:GetMaterial(),
								fx = ply:GetRenderFX(),
								mode = ply:GetRenderMode(),
								boneData = {},
								bodyGroups = {}
							}
							local boneData = ply.IG_MindOriginalAppearence.boneData
							for i=0,ply:GetBoneCount()-1 do
								boneData[i] = {
									ply:GetManipulateBoneScale(i),
									ply:GetManipulateBoneAngles(i),
									ply:GetManipulateBoneJiggle(i),
									ply:GetManipulateBonePosition(i)
								}
							end
							
							local bodyGroups = ply.IG_MindOriginalAppearence.bodyGroups
							for k,v in pairs(ply:GetBodyGroups()) do
								bodyGroups[v.id] = ply:GetBodygroup(v.id)
							end
						end
						
						ply:SetModel(mdl)
						ply:SetColor(ent:GetColor())
						ply:SetSkin(ent:GetSkin())
						ply:SetMaterial(ent:GetMaterial())
						ply:SetRenderFX(ent:GetRenderFX())
						ply:SetRenderMode(ent:GetRenderMode())
						for i=0,ent:GetBoneCount()-1 do
							local bone = ent:GetBoneName(i)
							local selfBone = ply:LookupBone(bone)
							local entBone = ent:LookupBone(bone)
							if !entBone or !selfBone then continue end
							ply:ManipulateBoneScale(selfBone,ent:GetManipulateBoneScale(entBone))
							ply:ManipulateBoneAngles(selfBone,ent:GetManipulateBoneAngles(entBone))
							ply:ManipulateBoneJiggle(selfBone,ent:GetManipulateBoneJiggle(entBone))
							ply:ManipulateBonePosition(selfBone,ent:GetManipulateBonePosition(entBone))
						end
						
						for k,v in pairs(ent:GetBodyGroups()) do
							self:SetBodygroup(v.id,ent:GetBodygroup(v.id))
						end
					end
				end,
			},
		},
	},
	[7] = { --Infinity
		name = "Infinity",
		element = {
			"soulstone_glow",
			"realitystone_glow",
			"spacestone_glow",
			"powerstone_glow",
			"timestone_glow",
			"mindstone_glow"
		},
		icon = Material("xyz/gui/infinitygauntlet/mindstone"),
		abilities = {
			{
				name = "Snap",
				description = "Wipe out half of all life. Perfectly balanced, as all things should be.",
				noGlow = true,
				Use = function(self)
					if nextSnap > CurTime() then return end
					nextSnap = CurTime()+5
					local living = {}
					self.Owner:EmitSound("xyz/infinitygauntlet/snap.wav")
					for k,v in ipairs(ents.GetAll()) do
						if v:IsPlayer() then
							v:ScreenFade(SCREENFADE.IN,color_white,2,2)
						end
						if IG_ZCityIsInfinityStoneRound() then
							if v:IsPlayer() and v != self.Owner and v:Alive() then
								living[#living+1] = v
							end
						elseif v != self.Owner and (v:IsNPC() or v:IsPlayer()) then
							living[#living+1] = v
						end
					end
					local toKill = math.ceil(#living/2)
					Shuffle(living)
					for k,v in pairs(living) do
						if toKill <= 0 then break end
						toKill = toKill - 1
						IG_ExistanceWipe(v)
					end
				end
			},
			{
				name = "Infinity Beam",
				description = "Channel a beam of infinite energy.",
				isChanneled = true,
				setBeamPos = function(self,data)
					local beam = data.beam
					if beam:IsValid() then
						local ang = self.Owner:EyeAngles()
						beam:SetPos(self.Owner:EyePos()+self.Owner:GetAimVector()*10-ang:Right()*5-ang:Up()*3)
						beam:SetAngles(self.Owner:GetAimVector():Angle())
					end
				end,
				Use = function(self,data,ability)
					local beam = ents.Create("ig_infinitybeam")
					beam:Spawn()
					beam:Activate()
					beam:SetOwner(self.Owner)
					data.beam = beam
					ability.setBeamPos(self,data)
					beam:Think()
				end,
				Channel = function(self,data,ability)
					ability.setBeamPos(self,data)
				end,
				FinishChannel = function(self,data)
					if data.beam:IsValid() then
						data.beam:Remove()
					end
				end
			},
			{
				name = "Direct Gravity",
				description = "Direct gravity while channeled.",
				isChanneled = true,
				Use = function(self,data)
					data.gravPower = physenv.GetGravity():Length()
					data.minGravPower = data.gravPower*.5
					data.maxGravPower = data.gravPower*3
					timer.Simple(0,function()
						for k,v in ipairs(ents.GetAll()) do
							if v:GetPhysicsObject():IsValid() then
								v:GetPhysicsObject():Wake()
							end
						end
					end)
				end,
				Channel = function(self,data,ability)
					local dir = self.Owner:GetAimVector()*data.gravPower
					for k,v in ipairs(ents.GetAll()) do
						if v == self.Owner then continue end
						
						if v:IsPlayer() or v:IsNPC() then
							v:SetLocalVelocity(dir*5)
						elseif v:GetPhysicsObject():IsValid() then
							v:GetPhysicsObject():SetVelocity(dir)
						end
					end
				end,
				OnWheeled = function(self,data,ability,amount)
					data.gravPower = math.Clamp(data.gravPower+amount*10,data.minGravPower,data.maxGravPower)
				end,
			},
			{
				name = "Timeline Erasure",
				description = "Erases a target from the timeline.",
				Use = function(self,data,ability)
					local target = FindTarget(self)
					local ent = target.Entity
					if IsValid(ent) then
						ent:IG_ClearTimeData()
						local ef = EffectData()
						local mins,maxs = ent:OBBMins(),ent:OBBMaxs()
						mins:Rotate(ent:GetAngles())
						maxs:Rotate(ent:GetAngles())
						ef:SetOrigin(ent:GetPos()+mins)
						ef:SetStart(ent:GetPos()+maxs)
						ef:SetRadius(ent:GetModelRadius())
						ef:SetAngles(Angle(0,255,0))
						util.Effect("ig_plasmad",ef,true,true)
						if ent:IsPlayer() then
							ent:Kick("Existence erased.")
						else
							ent:Remove()
						end
					end
				end,
			},
			{
				name = "Universal Law",
				description = "Define laws of reality.",
				laws = {},
				types = {
					any = {
						notSelectableType = true
					},
					number = {
						inherits = "any",
						name = "Number",
					},
					bool = {
						inherits = "any",
						name = "True/False",
					},
					string = {
						inherits = "any",
						name = "String",
					},
					player = {
						name = "Player",
						inherits = "entity",
						check = function(ent) return ent:IsPlayer() end,
					},
					npc = {
						name = "NPC",
						inherits = "entity",
						check = function(ent) return ent:IsNPC() end,
					},
					physobj = {
						name = "Physics Entity",
						inherits = "entity",
						check = function(ent) return ent:GetPhysicsObject():IsValid() end,
					},
					prop = {
						name = "Prop",
						inherits = "entity",
						check = function(ent) return ent:GetClass() == "prop_physics" end,
					},
					vehicle = {
						name = "Vehicle",
						inherits = "entity",
						check = function(ent) return ent:IsVehicle() end,
					},
					weapon = {
						name = "Weapon",
						inherits = "entity",
						check = function(ent) return ent:IsWeapon() end,
					},
					entity = {
						name = "Entity",
						inherits = "any",
						check = function(ent) return ent:IsValid() end
					},
					position = {
						name = "Position",
						inherits = "any",
						convertsFrom = {
							"npc",
							"player",
							"entity",
							"bulletdata",
						},
						converter = function(obj)
							local type = TypeID(obj)
							if type == TYPE_ENTITY then
								return obj:GetPos()
							elseif obj.Src then
								return obj.Src
							end
							return obj
						end,
					},
					damageinfo = {
						inherits = "any",
						name = "Damage Information",
					},
					sounddata = {
						inherits = "any",
						name = "Sound Information",
					},
					bulletdata = {
						inherits = "any",
						name = "Bullet Information",
					},
					movementdata = {
						inherits = "any",
						name = "Movement Information",
					},
				},
				arguments = {
					number = {
						settings = {
							min = 1,
							max = 100,
							decimals = 1,
							default = 0
						},
						frame = function(parent,value,settings,deliveryTable)
							local slider = vgui.Create("DNumSlider",parent)
							slider:SetMin(settings.min)
							slider:SetMax(settings.max)
							slider:SetDecimals(settings.decimals)
							
							function slider:OnValueChanged(val)
								deliveryTable.value = val
							end
							
							slider:SetValue(value or settings.default)
							
							return slider
						end
					},
					string = {
						settings = {
							default = ""
						},
						frame = function(parent,value,settings,deliveryTable)
							local textbox = vgui.Create("DTextEntry",parent)
							
							function textbox:OnChange()
								deliveryTable.value = self:GetValue()
							end
							
							textbox:SetText(value or settings.default)
							textbox:OnChange()
							
							return textbox
						end
					},
					color = {
						settings = {
							default = color_white
						},
						frame = function(parent,value,settings,deliveryTable)
							local colorMixer = vgui.Create("DColorMixer",parent)
							
							function colorMixer:ValueChanged(val)
								deliveryTable.value = val
							end
							
							colorMixer:SetColor(value or settings.default)
							
							return colorMixer
						end
					},
					options = {
						settings = {
							items = {},
							default = 0,
							sort = false
						},
						frame = function(parent,value,settings,deliveryTable)
							local combobox = vgui.Create("DComboBox",parent)
							combobox:SetSortItems(settings.sort)
							
							local default
							if value != nil then
								default = value
							else
								default = settings.default
							end
							
							function combobox:OnSelect(index,key,val)
								deliveryTable.value = val
							end
							
							for k,v in pairs(isfunction(settings.items) and settings.items() or settings.items) do
								combobox:AddChoice(k,v)
								if v == default then
									deliveryTable.value = v
									combobox:SetValue(k)
								end
							end
							
							return combobox
						end
					},
					bool = {
						settings = {
							default = false
						},
						noDock = true,
						frame = function(parent,value,settings,deliveryTable)
							local box = vgui.Create("DCheckBox",parent)
							function box:OnChange(val)
								deliveryTable.value = val
							end
							
							if value == nil then
								box:SetValue(settings.default)
							else
								box:SetValue(value)
							end
							
							return box
						end
					},
				},
				conditionals = {
					--Player
					["In Vehicle"] = {
						types = {
							"player",
						},
						func = function(ent)
							return ent:InVehicle()
						end
					},
					["SteamID Equal To"] = {
						types = {
							"player",
						},
						func = function(ent,name)
							return ent:SteamID() == name
						end,
						arguments = {
							{
								name = "SteamID",
								type = "string",
							},
						},
					},
					["Name Equal To"] = {
						types = {
							"player",
						},
						func = function(ent,name)
							return ent:GetName() == name
						end,
						arguments = {
							{
								name = "Name",
								type = "string",
							},
						},
					},
					["Is Typing"] = {
						types = {
							"player",
						},
						func = function(ent)
							return ent:IsTyping()
						end
					},
					["Is Ducking"] = {
						types = {
							"player",
						},
						func = function(ent)
							return ent:Crouching()
						end
					},
					["Is Sprinting"] = {
						types = {
							"player",
						},
						func = function(ent)
							return ent:IsSprinting()
						end
					},
					["Pressing Action Key"] = {
						types = {
							"player",
						},
						func = function(ent,key)
							return ent:KeyDown(key)
						end,
						arguments = {
							{
								name = "Action",
								type = "options",
								items = {
									["Attack"] = IN_ATTACK,
									["Alt Attack"] = IN_ATTACK2,
									["Jump"] = IN_JUMP,
									["Crouch"] = IN_DUCK,
									["Use"] = IN_USE,
									["Move Forwards"] = IN_FORWARD,
									["Move Backwards"] = IN_BACK,
									["Move Left"] = IN_MOVELEFT,
									["Move Right"] = IN_MOVERIGHT,
									["Reload"] = IN_RELOAD,
									["Alt1"] = IN_ALT1,
									["Alt2"] = IN_ALT2,
									["Scoreboard"] = IN_SCORE,
									["Sprint"] = IN_SPEED,
									["Walk"] = IN_WALK,
									["Zoom"] = IN_ZOOM,
								},
								default = IN_ATTACK,
							},
						}
					},
					["Has Godmode"] = {
						types = {
							"player",
						},
						func = function(ent)
							return ent:HasGodMode()
						end
					},
					--Player and NPC
					["Holding Weapon"] = {
						types = {
							"player",
							"npc",
						},
						func = function(ent,class,ignoreClass)
							if ent:GetActiveWeapon():IsValid() and (ignoreClass or ent:GetActiveWeapon():GetClass() == class) then
								return true
							end
						end,
						arguments = {
							{
								name = "Weapon Class (Use Copy To Clipboard in Q Menu)",
								type = "string",
							},
							{
								name = "Ignore Class",
								type = "bool",
								default = false,
							},
						},
					},
					["Has Weapon"] = {
						types = {
							"player",
							"npc",
						},
						func = function(ent,class)
							if ent:IsNPC() then
								if ent:GetActiveWeapon():IsValid() and ent:GetActiveWeapon():GetClass() == class then
									return true
								end
							elseif ent:IsPlayer() then
								return ent:GetWeapon(class):IsValid()
							end
							return false
						end,
						arguments = {
							{
								name = "Weapon Class (Use Copy To Clipboard in Q Menu)",
								type = "string",
							},
						},
					},
					--Weapon
					["Is Scripted"] = {
						types = {
							"weapon",
						},
						func = function(ent)
							return ent:IsScripted()
						end,
					},
					["Primary Ammo Number Comparison"] = {
						types = {
							"weapon",
						},
						func = function(ent,compareMode,compareNumber)
							local num = ent:Clip1()
							if compareMode == 1 then return num == compareNumber end
							if compareMode == 2 then return num > compareNumber end
							if compareMode == 3 then return num >= compareNumber end
							if compareMode == 4 then return num < compareNumber end
							if compareMode == 5 then return num <= compareNumber end
							return false
						end,
						arguments = {
							{
								name = "Compare Mode",
								type = "options",
								items = {
									["Equal To"] = 1,
									["Greater Than"] = 2,
									["Greater Than Or Equal To"] = 3,
									["Less Than"] = 4,
									["Less Than Or Equal To"] = 5,
								},
								default = 1,
							},
							{
								name = "Compare Number",
								type = "number",
								min = -9999,
								max = 9999,
								default = 0,
								decimals = 2
							},
						},
					},
					["Secondary Ammo Number Comparison"] = {
						types = {
							"weapon",
						},
						func = function(ent,compareMode,compareNumber)
							local num = ent:Clip2()
							if compareMode == 1 then return num == compareNumber end
							if compareMode == 2 then return num > compareNumber end
							if compareMode == 3 then return num >= compareNumber end
							if compareMode == 4 then return num < compareNumber end
							if compareMode == 5 then return num <= compareNumber end
							return false
						end,
						arguments = {
							{
								name = "Compare Mode",
								type = "options",
								items = {
									["Equal To"] = 1,
									["Greater Than"] = 2,
									["Greater Than Or Equal To"] = 3,
									["Less Than"] = 4,
									["Less Than Or Equal To"] = 5,
								},
								default = 1,
							},
							{
								name = "Compare Number",
								type = "number",
								min = -9999,
								max = 9999,
								default = 0,
								decimals = 2
							},
						},
					},
					--Entity
					["Variable Equal To"] = {
						types = {
							"entity",
						},
						func = function(ent,var,compareNumber)
							return ent.igconddata and ent.igconddata[var] == compareNumber
						end,
						arguments = {
							{
								name = "Variable",
								type = "string",
							},
							{
								name = "Compare Number",
								type = "number",
								min = -9999,
								max = 9999,
								default = 0,
								decimals = 2
							},
						},
					},
					["Variable Number Comparison"] = {
						types = {
							"entity",
						},
						func = function(ent,var,compareMode,compareNumber)
							if !ent.igconddata then return false end
							local num = ent.igconddata[var]
							if !isnumber(num) then return false end
							if compareMode == 1 then return num == compareNumber end
							if compareMode == 2 then return num > compareNumber end
							if compareMode == 3 then return num >= compareNumber end
							if compareMode == 4 then return num < compareNumber end
							if compareMode == 5 then return num <= compareNumber end
							return false
						end,
						arguments = {
							{
								name = "Variable",
								type = "string",
							},
							{
								name = "Compare Mode",
								type = "options",
								items = {
									["Equal To"] = 1,
									["Greater Than"] = 2,
									["Greater Than Or Equal To"] = 3,
									["Less Than"] = 4,
									["Less Than Or Equal To"] = 5,
								},
								default = 1,
							},
							{
								name = "Compare Number",
								type = "number",
								min = -9999,
								max = 9999,
								default = 0,
								decimals = 2
							},
						},
					},
					["Water Level Comparison"] = {
						types = {
							"entity",
						},
						func = function(ent,compareMode,compareNumber)
							local num = ent:WaterLevel()
							if compareMode == 1 then return num == compareNumber end
							if compareMode == 2 then return num > compareNumber end
							if compareMode == 3 then return num >= compareNumber end
							if compareMode == 4 then return num < compareNumber end
							if compareMode == 5 then return num <= compareNumber end
							return false
						end,
						arguments = {
							{
								name = "Compare Mode",
								type = "options",
								items = {
									["Equal To"] = 1,
									["Greater Than"] = 2,
									["Greater Than Or Equal To"] = 3,
									["Less Than"] = 4,
									["Less Than Or Equal To"] = 5,
								},
								default = 1,
							},
							{
								name = "Compare Number",
								type = "number",
								min = 0,
								max = 3,
								decimals = 0
							},
						},
					},
					["Speed Comparison"] = {
						types = {
							"entity",
						},
						func = function(ent,compareMode,compareNumber)
							local num = ent:GetVelocity():Length()
							if compareMode == 1 then return num == compareNumber end
							if compareMode == 2 then return num > compareNumber end
							if compareMode == 3 then return num >= compareNumber end
							if compareMode == 4 then return num < compareNumber end
							if compareMode == 5 then return num <= compareNumber end
							return false
						end,
						arguments = {
							{
								name = "Compare Mode",
								type = "options",
								items = {
									["Equal To"] = 1,
									["Greater Than"] = 2,
									["Greater Than Or Equal To"] = 3,
									["Less Than"] = 4,
									["Less Than Or Equal To"] = 5,
								},
								default = 1,
							},
							{
								name = "Compare Number",
								type = "number",
								min = 0,
								max = 2000,
								decimals = 0
							},
						},
					},
					["Health Comparison"] = {
						types = {
							"entity",
						},
						func = function(ent,var,compareMode,compareNumber)
							local num = ent:Health()
							if compareMode == 1 then return num == compareNumber end
							if compareMode == 2 then return num > compareNumber end
							if compareMode == 3 then return num >= compareNumber end
							if compareMode == 4 then return num < compareNumber end
							if compareMode == 5 then return num <= compareNumber end
							return false
						end,
						arguments = {
							{
								name = "Compare Mode",
								type = "options",
								items = {
									["Equal To"] = 1,
									["Greater Than"] = 2,
									["Greater Than Or Equal To"] = 3,
									["Less Than"] = 4,
									["Less Than Or Equal To"] = 5,
								},
								default = 1,
							},
							{
								name = "Compare Number",
								type = "number",
								min = -9999,
								max = 9999,
								default = 0,
								decimals = 2
							},
						},
					},
					["Is Player"] = {
						types = {
							"entity",
						},
						func = function(ent)
							return ent:IsPlayer()
						end
					},
					["Is NPC"] = {
						types = {
							"entity",
						},
						func = function(ent)
							return ent:IsNPC()
						end
					},
					["Is Physics Entity"] = {
						types = {
							"entity",
						},
						clientside = false,
						func = function(ent)
							return !ent:IsPlayer() and !ent:IsNPC() and ent:GetPhysicsObject():IsValid() and ent:GetPhysicsObject():GetName() != "world"
						end
					},
					["Is Ragdoll"] = {
						types = {
							"entity",
						},
						func = function(ent)
							return ent:IsRagdoll()
						end
					},
					["Is Weapon"] = {
						types = {
							"entity",
						},
						func = function(ent)
							return ent:IsWeapon()
						end
					},
					["Is On Fire"] = {
						types = {
							"entity",
						},
						func = function(ent)
							return ent:IsOnFire()
						end
					},
					["Is On Ground"] = {
						types = {
							"entity",
						},
						func = function(ent)
							return ent:IsOnGround()
						end
					},
					["Is Constrained"] = {
						types = {
							"entity",
						},
						func = function(ent)
							return ent:IsConstrained()
						end
					},
					["Is Constraint"] = {
						types = {
							"entity",
						},
						clientside = false,
						func = function(ent)
							return ent:IsConstraint()
						end
					},
					["Is Player Holding"] = {
						types = {
							"entity",
						},
						clientside = false,
						func = function(ent)
							return ent:IsPlayerHolding()
						end
					},
					["Is Class"] = {
						types = {
							"entity",
						},
						func = function(ent,class)
							return ent:GetClass() == class
						end,
						arguments = {
							{
								name = "Class Name",
								type = "string",
							},
						},
					},
					["Has Model"] = {
						types = {
							"entity",
						},
						func = function(ent,mdl)
							return ent:GetModel() == mdl
						end,
						arguments = {
							{
								name = "Model Path",
								type = "string",
							},
						},
					},
					["Has Material"] = {
						types = {
							"entity",
						},
						func = function(ent,mat)
							return ent:GetMaterial() == mat
						end,
						arguments = {
							{
								name = "Material Path",
								type = "string",
							},
						},
					},
					--Damage Info
					["Damage Comparison"] = {
						types = {
							"damageinfo",
						},
						func = function(dmg,compareMode,compareNumber)
							local num = dmg:GetDamage()
							if compareMode == 1 then return num == compareNumber end
							if compareMode == 2 then return num > compareNumber end
							if compareMode == 3 then return num >= compareNumber end
							if compareMode == 4 then return num < compareNumber end
							if compareMode == 5 then return num <= compareNumber end
							return false
						end,
						arguments = {
							{
								name = "Compare Mode",
								type = "options",
								items = {
									["Equal To"] = 1,
									["Greater Than"] = 2,
									["Greater Than Or Equal To"] = 3,
									["Less Than"] = 4,
									["Less Than Or Equal To"] = 5,
								},
								default = 1,
							},
							{
								name = "Compare Number",
								type = "number",
								min = -1000,
								max = 1000,
								decimals = 0
							},
						},
					},
					["Is Damage Type"] = {
						types = {
							"damageinfo",
						},
						func = function(dmg,type)
							return dmg:IsDamageType(type)
						end,
						arguments = {
							{
								name = "Damage Type",
								type = "options",
								items = {
									Default = -1,
									Generic = DMG_GENERIC,
									Physics = DMG_CRUSH,
									Bullet = DMG_BULLET,
									Stab = DMG_SLASH,
									Blunt = DMG_CLUB,
									Burn = DMG_BURN,
									Explosion = DMG_BLAST,
									Energy = DMG_DISSOLVE,
								},
								default = DMG_GENERIC,
							},
						},
					},
					--Number
					["Number Comparison"] = {
						types = {
							"number",
						},
						func = function(num,compareMode,compareNumber)
							if compareMode == 1 then return num == compareNumber end
							if compareMode == 2 then return num > compareNumber end
							if compareMode == 3 then return num >= compareNumber end
							if compareMode == 4 then return num < compareNumber end
							if compareMode == 5 then return num <= compareNumber end
							return false
						end,
						arguments = {
							{
								name = "Compare Mode",
								type = "options",
								items = {
									["Equal To"] = 1,
									["Greater Than"] = 2,
									["Greater Than Or Equal To"] = 3,
									["Less Than"] = 4,
									["Less Than Or Equal To"] = 5,
								},
								default = 1,
							},
							{
								name = "Compare Number",
								type = "number",
								min = -1000,
								max = 1000,
								decimals = 0
							},
						},
					},
					--Bool
					["Boolean Comparison"] = {
						types = {
							"bool",
						},
						func = function(bool,compare)
							return bool == compare
						end,
						arguments = {
							{
								name = "Continue If Value Is",
								type = "bool",
							}
						},
					},
					--String
					["String Comparison"] = {
						types = {
							"string",
						},
						func = function(str,compare)
							return str == compare
						end,
						arguments = {
							{
								name = "Must Be Equal To",
								type = "string",
							}
						},
					},
					--Any
					["Chance"] = {
						types = {
							"any",
						},
						func = function(ent,x)
							return math.random(1,x) == 1
						end,
						arguments = {
							{
								name = "Chance 1 in X",
								type = "number",
								min = 1,
								max = 100,
								default = 1,
								decimals = 0,
							},
						},
					},
				},
				actions = {
					--Player Specific
					["Set Armor"] = {
						types = {
							"player",
						},
						func = function(ent,armor,add)
							ent:SetArmor(math.max(0,(add and ent:Armor() or 0)+armor))
						end,
						arguments = {
							{
								name = "Armor",
								type = "number",
								min = 1,
								max = 255,
								default = 100,
								decimals = 0
							},
							{
								name = "Add",
								type = "bool",
								default = false,
							},
						},
					},
					["Message"] = {
						types = {
							"player",
						},
						func = function(ent,msg)
							ent:ChatPrint(msg)
						end,
						arguments = {
							{
								name = "Message",
								type = "string",
							},
						}
					},
					["Say"] = {
						types = {
							"player",
						},
						func = function(ent,msg)
							ent:Say(msg)
						end,
						arguments = {
							{
								name = "Message",
								type = "string",
							},
						}
					},
					["Set Walk Speed"] = {
						types = {
							"player",
						},
						func = function(ent,spd,add)
							if add then
								ent:SetWalkSpeed(ent:GetWalkSpeed()+spd)
							else
								ent:SetWalkSpeed(math.max(spd,1))
							end
						end,
						arguments = {
							{
								name = "Speed",
								type = "number",
								min = -500,
								max = 1000,
								default = 200
							},
							{
								name = "Add",
								type = "bool",
								default = false,
							},
						}
					},
					["Set Run Speed"] = {
						types = {
							"player",
						},
						func = function(ent,spd,add)
							if add then
								ent:SetRunSpeed(ent:GetRunSpeed()+spd)
							else
								ent:SetRunSpeed(math.max(spd,1))
							end
						end,
						arguments = {
							{
								name = "Speed",
								type = "number",
								min = -500,
								max = 1000,
								default = 200
							},
							{
								name = "Add",
								type = "bool",
								default = false,
							},
						}
					},
					["Respawn"] = {
						types = {
							"player",
						},
						func = function(ent)
							ent:Spawn()
						end,
					},
					["Select Weapon"] = {
						types = {
							"player",
						},
						func = function(ent,class)
							if class then
								ent:SelectWeapon(class)
							end
						end,
						arguments = {
							{
								name = "Weapon Class",
								type = "string",
							}
						}
					},
					["Take Weapon By Class"] = {
						types = {
							"player",
						},
						func = function(ent,class)
							if class then
								ent:StripWeapon(class)
							end
						end,
						arguments = {
							{
								name = "Weapon Class",
								type = "string",
							}
						}
					},
					["Give Ammo"] = {
						types = {
							"player",
						},
						func = function(ent,ammoType,amount,hide)
							ent:GiveAmmo(amount,ammoType,hide)
						end,
						arguments = {
							{
								name = "Ammo Type",
								type = "options",
								items = function()
									local ammos = {
										["AR2"] = "AR2",
										["AR2 Energy Ball"] = "AR2AltFire",
										["Pistol"] = "Pistol",
										["SMG1"] = "SMG",
										["SMG Grenade"] = "SMG1_Grenade",
										["357"] = "357",
										["X Bow Bolt"] = "XBowBolt",
										["Buckshot"] = "Buckshot",
										["RPG Round"] = "RPG_Round",
										["Grenade"] = "Grenade",
										["Slam"] = "slam",
									}
									for k,v in ipairs(game.BuildAmmoTypes()) do
										ammos[v.name] = v.name
									end
									return ammos
								end,
								default = "Pistol"
							},
							{
								name = "Amount",
								type = "number",
								min = 1,
								max = 500,
								default = 1,
								decimals = 0,
							},
							{
								name = "Hide Notification",
								type = "bool",
								default = false,
							}
						}
					},
					["Take Ammo"] = {
						types = {
							"player",
						},
						func = function(ent,ammoType,amount)
							ent:RemoveAmmo(amount,ammoType)
						end,
						arguments = {
							{
								name = "Ammo Type",
								type = "options",
								items = function()
									local ammos = {
										["AR2"] = "AR2",
										["AR2 Energy Ball"] = "AR2AltFire",
										["Pistol"] = "Pistol",
										["SMG1"] = "SMG",
										["SMG Grenade"] = "SMG1_Grenade",
										["357"] = "357",
										["X Bow Bolt"] = "XBowBolt",
										["Buckshot"] = "Buckshot",
										["RPG Round"] = "RPG_Round",
										["Grenade"] = "Grenade",
										["Slam"] = "slam",
									}
									for k,v in ipairs(game.BuildAmmoTypes()) do
										ammos[v.name] = v.name
									end
									return ammos
								end,
								default = "Pistol"
							},
							{
								name = "Amount",
								type = "number",
								min = 1,
								max = 500,
								default = 1,
								decimals = 0,
							},
						}
					},
					["Set Flashlight"] = {
						types = {
							"player",
						},
						func = function(ent,on)
							if ent:FlashlightIsOn() == on then return end
							ent:Flashlight(on)
						end,
						arguments = {
							{
								name = "Turn On/Off",
								type = "bool",
								default = true
							},
						}
					},
					["Enable Godmode"] = {
						types = {
							"player",
						},
						func = function(ent,on)
							if on then
								ent:GodEnable()
							else
								ent:GodDisable()
							end
						end,
						arguments = {
							{
								name = "Turn On/Off",
								type = "bool",
								default = true
							},
						}
					},
					--Player and NPC
					["Kill"] = {
						types = {
							"player",
							"npc"
						},
						func = function(ent)
							if ent:IsPlayer() then
								if ent:Alive() then
									ent:Kill()
								end
							elseif ent:Health() > 0 then
								ent:TakeDamage(99999,ent,ent)
							end
						end,
					},
					["Ragdoll"] = {
						types = {
							"player",
							"npc"
						},
						func = function(ent,time)
							ent:IG_StartRagdoll()
							timer.Simple(time,function()
								ent:IG_StopRagdoll()
							end)
						end,
						arguments = {
							{
								name = "Time",
								type = "number",
								min = 0,
								max = 999,
								decimals = 2,
								default = 1
							}
						}
					},
					["Remove Weapon"] = {
						types = {
							"player",
							"npc"
						},
						func = function(ent)
							if ent:GetActiveWeapon():IsValid() then
								ent:GetActiveWeapon():Remove()
							end
						end,
					},
					["Give Weapon"] = {
						types = {
							"player",
							"npc"
						},
						func = function(ent,class)
							if class then
								ent:Give(class)
							end
						end,
						arguments = {
							{
								name = "Weapon Class",
								type = "string",
							}
						}
					},
					--Physics
					["Set Mass"] = {
						types = {
							"physobj",
						},
						func = function(ent,mass)
							ent:GetPhysicsObject():SetMass(mass)
						end,
						arguments = {
							{
								name = "Mass",
								type = "number",
								min = 1,
								max = 10000,
								default = 10,
							}
						}
					},
					--Positional
					["Create Explosion"] = {
						types = {
							"position",
						},
						func = function(pos,size,damage)
							CreateExplosion(pos,size,dmg,Entity(0),Entity(0))
						end,
						arguments = {
							{
								name = "Size",
								type = "number",
								min = 50,
								max = 5000,
								decimals = 0
							},
							{
								name = "Damage Amount",
								type = "number",
								min = 1,
								max = 99999,
								decimals = 0
							},
						}
					},
					["Cause Quake"] = {
						types = {
							"position",
						},
						func = function(pos,amp,freq,dur,radius)
							util.ScreenShake(pos,amp,freq,dur,radius)
						end,
						arguments = {
							{
								name = "Amplitude",
								type = "number",
								min = 0,
								max = 100,
								default = 5,
								decimals = 2
							},
							{
								name = "Frequency",
								type = "number",
								min = 0,
								max = 10,
								default = .2,
								decimals = 2
							},
							{
								name = "Duration",
								type = "number",
								min = 0,
								max = 30,
								decimals = 2,
								default = 3
							},
							{
								name = "radius",
								type = "number",
								min = 1,
								max = 5000,
								decimals = 0
							},
						}
					},
					["Create Blackhole"] = {
						types = {
							"position",
						},
						func = function(pos,randomOffset,radius)
							ball = ents.Create("ig_blackhole")
							ball:SetPos(pos+VectorRand()*randomOffset)
							ball:Spawn()
							ball:Activate()
							ball:SetRadius(radius)
							local velocity = Vector()
							ball.velocity = velocity
							local phys = ball:GetPhysicsObject()
							if phys:IsValid() then
								phys:SetVelocity(velocity)
							end
						end,
						arguments = {
							{
								name = "Random Offset",
								type = "number",
								min = 0,
								max = 500,
								decimals = 0
							},
							{
								name = "Radius",
								type = "number",
								min = 1,
								max = 1000,
								decimals = 0
							},
						}
					},
					["Push/Pull"] = {
						types = {
							"position",
						},
						func = function(pos,radius,power,pull)
							if pull then power = -power end
							for k,v in ipairs(ents.FindInSphere(pos,radius)) do
								if (v:IsPlayer() or v:GetPhysicsObject():IsValid()) and v:IG_MotionEnabled() then
									local dir = ((pos-v:GetPos()):GetNormal()*-power)
									
									if v:IsPlayer() or v:IsNPC() then
										v:SetLocalVelocity(dir)
									else
										v:GetPhysicsObject():SetVelocity(dir)
									end
								end
							end
						end,
						arguments = {
							{
								name = "Radius",
								type = "number",
								min = 1,
								max = 2000,
								decimals = 0
							},
							{
								name = "Power",
								type = "number",
								min = 1,
								max = 3000,
								decimals = 0
							},
							{
								name = "Pull?",
								type = "bool",
								default = false,
							},
						}
					},
					["Create Prop"] = {
						types = {
							"position"
						},
						func = function(pos,model,lifetime,color,material,specialDir,x,y,z,distance)
							if !model or model == "" or !model:find(".mdl") or !util.IsInWorld(pos) then return end
							local dir
							if specialDir == 1 then
								dir = VectorRand()*distance
							else
								dir = Vector(x,y,z)*distance
							end
							
							local ent = ents.Create("prop_physics")
							ent:SetModel(model)
							ent:SetColor(color)
							ent:SetMaterial(material)
							ent:SetPos(pos+dir)
							ent:Spawn()
							ent:Activate()
							
							if lifetime <= 0 then return end
							timer.Simple(lifetime,function()
								if ent:IsValid() then
									ent:Remove()
								end
							end)
						end,
						arguments = {
							{
								name = "Model Path",
								type = "string",
								default = "models/props_phx/misc/egg.mdl",
							},
							{
								name = "Lifetime (0 for infinite)",
								type = "number",
								min = 0,
								max = 500,
								decimals = 2,
							},
							{
								name = "Color",
								type = "color",
							},
							{
								name = "Material Path",
								type = "string",
							},
							{
								name = "Special Offset",
								type = "options",
								items = {
									["Disabled"] = 0,
									["Random"] = 1,
								},
								default = 0,
							},
							{
								name = "Offset X Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Offset Y Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Offset Z Direction (UP)",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Offset Distance",
								type = "number",
								min = -3000,
								max = 3000,
								default = 100,
								decimals = 2
							},
						}
					},
					["Create Entity"] = {
						types = {
							"position"
						},
						func = function(pos,class,lifetime,color,material,specialDir,x,y,z,distance)
							local dir
							if specialDir == 1 then
								dir = VectorRand()*distance
							else
								dir = Vector(x,y,z)*distance
							end
							
							local ent = ents.Create(class)
							ent:SetColor(color)
							ent:SetMaterial(material)
							ent:SetPos(pos+dir)
							ent:Spawn()
							ent:Activate()
							
							if lifetime <= 0 then return end
							timer.Simple(lifetime,function()
								if ent:IsValid() then
									ent:Remove()
								end
							end)
						end,
						arguments = {
							{
								name = "Entity Class",
								type = "string",
								default = "npc_zombie",
							},
							{
								name = "Lifetime (0 for infinite)",
								type = "number",
								min = 0,
								max = 500,
								decimals = 2,
							},
							{
								name = "Color",
								type = "color",
							},
							{
								name = "Material Path",
								type = "string",
							},
							{
								name = "Special Offset",
								type = "options",
								items = {
									["Disabled"] = 0,
									["Random"] = 1,
								},
								default = 0,
							},
							{
								name = "Offset X Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Offset Y Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Offset Z Direction (UP)",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Offset Distance",
								type = "number",
								min = -3000,
								max = 3000,
								default = 100,
								decimals = 2
							},
						}
					},
					["Play Sound"] = {
						types = {
							"position",
						},
						func = function(pos,snd,DBs,pitch,volume)
							sound.Play(snd,pos,DBs,pitch,volume)
						end,
						arguments = {
							{
								name = "Sound Path",
								type = "string",
								default = "garrysmod/balloon_pop_cute.wav",
							},
							{
								name = "DBs",
								type = "number",
								min = 0,
								max = 511,
								default = 75,
								decimals = 0
							},
							{
								name = "Pitch",
								type = "number",
								min = 0,
								max = 200,
								default = 100,
								decimals = 0
							},
							{
								name = "Volume",
								type = "number",
								min = 0,
								max = 1,
								default = 1,
								decimals = 2
							},
						}
					},
					["Bubbles"] = {
						types = {
							"position",
						},
						func = function(pos,randomOffset)
							local ef = EffectData()
							ef:SetOrigin(pos+VectorRand()*randomOffset)
							util.Effect("ig_bubbles",ef,true,true)
						end,
						arguments = {
							{
								name = "Random Offset",
								type = "number",
								min = 0,
								max = 500,
								decimals = 0
							},
						}
					},
					["Gore"] = {
						types = {
							"position",
						},
						func = function(pos,amount,randomOffset,xdir,ydir,zdir,randDir,power,noSound)
							local ef = EffectData()
							ef:SetFlags(1)
							ef:SetNormal(randDir and VectorRand() or Vector(xdir,ydir,zdir))
							ef:SetDamageType(power)
							
							for i=0,amount do
								ef:SetOrigin(pos+VectorRand()*randomOffset)
								
								util.Effect("ig_bloodsplash",ef,true,true)
								util.Effect("ig_entrails",ef,true,true)
								if !noSound then
									sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav",pos,75,math.random(90,110),1)
								end
							end
						end,
						arguments = {
							{
								name = "Amount",
								type = "number",
								min = 0,
								max = 20,
								default = 10,
								decimals = 0,
							},
							{
								name = "Random Offset",
								type = "number",
								min = 0,
								max = 500,
								decimals = 0
							},
							{
								name = "X Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Y Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Z Direction (UP)",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Random Direction",
								type = "bool",
								default = false,
							},
							{
								name = "Power",
								type = "number",
								min = 0,
								max = 500,
								default = 60,
								decimals = 0
							},
							{
								name = "No Sound",
								type = "bool",
								default = false,
							},
						}
					},
					["Tesla Zap"] = {
						types = {
							"position",
						},
						func = function(pos,randomOffset,power,silent)
							local ef = EffectData()
							ef:SetOrigin(pos+VectorRand()*randomOffset)
							ef:SetMagnitude(power)
							util.Effect("TeslaHitboxes",ef,false,true)
							
							if !silent then
								sound.Play("ambient.electrical_zap_"..tostring(math.random(1,3)),pos)
							end
						end,
						arguments = {
							{
								name = "Random Offset",
								type = "number",
								min = 0,
								max = 500,
								decimals = 0
							},
							{
								name = "Power",
								type = "number",
								min = 0,
								max = 500,
								default = 60,
								decimals = 0
							},
							{
								name = "Silent",
								type = "bool",
								default = false,
							},
						}
					},
					["Sparks"] = {
						types = {
							"position",
						},
						func = function(pos,randomOffset,randDir,x,y,z)
							local ef = EffectData()
							ef:SetOrigin(pos+VectorRand()*randomOffset)
							ef:SetNormal(randDir and VectorRand() or Vector(x,y,z))
							util.Effect("ManhackSparks",ef,false,true)
						end,
						arguments = {
							{
								name = "Random Offset",
								type = "number",
								min = 0,
								max = 500,
								decimals = 0
							},
							{
								name = "Use Random Direction?",
								type = "bool",
								default = false,
							},
							{
								name = "X Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Y Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Z Direction (UP)",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
						}
					},
					--All Entities
					["Set Variable"] = {
						types = {
							"entity",
						},
						func = function(ent,var,type,number,addNum,string,color)
							if var == "" then return end
							if !ent.igconddata then
								ent.igconddata = {}
							end
							local val
							if type == 1 then
								val = addNum and (ent.igconddata[var] or 0)+number or number
							elseif type == 2 then
								val = string
							else
								val = color
							end
							
							ent.igconddata[var] = val
						end,
						arguments = {
							{
								name = "Variable",
								type = "string",
							},
							{
								name = "Variable Type",
								type = "options",
								items = {
									Number = 1,
									String = 2,
									Color = 3,
								},
								default = "Number"
							},
							{
								name = "[Number] Value",
								type = "number",
								min = -100,
								max = 100,
								default = 0,
								decimals = 2,
							},
							{
								name = "[Number] Add Value",
								type = "bool",
								default = false,
							},
							{
								name = "[String] Value",
								type = "string",
							},
							{
								name = "[Color] Value",
								type = "color",
							},
						}
					},
					["Remove"] = {
						types = {
							"entity",
						},
						func = function(ent)
							ent:Remove()
						end,
					},
					["Randomize Angles"] = {
						types = {
							"entity",
						},
						func = function(ent)
							ent:SetAngles(AngleRand())
						end,
					},
					["Damage"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,damage)
							ent:TakeDamage(damage,ent,ent)
						end,
						arguments = {
							{
								name = "Damage Amount",
								type = "number",
								min = 1,
								max = 99999,
								decimals = 0
							}
						}
					},
					["Set Scale"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,scale,add)
							ent:IG_SetScale(math.max(.001,(add and ent:GetModelScale() or 0)+scale))
						end,
						arguments = {
							{
								name = "Scale",
								type = "number",
								min = 0,
								max = 5,
								default = 1,
								decimals = 2
							},
							{
								name = "Add",
								type = "bool",
								default = false,
							}
						}
					},
					["Ignite"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,time,spreadRange)
							if time <= 0 then return end
							ent:Ignite(time,spreadRange)
						end,
						arguments = {
							{
								name = "Ignition Time",
								type = "number",
								min = 0,
								max = 100,
								default = 1,
								decimals = 2
							},
							{
								name = "Ignition Radius",
								type = "number",
								min = 0,
								max = 99999,
								default = 0,
								decimals = 0
							},
						}
					},
					["Set Color"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,color)
							ent:SetColor(color)
						end,
						arguments = {
							{
								name = "Color",
								type = "color",
							},
						}
					},
					["Set Collision Group"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,group)
							ent:SetCollisionGroup(group)
						end,
						arguments = {
							{
								name = "Group",
								type = "options",
								items = {
									Default = 0,
									Debris = 1,
									Trigger = 2,
									["Interactive Debris"] = 3,
									Interactive = 4,
									Player = 5,
									["Breakable Glass"] = 6,
									Vehicle = 7,
									["Blocks Player Movement"] = 8,
									NPC = 9,
									["No Collide"] = 10,
									["Weapon"] = 11,
									["Vehicles Only"] = 12,
									["Projectile"] = 13,
									["World"] = 20,
								},
								default = 0,
							},
						}
					},
					["Set RenderFX"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,group)
							ent:SetRenderFX(group == -1 and math.random(0,16) or group)
						end,
						arguments = {
							{
								name = "RenderFX",
								type = "options",
								items = {
									None = 0,
									Random = -1,
									["Pulse Slow"] = 1,
									["Pulse Fast"] = 2,
									["Pulse Slow Wide"] = 3,
									["Pulse Fast Wide"] = 4,
									["Fade Slow"] = 5,
									["Fade Fast"] = 6,
									["Solid Slow"] = 7,
									["Solid Fast"] = 8,
									["Strobe Slow"] = 9,
									["Strobe Fast"] = 10,
									["Strobe Faster"] = 11,
									["Flicker Slow"] = 12,
									["Flicker Fast"] = 13,
									["No Dissipation"] = 14,
									["Distort"] = 15,
									["Hologram"] = 16,
									["Explode"] = 17,
									["Glow Shell"] = 18,
								},
								default = 0,
							},
						}
					},
					["Set Gravity"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,gravity)
							if gravity < 1 and ent:GetPhysicsObject():IsValid() then
								ent:GetPhysicsObject():EnableGravity(false)
							else
								ent:SetGravity(gravity)
							end
						end,
						arguments = {
							{
								name = "Gravity",
								type = "number",
								min = 0,
								max = 1,
								default = 1,
								decimals = 2
							},
						}
					},
					["Set Health"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,hp,add)
							ent:SetHealth(math.max(1,(add and ent:Health() or 0)+hp))
						end,
						arguments = {
							{
								name = "Health",
								type = "number",
								min = 1,
								max = 1000,
								default = 100,
								decimals = 0
							},
							{
								name = "Add",
								type = "bool",
								default = false,
							}
						}
					},
					["Launch"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,specialDir,x,y,z,power)
							local vel
							if specialDir == 1 then
								vel = VectorRand()*power
							elseif specialDir == 2 then
								local closestRange
								local closestEnt = NULL
								for k,v in ipairs(ents.GetAll()) do
									if v != owner and ((v:IsPlayer() and v:Alive()) or (v:IsNPC() and v:Health() > 0)) then
										local dist = v:GetPos():DistToSqr(ent:GetPos()) 
										if closestRange == nil or dist < closestRange then
											closestRange = dist
											closestEnt = v
										end
									end
								end
								
								vel = closestEnt:IsValid() and (closestEnt:LocalToWorld(closestEnt:OBBCenter())-ent:GetPos()):GetNormalized()*power
							else
								vel = Vector(x,y,z)*power
							end
							if ent:IsNPC() or ent:IsPlayer() then
								ent:SetLocalVelocity(vel)
							elseif ent:GetPhysicsObject():IsValid() then
								ent:GetPhysicsObject():SetVelocity(vel)
							end
						end,
						arguments = {
							{
								name = "Special Direction",
								type = "options",
								items = {
									["Disabled"] = 0,
									["Random"] = 1,
									["Nearest Creature"] = 2,
								},
								default = 0,
							},
							{
								name = "X Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Y Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Z Direction (UP)",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Power",
								type = "number",
								min = -3000,
								max = 3000,
								default = 100,
								decimals = 2
							},
						}
					},
					["Teleport"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,specialDir,x,y,z,power)
							local dir
							if specialDir == 1 then
								dir = VectorRand()*power
							else
								dir = Vector(x,y,z)*power
							end
							ent:SetPos(ent:GetPos()+dir)
						end,
						arguments = {
							{
								name = "Special Direction",
								type = "options",
								items = {
									["Disabled"] = 0,
									["Random"] = 1,
								},
								default = 0,
							},
							{
								name = "X Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Y Direction",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Z Direction (UP)",
								type = "number",
								min = -1,
								max = 1,
								default = 0,
								decimals = 2
							},
							{
								name = "Distance",
								type = "number",
								min = -3000,
								max = 3000,
								default = 100,
								decimals = 2
							},
						}
					},
					["Emit Sound"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,sound,dbs,pitch,volume)
							if sound != "" then
								ent:EmitSound(sound,dbs,pitch,volume)
							end
						end,
						arguments = {
							{
								name = "Sound Path",
								type = "string",
								default = "garrysmod/balloon_pop_cute.wav",
							},
							{
								name = "DBs",
								type = "number",
								min = 0,
								max = 511,
								default = 75,
								decimals = 0
							},
							{
								name = "Pitch",
								type = "number",
								min = 0,
								max = 200,
								default = 100,
								decimals = 0
							},
							{
								name = "Volume",
								type = "number",
								min = 0,
								max = 1,
								default = 1,
								decimals = 2
							},
						}
					},
					["Set Material"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,mat)
							ent:SetMaterial(mat)
						end,
						arguments = {
							{
								name = "Material Path",
								type = "string",
							},
						}
					},
					["Wipe Existence"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent)
							IG_ExistanceWipe(ent)
						end,
					},
					["Set Model"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,mdl)
							ent:SetModel(mdl)
						end,
						arguments = {
							{
								name = "Model Path",
								type = "string",
								default = "models/props_phx/misc/egg.mdl",
							},
						}
					},
					["Set Invisible"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,invisible)
							ent:SetNoDraw(invisible)
						end,
						arguments = {
							{
								name = "Invisible",
								type = "bool",
								default = true,
							},
						}
					},
					["Freeze"] = {
						types = {
							"player",
							"npc",
							"entity",
						},
						func = function(ent,time)
							ent:IG_EnableMotion(false)
							if time <= 0 then return end
							timer.Create("IG_Law_MotionEnable"..ent:EntIndex(),time,1,function()
								if ent:IsValid() then
									ent:IG_EnableMotion(true)
								end
							end)
						end,
						arguments = {
							{
								name = "Time (0 for infinite)",
								type = "number",
								min = 0,
								max = 500,
								default = 1,
							},
						}
					},
					--Specific/Misc
					["Edit Sound"] = {
						clientside = true,
						types = {
							"sounddata"
						},
						func = function(data,dbs,pitch,vol,dsp)
							data.SoundLevel = dbs
							data.Pitch = pitch
							data.Volume = vol
							data.DSP = dsp
						end,
						arguments = {
							{
								name = "Decibels",
								type = "number",
								min = 0,
								max = 511,
								decimals = 0,
								default = 75
							},
							{
								name = "Pitch",
								type = "number",
								min = 10,
								max = 200,
								decimals = 0,
								default = 100,
							},
							{
								name = "Volume",
								type = "number",
								min = 0,
								max = 1,
								decimals = 2,
								default = 1
							},
							{
								name = "DSP",
								type = "number",
								min = 0,
								max = 133,
								decimals = 0,
								default = 0
							},
						}
					},
					["Edit Bullets"] = {
						clientside = true,
						types = {
							"bulletdata"
						},
						func = function(data,dmgMulti,bulletCountMulti,forceMulti,distance,spread)
							data.Damage = data.Damage*dmgMulti
							data.Force = data.Force*forceMulti
							data.Distance = distance
							data.Num = math.ceil(data.Num*bulletCountMulti)
							data.Spread = Vector(spread,spread,0)
						end,
						arguments = {
							{
								name = "Damage Multiplier",
								type = "number",
								min = 0,
								max = 100,
								decimals = 2,
								default = 1
							},
							{
								name = "Bullet Count Multiplier",
								type = "number",
								min = 0,
								max = 100,
								decimals = 2,
								default = 1
							},
							{
								name = "Force Multiplier",
								type = "number",
								min = 0,
								max = 100,
								decimals = 2,
								default = 1
							},
							{
								name = "Distance",
								type = "number",
								min = 0,
								max = 56756,
								decimals = 0,
								default = 56756
							},
							{
								name = "Spread",
								type = "number",
								min = 0,
								max = 10,
								decimals = 2,
								default = 0
							},
						}
					},
					["Edit Movement"] = {
						clientside = true,
						types = {
							"movementdata"
						},
						func = function(mv,speedMultiplier)
							mv:SetMaxClientSpeed(mv:GetMaxClientSpeed()*speedMultiplier)
							mv:SetMaxSpeed(mv:GetMaxSpeed()*speedMultiplier)
						end,
						arguments = {
							{
								name = "Speed Multiplier",
								type = "number",
								min = 0,
								max = 100,
								decimals = 2,
								default = 1
							},
						}
					},
					["Edit Damage"] = {
						types = {
							"damageinfo"
						},
						func = function(dmg,damageScaler,damageAddition,forceScaler,dmgType)
							dmg:ScaleDamage(damageScaler)
							dmg:AddDamage(damageAddition)
							dmg:SetDamageForce(dmg:GetDamageForce()*forceScaler)
							if dmgType >= 0 then
								dmg:SetDamageType(dmgType)
							end
						end,
						arguments = {
							{
								name = "Scale Damage",
								type = "number",
								min = 0,
								max = 100,
								decimals = 2,
								default = 1,
							},
							{
								name = "Add Damage",
								type = "number",
								min = -5000,
								max = 5000,
								decimals = 0,
								default = 0,
							},
							{
								name = "Scale Force",
								type = "number",
								min = 0,
								max = 100,
								decimals = 2,
								default = 1,
							},
							{
								name = "Damage Type",
								type = "options",
								items = {
									Default = -1,
									Generic = DMG_GENERIC,
									Physics = DMG_CRUSH,
									Bullet = DMG_BULLET,
									Stab = DMG_SLASH,
									Blunt = DMG_CLUB,
									Burn = DMG_BURN,
									Explosion = DMG_BLAST,
									Energy = DMG_DISSOLVE,
								},
								default = DMG_GENERIC,
							},
						}
					},
				},
				events = {
					["Entity Damaged"] = {
						hook = "EntityTakeDamage",
						structFunc = function(ent,dmg)
							return ent,dmg:GetAttacker(),dmg
						end,
						arguments = {
							{
								name = "Entity",
								type = "entity",
							},
							{
								name = "Attacker",
								type = "entity",
							},
							{
								name = "Modify Damage",
								type = "damageinfo"
							},
						},
						returns = {
							name = "Negate Damage",
							type = "bool",
							nilValue = false
						}
					},
					["Entity Emit Sound"] = {
						hook = "EntityEmitSound",
						clientside = true,
						arguments = {
							{
								name = "Sound Settings",
								type = "sounddata",
							},
							{
								name = "Emitting Entity",
								type = "entity",
							},
							{
								name = "Position Emitted At",
								type = "position",
							},
						},
						structFunc = function(data)
							return data,data.Entity,(data.Pos or data.Entity:GetPos())
						end,
						returns = {
							name = "Allow Emittion",
							type = "bool",
							default = true,
						}
					},
					["Entity Tick (Triggered Constantly)"] = {
						hook = "Think",
						hookMod = function(func)
							for k,v in ipairs(ents.GetAll()) do
								func(v)
							end
						end,
						arguments = {
							{
								name = "Entity",
								type = "entity",
							},
						},
					},
					["Prop Destroyed"] = {
						hook = "PropBreak",
						arguments = {
							{
								name = "Player Who Broke Prop",
								type = "player",
							},
							{
								name = "Prop That Was Broken",
								type = "entity",
							},
						},
					},
					["Bullets Fired"] = {
						clientside = true,
						hook = "EntityFireBullets",
						structFunc = function(ent,data)
							return ent,data,util.TraceLine{
								start = data.Src,
								endpos = data.Src+data.Dir*data.Distance,
								filter = data.Attacker
							}.HitPos
						end,
						arguments = {
							{
								name = "Entity Firing",
								type = "entity",
							},
							{
								name = "Bullet Settings",
								type = "bulletdata",
							},
							{
								name = "Hit Position",
								type = "position",
							},
						},
						returns = {
							name = "Allow Bullets Being Fired",
							type = "bool",
							default = true,
						}
					},
					["Entity Removed"] = {
						hook = "EntityRemoved",
						arguments = {
							{
								name = "Removed Entity",
								type = "entity",
							},
						},
					},
					["Entity Created"] = {
						hook = "OnEntityCreated",
						hookMod = function(func,ent)
							timer.Simple(0,function()
								if ent:IsValid() then
									func(ent)
								end
							end)
						end,
						arguments = {
							{
								name = "Created Entity",
								type = "entity",
							},
						},
					},
					["Physics Collision"] = {
						apply = function(func,uniqueName)
							local function Collide(ent,data)
								func(ent,data.Speed)
							end
							for k,v in ipairs(ents.GetAll()) do
								v[uniqueName] = v:AddCallback("PhysicsCollide",Collide)
							end
							hook.Add("OnEntityCreated",uniqueName,function(ent)
								ent[uniqueName] = ent:AddCallback("PhysicsCollide",Collide)
							end)
						end,
						remove = function(uniqueName)
							for k,v in ipairs(ents.GetAll()) do
								if v[uniqueName] then
									v:RemoveCallback("PhysicsCollide",v[uniqueName])
								end
							end
							hook.Remove("OnEntityCreated",uniqueName)
						end,
						arguments = {
							{
								name = "Colliding Entity",
								type = "entity",
							},
							{
								name = "Impact Speed",
								type = "number",
							},
						},
					},
					
					--Player Related.
					["Player Movement"] = {
						clientside = true,
						hook = "Move",
						arguments = {
							{
								name = "Player",
								type = "player",
							},
							{
								name = "Movement Settings",
								type = "movementdata",
							},
						},
					},
					["Player Switch Weapon"] = {
						hook = "PlayerSwitchWeapon",
						arguments = {
							{
								name = "Player",
								type = "player",
							},
							{
								name = "Old Weapon",
								type = "weapon"
							},
							{
								name = "New Weapon",
								type = "weapon"
							},
						},
						returns = {
							name = "Prevent Switch",
							type = "bool",
							default = false,
							nilValue = false,
						}
					},
					["Player Pickup Weapon"] = {
						hook = "PlayerCanPickupWeapon",
						arguments = {
							{
								name = "Player",
								type = "player",
							},
							{
								name = "Weapon",
								type = "weapon"
							},
						},
						returns = {
							name = "Allow Pickup",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Footstep"] = {
						hook = "PlayerFootstep",
						arguments = {
							{
								name = "Player",
								type = "player",
							},
							{
								name = "Position",
								type = "position"
							},
							{
								name = "Foot Number 0 = Left 1 = Right",
								type = "number"
							},
							NULL,--sound
							NULL,--volume
							NULL--filter
						},
						returns = {
							name = "Silence footstep",
							type = "bool",
							nilValue = false,
						}
					},
					["Player Pickup Entity"] = {
						hook = "AllowPlayerPickup",
						arguments = {
							{
								name = "Player Picking Up Entity",
								type = "player",
							},
							{
								name = "Entity Being Picked Up",
								type = "entity"
							},
						},
						returns = {
							name = "Allow Pickup",
							type = "bool",
							default = true,
							nilValue = true
						}
					},
					["Player Suicide"] = {
						hook = "CanPlayerSuicide",
						arguments = {
							{
								name = "Suiciding Player",
								type = "player",
							},
						},
						returns = {
							name = "Allow Suicide",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Fall Damage"] = {
						hook = "GetFallDamage",
						arguments = {
							{
								name = "Player Who Fell",
								type = "player",
							},
							{
								name = "Impact Speed",
								type = "number",
							},
						},
						returns = {
							name = "Fall Damage",
							type = "number",
							min = 0,
							max = 999999,
							default = 0,
							nilValue = 0,
						}
					},
					["Player Hit Ground"] = {
						hook = "OnPlayerHitGround",
						hookMod = function(func,ply,water,obj,spd)
							timer.Simple(0,function()
								if ply:IsValid() then
									func(ply,water,obj,spd)
								end
							end)
						end,
						arguments = {
							{
								name = "Player Who Hit The Floor",
								type = "player",
							},
							{
								name = "Player Land In Water?",
								type = "bool",
							},
							{
								name = "Player Hit Object Floating In Water?",
								type = "bool",
							},
							{
								name = "Impact Speed",
								type = "number",
							},
						},
					},
					["Player Touch Ceiling"] = {
						hook = "PlayerPostThink",
						hookMod = function(func,ply)
							if ply:GetMoveType() == MOVETYPE_WALK and util.TraceEntity({
								start = ply:GetPos(),
								endpos = ply:GetPos()+vector_up,
								filter = ply,
							},ply).Hit then
								if !ply.ig_touchingCeiling then
									ply.ig_touchingCeiling = true
									func(ply)
								end
							else
								ply.ig_touchingCeiling = false
							end
						end,
						arguments = {
							{
								name = "Player Who Touched Ceiling",
								type = "player",
							},
						},
					},
					["Gravity Gun Punt Used"] = {
						clientside = true,
						hook = "GravGunPunt",
						arguments = {
							{
								name = "Player Who Used Punt",
								type = "player",
							},
							{
								name = "Entity Being Punted",
								type = "entity",
							},
						},
						returns = {
							name = "Allow Punt",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Use Noclip"] = {
						hook = "PlayerNoClip",
						arguments = {
							{
								name = "Player Who Used Noclip",
								type = "player",
							},
						},
						returns = {
							name = "Allow Toggling",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Enter Vehicle"] = {
						hook = "CanPlayerEnterVehicle",
						arguments = {
							{
								name = "Player Entering Vehicle",
								type = "player",
							},
							{
								name = "Vehicle Being Entered",
								type = "vehicle",
							},
						},
						returns = {
							name = "Allow Entering",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawned"] = {
						hook = "PlayerSpawn",
						arguments = {
							{
								name = "Player Who Spawned",
								type = "player",
							},
						},
					},
					["Player Unfreeze Entity"] = {
						hook = "CanPlayerUnfreeze",
						arguments = {
							{
								name = "Player",
								type = "player",
							},
							{
								name = "Entity Being Unfrozen",
								type = "entity",
							},
						},
						returns = {
							name = "Allow Unfreezing",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawn Vehicle"] = {
						hook = "PlayerSpawnVehicle",
						arguments = {
							{
								name = "Player Spawning Vehicle",
								type = "player",
							},
							{
								name = "Model Path",
								type = "string",
							},
							{
								name = "Vehicle Class",
								type = "string",
							},
						},
						returns = {
							name = "Allow Spawning",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawn SWEP"] = {
						hook = "PlayerSpawnSWEP",
						arguments = {
							{
								name = "Player Spawning SWEP",
								type = "player",
							},
							{
								name = "Weapon Class",
								type = "string",
							},
						},
						returns = {
							name = "Allow Spawning",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Give SWEP"] = {
						hook = "PlayerGiveSWEP",
						arguments = {
							{
								name = "Player Giving Themself A SWEP",
								type = "player",
							},
							{
								name = "Weapon Class",
								type = "string",
							},
						},
						returns = {
							name = "Allow Spawning",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawn SENT"] = {
						hook = "PlayerSpawnSENT",
						arguments = {
							{
								name = "Player Spawning SENT",
								type = "player",
							},
							{
								name = "Entity Class",
								type = "string",
							},
						},
						returns = {
							name = "Allow Spawning",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawn Ragdoll"] = {
						hook = "PlayerSpawnRagdoll",
						arguments = {
							{
								name = "Player Spawning Ragdoll",
								type = "player",
							},
							{
								name = "Model Path",
								type = "string",
							},
						},
						returns = {
							name = "Allow Spawning",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawn Prop"] = {
						hook = "PlayerSpawnProp",
						arguments = {
							{
								name = "Player Spawning Prop",
								type = "player",
							},
							{
								name = "Model Path",
								type = "string",
							},
						},
						returns = {
							name = "Allow Spawning",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawn Object"] = {
						hook = "PlayerSpawnObject",
						arguments = {
							{
								name = "Player Spawning Object",
								type = "player",
							},
							{
								name = "Model Path",
								type = "string",
							},
						},
						returns = {
							name = "Allow Spawning",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawn NPC"] = {
						hook = "PlayerSpawnNPC",
						arguments = {
							{
								name = "Player Spawning NPC",
								type = "player",
							},
							{
								name = "NPC Class",
								type = "string",
							},
							{
								name = "NPC Weapon Class",
								type = "string",
							},
						},
						returns = {
							name = "Allow Spawning",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawn Effect"] = {
						hook = "PlayerSpawnEffect",
						arguments = {
							{
								name = "Player Spawning Effect",
								type = "player",
							},
						},
						returns = {
							name = "Allow Spawning",
							type = "bool",
							default = true,
							nilValue = true,
						}
					},
					["Player Spawned Effect"] = {
						hook = "PlayerSpawnedEffect",
						arguments = {
							{
								name = "Player Who Spawned Effect",
								type = "player",
							},
							NULL,
							{
								name = "Spawned Entity",
								type = "entity",
							},
						},
					},
					["Player Spawned NPC"] = {
						hook = "PlayerSpawnedNPC",
						arguments = {
							{
								name = "Player Who Spawned NPC",
								type = "player",
							},
							NULL,
							{
								name = "Spawned NPC",
								type = "npc",
							},
						},
					},
					["Player Spawned Prop"] = {
						hook = "PlayerSpawnedProp",
						arguments = {
							{
								name = "Player Who Spawned Prop",
								type = "player",
							},
							NULL,
							{
								name = "Spawned Prop",
								type = "entity",
							},
						},
					},
					["Player Spawned Ragdoll"] = {
						hook = "PlayerSpawnedRagdoll",
						arguments = {
							{
								name = "Player Who Spawned Ragdoll",
								type = "player",
							},
							NULL,
							{
								name = "Spawned Ragdoll",
								type = "entity",
							},
						},
					},
					["Player Spawned SENT"] = {
						hook = "PlayerSpawnedSENT",
						arguments = {
							{
								name = "Player Who Spawned SENT",
								type = "player",
							},
							NULL,
							{
								name = "Spawned SENT",
								type = "entity",
							},
						},
					},
					["Player Spawned Vehicle"] = {
						hook = "PlayerSpawnedVehicle",
						arguments = {
							{
								name = "Player Who Spawned Vehicle",
								type = "player",
							},
							NULL,
							{
								name = "Spawned Vehicle",
								type = "vehicle",
							},
						},
					},
				},
				typeFitsFilter = function(type,filter)
					if !type then return false end
					local types = IG_LawData.types
					local typeFitsList = {[type] = true}
					
					if types[type] then
						local inherits = types[type].inherits
						if inherits then
							while inherits do
								typeFitsList[inherits] = true
								inherits = types[inherits].inherits
							end
						end
					end
					
					for k,v in ipairs(filter) do
						if typeFitsList[v] then return true end
					end
					
					return false
				end,
				typeInherits = function(type,testParent)
					if type == testParent then return true end
					
					local types = IG_LawData.types
					
					if types[type] then
						local inherits = types[type].inherits
						if inherits then
							while inherits do
								if inherits == testParent then return true end
								inherits = types[inherits].inherits
							end
						end
					end
					
					return false
				end,
				findTypeChildren = function(type)
					local children = {}
					
					for k,v in pairs(IG_LawData.types) do
						if k != type and IG_LawData.typeInherits(k,type) then
							children[#children+1] = k
						end
					end
					
					return children
				end,
				typeConvertsInto = function(startType,goalType)
					local goalTypeData = IG_LawData.types[goalType]
					if !goalTypeData or !IG_LawData.types[startType] then return false end
					return goalTypeData.convertsFrom and table.HasValue(goalTypeData.convertsFrom,startType)
				end,
				findTypesCompatible = function(type,settings)
					local compatible = {}
					local mustBeSelectableType = settings and settings.selectibleType
					
					for k,v in pairs(IG_LawData.types) do
						if !table.HasValue(compatible,k) and (IG_LawData.typeInherits(k,type) or IG_LawData.typeConvertsInto(type,k)) and (!mustBeSelectableType or !v.notSelectableType) then
							compatible[#compatible+1] = k
						end
					end
					
					return compatible
				end,
				createConditionalFunction = function(conditionData,lawData)
					local conditionMeta = IG_LawData.conditionals[conditionData.conditional]
					if conditionMeta and (SERVER or (CLIENT and conditionMeta.clientside != false)) then
						local passingArgs = {} 
						for passArgNum,passingArgsData in ipairs(conditionData.arguments) do
							passingArgs[passArgNum] = passingArgsData.value
						end
						
						local conditionFunc = conditionMeta.func
						local targetArgument = conditionData.targetArgument
						local invert = conditionData.invert
						
						local argTypeMeta = IG_LawData.types[conditionData.type]
						local check
						if argTypeMeta then
							check = argTypeMeta.check
						end
						
						return function(args)
							if check and !check(args[targetArgument]) then return false end
							local result = conditionFunc(args[targetArgument],unpack(passingArgs))
							if invert then
								return !result
							end
							return result
						end
					end
				end,
				defineLaw = function(ability,lawName,law)
					local eventData = ability.events[law.event]
					ability.deleteLaw(ability,lawName,true)
					if SERVER or (CLIENT and eventData.clientside) then
						local compiledActions = {}
						for argID,actionsList in pairs(law.actions) do
							compiledActions[argID] = {}
							for k,actionData in ipairs(actionsList) do
								local actionMeta = ability.actions[actionData.action]
								if CLIENT and !actionMeta.clientside then continue end
								
								local passingArgs = {} 
								for passArgNum,passingArgsData in ipairs(actionData.arguments) do
									passingArgs[passArgNum] = passingArgsData.value
								end
								
								local actionTypeMeta = ability.types[actionData.type]
								local check,converter
								if actionTypeMeta then
									check = actionTypeMeta.check
									converter = actionTypeMeta.converter
								end
								
								local condition
								if actionData.conditional then
									condition = ability.createConditionalFunction(actionData.conditional,law)
								end
								
								local actionFunc = actionMeta.func
								compiledActions[argID][#compiledActions[argID]+1] = function(arg,args)
									 --Runs if there are no checks, as the for loop doesn't execute.
									if converter then
										arg = converter(arg)
									end
									if (check == nil or check(arg)) and (condition == nil or condition(args)) then
										actionFunc(arg,unpack(passingArgs))
									end
								end
							end
						end
						local returnConditional
						local returnValue
						
						if law.returns then
							if law.returns.conditional then
								returnConditional = ability.createConditionalFunction(law.returns.conditional,law)
							else
								returnValue = law.returns and law.returns.value
								if eventData.returns and returnValue == eventData.returns.nilValue then
									returnValue = nil
								end
							end
						end
						local structureFunc = eventData.structFunc or DoNothing
						local function Event(...)
							local args = {structureFunc(...)}
							for argID,actionsList in pairs(compiledActions) do
								for k,func in ipairs(actionsList) do
									func(args[argID],args)
								end
							end
							
							if returnConditional then
								return returnConditional(args)
							end
							
							return returnValue
						end
						
						local uniqueName = "IG_UniversalLaw"..law.event..lawName
						if eventData.hook then
							hook.Add(eventData.hook,uniqueName,
							eventData.hookMod and function(...)
								return eventData.hookMod(Event,...)
							end or Event)
						else
							eventData.apply(Event,uniqueName)
						end
					end
					ability.laws[lawName] = law
					if SERVER then
						net.Start("IG_SyncLaw")
						net.WriteIGLaw(lawName,law)
						net.Broadcast()
					end
				end,
				deleteLaw = function(ability,lawName,noNetwork)
					local law = ability.laws[lawName]
					if law then
						local eventData = ability.events[law.event]
						
						if (SERVER or (CLIENT and eventData.clientside)) then
							local uniqueName = "IG_UniversalLaw"..law.event..lawName
							if eventData.hook then
								hook.Remove(eventData.hook,uniqueName)
							else
								eventData.remove(uniqueName)
							end
						end
						
						ability.laws[lawName] = nil
						if SERVER and !noNetwork then
							net.Start("IG_DeleteLaw")
							net.WriteString(lawName)
							net.Broadcast()
						end
					end
				end,
				Use = function(self,data,ability)
					net.Start("IG_URMenu")
					net.WriteTable(ability.laws)
					net.Send(self.Owner)
				end,
			},
		},
	}
}
IG_LawData = IG_StoneData[IG_STONE_INFINITY].abilities[5]

function SWEP:DoAnim(anim)
	local vm = self.Owner:GetViewModel()
	if vm:IsValid() then
		vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
		self:UpdateNextIdle()
	end
end

function SWEP:GetAnimDuration()
	local vm = self.Owner:GetViewModel()
	if vm:IsValid() then
		return vm:SequenceDuration()/vm:GetPlaybackRate()
	end
end

function SWEP:DoPunch(damage,anim,callback)
	if self.nextPunch and self.nextPunch > CurTime() then return end
	self.nextPunch = CurTime()+.85
	local ply = self.Owner
	net.Start("IG_PunchAnim")
	net.Send(ply)
	ply:SetAnimation(PLAYER_ATTACK1)
	if UsingOldModel() then
		self:DoAnim(anim or "fists_right")
	else
		self:DoAnim("punch")
	end
	ply:EmitSound("WeaponFrag.Throw")
	timer.Simple(.33,function()
		if self:IsValid() then
			local tr = FindTarget(self,200)
			local hitEnt = tr.Entity
			if damage >= 99999 then
				if !tr.Hit then
					local dir = ply:GetAimVector()
					local pos = tr.HitPos
					for i=0,15 do
						tr = util.TraceLine{
							start = pos,
							endpos = pos + dir*100,
							filter = ply,
						}
						pos = tr.HitPos
						if tr.Hit then
							CreateExplosion(tr.HitPos,1200,1500,ply,self)
							hitEnt = tr.Entity
						else
							CreateExplosion(pos,100,50,ply,self)
						end
					end
				else
					CreateExplosion(tr.HitPos,1200,1500,ply,self)
				end
			end
			if tr.Hit then
				ply:EmitSound("Flesh.ImpactHard")
			end
			if IsValid(hitEnt) then
				local dmg = DamageInfo()
				dmg:SetDamage(DMG_CLUB)
				dmg:SetAttacker(ply)
				dmg:SetInflictor(self)
				dmg:SetDamageForce(ply:GetRight()*4912+ply:GetForward()*9998)
				dmg:SetDamage(damage)
				hitEnt:TakeDamageInfo(dmg)
				
				if hitEnt:IsValid() and (hitEnt:IsPlayer() or hitEnt:IsNPC()) and hitEnt:Health() <= 0 and damage >= 99999 and (!hitEnt.GetBloodColor or hitEnt:GetBloodColor() != DONT_BLEED) then
					local dir = ply:GetAimVector()
					dir.z = 0
					GoreExplodeEffect(hitEnt,dir,5000)
					if hitEnt:IsPlayer() then
						if IsValid(hitEnt:GetRagdollEntity()) then
							hitEnt:GetRagdollEntity():Remove()
						end
					else
						hitEnt:Remove()
					end
				end
				
				if hitEnt:IsValid() then
					if hitEnt:GetClass() == "func_door" or hitEnt:GetClass() == "prop_door_rotating" then
						for k,v in ipairs(ents.FindByName(hitEnt:GetName())) do
							v:Fire("Open")
						end
					else
						local phys = hitEnt:GetPhysicsObject()
						if phys:IsValid() then
							phys:ApplyForceOffset(ply:GetAimVector()*80*(phys:GetMass() or 1),tr.HitPos)
						end
					end
				end
			end
			if callback then
				callback(tr)
			end
		end
	end)
end

function SWEP:HasStone(stoneID)
	if stoneID == 7 then
		for i=1,6 do
			if !self:HasStone(i) then return false end
		end
		return true
	end
	if stoneID == IG_STONE_SOUL then
		return self:GetHasSoulStone()
	end
	if stoneID == IG_STONE_POWER then
		return self:GetHasPowerStone()
	end
	if stoneID == IG_STONE_REALITY then
		return self:GetHasRealityStone()
	end
	if stoneID == IG_STONE_TIME then
		return self:GetHasTimeStone()
	end
	if stoneID == IG_STONE_MIND then
		return self:GetHasMindStone()
	end
	if stoneID == IG_STONE_SPACE then
		return self:GetHasSpaceStone()
	end
end

function SWEP:SetHasStone(stoneID,bool)
	if stoneID == IG_STONE_SOUL then
		self:SetHasSoulStone(bool)
		return
	end
	if stoneID == IG_STONE_POWER then
		self:SetHasPowerStone(bool)
		return
	end
	if stoneID == IG_STONE_REALITY then
		self:SetHasRealityStone(bool)
		return
	end
	if stoneID == IG_STONE_TIME then
		self:SetHasTimeStone(bool)
		return
	end
	if stoneID == IG_STONE_MIND then
		self:SetHasMindStone(bool)
		return
	end
	if stoneID == IG_STONE_SPACE then
		self:SetHasSpaceStone(bool)
		return
	end
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	if vm:IsValid() then
		self:SetNextIdle(CurTime()+vm:SequenceDuration()/vm:GetPlaybackRate())
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float",0,"NextIdle")
	self:NetworkVar("Bool",0,"HasPowerStone")
	self:NetworkVar("Bool",1,"HasSpaceStone")
	self:NetworkVar("Bool",2,"HasRealityStone")
	self:NetworkVar("Bool",3,"HasTimeStone")
	self:NetworkVar("Bool",4,"HasSoulStone")
	self:NetworkVar("Bool",5,"HasMindStone")
end

function SWEP:Think()
	local vm = self.Owner:GetViewModel()
	if vm:IsValid() then
		local idleTime = self:GetNextIdle() or 0
		if idleTime > 0 and CurTime() > idleTime then
			self:DoAnim(UsingOldModel() and "fists_idle_0"..math.random(1,2) or "idle")
		end
	end
	
	if CLIENT then
		self:UpdateAppearence()
		
		if self.stoneSpinnerDisplay then
			if !LocalPlayer():KeyDown(IN_RELOAD) then
				self.stoneSpinnerDisplay = false
				gui.EnableScreenClicker(false)
				surface.PlaySound("garrysmod/ui_hover.wav")
				net.Start("IG_SelectedStone")
				net.WriteUInt(self.selectedStone,4)
				net.SendToServer()
			end
		end
		if self.stoneAbilityDisplay then
			if !input.IsMouseDown(MOUSE_RIGHT) then
				self:StopSelectingAbility()
			end
		end
		if (!LocalPlayer():KeyDown(IN_ATTACK) and !input.IsMouseDown(MOUSE_LEFT)) and table.Count(self.channelingStones) > 0 then
			for k,v in pairs(self.channelingBinds) do
				if self.selectedStone == v[1] and self.selectedAbility == v[2] then
					return
				end
			end
			for k,v in pairs(self.channelingStones) do
				local cont = false
				for l,i in pairs(self.channelingBinds) do
					if i[1] == k then
						cont = true
						break
					end
				end
				if cont then continue end
				
				net.Start("IG_StopChanneling")
				net.WriteUInt(k,4)
				net.SendToServer()
				self.channelingStones[k] = nil
			end
		end
	else
		for k,v in pairs(self.channelingStones) do
			local stoneData = IG_StoneData[k]
			local abilityData = stoneData.abilities[v.id]
			if abilityData.Channel then
				abilityData.Channel(self,v.data,abilityData)
			end
		end
	end
end

local seenOptions = false
function SWEP:Deploy()
	self:SetHoldType(self.HoldType)
	self:SetDeploySpeed(999)
	if !self.hasDeployed then
		if !self.noStonesCreated then
			for i=1,6 do
				self:SetHasStone(i,true)
			end
		end
		self:DoAnim(UsingOldModel() and "idle" or "deploy")
		if !seenOptions then
			seenOptions = true
			self.Owner:ChatPrint("Check the options tab in the spawnmenu to adjust Infinity Gauntlet settings.")
		end
		self.hasDeployed = true
	else
		self:SendWeaponAnim(ACT_VM_IDLE) --Avoid attack delay
		self:DoAnim(UsingOldModel() and "idle" or "deploy_quick")
	end
end

function SWEP:CanPrimaryAttack() return true end

function SWEP:OnRemove()
	self:Holster()
end

/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
********************************************************/

function SWEP:Initialize()
	self.channelingStones = {}
	self.stoneLastSelectedAbilities = {}
	self.selectedAbility = 1
	self.selectedStone = 1
	
	if CLIENT then
		self.abilityBindings = {}
		for k,v in pairs(IG_StoneData) do
			self.abilityBindings[k] = {}
		end
		self.boundNumbers = {}
		self.channelingBinds = {}
		self.VElements = table.FullCopy(self.VElements)
		self.WElements = table.FullCopy(self.WElements)
		self.ViewModelBoneMods = UsingOldModel() and table.FullCopy(self.ViewModelBoneMods) or {}
		self:CreateModels(self.VElements)
		self:CreateModels(self.WElements)
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					vm:SetColor(Color(255,255,255,1))
					vm:SetMaterial("Debug/hsv")
				end
			end
		end
		
	end
end

function SWEP:Holster()
	if SERVER and self.Owner:IsValid() then
		for k,v in pairs(self.channelingStones) do
			self:StopChannelingStone(k)
		end
	end
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end
