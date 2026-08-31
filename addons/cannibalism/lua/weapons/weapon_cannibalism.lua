if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Cannibalism"
SWEP.Instructions = "yum"
SWEP.Category = "Other"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 1
SWEP.SlotPos = 4

SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.UseHands = false
SWEP.ViewModelFOV = 60

SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.HoldType = "normal"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Delay = 0.16

local CLEANUP_RADIUS = 180
local CLEANUP_RADIUS_SQR = CLEANUP_RADIUS * CLEANUP_RADIUS
local CLEANUP_NET = "ZC_CannibalCleanRemains"
local CANNIBAL_STAGE_KEY = "ZC_CannibalStage"

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	self:SetHoldType(self.HoldType)
	return true
end

function SWEP:SecondaryAttack()
end

if SERVER then
	util.AddNetworkString(CLEANUP_NET)

    local npc = CreateConVar("cannibalism_npc", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED})

    local function IsCorpse(ent)
		if not IsValid(ent) or not ent:IsRagdoll() then return false end

		local owner = hg and hg.RagdollOwner and hg.RagdollOwner(ent) or ent:GetNWEntity("OldRagdollController")
		if IsValid(owner) and owner:IsPlayer() and owner:Alive() then return false end

		if not IsValid(owner) and not npc:GetBool() then return false end
        
        return true
    end

	local function IsBiologicalDebris(ent)
		if not IsValid(ent) then return false end
		local class = ent:GetClass()
		if class ~= "prop_physics" and class ~= "prop_dynamic" then return false end

		local model = string.lower(ent:GetModel() or "")
		if model == "models/gleb/zcity/headboom.mdl" then return true end
		if string.find(model, "models/gibs/hgibs", 1, true) then return true end
		if string.find(model, "models/gibs/flesh", 1, true) then return true end

		if model == "models/props_junk/watermelon01_chunk02a.mdl" then
			local material = string.lower(ent:GetMaterial() or "")
			local subMaterial = string.lower(ent:GetSubMaterial(0) or "")
			return string.find(material, "flesh", 1, true) ~= nil or string.find(subMaterial, "flesh", 1, true) ~= nil
		end

		return false
	end

	local function ConsumeSkeleton(rag)
		local pos = rag:WorldSpaceCenter()

		for _, ent in ipairs(ents.FindInSphere(pos, CLEANUP_RADIUS)) do
			if ent ~= rag and IsBiologicalDebris(ent) then
				SafeRemoveEntity(ent)
			end
		end

		net.Start(CLEANUP_NET)
			net.WriteVector(pos)
		net.Broadcast()

		SafeRemoveEntity(rag)
	end


	function SWEP:PrimaryAttack()
		self:SetNextPrimaryFire(CurTime() + self.Delay)

		local ply = self:GetOwner()
		if not IsValid(ply) then return end

		local eyeAtt = ply:GetAttachment(ply:LookupAttachment("eyes"))
		local startPos = eyeAtt and eyeAtt.Pos or ply:EyePos()

		local tr = util.TraceLine({
			start = startPos,
			endpos = startPos + ply:GetAimVector() * 100,
			filter = ply,
		})

		local rag = tr.Entity
		if not IsCorpse(rag) then return end

		if (rag.CannibalismStage or 0) >= 3 then
			ConsumeSkeleton(rag)
			ply:EmitSound("npc/barnacle/barnacle_crunch2.wav", 100, 85)
			return
		end

		rag.CannibalismStage = (rag.CannibalismStage or 0) + 1
		local stage = rag.CannibalismStage
		rag:SetNWInt(CANNIBAL_STAGE_KEY, stage)

		if stage == 1 then
			rag:SetMaterial("models/flesh")
		elseif stage == 2 then
			rag:SetMaterial("")
		elseif stage == 3 then
			rag:SetMaterial("")
		end

		ply:EmitSound("npc/barnacle/barnacle_crunch2.wav", 100, 100)

		ply:SetHealth(math.min(ply:Health() + 20, ply:GetMaxHealth()))
	end
