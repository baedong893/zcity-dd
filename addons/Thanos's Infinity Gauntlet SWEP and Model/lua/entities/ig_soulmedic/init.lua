AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Think()
	if !self.npc:IsValid() or self.dieTime < CurTime() then
		self:Remove()
		return
	end
	
	if self.nextAttack > CurTime() then return end
	self.nextAttack = CurTime()+1
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),500)) do
		if v:IsPlayer() and v:HasInfinityStone(IG_STONE_SOUL) and v:Alive() then
			v:SetHealth(math.min(100,v:Health()+10))
		end
	end
end
