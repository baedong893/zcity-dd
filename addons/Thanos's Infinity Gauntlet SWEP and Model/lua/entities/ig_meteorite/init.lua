AddCSLuaFile("shared.lua")
include("shared.lua")

local models = {
	["models/props_wasteland/rockgranite02a.mdl"] = {},
	["models/props_wasteland/rockgranite02c.mdl"] = {},
}

function ENT:Initialize()
	local _,mdl = table.Random(models)
	self:SetModel(mdl)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local scaleRange = self:GetModelVar("scaleRange")
	if scaleRange then
		self:SetModelScale(math.Rand(scaleRange[1],scaleRange[2]))
		self:Activate()
	end
	self:SetAngles(AngleRand())
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(5000)
		phys:EnableDrag(false)
		phys:Wake()
	end
end

function ENT:GetModelVar(var)
	return models[self:GetModel()][var]
end

function ENT:PhysicsCollide(data)
	if data.Speed >= self.explodeVelocity and !self.destroy then
		self.destroy = true
		self.explode = data.Speed >= self.explodeVelocity
		self:SetNoDraw(true)
	end
end

function ENT:OnRemove()
	if self.explode then
		IG_CreateExplosion(self:GetPos(),900,500,self:GetOwner():IsValid() and self:GetOwner() or self,self)
	end
end

function ENT:Think()
	if self.destroy then
		self:Remove()
	end
end