else
	-- Keep the real corpse entity, physics, inventory and Z-City references intact.
	-- Only its clientside appearance changes, bone-merged to the existing corpse.
	if ZC_CannibalVisuals then
		for rag, data in pairs(ZC_CannibalVisuals) do
			if IsValid(data.model) then data.model:Remove() end
			if IsValid(rag) then
				rag:SetNoDraw(false)
				rag:DrawShadow(true)
			end
		end
	end

	ZC_CannibalVisuals = {}
	local cannibalVisuals = ZC_CannibalVisuals
	local stageModels = {
		[2] = "models/zombie/fast.mdl",
		[3] = "models/player/skeleton.mdl",
	}

	local function ClearCannibalVisual(rag)
		local data = cannibalVisuals[rag]
		if data and IsValid(data.model) then data.model:Remove() end
		cannibalVisuals[rag] = nil

		if IsValid(rag) then
			rag:SetNoDraw(false)
			rag:DrawShadow(true)
		end
	end

	local function UpdateCannibalVisual(rag, stage)
		if not IsValid(rag) or rag:GetClass() ~= "prop_ragdoll" then return end

		stage = tonumber(stage) or 0
		local modelPath = stageModels[stage]
		if not modelPath then
			ClearCannibalVisual(rag)
			return
		end

		local old = cannibalVisuals[rag]
		if old and old.stage == stage and IsValid(old.model) then return end
		ClearCannibalVisual(rag)

		local visual = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
		if not IsValid(visual) then return end

		visual:SetMoveType(MOVETYPE_NONE)
		visual:SetParent(rag)
		visual:SetLocalPos(vector_origin)
		visual:SetLocalAngles(angle_zero)
		visual:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES))
		visual:SetSkin(0)
		visual:SetNoDraw(false)
		visual:DrawShadow(true)

		rag:SetNoDraw(true)
		rag:DrawShadow(false)
		cannibalVisuals[rag] = {model = visual, stage = stage}
	end

	local function WatchCannibalCorpse(ent)
		if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" then return end

		ent:SetNWVarProxy(CANNIBAL_STAGE_KEY, function(rag, _, _, newStage)
			UpdateCannibalVisual(rag, newStage)
		end)

		timer.Simple(0, function()
			if IsValid(ent) then
				UpdateCannibalVisual(ent, ent:GetNWInt(CANNIBAL_STAGE_KEY, 0))
			end
		end)
	end

	hook.Add("NetworkEntityCreated", "ZC_CannibalWatchCorpse", WatchCannibalCorpse)
	hook.Add("EntityRemoved", "ZC_CannibalRemoveVisual", function(ent)
		local data = cannibalVisuals[ent]
		if data and IsValid(data.model) then data.model:Remove() end
		cannibalVisuals[ent] = nil
	end)

	timer.Simple(0, function()
		for _, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
			WatchCannibalCorpse(rag)
		end
	end)

	local function RemoveNearbyBloodParticles(particles, pos)
		if not istable(particles) then return end

		for index = #particles, 1, -1 do
			local particle = particles[index]
			local particlePos = istable(particle) and (isvector(particle[1]) and particle[1] or particle[2])
			if isvector(particlePos) and particlePos:DistToSqr(pos) <= CLEANUP_RADIUS_SQR then
				table.remove(particles, index)
			end
		end
	end

	net.Receive(CLEANUP_NET, function()
		local pos = net.ReadVector()
		if hg then
			RemoveNearbyBloodParticles(hg.bloodparticles1, pos)
			RemoveNearbyBloodParticles(hg.bloodparticles2, pos)
		end

		for _, ent in ipairs(ents.FindInSphere(pos, CLEANUP_RADIUS)) do
			if IsValid(ent) and ent.RemoveAllDecals then
				ent:RemoveAllDecals()
			end
		end
	end)

	function SWEP:PrimaryAttack()
		self:SetNextPrimaryFire(CurTime() + self.Delay)
	end
end
