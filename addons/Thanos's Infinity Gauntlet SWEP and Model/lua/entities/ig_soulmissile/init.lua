AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.damage = 100

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.dieTime = CurTime()+99999
	self.isKeyDown = {}
end

function ENT:SetDriver(ply)
	self:SetOwner(ply)
	ply:DeleteOnRemove(self)
	ply:SetNWEntity("IG_MindMissile",self)
end

function ENT:StopDriver()
	local ply = self:GetOwner()
	if !ply:IsValid() or !ply:IsPlayer() then return end
	ply:TransferInput(false)
end

function ENT:OnRemove()
	self:StopDriver()
end

function ENT:KeyDown(key)
	return self.isKeyDown[key]
end

function ENT:Think()
	if self:KeyDown(IN_USE) or self.remove or (!IsValid(self:GetOwner()) or (self:GetOwner():IsPlayer() and !self:GetOwner():Alive())) or self.dieTime < CurTime() then
		self:Remove()
		return
	end
end

function ENT:PhysicsUpdate(phys)
	local ply = self:GetOwner()
	if !ply:IsValid() or !ply:IsPlayer() or !phys:IsValid() then return end
	if phys:IsGravityEnabled() then 
		phys:EnableGravity(false)
	end
	
	phys:AddVelocity(self:GetAngles():Forward()*30-phys:GetVelocity()*.02)
	local angleAdjustmentAng = self:WorldToLocalAngles(Angle(math.Clamp(ply:EyeAngles().p,-50,50),ply:EyeAngles().y,0))
	phys:AddAngleVelocity(-phys:GetAngleVelocity()+Vector(angleAdjustmentAng.r*30,angleAdjustmentAng.p*30,angleAdjustmentAng.y*30))
end

function ENT:PhysicsCollide(data)
	if self.remove then return end
	local hitEnt = data.HitEntity
	if hitEnt:IsValid() then
		hitEnt:TakeDamage(self.damage,self:GetOwner(),self)
	end
	self:StopDriver()
	SafeRemoveEntityDelayed(self,0)
end
