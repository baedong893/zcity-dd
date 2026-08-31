ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName 	= "Illusion"
ENT.Name 		= "Illusion"
ENT.Spawnable 	= false
ENT.Category = "XYZ"

if SERVER then return end
local Rand = math.Rand
function ENT:OnRemove()
	local emitter = ParticleEmitter(self:GetPos())
	local mins,maxs = self:OBBMins(),self:OBBMaxs()
	
	for i=0,60 do
		local p = emitter:Add("sprites/physg_glow1",self:GetPos()+Vector(Rand(mins.x,maxs.x),Rand(mins.y,maxs.y),Rand(mins.z,maxs.z)))
		p:SetGravity(Vector(0,0,-30))
		p:SetRoll(Rand(-.5, .5))
		p:SetDieTime(Rand(2,3))
		p:SetStartAlpha(math.random(150,200))
		p:SetEndAlpha(0)
		p:SetStartSize(Rand(8,15))
		p:SetEndSize(Rand(10,10))
		p:SetColor(255,0,0)
		p:SetCollide(true)
	end
	
	emitter:Finish()
end

function ENT:Draw()
	self:FrameAdvance()
	
	render.PushFlashlightMode(true)
	self:DrawModel()
	render.PopFlashlightMode()
	
	self:DrawModel()
	
	if !self.weapon then
		local data = weapons.GetStored("infinitygauntlet").WElements.gauntlet
		self.weaponData = data
		local weapon = ClientsideModel(data.model)
		self.weapon = weapon
		weapon:SetNoDraw(true)
		weapon:SetModelScale(data.size.x)
		weapon:SetParent(self)
	elseif self.weapon:IsValid() then
		local data = self.weaponData
		local pos,ang = self:GetBonePosition(self:LookupBone(data.bone))
		
		pos = pos+ang:Forward()*data.pos.x+ang:Right()*data.pos.y+ang:Up()*data.pos.z
		ang:RotateAroundAxis(ang:Up(),data.angle.y)
		ang:RotateAroundAxis(ang:Right(),data.angle.p)
		ang:RotateAroundAxis(ang:Forward(),data.angle.r)
		
		self.weapon:SetPos(pos)
		self.weapon:SetAngles(ang)
		
		self.weapon:DrawModel()
	end
end
