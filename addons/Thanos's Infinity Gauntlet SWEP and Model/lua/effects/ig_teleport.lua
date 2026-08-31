local Rand = math.Rand

function EFFECT:Init(data)
	local obbMin = data:GetOrigin()
	local obbMax = data:GetStart()
	local count = data:GetRadius()
	
	self.emitter = ParticleEmitter(obbMax-obbMin+obbMin)
	
	for i=0,count do
		self:MakeParticle(Vector(Rand(obbMin.x,obbMax.x),Rand(obbMin.y,obbMax.y),Rand(obbMin.z,obbMax.z))+IG_RandomPointInSphere(10))
	end
	
	self.emitter:Finish()
end

function EFFECT:MakeParticle(startPos)
	local p = self.emitter:Add("particle/smokesprites_000"..math.random(1,9),startPos)
	p:SetRoll(Rand(-.5,.5))
	p:SetDieTime(Rand(3,5))
	p:SetStartAlpha(math.random(150,200))
	p:SetEndAlpha(0)
	p:SetStartSize(Rand(8,15))
	p:SetEndSize(0)
	p:SetColor(40,40,40)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
