ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName 	= "Meteorite"
ENT.Name 		= "Meteorite"
ENT.Category = "XYZ"
ENT.Spawnable 	= true
ENT.explodeVelocity = 1500

function ENT:HasExplodeVelocity()
	return self:GetVelocity():Length() >= self.explodeVelocity
end

if SERVER then return end

ENT.nextParticles = 0

function ENT:Think()
	if self.nextParticles > CurTime() or !self:HasExplodeVelocity() then return end
	self.nextParticles = CurTime()+.1
	local pos = self:GetPos()
	
	local emitter = ParticleEmitter(pos)
	
	local part = emitter:Add("particle/smokesprites_000"..math.random(1,9),pos)
	part:SetGravity(Vector(math.random(-300,300),math.random(-300,300),math.random(5,1000)))
	part:SetAirResistance(300)
	part:SetStartSize(255)
	part:SetEndSize(0)
	part:SetStartAlpha(70)
	part:SetEndAlpha(0)
	part:SetRoll(math.random(0,360))
	part:SetRollDelta(math.Rand(-1,1))
	part:SetDieTime(math.Rand(6,12))
	part:SetColor(90,90,90)
	
	local part = emitter:Add("effects/muzzleflash"..math.random(1,4),pos)
	part:SetAirResistance(200)
	part:SetStartSize(300)
	part:SetEndSize(0)
	part:SetStartAlpha(255)
	part:SetEndAlpha(200)
	part:SetRoll(math.random(0,360))
	part:SetRollDelta(math.Rand(-1,1))
	part:SetDieTime(.1)
	
	for i=1,2 do
		local part = emitter:Add("sprites/flamelet4",pos+IG_RandomPointInSphere(self:GetModelRadius()*self:GetModelScale()))
		part:SetStartSize(20)
		part:SetEndSize(0)
		part:SetStartAlpha(255)
		part:SetEndAlpha(0)
		part:SetRoll(math.random(0,360))
		part:SetRollDelta(math.Rand(-1,1))
		part:SetDieTime(1)
	end
	
	emitter:Finish()
end
