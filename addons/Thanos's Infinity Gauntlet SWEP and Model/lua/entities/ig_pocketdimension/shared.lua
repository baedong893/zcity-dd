ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName 	= "Pocket Dimension"
ENT.Name 		= "Pocket Dimension"
ENT.Spawnable 	= false

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Width")
	self:NetworkVar("Int",1,"Length")
	self:NetworkVar("Int",2,"Height")
end

function ENT:GetPocketBounds()
	return Vector(self:GetWidth()/2,self:GetLength()/2,self:GetHeight()/2)
end

function ENT:PositionInside(pos)
	local bounds = self:GetPocketBounds()
	return pos:WithinAABox(self:GetPos()-bounds,self:GetPos()+bounds)
end

if SERVER then return end

local function GetEyePos()
	return EyePos()
end

function ENT:Initialize()
	local bounds = self:GetPocketBounds()
	self:SetRenderBounds(-bounds,bounds)
end

function ENT:Draw()
end

function ENT:ShouldRenderInterior()
	return self:PositionInside(GetEyePos())
end

hook.Add("PreRender","IG_PreRenderPocketEnts",function()
	for k,pocket in ipairs(ents.FindByClass("ig_pocketdimension")) do
		if pocket:ShouldRenderInterior() then continue end
		for o,ent in ipairs(ents.GetAll()) do
			if !ent.ig_pocketRenderingMode and ent != pocket and ent:GetClass() != "ig_pocketwall" and pocket:PositionInside(ent:GetPos()) then
				ent.ig_pocketRenderingMode = true
				local prevRender = ent.RenderOverride
				ent.RenderOverride = function(self)
					if !pocket:IsValid() or !pocket:PositionInside(self:GetPos()) or pocket:ShouldRenderInterior() then
						self.RenderOverride = prevRender
						self.ig_pocketRenderingMode = nil
						return
					end
				end
			end
		end
	end
end)

hook.Add("PreDrawTranslucentRenderables","IG_CatchPocketEyePos",function()
	EyePos()
end)
