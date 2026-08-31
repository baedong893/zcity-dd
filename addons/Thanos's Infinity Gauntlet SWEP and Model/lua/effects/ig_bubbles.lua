local Rand = math.Rand

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	
	local emitter = ParticleEmitter(pos)
	
	local spd = 250
	for i=0,5 do
		local p = emitter:Add("effects/bubble",pos)
		p:SetGravity(Vector(0,0,100)+VectorRand()*100)
		p:SetDieTime(.5)
		p:SetStartAlpha(255)
		p:SetEndAlpha(255)
		p:SetStartSize(3)
		p:SetRollDelta(Rand(-1,1))
		p:SetRoll(math.random(0,360))
		p:SetEndSize(Rand(5,8))
	end
	
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
