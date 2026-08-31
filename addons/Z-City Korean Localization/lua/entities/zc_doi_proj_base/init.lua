AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model or "models/Items/grenadeAmmo.mdl")
	self:PhysicsInitSphere(self.SphereSize or 4, self.PhysMat or "grenade")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(self.CollisionGroup or COLLISION_GROUP_PROJECTILE)
	self.SpawnTime = CurTime()
	self.Boost = self.Boost or 1
	self.SmokeTrailTime = self.SmokeTrailTime or 0

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(5)
	end

	if self.LifeTime and self.LifeTime > 0 then
		timer.Simple(self.LifeTime, function()
			if IsValid(self) and not self.Defused then
				self.LastHitNormal = self.LastHitNormal or vector_up
				if self.Detonate then self:Detonate({HitNormal = vector_up}) else SafeRemoveEntity(self) end
			end
		end)
	end
end

function ENT:PhysicsCollide(data, phys)
	self.HitVelocity = data.OurOldVelocity
	self.LastHitNormal = data.HitNormal

	if self.ExplodeOnImpact and (CurTime() - (self.SpawnTime or 0)) >= (self.FuseTime or 0) then
		if self.Detonate then
			self:Detonate(data)
		else
			SafeRemoveEntity(self)
		end
		return
	end

	local snd = istable(self.BounceSounds) and self.BounceSounds[math.random(#self.BounceSounds)] or self.BounceSound
	if snd and data.Speed > 80 then self:EmitSound(snd, 65, 100, 0.7) end
end

function ENT:Defuse()
	self.Defused = true
	SafeRemoveEntity(self)
end
