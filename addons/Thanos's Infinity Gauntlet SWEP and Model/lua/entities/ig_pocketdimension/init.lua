AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:DrawShadow(false)
	self.walls = {}
end

function ENT:AddWall(ent)
	self.walls[#self.walls+1] = ent
	ent:SetPocketDimension(self)
end

local noRemoveEnts = {
	predicted_viewmodel = false,
}

function ENT:OnRemove()
	for k,v in ipairs(self.walls) do
		if v:IsValid() then
			v:Remove()
		end
	end
	for k,v in ipairs(ents.GetAll()) do
		if v:IsValid() and noRemoveEnts[v:GetClass()] != false and (!v:IsWeapon() or !v:GetParent():IsValid()) and self:PositionInside(v:GetPos()) then
			if v:IsPlayer() then
				v:KillSilent()
			else
				v:Remove()
			end
		end
	end
end

