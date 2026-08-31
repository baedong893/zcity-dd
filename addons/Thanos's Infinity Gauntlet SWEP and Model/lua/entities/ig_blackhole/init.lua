AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:DrawShadow(false)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity(false)
		phys:EnableCollisions(false)
	end
	self:SetRadius(10)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Think(ent)
	local radius = self:GetRadius()-.5
	self:SetRadius(radius)
	if radius <= 0 then self:Remove() return end
	
	if !self.velocity then
		self.velocity = self:GetVelocity()
	end
	--local phys = self:GetPhysicsObject()
	--if phys:IsValid() then
		--phys:SetVelocity(self.velocity)
	--end
	
	local destroyList = {}
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),radius)) do --Using collision boxes
		if v != self and (v:IsPlayer() or v:GetPhysicsObject():IsValid()) then
			destroyList[v] = true
		end
	end
	
	local pullDist = (radius*20)
	local pullDistSqr = pullDist^2
	local unfreezeDist = (radius*2)^2
	for k,v in ipairs(ents.FindInSphere(self:GetPos(),pullDist)) do
		if v != self and (v:IsPlayer() or v:GetPhysicsObject():IsValid()) and v:IsValid() then
			local dist = self:GetPos():DistToSqr(v:GetPos())
			local power = (1-dist/pullDistSqr)*self:GetRadius()
			local vel = ((self:GetPos()-v:GetPos()):GetNormalized()*power)
			
			local inKillRange = destroyList[v]
			if v:IsPlayer() then
				if inKillRange and !v:HasGodMode() then
					v:KillSilent()
				elseif !v:HasInfinityStone(IG_STONE_SPACE) then
					v:SetLocalVelocity(v:GetVelocity()+vel)
				end
			else
				if inKillRange then
					local mass
					if v:GetClass() == "ig_blackhole" then
						mass = v:GetRadius()
					elseif v:GetClass() == "ig_powerbomb" then
						mass = 100
					else
						mass = math.min(v:GetModelRadius()/70,20)
					end
					
					if mass then
						self:SetRadius(radius+mass)
					end
					v:Remove()
				else
					if v:IsNPC() then
						v:SetLocalVelocity(vel)
					else
						if dist < unfreezeDist then
							if !v:GetPhysicsObject():IsMotionEnabled() then
								v:GetPhysicsObject():EnableMotion(true)
							end
							constraint.RemoveAll(v)
						end
						v:GetPhysicsObject():AddVelocity(vel)
					end
				end
			end
		end
	end
end
