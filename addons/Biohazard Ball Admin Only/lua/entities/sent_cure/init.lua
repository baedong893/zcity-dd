AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_bugbait.mdl")
	self:PrecacheGibs()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local Phys = self.Entity:GetPhysicsObject()
	if (Phys:IsValid()) then
		Phys:Wake()
	end
end

function ENT:PhysicsCollide(Data, PhysObj)
	local handled = hook.Run("ZC_CureImpact", self, Data.HitEntity, IsValid(self:GetOwner()) and self:GetOwner() or self.ZC_CureOwner)
	if handled then
		self.Entity:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(1, 4)..".wav", 100, 100)
		self:Remove()
		return
	end

	if (Data.HitEntity:IsValid() && (Data.HitEntity:IsPlayer() || Data.HitEntity:IsNPC())) then
		self:Cure(Data.HitEntity)
	end
	
	self.Entity:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(1, 4)..".wav", 100, 100)
	
	self:Remove()
end

function ENT:OnRemove( )	
end

function ENT:OnTakeDamage(DmgInfo)
end

function ENT:Think()
end


function ENT:Break()
	
end
