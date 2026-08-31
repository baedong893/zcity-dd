ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName 	= "Power Bomb"
ENT.Name 		= "Power Bomb"
ENT.Spawnable 	= false

ENT.radius = 50

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Radius")
end

if SERVER then return end
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.nextParticles = 0

local sphereMat = Material("sprites/tp_beam001")
local blackness = Material("xyz/effects/infinitygauntlet/blackgoop")
local magicglow = Material("xyz/effects/infinitygauntlet/magicglow")
local glowMat = Material("particle/particle_glow_05")
local color = Color(88,14,117)
local Rand = math.Rand
function ENT:Draw()
	local pos = self:GetPos()
	
	render.SetMaterial(sphereMat)
	render.DrawSphere(pos,self:GetRadius(),50,50,color)
	render.SetMaterial(blackness)
	render.DrawSphere(pos,self:GetRadius()*.75,50,50,color)
	render.SetMaterial(magicglow)
	render.DrawSphere(pos,self:GetRadius()*.8,50,50,color)
	render.SetMaterial(glowMat)
	local spriteRadius = self:GetRadius()*5
	render.DrawSprite(pos,spriteRadius,spriteRadius,color)
	
	if self.nextParticles > CurTime() then return end
	self.nextParticles = CurTime()+.01
	local emitter = ParticleEmitter(pos)
	
	local spd = 10
	local p = emitter:Add("sprites/physg_glow1",pos+VectorRand()*self:GetRadius()/3)
	p:SetVelocity(Vector(Rand(-spd,spd),Rand(-spd,spd),Rand(-spd,spd))*Rand(-spd,spd))
	p:SetGravity(VectorRand())
	p:SetRoll(Rand(-.5, .5))
	p:SetDieTime(Rand(.5,1.1))
	p:SetStartAlpha(math.random(150,200))
	p:SetEndAlpha(0)
	p:SetStartSize(Rand(8,15))
	p:SetEndSize(Rand(10,10))
	p:SetColor(color.r,color.g,color.b)
	p:SetCollide(true)
	
	emitter:Finish()
end

function ENT:OnRemove()
	local startPos = self:GetPos()
	local emitter = ParticleEmitter(startPos)
	for i=0,120 do
		local spd = 5
		local p = emitter:Add("sprites/physg_glow1",startPos)
		p:SetVelocity(Vector(Rand(-spd,spd),Rand(-spd,spd),Rand(spd/10,spd))*Rand(spd,spd*25))
		p:SetGravity(Vector(0,0,-30))
		p:SetRoll(Rand(-.5, .5))
		p:SetDieTime(Rand(2,3))
		p:SetStartAlpha(math.random(150,200))
		p:SetEndAlpha(0)
		p:SetStartSize(Rand(8,15))
		p:SetEndSize(Rand(10,10))
		p:SetColor(104,26,150)
	end
	emitter:Finish()
end
