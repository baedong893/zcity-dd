ENT.Type 		= "anim"
ENT.Base 		= "ig_base_beam"
ENT.PrintName 	= "Infinity Beam"
ENT.Name 		= "Infinity Beam"
ENT.Spawnable 	= false

ENT.decalColor = Color(255,255,255)
ENT.beamColor = Color(255,255,255)
ENT.stoneChanneler = IG_STONE_INFINITY

function ENT:GetBeamTrace()
	local startPos = self:GetStartPos()
	return util.TraceLine{
		start = startPos,
		endpos = startPos+(self:GetOwner():IsValid() and self:GetOwner():GetAimVector() or self:GetAngles():Forward())*999999,
		filter = {self,self:GetOwner()},
		ignoreworld = true
	}
end

if SERVER then return end

local rainbow = {
	Color(255,255,255),
	Color(255,0,0),
	Color(255,0,255),
	Color(0,255,0)
}
function ENT:DrawBeam(tr,startPos,endPos)
	for i=1,#rainbow do
		render.DrawBeam(startPos,endPos,5+i,0,100*tr.Fraction,rainbow[i])
	end
end
