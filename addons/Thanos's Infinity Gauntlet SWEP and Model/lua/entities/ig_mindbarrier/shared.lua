ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName 	= "Mind Barrier"
ENT.Name 		= "Mind Barrier"
ENT.Spawnable 	= false
ENT.radius = 100

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Radius")
end

hook.Add("EntityFireBullets","IG_MindShieldIntercept",function(ent,data)
	for k,v in ipairs(ents.FindByClass("ig_mindbarrier")) do
		local hitPos = IG_RayIntersectSphere(data.Src,data.Dir,v:GetPos(),v:GetRadius())
		if hitPos then
			local ef = EffectData()
			ef:SetOrigin(hitPos)
			ef:SetNormal(data.Dir)
			util.Effect("ig_shieldshot",ef,true,true)
			sound.Play("xyz/infinitygauntlet/shield_impact.wav",hitPos,150,math.random(90,110),1)--math.Rand(.7,1))
			data.Distance = data.Src:Distance(hitPos)
			return true
		end
	end
end)

if SERVER then return end

function ENT:Initialize()
	local bounds = Vector(self.radius,self.radius,self.radius)*3
	self:SetRenderBounds(-bounds,bounds)
	self:SetRadius(self.radius)
end

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local sphereMat = Material("xyz/effects/infinitygauntlet/magicglow")
local matColor = Color(140,5,0)
local color = Color(241,144,19,50)
function ENT:Draw()
	local owner = self:GetOwner()
	local pos = self:GetPos()
	if owner:IsValid() then
		pos = owner:GetPos()+owner:OBBCenter()
	end
	render.SetMaterial(sphereMat)
	render.DrawSphere(pos,-self:GetRadius(),50,50,matColor)
	for i=0,5 do
		render.DrawSphere(pos,self:GetRadius()-i*10,50,50,matColor)
	end
	render.SetColorMaterial()
	render.DrawSphere(pos,-self:GetRadius(),50,50,color)
	for i=0,5 do
		render.DrawSphere(pos,self:GetRadius()-i*10,50,50,color)
	end
end
