--Modified spawneffect from sandbox
local Rand = math.Rand

function EFFECT:Init(data)
	self.time = data:GetMagnitude()
	self.lifeTime = CurTime()+self.time
	
	local ent = data:GetEntity()
	
	if (!IsValid(ent)) then return end
	if (!ent:GetModel()) then return end
	
	self.entity = ent
	self:SetParent(ent)
	
	self.entity.RenderOverride = self.RenderParent
	self.entity.IG_dustingEffect = self
	--self.entity:DrawShadow(false)
	
	self.emitter = ParticleEmitter(ent:GetPos())
	self.nextParticleEmission = 0
end

function EFFECT:Think()
	if (!IsValid(self.entity)) then return false end
	self.entity.RenderOverride = self.RenderParent
	self.entity.IG_dustingEffect = self
	
	if self.lifeTime-2 < CurTime() then
		self.entity:DrawShadow(false)
	end
	
	if (self.lifeTime > CurTime()) then
		return true
	end
	
	self.entity.RenderOverride = nil
	self.entity.IG_dustingEffect = nil
	
	self.entity:SetNoDraw(true)
	self.emitter:Finish()
	return false
end

function EFFECT:Render()
	if (!IsValid(self.entity)) then return end
	self.entity.RenderOverride = self.RenderParent
	self.entity.IG_dustingEffect = self
end

function EFFECT:RenderParent()
	local bClipping = self.IG_dustingEffect:StartClip(self,1)
	self:DrawModel()
	render.PopCustomClipPlane()
	render.EnableClipping(bClipping)
end

function EFFECT:StartClip(model,spd)
	local mn,mx = model:GetRenderBounds()
	local up = (mx-mn):GetNormal()
	local Bottom = model:GetPos()+mn
	local Top = model:GetPos()+mx
	local Fraction = 1-((self.lifeTime-CurTime())/self.time)
	Fraction = math.Clamp(Fraction / spd, 0, 1)
	
	local Lerped = LerpVector(Fraction,Bottom,Top)
	local distance = up:Dot(Lerped)
	
	if self.nextParticleEmission < CurTime() then
		self.nextParticleEmission = CurTime()+.3
		local ent = self.entity
		for n=0,10*GetConVar("ig_particlescale"):GetFloat() do
			if ent:GetBoneCount() and ent:GetBoneCount() >= 10 then
				local count = ent:GetBoneCount()-1
				for bone=0,count do
					if math.random(0,20) != 0 then continue end
					local matrix = ent:GetBoneMatrix(bone)
					if matrix then
						local pos = matrix:GetTranslation()
						if pos.z > Lerped.z then
							self:MakeParticle(pos)
						end
					end
				end
			else
				local obbMin, obbMax = ent:OBBMins(),ent:OBBMaxs()
				local count = ent:GetModelRadius()/6
				for i=0,count do
					local pos = ent:LocalToWorld(Vector(Rand(obbMin.x,obbMax.x),Rand(obbMin.y,obbMax.y),Rand(obbMin.z,obbMax.z)))
					if up:Dot(pos) >= distance then
						self:MakeParticle(pos)
					end
				end
			end
		end
	end
	
	local bEnabled = render.EnableClipping(true)
	render.PushCustomClipPlane(up,distance)
	
	return bEnabled
end

function EFFECT:MakeParticle(startPos)
	local spd = 1
	local p = self.emitter:Add("particle/particle_debris_02",startPos)
	p:SetVelocity(Vector(Rand(-spd,spd),Rand(-spd,spd),Rand(spd/10,spd))*Rand(spd,spd*25))
	p:SetGravity(Vector(0,0,-30))
	p:SetRoll(Rand(-.5, .5))
	p:SetDieTime(15)
	p:SetStartAlpha(math.random(150,200))
	p:SetEndAlpha(0)
	p:SetStartSize(Rand(8,15))
	p:SetEndSize(Rand(10,10))
	p:SetColor(46,46,46)
	p:SetCollide(true)
end
