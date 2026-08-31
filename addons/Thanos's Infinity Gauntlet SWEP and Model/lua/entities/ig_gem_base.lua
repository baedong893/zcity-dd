AddCSLuaFile()
ENT.Type 		= "anim"
ENT.Base 		= "base_gmodentity"
ENT.Category 	= "XYZ"
ENT.PrintName 	= "Infinity Stone"
ENT.Spawnable 	= false
ENT.stoneID = 1

function ENT:Initialize()
	self:SetModel(IG_StoneData[self.stoneID].worldModel)
	
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
		end
	end
	self.hp = 99999
end

function ENT:Use(use,user)
	local wep = user:GetActiveWeapon()
	if !wep:IsValid() or wep:GetClass() != "infinitygauntlet" or wep:HasStone(self.stoneID) or timer.Exists("GiveInfinityStone"..wep:EntIndex()) then return end
	self:IG_ClearTimeData()
	user:EmitSound("xyz/infinitygauntlet/gem_acquired.wav")
	local stoneID = self.stoneID
	timer.Create("GiveInfinityStone"..wep:EntIndex(),.8,1,function()
		if wep:IsValid() then
			wep:SetHasStone(stoneID,true)
			wep:PerformStoneGlow(stoneID,false)
		end
	end)
	self:Remove()
end

function ENT:OnTakeDamage(dmg)
	self.hp = self.hp - dmg:GetDamage()
	if self.hp <= 0 then
		self:Remove()
	end
end

if CLIENT then
	local Rand = math.Rand
	function ENT:Draw()
		self:DrawModel()
		
		local pos = self:GetPos()
		local emitter = ParticleEmitter(pos)
		
		local p = emitter:Add("sprites/physg_glow1",pos)
		p:SetVelocity(Vector(Rand(-1,1),Rand(-1,1),Rand(.1,1))*Rand(1,25))
		p:SetRoll(Rand(-.5, .5))
		p:SetDieTime(Rand(.5,.7))
		p:SetStartAlpha(math.random(150,200))
		p:SetEndAlpha(0)
		p:SetStartSize(Rand(2,5))
		p:SetEndSize(Rand(5,10))
		local color = IG_StoneData[self.stoneID].color
		p:SetColor(color.r,color.g,color.b)
		
		emitter:Finish()
	end
end
