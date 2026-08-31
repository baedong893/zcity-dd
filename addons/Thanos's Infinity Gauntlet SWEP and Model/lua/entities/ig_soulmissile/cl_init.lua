include("shared.lua")

hook.Add("CalcView","IG_MindMissileCam",function(ply,origin,angles,fov,znear,zfarA)
	local viewEntity = ply:GetNWEntity("IG_MindMissile")
	if !viewEntity:IsValid() or ply:GetViewEntity() != ply then return end
	local tr = util.TraceLine({
		start = viewEntity:GetPos(),
		endpos = viewEntity:GetPos()-angles:Forward()*105,
		filter = function(ent) return !(ent == viewEntity or ent:GetParent() == viewEntity) end
	})
	return {
		origin = viewEntity:GetPos()-angles:Forward()*(100*tr.Fraction),
		angles = angles,
		fov = fov,
		znear = 0.5,
		drawviewer = true
	} 
end)

local Rand = math.Rand

function ENT:Draw()
	local pos = self:GetPos()
	local emitter = ParticleEmitter(pos)
	
	local p = emitter:Add("sprites/physg_glow1",pos)
	p:SetVelocity(Vector(Rand(-1,1),Rand(-1,1),Rand(.1,1))*Rand(1,25))
	p:SetRoll(Rand(-.5,.5))
	p:SetDieTime(Rand(.5,.7))
	p:SetStartAlpha(math.random(150,200))
	p:SetEndAlpha(0)
	p:SetStartSize(Rand(2,5))
	p:SetEndSize(Rand(5,10))
	local color = IG_StoneData[IG_STONE_SOUL].color
	p:SetColor(color.r,color.g,color.b)
	
	emitter:Finish()
	
	local light = DynamicLight(self:EntIndex())
	if light then
		light.pos = pos
		light.r = color.r
		light.g = color.g
		light.b = color.b
		light.brightness = 2
		light.decay = 1000
		light.size = 200
		light.dietime = CurTime() + 1
	end
end

