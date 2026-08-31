include("shared.lua")

function ENT:Initialize()
	local bound = Vector(9999,9999,9999)
	self:SetRenderBounds(-bound,bound)
end

local Rand = math.Rand

local mat = Material("sprites/tp_beam001")
function ENT:Draw()
	self.BaseClass.Draw(self)
	local pos = self:GetPos()+self:OBBCenter()
	for k,ent in ipairs(ents.FindInSphere(self:GetPos(),500)) do
		if ent:HasInfinityStone(IG_STONE_SOUL) then
			render.SetMaterial(mat)
			render.DrawBeam(pos,ent:GetPos()+ent:OBBCenter(),5,0,0,IG_StoneData[IG_STONE_SOUL].color)
		end
	end
end

