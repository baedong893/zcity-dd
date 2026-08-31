local Rand = math.Rand

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local dir = data:GetNormal()
	
	local emitter = ParticleEmitter(pos)
	
	local spd = 250
	for i=0,2 do
		local p = emitter:Add("sprites/physg_glow1",pos)
		p:SetVelocity(dir*-50+VectorRand()*15)--dir*Vector(Rand(-spd,spd),Rand(-spd,spd),Rand(-spd,spd)))
		p:SetRoll(Rand(-.5, .5))
		p:SetDieTime(.5)
		p:SetStartAlpha(math.random(150,200))
		p:SetEndAlpha(0)
		p:SetStartSize(0)
		p:SetEndSize(Rand(5,5))
		p:SetColor(241,144,19)
		local p = emitter:Add("particle/particle_glow_02",pos)
		p:SetVelocity(dir*-50+VectorRand()*15)--dir*Vector(Rand(-spd,spd),Rand(-spd,spd),Rand(-spd,spd)))
		p:SetRoll(Rand(-.5, .5))
		p:SetDieTime(.5)
		p:SetStartAlpha(math.random(150,200))
		p:SetEndAlpha(0)
		p:SetStartSize(0)
		p:SetEndSize(Rand(5,5))
		p:SetColor(241,144,19)
	end
	
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
