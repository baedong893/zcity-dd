AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:BeamHit(tr)
	local target = tr.Entity
	if target and target:IsValid() then
		local dmg = DamageInfo()
		dmg:SetDamage(20)
		dmg:SetDamageForce((tr.HitPos-target:GetPos()+target:OBBCenter()):GetNormalized()*-70)
		dmg:SetDamageType(DMG_GENERIC)
		dmg:SetAttacker(self:GetOwner())
		dmg:SetInflictor(self:GetOwner():GetActiveWeapon():IsValid() and self:GetOwner():GetActiveWeapon() or self)
		target:TakeDamageInfo(dmg)
		
		local velocity = (target:GetPos()-self:GetStartPos()):GetNormalized()*1500
		if target:IsPlayer() or target:IsNPC() then
			target:SetLocalVelocity(velocity)
		elseif target:GetPhysicsObject():IsValid() then
			target:GetPhysicsObject():AddVelocity(velocity)
		end
		
	end
end
