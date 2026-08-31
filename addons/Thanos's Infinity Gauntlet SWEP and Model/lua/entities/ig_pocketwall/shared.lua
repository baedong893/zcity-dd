ENT.Type 		= "anim"
ENT.Base 		= "base_gmodentity"
ENT.Category 	= "XYZ"
ENT.PrintName 	= "Pocket Dimension Wall"
ENT.Author    	= "Xyz"
ENT.Spawnable 	= true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Width")
	self:NetworkVar("Int",1,"Length")
	self:NetworkVar("Int",2,"Height")
	self:NetworkVar("Entity",0,"PocketDimension")
end

function ENT:GetWallBounds()
	return Vector(self:GetWidth()/2,self:GetLength()/2,self:GetHeight()/2)
end
