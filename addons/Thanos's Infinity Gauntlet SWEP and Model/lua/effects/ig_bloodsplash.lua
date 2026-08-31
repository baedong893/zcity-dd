
local function ParticleCollide(part,pos,normal)
	if math.random(1,3) == 1 then
		if part.bloodType == 1 then
			util.Decal("Blood", pos + pos:GetNormal(), pos - pos:GetNormal())
		elseif part.bloodType == 2 then
			util.Decal("YellowBlood", pos + pos:GetNormal(), pos - pos:GetNormal())
		elseif part.bloodType == 3 then
			util.Decal("Blood", pos + pos:GetNormal(), pos - pos:GetNormal())
			util.Decal("YellowBlood", pos + pos:GetNormal(), pos - pos:GetNormal())
		end
	end
	
	local ang = normal:Angle()
	if ang.r == 0 and ang.p == 270 then
		ang.y = math.random(0,359)
	end
	
	part:SetAngleVelocity(Angle(0,0,0))
	part:SetAngles(ang)
	part:SetVelocity(Vector(0,0,0))
	part:SetGravity(Vector(0,0,0))
	part:SetPos(pos + normal)
	part:SetDieTime(100)
	part:SetEndSize(math.random(15,30))
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local power = data:GetDamageType()
	local dir = data:GetNormal()*power
	local dirAngle = dir:Angle()
	
	local bloodFaceAngle = dir:Angle()
	bloodFaceAngle:RotateAroundAxis(bloodFaceAngle:Up(),180)
	
	local lightColor = render.GetLightColor(pos)*127
	lightColor.r = math.max(lightColor.r,20)
	lightColor.g = math.max(lightColor.r,20)
	
	self.bloodType = data:GetFlags() or 1
	local color
	
	if self.bloodType == 1 then
		color = Color(lightColor.r,0,0)
	else
		color = Color(lightColor.r,lightColor.g,0)
	end
	
	local emitter = ParticleEmitter(pos,true)
	for i=1,math.random(5,10)*GetConVar("ig_particlescale"):GetFloat() do
		local part = emitter:Add("xyz/effects/infinitygauntlet/blood_drop",pos)
		part:SetVelocity(dir*(i/50)+dirAngle:Right()*math.Rand(-25,25))
		part:SetGravity(Vector(0,0,-600))
		part:SetStartSize(math.Rand(8,10))
		part:SetEndSize(math.Rand(3,10))
		part:SetStartAlpha(255)
		part:SetEndAlpha(200)
		part:SetRoll(math.random(-100,100))
		part:SetRollDelta(.4)
		part:SetStartLength(1)
		part:SetEndLength(5)
		part:SetDieTime(20)
		part:SetAngles(bloodFaceAngle)
		part:SetCollide(true)
		part:SetCollideCallback(ParticleCollide)
		part:SetColor(color.r,color.g,color.b)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end



