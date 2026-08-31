
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local scale = GetConVar("ig_particlescale"):GetFloat()
	
	local emitter = ParticleEmitter(pos)
	
	for i=1,80*scale do
		local part = emitter:Add("sprites/flamelet4",pos)
		part:SetVelocity(Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-.1,.6))*500)
		part:SetStartSize(20)
		part:SetEndSize(0)
		part:SetStartAlpha(255)
		part:SetEndAlpha(0)
		part:SetRoll(math.random(0,360))
		part:SetRollDelta(math.Rand(-1,1))
		part:SetDieTime(math.Rand(1,6)*scale)
	end
	
	for i=1,6 do
		local part = emitter:Add("effects/muzzleflash"..math.random(1,4),pos)
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



