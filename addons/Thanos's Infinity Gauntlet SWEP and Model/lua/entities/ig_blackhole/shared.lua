ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName 	= "Black Hole"
ENT.Name 		= "Black Hole"
ENT.Spawnable 	= false

ENT.isBlackHole = true

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"Radius")
end

if SERVER then return end
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.nextParticles = 0

function ENT:Think()
	local bounds = Vector(self:GetRadius(),self:GetRadius(),self:GetRadius())
	self:SetRenderBounds(-bounds,bounds)
end

local blackness = Material("xyz/effects/infinitygauntlet/blackgoop")
local distort = Material("xyz/effects/infinitygauntlet/blackhole")
local color = Color(20,20,20)
local Rand = math.Rand

local eyesInside = false
function ENT:Draw()
	local pos = self:GetPos()
	render.SetMaterial(distort)
	distort:SetFloat("$refractamount",-math.min(self:GetRadius()/10,.9)*math.abs(math.sin(RealTime())/10)/2)
	render.UpdateRefractTexture()
	local distortSize = self:GetRadius()*5
	render.DrawSprite(self:GetPos(),distortSize,distortSize,color_white)
	render.DrawQuadEasy(self:GetPos(),vector_up,distortSize,distortSize,color_white,0)
	
	render.SetMaterial(blackness)
	render.DrawSphere(pos,-self:GetRadius(),50,50,color)
	render.DrawSphere(pos,self:GetRadius(),50,50,color)
	
	if !eyesInside then
		eyesInside = EyePos():Distance(self:GetPos()) <= self:GetRadius()
	end
	
	if self.nextParticles > CurTime() then return end
	self.nextParticles = CurTime()+.05
	
	local emitter = ParticleEmitter(pos)
	
	local spd = 10
	local partPos = pos+IG_RandomPointInSphere(self:GetRadius())
	local p = emitter:Add("particle/smokesprites_000"..math.random(1,9),partPos)
	p:SetVelocity((partPos-pos):GetNormalized()*50)
	p:SetRoll(Rand(-.5,.5))
	p:SetDieTime(Rand(.5,1.1))
	p:SetStartAlpha(math.random(150,200))
	p:SetEndAlpha(0)
	p:SetStartSize(Rand(8,15)*(self:GetRadius()/100))
	p:SetEndSize(0)
	p:SetColor(40,40,40)
	
	emitter:Finish()
end

hook.Add("PostDrawHUD","IG_BlackHole",function()
	if eyesInside then
		eyesInside = false
		surface.SetDrawColor(color_black)
		surface.DrawRect(0,0,ScrW(),ScrH())
	end
end)
