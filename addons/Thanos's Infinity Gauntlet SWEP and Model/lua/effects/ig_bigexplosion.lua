

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local dir = data:GetNormal()
	local scale = data:GetScale()*GetConVar("ig_particlescale"):GetFloat()
	
	local emitter = ParticleEmitter(pos)
	
	for i=1,30*scale do
		local part = emitter:Add("particle/smokesprites_000"..math.random(1,9),pos)
		part:SetVelocity(dir*math.random(100,500)*scale+VectorRand()*400*scale)
		part:SetGravity(Vector(math.random(-300,300),math.random(-300,300),math.random(5,100)))
		part:SetAirResistance(300)
		part:SetStartSize(scale*70)
		part:SetEndSize(scale*100)
		part:SetStartAlpha(70)
		part:SetEndAlpha(0)
		part:SetRoll(math.random(160,360))
		part:SetRollDelta(math.Rand(-1,1))
		part:SetDieTime(math.Rand(1,6)*scale)
		part:SetColor(90,90,90)
	end
	
	for i=1,20*scale do
		local part = emitter:Add("effects/fleck_cement"..math.random(1,2),pos)
		part:SetVelocity(dir*math.random(20,900)*scale+VectorRand()*700*scale)
		part:SetGravity(Vector(0,0,-600))
		part:SetAirResistance(30)
		part:SetStartSize(scale*math.random(3,15))
		part:SetEndSize(scale*math.random(1,3))
		part:SetStartAlpha(255)
		part:SetEndAlpha(0)
		part:SetRoll(math.random(0,360))
		part:SetRollDelta(math.Rand(-1,1))
		part:SetDieTime(math.Rand(1,6)*scale)
		part:SetColor(60,60,60)
	end
	
	for i=1,15*scale do
		local part = emitter:Add("particle/particle_composite",pos)
		part:SetVelocity(dir*100)
		part:SetGravity(Vector(0,0,math.Rand(-200,-500)))
		part:SetAirResistance(150)
		part:SetStartSize(scale*50)
		part:SetEndSize(scale*150)
		part:SetStartAlpha(255)
		part:SetEndAlpha(200)
		part:SetRoll(math.random(100,360))
		part:SetRollDelta(math.Rand(-1,1))
		part:SetDieTime(math.Rand(2,4))
		part:SetColor(90,90,90)
	end
	
	for i=1,6 do
		local part = emitter:Add("effects/muzzleflash"..math.random(1,4),pos)
		part:SetVelocity(dir*100)
		part:SetAirResistance(200)
		part:SetStartSize(scale*300)
		part:SetEndSize(0)
		part:SetStartAlpha(255)
		part:SetEndAlpha(200)
		part:SetRoll(math.random(0,360))
		part:SetRollDelta(math.Rand(-1,1))
		part:SetDieTime(.1)
	end
	
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end



