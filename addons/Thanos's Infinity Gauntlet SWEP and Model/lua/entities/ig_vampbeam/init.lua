AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:BeamHit(tr)
	local target = tr.Entity
	if target and target:IsValid() and (target:IsNPC() or target:IsPlayer()) and target:Health() > 0 and target:IG_HasSoul() then
		local dmg = DamageInfo()
		dmg:SetDamage(15)
		dmg:SetDamageForce((tr.HitPos-target:GetPos()+target:OBBCenter()):GetNormalized()*-70)
		dmg:SetDamageType(DMG_GENERIC)
		dmg:SetAttacker(self:GetOwner())
		dmg:SetInflictor(self:GetOwner():GetActiveWeapon():IsValid() and self:GetOwner():GetActiveWeapon() or self)
		target:TakeDamageInfo(dmg)
		
		local owner = self:GetOwner()
		owner:SetHealth(self:GetOwner():Health()+15)
		
		owner:IG_EnableEffect("soulstone_glow",true)
		timer.Create("IG_RemoveSoulStoneGlow"..owner:EntIndex(),1,1,function()
			if owner:IsValid() then
				owner:IG_EnableEffect("soulstone_glow",false)
			end
		end)
		
		target:IG_EnableEffect("soulstone_glow",true)
		timer.Create("IG_RemoveSoulStoneGlow"..target:EntIndex(),1,1,function()
			if target:IsValid() then
				target:IG_EnableEffect("soulstone_glow",false)
			end
		end)
	end
end
