AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetStartTime(CurTime())
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:DisintigrateEntity(ent)
	local ef = EffectData()
	local mins,maxs = ent:OBBMins(),ent:OBBMaxs()
	mins:Rotate(ent:GetAngles())
	maxs:Rotate(ent:GetAngles())
	ef:SetOrigin(ent:GetPos()+mins)
	ef:SetStart(ent:GetPos()+maxs)
	ef:SetRadius(ent:GetModelRadius() or 50)
	ef:SetAngles(Angle(104,26,150))
	util.Effect("ig_plasmad",ef,true,true)
	if ent:IsPlayer() then
		ent:KillSilent()
	else
		ent:Remove()
	end
end

function ENT:Think()
	local percent = self:GetPercent()
	if percent >= .7 then
		if percent >= 1 then
			self:Remove()
		end
		return
	end
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self:GetRadius())) do--SetSolidMask tests if it's a nextbot
		if v:IsValid() and v:GetClass() != "ig_worldsunder" and v != self:GetOwner() and ((v:IsPlayer() and v:Alive()) or v:IsNPC() or v.SetSolidMask or (!v:IsPlayer() and v:GetPhysicsObject():IsValid())) and !v:HasInfinityStone(IG_STONE_POWER) and !v.isBlackHole then
			self:DisintigrateEntity(v)
		end
	end
	self:NextThink(CurTime()+1)
	return true
end
