local entrailMat = Material("effects/bloodstream")

local bounds = Vector(9999,9999,9999)

EFFECT.trailWidth = 7
EFFECT.timeScale = 5

function EFFECT:Init(data)
	self:SetRenderBounds(-bounds,bounds)
	
	local pos = data:GetOrigin()
	local power = 500 or data:GetDamageType()
	local dir = data:GetNormal()*power
	local dirAngle = dir:Angle()
	self.particles = {}
	
	self.bloodType = data:GetFlags() or 1
	
	local lightColor = render.GetLightColor(pos)*127
	lightColor.r = math.max(lightColor.r,20)
	lightColor.g = math.max(lightColor.r,20)
	
	if self.bloodType == 1 then
		self.color = Color(lightColor.r,0,0)
	else
		self.color = Color(lightColor.r,lightColor.g,0)
	end
	
	for i=0,math.random(6,12) do
		self.particles[#self.particles+1] = {
			pos = pos,
			velocity = dir*(i/50)+dirAngle:Right()*math.Rand(-10,10)
		}
	end
end

function EFFECT:Think()
	local physicsRate = self.timeScale * FrameTime()
	
	local prevPos
	for k,v in pairs(self.particles) do
		if !v.asleep then
			local velocity = v.velocity
			velocity.x = math.Approach(velocity.x,0,5*physicsRate)
			velocity.y = math.Approach(velocity.y,0,5*physicsRate)
			velocity.z = velocity.z-20*physicsRate
			
			local tr = util.TraceLine{
				start = v.pos,
				endpos = v.pos+velocity*physicsRate,
				mask = MASK_SOLID_BRUSHONLY
			}
			v.pos = tr.HitPos
			if tr.Hit then
				if prevPos and prevPos:Distance(v.pos) > 200 then
					self.particles[k] = nil
					continue
				end
				
				v.asleep = true
			end
			
			v.velocity = velocity
		end
		prevPos = v.pos
	end
	
	self.trailWidth = self.trailWidth-.05*physicsRate
	if self.trailWidth <= 0 then
		return false
	end
	return true
end

function EFFECT:Render()
	local prevPos
	render.SetMaterial(entrailMat)
	for k,v in pairs(self.particles) do
		if prevPos then
			render.DrawBeam(prevPos,v.pos,self.trailWidth,1,0,self.color)
		end
		prevPos = v.pos
	end
end
