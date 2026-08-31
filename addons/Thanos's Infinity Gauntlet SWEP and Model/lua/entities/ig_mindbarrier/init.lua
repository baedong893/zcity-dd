AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.maxHealth = 99999
ENT.hp = ENT.maxHealth

function ENT:Initialize()
	self:DrawShadow(false)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(99999)
		phys:EnableGravity(false)
	end
	self:SetRadius(self.radius)
	self.hp = maxHealth
end

function ENT:Think()
	local owner = self:GetOwner()
	if !owner:IsValid() or !owner:GetWeapon("infinitygauntlet"):IsValid() or !owner:GetWeapon("infinitygauntlet"):IsChannelingStone(IG_STONE_MIND) then
		self:Remove()
		return
	end
	self.hp = math.min(self.maxHealth,(self.hp or self.maxHealth)+10)
	owner.IG_MindShield = self
	local pos = self:GetPos()
	local goodDist = (self:GetRadius()*3)^2
	for k,v in ipairs(ents.FindInSphere(pos,self:GetRadius()*1.2)) do
		if v != self and v != owner and (v:IsPlayer() or v:GetPhysicsObject():IsValid()) then
			local dir = ((pos-v:GetPos()):GetNormal()*-(1500*(goodDist/pos:DistToSqr(v:GetPos()))))
			
			if v:IsPlayer() or v:IsNPC() then
				v:SetLocalVelocity(dir+Vector(0,0,1500))
			else
				v:GetPhysicsObject():SetVelocity(dir)
			end
		end
	end
end

hook.Add("EntityTakeDamage","IG_MindShieldAbsorb",function(ent,dmg)
	if ent.IG_MindShield and ent.IG_MindShield:IsValid() then
		if ent.IG_MindShield.hp > 0 then
			ent.IG_MindShield.hp = ent.IG_MindShield.hp - dmg:GetDamage()
			return true
		end
	end
end)
