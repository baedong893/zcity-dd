AddCSLuaFile()
local RandF,RandI = math.Rand,math.random
local color = Color(104,26,150,255)
local glowMat = Material("sprites/physg_glow1")

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local scale = data:GetScale()/200
	local emitter = ParticleEmitter(pos)
	
	--Center residue
	for i=1,8*GetConVar("ig_particlescale"):GetFloat() do
		local p = emitter:Add(glowMat,pos+VectorRand()*(45*scale))
		p:SetRoll(RandF(-1,1))
		p:SetRollDelta(RandF(-1,1))
		p:SetAirResistance(20)
		
		p:SetStartSize(80 * scale)
		p:SetEndSize(240 * scale)
		p:SetStartAlpha(RandI(195,235))
		p:SetEndAlpha(0)
		p:SetDieTime(RandF(2,3))
		p:SetColor(190,70,238)
	end
	
	for i=1,RandI(20,30)*GetConVar("ig_particlescale"):GetFloat() do
		--Big Smoke
		local p = emitter:Add("particle/smokesprites_000"..RandI(1,9),pos)
		p:SetGravity(Vector(0,0,RandI(-10,10)))
		p:SetVelocity(VectorRand() * 150 * scale)
		p:SetRoll(RandF(-1,1))
		p:SetRollDelta(RandF(-1,1))
		p:SetAirResistance(20)
		p:SetStartSize(80*scale)
		p:SetEndSize(240*scale)
		p:SetStartAlpha(RandI(175,215))
		p:SetEndAlpha(0)
		p:SetDieTime(RandF(2,4))
		p:SetColor(color.r,color.g,color.b)
		
		--Small balls
		local p = emitter:Add(glowMat,pos+VectorRand()*(30*scale))
		p:SetGravity(Vector(0,0,RandI(-10,10)))
		p:SetVelocity(VectorRand()*250*scale)
		p:SetRoll(RandF(-1,1))
		p:SetRollDelta(RandF(-1,1))
		p:SetAirResistance(20)
		
		p:SetStartSize(30 * scale)
		p:SetEndSize(0)
		p:SetStartAlpha(RandI(175,215))
		p:SetEndAlpha(0)
		p:SetDieTime(RandF(1,3))
		p:SetColor(190,70,238)
	end
	
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end





