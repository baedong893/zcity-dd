AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.health = 50

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.dieTime = CurTime()+60
	self.nextAttack = 0
	self.forgetRecordedPos = 0
	self.lastRecordedPos = {}
	self:DrawShadow(false)
	
	local npc = ents.Create("npc_bullseye")
	npc:SetPos(self:GetPos())
	npc:SetHealth(self.health)
	npc:Spawn()
	npc:SetParent(self)
	self.npc = npc
	npc.isSoulStoneMinion = true
	
	for k,v in ipairs(ents.GetAll()) do
		if v.AddEntityRelationship then
			v:AddEntityRelationship(npc,D_HT,99)
		end
	end
	
	hook.Add("OnEntityCreated",self,function(_,ent)
		if ent.AddEntityRelationship and npc:IsValid() then
			ent:AddEntityRelationship(npc,D_HT,99)
		end
	end)
end

function ENT:Think()
	if !self.npc:IsValid() or self.dieTime < CurTime() then
		self:Remove()
		return
	end
	
	if self.nextAttack > CurTime() then return end
	self.nextAttack = CurTime()+1
	if self.forgetRecordedPos < CurTime() then
		self.forgetRecordedPos = CurTime()+5
		self.lastRecordedPos = {}
	end
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),500)) do
		if ((v:IsNPC() and v != self.npc) or (v:IsPlayer() and !v:HasInfinityStone(IG_STONE_SOUL))) and v:Health() > 0 then
			local posDiff = self.lastRecordedPos[v] and self.lastRecordedPos[v]-v:GetPos() or Vector()
			self.lastRecordedPos[v] = v:GetPos()
			local missile = ents.Create("ig_soulmissile")
			local dir = ((v:OBBCenter()+v:GetPos()-posDiff/2)-self:GetPos()):GetNormalized()
			missile:SetPos(self:GetPos())
			missile:SetOwner(self)
			missile:SetAngles(dir:Angle())
			missile:Spawn()
			if missile:GetPhysicsObject():IsValid() then
				missile:GetPhysicsObject():SetVelocity(dir*1500)
			end
			missile.damage = 30
			missile.dieTime = CurTime()+5
			break
		end
	end
end

function ENT:OnTakeDamage(dmg)
	if self.npc:IsValid() then
		self.npc:TakeDamageInfo(dmg)
		if self.npc:Health() <= 0 then
			self:Remove()
		end
	else
		self:Remove()
	end
end
