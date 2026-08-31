AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:DrawShadow(false)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity(false)
	end
	self.dieTime = CurTime()+60
	self:SetRadius(50)
end

function ENT:DisintigrateEntity(ent)
	local ef = EffectData()
	local mins,maxs = ent:OBBMins(),ent:OBBMaxs()
	mins:Rotate(ent:GetAngles())
	maxs:Rotate(ent:GetAngles())
	ef:SetOrigin(ent:GetPos()+mins)
	ef:SetStart(ent:GetPos()+maxs)
	ef:SetRadius(ent:GetModelRadius())
	ef:SetAngles(Angle(104,26,150))
	util.Effect("ig_plasmad",ef,true,true)
	if ent:IsPlayer() then
		ent:KillSilent()
	else
		ent:Remove()
	end
end

function ENT:PhysicsCollide(data)
	timer.Simple(0,function()
		if self:IsValid() then
			self:Remove()
		end
	end)
end

function ENT:OnRemove()
	local ef = EffectData()
	ef:SetOrigin(self:GetPos())
	ef:SetScale(600)
	util.Effect("ig_explosion",ef,true,true)
	local ef = EffectData()
	ef:SetMagnitude(50)
	ef:SetOrigin(self:GetPos())
	util.Effect("Explosion",ef,true,true)
	util.BlastDamage(self,self:GetOwner():IsValid() and self:GetOwner() or self,self:GetPos(),self:GetRadius()*3,90)
end

function ENT:Think(ent)
	if !self.velocity then
		self.velocity = self:GetVelocity()
	end
	if self.dieTime < CurTime() then self:Remove() return end
	self:SetRadius(self:GetRadius()+1)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetVelocity(self.velocity)
	end
	
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self:GetRadius()*2)) do
		if v == self:GetOwner() or v:GetNoDraw() or v == self or (v:IsPlayer() and !v:Alive()) or v:Health() <= 0 or v.isBlackHole then continue end
		self:DisintigrateEntity(v)
	end
end

