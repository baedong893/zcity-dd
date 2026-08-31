local Rand = math.Rand

function EFFECT:Init(data)
	local obbMin = data:GetOrigin()
	local obbMax = data:GetStart()
	local count = data:GetRadius()
	local color = data:GetAngles()
	self.color = Color(color.p,color.y,color.r)
	
	self.emitter = ParticleEmitter(obbMax-obbMin+obbMin)
	
	for i=0,count do
		self:MakeParticle(Vector(Rand(obbMin.x,obbMax.x),Rand(obbMin.y,obbMax.y),Rand(obbMin.z,obbMax.z)))
	end
	
	self.emitter:Finish()
end

function EFFECT:MakeParticle(startPos)
	local spd = 5
	local p = self.emitter:Add("sprites/physg_glow1",startPos)
	p:SetVelocity(Vector(Rand(-spd,spd),Rand(-spd,spd),Rand(spd/10,spd))*Rand(spd,spd*25))
	p:SetGravity(Vector(0,0,-30))
	p:SetRoll(Rand(-.5, .5))
	p:SetDieTime(Rand(2,3))
	p:SetStartAlpha(math.random(150,200))
	p:SetEndAlpha(0)
	p:SetStartSize(Rand(8,15))
	p:SetEndSize(Rand(10,10))
	--p:SetColor(104,26,150)
	p:SetColor(self.color.r,self.color.g,self.color.b)
	p:SetCollide(true)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
