AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:Initialize()
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:DrawShadow(false)
end

function ENT:Think()
	if !self:GetOwner():IsValid() or !self:GetOwner():GetWeapon("infinitygauntlet"):IsValid() or !self:GetOwner():GetWeapon("infinitygauntlet"):IsChannelingStone(self.stoneChanneler) then
		self:Remove()
		return
	end
	self:BeamHit(self:GetBeamTrace())
end

function ENT:BeamHit(tr) end
