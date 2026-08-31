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
	local ply = self:GetOwner()
	if !ply:IsValid() or !ply:GetWeapon("infinitygauntlet"):IsValid() or !ply:GetWeapon("infinitygauntlet"):IsChannelingStone(IG_STONE_POWER) then
		self:Remove()
		return
	end
	
	for k,v in ipairs(ents.FindInSphere(self:GetStormPosition(),self:GetRadius())) do
		if v:IsValid() and v != ply and !v:IsWeapon() and (v:GetPhysicsObject():IsValid() or v:IsNPC() or (v:IsPlayer() and v:Alive())) and !v:GetModel():find("*") then
			local dmg = DamageInfo()
			dmg:SetDamage(math.random(10,20))
			dmg:SetDamageType(DMG_DISSOLVE)
			dmg:SetAttacker(ply)
			dmg:SetInflictor(self)
			v:TakeDamageInfo(dmg)
			v:Ignite(30)
			local ef = EffectData()
			ef:SetOrigin(v:GetPos()+v:OBBCenter()+VectorRand()*((v:GetModelRadius() or 50)/2))
			util.Effect("ig_energystorm_hit",ef,true,true)
			v:EmitSound("xyz/infinitygauntlet/shield_impact.wav")
		end
	end
end
