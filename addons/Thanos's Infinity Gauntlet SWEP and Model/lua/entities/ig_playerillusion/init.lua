AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.health = 100
ENT.lifetime = 30

function ENT:Initialize()
	self.dieTime = CurTime()+self.lifetime
	self:SetModel(self.owner:GetModel())
	self:SetSolid(SOLID_BBOX)
	self:ResetSequence(self:LookupSequence("idle_fist"))
	--self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	local groundTr = util.TraceLine{
		start = self:GetPos(),
		endpos = self:GetPos()-self:GetAngles():Up()*99999,
		filter = self
	}
	
	self:SetPos(groundTr.HitPos)
	if groundTr.Entity:IsValid() then
		self:SetParent(groundTr.Entity)
	end
	
	local npc = ents.Create("npc_bullseye")
	npc:SetPos(self:GetPos()+vector_up*30)
	npc:SetHealth(self.health)
	--npc:SetCollisionGroup(self:GetCollisionGroup())
	npc:Spawn()
	npc:SetParent(self)
	self.npc = npc
	
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
	if self.dieTime <= CurTime() or !self.npc:IsValid() then
		self:Remove()
		return
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
