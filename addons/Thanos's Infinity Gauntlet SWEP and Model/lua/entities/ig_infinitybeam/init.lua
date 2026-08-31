AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:BeamHit(tr)
	local target = tr.Entity
	if target and target:IsValid() then
		local ef = EffectData()
		local mins,maxs = target:OBBMins(),target:OBBMaxs()
		mins:Rotate(target:GetAngles())
		maxs:Rotate(target:GetAngles())
		ef:SetOrigin(target:GetPos()+mins)
		ef:SetStart(target:GetPos()+maxs)
		ef:SetRadius(target:GetModelRadius() or 50)
		ef:SetAngles(Angle(255,255,255))
		util.Effect("ig_plasmad",ef,true,true)
		if target:IsPlayer() then
			target:KillSilent()
		else
			target:Remove()
		end
	end
end
