ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName 	= "Beam"
ENT.Name 		= "Beam"
ENT.Spawnable 	= false

ENT.decalColor = Color(255,255,255)
ENT.beamColor = Color(255,255,255)
ENT.stoneChanneler = IG_STONE_INFINITY
ENT.decalSize = 64
ENT.beamMat = Material("sprites/tp_beam001")
ENT.decalMat = Material("particle/particle_glow_05")

function ENT:GetStartPos()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local ang = owner:EyeAngles()
		return (owner:EyePos()+owner:GetAimVector()*10-ang:Right()*5-ang:Up()*3)
	end
	return self:GetPos()
end

function ENT:GetBeamTrace()
	local startPos = self:GetStartPos()
	return util.TraceLine{
		start = startPos,
		endpos = startPos+(self:GetOwner():IsValid() and self:GetOwner():GetAimVector() or self:GetAngles():Forward())*999999,
		filter = {self,self:GetOwner()},
	}
end

function ENT:GetBeamLightTrace()
	local startPos = self:GetStartPos()
	return util.TraceLine{
		start = startPos,
		endpos = startPos+(self:GetOwner():IsValid() and self:GetOwner():GetAimVector() or self:GetAngles():Forward())*999999,
		filter = {self,self:GetOwner()},
	}
end

if SERVER then return end

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawBeam(tr,startPos,endPos)
	render.DrawBeam(startPos,endPos,5,0,100*tr.Fraction,self.beamColor)
end

function ENT:DrawLight(tr,startPos,endPos)
	local count = math.Clamp(startPos:Distance(endPos)/100,5,15)
	
	for i=0,count do
		local pos = LerpVector(i/count,startPos,endPos)
		local light = DynamicLight(self:EntIndex()*51+i)
		if light then
			light.pos = pos
			light.r = self.beamColor.r
			light.g = self.beamColor.g
			light.b = self.beamColor.b
			light.brightness = 2
			light.decay = 1000
			light.size = 200
			light.dietime = CurTime() + 1
		end
	end
end

function ENT:Initialize()
	local bounds = Vector(99999,99999,99999)
	self:SetRenderBounds(-bounds,bounds)
	self.nextDecal = 0
end

function ENT:Draw()
	local startPos = self:GetStartPos()
	local tr = self:GetBeamTrace()
	local endPos = tr.HitPos
	if LocalPlayer():GetViewEntity() != self:GetOwner() and self:GetOwner():IsValid() then
		local wep = self:GetOwner():GetWeapon("infinitygauntlet")
		if wep:IsValid() and wep.WElements then
			local v = wep.WElements.powerstone_glow
			local pos,ang = wep:GetBoneOrientation(wep.WElements, v,self:GetOwner())
			startPos = (pos + ang:Forward() * v.pos.x*.1 + ang:Right() * v.pos.y*-1 + ang:Up() * v.pos.z)
		end
	end
	local lightTrace = self:GetBeamLightTrace()
	self:DrawLight(lightTrace,startPos,lightTrace.HitPos)
	
	render.SetMaterial(self.beamMat)
	self:DrawBeam(tr,startPos,endPos)
	render.SetMaterial(self.decalMat)
	render.DrawSprite(endPos,self.decalSize,self.decalSize,self.decalColor)
	render.DrawSprite(startPos,self.decalSize/4,self.decalSize/4,self.decalColor)
end
