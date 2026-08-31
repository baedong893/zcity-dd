AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:BeamHit(tr)
	local target = tr.Entity
	if target and target:IsValid() then
		target:Ignite(50)
		local dmg = DamageInfo()
		dmg:SetDamage(50)
		dmg:SetDamageForce((tr.HitPos-target:GetPos()+target:OBBCenter()):GetNormalized()*-70)
		dmg:SetDamageType(DMG_ENERGYBEAM)
		dmg:SetAttacker(self:GetOwner())
		dmg:SetInflictor(self:GetOwner():GetActiveWeapon():IsValid() and self:GetOwner():GetActiveWeapon() or self)
		target:TakeDamageInfo(dmg)
	end
end
