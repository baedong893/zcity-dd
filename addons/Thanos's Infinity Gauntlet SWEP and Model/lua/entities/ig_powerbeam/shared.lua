ENT.Type 		= "anim"
ENT.Base 		= "ig_base_beam"
ENT.PrintName 	= "Power Beam"
ENT.Name 		= "Power Beam"
ENT.Spawnable 	= false

ENT.decalColor = Color(88,14,117)
ENT.beamColor = Color(255,0,255)
ENT.stoneChanneler = IG_STONE_POWER

if SERVER then return end

function ENT:DrawBeam(tr,startPos,endPos)
	self.BaseClass.DrawBeam(self,tr,startPos,endPos)
	
	if self.nextDecal > CurTime() then return end
	util.Decal("Scorch",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal,self:GetOwner())
	self.nextDecal = CurTime()+.05
end
