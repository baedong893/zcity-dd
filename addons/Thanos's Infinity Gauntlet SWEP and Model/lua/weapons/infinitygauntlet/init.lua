AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("IG_OpenStoneMenu")
util.AddNetworkString("IG_OpenAbilityMenu")
util.AddNetworkString("IG_SelectedStone")
util.AddNetworkString("IG_SelectedAbility")
util.AddNetworkString("IG_ChannelMousewheeled")
util.AddNetworkString("IG_URMenu")
util.AddNetworkString("IG_DefineLaw")
util.AddNetworkString("IG_DeleteLaw")
util.AddNetworkString("IG_SyncLaw")

util.AddNetworkString("IG_StoneUsed")
util.AddNetworkString("IG_StopChanneling")
util.AddNetworkString("IG_EnableEntityEffect")
util.AddNetworkString("IG_ClearEntityEffect")
util.AddNetworkString("IG_SetEntityFrozen")
util.AddNetworkString("IG_ScalePlayer")
util.AddNetworkString("IG_PunchAnim")
util.AddNetworkString("IG_NPCCorpseRemoved")

local ENT = FindMetaTable("Entity")
local PLY = FindMetaTable("Player")

function ENT:IG_RemoveCorpse()
	net.Start("IG_NPCCorpseRemoved")
	net.WriteUInt(self:EntIndex(),16)
	net.Broadcast()
end

function ENT:IG_SetScale(scale)
	self:SetModelScale(scale)
	self:Activate()
	/*local children = {}
	for k,v in ipairs(self:GetChildren()) do
		children[v] = true
	end
	for k,v in pairs(constraint.GetAllConstrainedEntities(self)) do
		children[v] = true
	end
	for ent in pairs(children) do
		ent:SetModelScale(ent:GetModelScale()+diff)
	end*/
end

function ENT:IG_MakeStatue()
	if self.IG_isStatue or !IG_IsRagdoll(self:GetModel()) then return end
	local ragdoll
	if self:IsRagdoll() then
		ragdoll = self
	else
		ragdoll = ents.Create("prop_ragdoll")
		ragdoll:SetModel(self:GetModel())
		ragdoll:SetPos(self:GetPos())
		for _,v in pairs(self:GetBodyGroups()) do
			ragdoll:SetBodygroup(v.id,self:GetBodygroup(v.id))
		end
		ragdoll:SetSkin(self:GetSkin())
		ragdoll:SetColor(self:GetColor())
		ragdoll:SetMaterial(self:GetMaterial())
		ragdoll:Spawn()
	end
	
	ragdoll.IG_isStatue = true
	
	for id=0,ragdoll:GetPhysicsObjectCount()-1 do
		local phys = ragdoll:GetPhysicsObjectNum(id)
		if phys:IsValid() then
			local pos,ang = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(id))
			phys:SetPos(pos)
			phys:SetAngles(ang)
			
			constraint.Weld(ragdoll,ragdoll,id,0,0)
		end
	end
	
	if self != ragdoll then
		if self:IsPlayer() then
			self:KillSilent()
		else
			self:Remove()
		end
	end
end

function ENT:IG_SetExistant(bool)
	if self:IG_Exists() == bool then
		return
	end
	
	local phys = self:GetPhysicsObject()
	if bool then
		self:SetNoDraw(self.IG_ExistanceData.noDraw)
		self:SetCollisionGroup(self.IG_ExistanceData.collisionGroup)
		if phys:IsValid() then
			phys:EnableCollisions(self.IG_ExistanceData.collisionsEnabled)
			phys:EnableMotion(self.IG_ExistanceData.motionEnabled)
			phys:Wake()
		end
		if self:IsNPC() then
			self:SetCondition(68)
			self:SetMoveType(self.IG_ExistanceData.moveType)
			self:SetPos(self.IG_ExistanceData.prevPos)
		end
		self.IG_ExistanceData = nil
	else
		self.IG_ExistanceData = {
			noDraw = self:GetNoDraw(),
			collisionGroup = self:GetCollisionGroup(),
			moveType = self:GetMoveType()
		}
		if self:IsNPC() then
			self:SetSchedule(SCHED_NPC_FREEZE)
			self:SetMoveType(MOVETYPE_NONE)
			self.IG_ExistanceData.prevPos = self:GetPos()
			self:SetPos(Vector(-9999,999999,50))
		end
		self:SetNoDraw(true)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		
		if phys:IsValid() then
			self.IG_ExistanceData.motionEnabled = phys:IsMotionEnabled()
			self.IG_ExistanceData.collisionsEnabled = phys:IsCollisionEnabled()
			phys:EnableMotion(false)
			phys:EnableCollisions(false)
			phys:Wake()
		end
	end
end

function PLY:IG_SetExistant(bool,entParent)
	if self:IG_Exists() == bool then
		local cont = false
		if self.IG_ExistanceData then
			if self.IG_ExistanceData.vehicle:IsValid() then
				return self.IG_ExistanceData.vehicle
			else
				cont = true
			end
		end
		if !cont then
			return
		end
	end
	if !bool then
		self.IG_ExistanceData = {
			noDraw = self:GetNoDraw(),
			godmode = self:HasGodMode()
		}
		self:GodEnable()
		self:DropObject()
		self:SetNoDraw(true)
		self:DrawShadow(false)
		if self:GetActiveWeapon():IsValid() and !self:GetActiveWeapon():GetNoDraw() then
			self:GetActiveWeapon():SetNoDraw(true)
			self.IG_ExistanceData.noDrawWep = false
		end
		
		local vehicle = ents.Create("prop_vehicle_prisoner_pod")
		vehicle:SetPos(self:GetPos())
		vehicle:SetModel("models/nova/airboat_seat.mdl")
		
		vehicle:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		vehicle:SetKeyValue("limitview","0")
		vehicle:Spawn()
		vehicle:Activate()
		
		vehicle:SetMoveType(MOVETYPE_PUSH)
		vehicle:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
		
		vehicle:SetNotSolid(true)
		vehicle:GetPhysicsObject():EnableGravity(false)
		vehicle:GetPhysicsObject():EnableMotion(false)
		vehicle:GetPhysicsObject():EnableCollisions(false)
		vehicle:GetPhysicsObject():SetMass(1)
		vehicle:GetPhysicsObject():Sleep()
		
		vehicle:DrawShadow(false)
		vehicle:SetColor(Color(0,0,0,0))
		vehicle:SetRenderMode(RENDERMODE_TRANSALPHA)
		vehicle:SetNoDraw(true)
		
		vehicle.VehicleName = "Airboat Seat"
		vehicle.ClassOverride = "prop_vehicle_prisoner_pod"
		if IsValid(entParent) then
			vehicle:SetParent(entParent)
		end
		
		self:EnterVehicle(vehicle)
		self.IG_ExistanceData.vehicle = vehicle
		
		return vehicle
	else
		local data = self.IG_ExistanceData
		if data and IsValid(data.vehicle) then
			self:SetNoDraw(data.noDraw)
			if self:GetActiveWeapon():IsValid() and data.noDrawWep != nil then
				self:GetActiveWeapon():SetNoDraw(data.noDrawWep)
			end
			if data.godmode then
				self:GodEnable()
			else
				self:GodDisable()
			end
			data.vehicle:Remove()
			self.IG_ExistanceData = nil
		end
	end
end

function ENT:IG_Exists()
	return self.IG_ExistanceData == nil
end

function ENT:IG_MakeBodyRagdoll()
	if !IsValid(self) then return NULL end
	
	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetModel(self:GetModel())
	ragdoll:SetPos(self:GetPos())
	for _,v in pairs(self:GetBodyGroups()) do
		ragdoll:SetBodygroup(v.id,self:GetBodygroup(v.id))
	end
	ragdoll:SetSkin(self:GetSkin())
	ragdoll:SetColor(self:GetColor())
	ragdoll:SetMaterial(self:GetMaterial())
	ragdoll:Spawn()
	
	local velocity = self:GetVelocity()
	for id=0,ragdoll:GetPhysicsObjectCount()-1 do
		local phys = ragdoll:GetPhysicsObjectNum(id)
		if phys:IsValid() then
			local pos,ang = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(id))
			phys:SetPos(pos)
			phys:SetAngles(ang)
			phys:AddVelocity(velocity)
		end
	end
	
	if ragdoll.SnatchModelInstance then
		ragdoll:SnatchModelInstance(self)
	end
	
	return ragdoll
end

function ENT:IG_StartRagdoll()
	if IsValid(self.IG_ragdolled) or !self:IG_Exists() then return end
	local ragdoll = self:IG_MakeBodyRagdoll()
	if !ragdoll:IsValid() then return end
	ragdoll.ig_entity = self
	self.IG_ragdolled = ragdoll
	self:DeleteOnRemove(ragdoll)
	
	if self:IsPlayer() then
		self.ig_ragdolledVehicle = self:IG_SetExistant(false)
		if IsValid(self.ig_ragdolledVehicle) then
			self.ig_ragdolledVehicle:SetParent(ragdoll)
			self:GodDisable()
		end
	else
		self:IG_SetExistant(false)
	end
	
	local hookName = "KillIfBodyRemoved"..self:EntIndex()
	hook.Add("Think",hookName,function()
		if !self:IsValid() or !self.IG_ragdolled or (self:IsPlayer() and !self:Alive()) then
			hook.Remove("Think",hookName)
			return
		end
		if !ragdoll:IsValid() then
			if self.IG_ragdolled == ragdoll then
				if self:IsPlayer() then
					self:KillSilent()
					hook.Remove("Think",hookName)
				else
					self:Remove()
				end
			end
		end
	end)
	return ragdoll
end

function ENT:IG_StopRagdoll()
	self:IG_SetExistant(true)
	local ragdoll = self.IG_ragdolled
	self.IG_ragdolled = nil
	if IsValid(ragdoll) then
		local wakePos = ragdoll:GetPos()+vector_up*20
		if util.TraceEntity({
			start = wakePos,
			endpos = wakePos,
			filter = {self,ragdoll},
		},self).Hit then
			wakePos = IG_FindEmptyPositionEntity(self,wakePos,500,10,{self,ragdoll})
		end
		self:SetPos(wakePos)
		ragdoll:Remove()
	end
end

--Input Transferring
do

util.AddNetworkString("IG_TransferInput")

local readKeys = {
	IN_DUCK,
	IN_JUMP,
	IN_ATTACK,
	IN_ATTACK2,
	IN_USE,
	IN_SPEED,
	IN_MOVELEFT,
	IN_MOVERIGHT,
	IN_FORWARD,
	IN_BACK
}

net.Receive("IG_TransferInput",function(len,ply)
	local tbl = ply.ig_transferInputTable
	if !tbl then return end
	local cmds = net.ReadUInt(16)
	for _,key in ipairs(readKeys) do
		if bit.band(cmds,key) != 0 then
			tbl[key] = true
		else
			tbl[key] = false
		end
	end
end)

function PLY:TransferInput(bool)
	self:SetNWBool("IG_TransferInput",bool)
	if bool then
		self.ig_transferInputTable = {}
		
		return self.ig_transferInputTable
	end
end

end

hook.Add("PlayerSpawn","IG_ResetStuff",function(ply)
	ply.IG_Frozen = nil
	ply.IG_FrozenHadGod = nil
	ply.IG_TrappedSouls = {}
	ply:SetNWBool("IG_SoulVision",false)
	ply:IG_SetScale(1)
	ply:IG_StopRagdoll()
	ply.IG_WaterWalking = false
	ply:IG_RemoveMaterialEffect()
	ply.ig_blewup = false
	ply.igconddata = nil
	ply.IG_soulBonds = nil
	ply:IG_EnableEffect("soulbond",false)
	ply.IG_MindOriginalAppearence = nil
	ply.IG_existenceRemoving = nil
	if !ply:IG_MotionEnabled() then
		ply:IG_EnableMotion(true)
	end
	ply:TransferInput(false)
end)

hook.Add("GetFallDamage","IG_NoFall",function(ply,spd)
	if ply:HasInfinityStone(IG_STONE_POWER) then
		local ef = EffectData()
		ef:SetOrigin(ply:GetPos())
		ef:SetScale(600)
		util.Effect("ig_explosion",ef,true,true)
		local ef = EffectData()
		ef:SetMagnitude(50)
		ef:SetOrigin(ply:GetPos())
		util.Effect("Explosion",ef,true,true)
		util.BlastDamage(ply:GetWeapon("infinitygauntlet"),ply,ply:GetPos(),spd/4,90)
		return 0
	end
end)

hook.Add("EntityTakeDamage","IG_Damages",function(ent,dmg)
	if ent.ig_entity and ent.ig_entity:IsValid() then
		ent.ig_entity:TakeDamageInfo(dmg)
		return true
	end
	
	if ent:HasInfinityStone(IG_STONE_POWER) then
		if dmg:IsDamageType(DMG_CRUSH+DMG_BLAST) then
			return true
		end
		dmg:ScaleDamage(.25)
	end
	
	if ent.IG_soulBonds and !ent.IG_takingSplitDamage then
		dmg:SetDamage(dmg:GetDamage()/table.Count(ent.IG_soulBonds))
		for k,v in pairs(ent.IG_soulBonds) do
			if k:IsValid() then
				k.IG_takingSplitDamage = true
				k:TakeDamageInfo(dmg)
				k.IG_takingSplitDamage = false
			else
				ent.IG_soulBonds[k] = nil
			end
		end
	end
end)

hook.Add("PlayerDeath","IG_RagdolledDeath",function(ply)
	if ply.IG_ragdolled and ply.IG_ragdolled:IsValid() then
		local fakeCorpse = ply:GetRagdollEntity()
		if IsValid(fakeCorpse) then fakeCorpse:Remove() end
	end
end)

hook.Add("CanExitVehicle","IG_KeepPlayerNonExistant",function(veh,ply)
	if !ply:IG_Exists() then
		return false
	end
end)

hook.Add("PlayerLeaveVehicle","IG_MakePlayerExist",function(ply,veh)
	if !ply:IG_Exists() then
		ply:IG_SetExistant(true)
	end
end)

hook.Add("PlayerSpawn","IG_MakePlayerExist",function(ply)
	ply:IG_SetExistant(true)
end)

hook.Add("PlayerDisconnected","IG_ClearExistanceVehicle",function(ply)
	ply:IG_SetExistant(true)
end)

hook.Add("PhysgunPickup","IG_FreezeEntStopPickup",function(ply,ent)
	if !ent:IG_MotionEnabled() then return false end
end)

hook.Add("CanPlayerUnfreeze","IG_FreezeEntStopPickup",function(ply,ent)
	if !ent:IG_MotionEnabled() then return false end
end)

hook.Add("SetupPlayerVisibility","IG_SoulSeeAll",function(ply)
	if ply:GetNWBool("IG_SoulVision",false) then
		for k,v in ipairs(ents.GetAll()) do
			if (v:IsPlayer() or v:IsNPC()) and v != ply then
				AddOriginToPVS(v:GetPos())
			end
		end
	end
end)

hook.Add("OnNPCKilled","IG_SoulBinding",function(npc)
	if npc.IG_soulBonds then
		for k,v in pairs(npc.IG_soulBonds) do
			if k:IsValid() then
				local total = 0
				for l,o in pairs(k.IG_soulBonds) do
					if l:IsValid() and l:Health() > 0 then
						total = total + 1
					end
				end
				if total == 0 then
					k:IG_EnableEffect("soulbond",false)
				end
			end
		end
		npc:IG_EnableEffect("soulbond",false)
	end
end)

function ENT:IG_EnableMotion(bool)
	if self.IG_isMotionEnabled == bool then return end
	self.IG_isMotionEnabled = bool
	self:IG_EnableEffect("motion_disabled",!bool)
	
	if bool then
		local data = self.IG_motionEnabledData
		if !data then
			for i=0,self:GetPhysicsObjectCount()-1 do
				local phys = self:GetPhysicsObjectNum(i)
				if phys:IsValid() then
					phys:EnableMotion(true)
					phys:Wake()
				end
			end
		end
		if self:IsPlayer() then
			self:SetMoveType(data.mv)
			self:UnLock()
			self:SetVelocity(data.vel)
		elseif self:IsNPC() then
			self:SetCondition(68)
			self:SetMoveType(data.moveType)
			if self:GetClass() == "npc_rollermine" or self:GetClass() == "npc_manhack" or self:GetClass() == "npc_clawscanner" or self:GetClass() == "npc_cscanner" then
				local phys = self:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableMotion(true)
				end
			elseif self:GetClass() == "npc_turret_floor" then
				self:SetSaveValue("m_bEnabled", true)
			end
		elseif data and data.isProjectile then
			self:SetMoveType(MOVETYPE_FLYGRAVITY)
		elseif self:GetClass() == "prop_combine_ball" then
			self:SetMoveType(MOVETYPE_VPHYSICS)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(true)
				phys:SetVelocity(data.vel)
			end
			timer.Create("IG_ExplodeCombineBall"..tostring(self:EntIndex()), 3, 1, function()
				if IsValid(self) then
					self:Fire("Explode")
				end
			end)
		elseif data and data.isRagdoll then
			for i=0,self:GetPhysicsObjectCount()-1 do
				local phys = self:GetPhysicsObjectNum(i)
				if phys:IsValid() then
					if data.mv and data.mv[i] then
						phys:EnableMotion(data.mv[i])
						phys:Wake()
					end
					if data.vel and data.vel[i] then
						phys:SetVelocity(data.vel[i])
					end
				end
			end
		elseif data then
			if IsValid(data.phys) then
				data.phys:EnableMotion(data.motionEnabled)
				
				if data.vel then
					data.phys:SetVelocity(data.vel)
				end
				if data.angleVel then
					data.phys:AddAngleVelocity(data.angleVel)
				end
			end
			if data.vel then
				self:SetVelocity(data.vel)
			end
		end
		return
	end
	
	if self:IsPlayer() then
		if !self.IG_motionEnabledData then
			self.IG_motionEnabledData = {
				vel = self:GetVelocity(),
				mv = self:GetMoveType()
			}
		end
		self:Lock()
		self:SetMoveType(MOVETYPE_NONE)
		self:SetLocalVelocity(Vector())
	elseif self:IsNPC() then
		self:SetSchedule(SCHED_NPC_FREEZE)
		if !self.IG_motionEnabledData then
			self.IG_motionEnabledData = {
				moveType = self:GetMoveType()
			}
		end
		self:SetMoveType(MOVETYPE_NONE)
		if self:GetClass() == "npc_rollermine" or self:GetClass() == "npc_manhack" or self:GetClass() == "npc_clawscanner" or self:GetClass() == "npc_cscanner" then
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
			end
		elseif self:GetClass() == "npc_turret_floor" then
			self:SetSaveValue("m_bEnabled", false)
		end
	elseif self:IsRagdoll() and !self.IG_motionEnabledData then
		local savedVelocities = {}
		local savedMotion = {}
		for i=0,self:GetPhysicsObjectCount()-1 do
			local phys = self:GetPhysicsObjectNum(i)
			if phys:IsValid() then
				savedVelocities[i] = phys:GetVelocity()
				if !savedMotion[i] then
					savedMotion[i] = phys:IsMotionEnabled()
				end
				phys:EnableMotion(false)
			end
		end
		self.IG_motionEnabledData = {
			vel = savedVelocities,
			mv = savedMotion,
			isRagdoll = true
		}
	else
		if self:GetClass() == "npc_grenade_frag" then
			if !self.savedtime then self.savedtime = self:GetSaveTable().m_flDetonateTime end
			self:SetSaveValue("m_flDetonateTime", self.savedtime)
		elseif self:GetClass() == "rpg_missile" or self:GetClass() == "crossbow_bolt" then
			if !self.IG_motionEnabledData then self.IG_motionEnabledData = {ang = self:GetAngles(), isProjectile = true} end
			self:SetMoveType(MOVETYPE_NONE)
			self:SetAngles(self.IG_motionEnabledData.ang)
		elseif self:GetClass() == "prop_combine_ball" then
			if timer.Exists("IG_ExplodeCombineBall"..self:EntIndex()) then
				timer.Remove("IG_ExplodeCombineBall"..self:EntIndex())
			end
			
			if !self.IG_motionEnabledData then
				self.IG_motionEnabledData = {
					vel = self:GetVelocity()
				}
			end
			
			self:SetMoveType(MOVETYPE_NONE)
			
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
			end
			
			return
		end
		
		if self:GetClass() == "hunter_flechette" or self:GetClass() == "grenade_ar2" or self:GetClass() == "grenade_spit" then
			if !self.IG_motionEnabledData then
				self.IG_motionEnabledData = {
					isProjectile = true
				}
			end
			self:SetMoveType(MOVETYPE_NONE)
		end
		
		local phys = self:GetPhysicsObject()
		local vel = self:GetVelocity()
		
		self.IG_motionEnabledData = {
			phys = phys,
			health = self:Health(),
			vel = vel
		}
		
		if phys:IsValid() then
			self.IG_motionEnabledData.angleVel = phys:GetAngleVelocity()
			self.IG_motionEnabledData.motionEnabled = phys:IsMotionEnabled()
			phys:SetVelocity(Vector())
			phys:EnableMotion(false)
		end
		self:SetVelocity(Vector())
	end
end

function ENT:IG_MotionEnabled()
	return (self.IG_isMotionEnabled == nil and true or self.IG_isMotionEnabled)
end

function ENT:IG_EnableEffect(effect,data)
	if !self.IG_effects then
		self.IG_effects = {}
	end
	if data and !istable(data) and self.IG_effects[effect] then return end
	if data and !istable(data) then data = {} end
	self.IG_effects[effect] = data
	net.Start("IG_EnableEntityEffect")
	net.WriteEntity(self)
	net.WriteBool(data)
	net.WriteString(effect)
	if data then
		net.WriteTable(data or {})
	end
	net.Broadcast()
end

net.Receive("IG_SelectedStone",function(len,ply)
	local wep = ply:GetWeapon("infinitygauntlet")
	if wep:IsValid() then
		local stoneID = net.ReadUInt(4)
		if !wep:HasStone(stoneID) then return end
		wep.selectedStone = stoneID
		wep.selectedAbility = wep.stoneLastSelectedAbilities[wep.selectedStone] or IG_ZCityFirstAllowedAbility(wep.selectedStone)
		if not IG_ZCityAbilityAllowed(wep.selectedStone, wep.selectedAbility) then
			wep.selectedAbility = IG_ZCityFirstAllowedAbility(wep.selectedStone)
		end
	end
end)

net.Receive("IG_SelectedAbility",function(len,ply)
	local wep = ply:GetWeapon("infinitygauntlet")
	if wep:IsValid() then
		local abilityID = net.ReadUInt(8)
		if wep.selectedStone and not IG_ZCityAbilityAllowed(wep.selectedStone, abilityID) then return end

		wep.selectedAbility = abilityID
		if wep.selectedStone then
			wep.stoneLastSelectedAbilities[wep.selectedStone] = wep.selectedAbility
		end
	end
end)

net.Receive("IG_StoneUsed",function(len,ply)
	local wep = ply:GetActiveWeapon()
	if wep:IsValid() and wep:GetClass() == "infinitygauntlet" then
		local stoneID = net.ReadUInt(4)
		local abilityID = net.ReadUInt(8)
		if not IG_ZCityAbilityAllowed(stoneID, abilityID) then return end
		wep:UseStone(stoneID,abilityID)
	end
end)

net.Receive("IG_StopChanneling",function(len,ply)
	local wep = ply:GetWeapon("infinitygauntlet")
	if wep:IsValid() then
		local stoneID = net.ReadUInt(4)
		wep:StopChannelingStone(stoneID)
	end
end)

net.Receive("IG_ChannelMousewheeled",function(len,ply)
	local wep = ply:GetWeapon("infinitygauntlet")
	if wep:IsValid() then
		for k,v in pairs(wep.channelingStones) do
			if not IG_ZCityAbilityAllowed(k, v.id) then
				wep:StopChannelingStone(k)
				continue
			end

			local ability = IG_StoneData[k].abilities[v.id]
			if ability.OnWheeled then
				ability.OnWheeled(wep,v.data,ability,net.ReadBool() and 1 or -1)
			end
		end
	end
end)

net.Receive("IG_DefineLaw",function(len,ply)
	if ply:HasInfinityStone(IG_STONE_INFINITY) then
		local lawName,law = net.ReadIGLaw()
		IG_StoneData[IG_STONE_INFINITY].abilities[5]:defineLaw(lawName,law)
	end
end)

net.Receive("IG_DeleteLaw",function(len,ply)
	if ply:HasInfinityStone(IG_STONE_INFINITY) then
		IG_StoneData[IG_STONE_INFINITY].abilities[5]:deleteLaw(net.ReadString())
	end
end)

function SWEP:IsChannelingStone(stoneID)
	return self.channelingStones[stoneID] != nil
end

local conVarChecks = {
	[IG_STONE_SOUL] = "ig_enable_soulstone",
	[IG_STONE_MIND] = "ig_enable_mindstone",
	[IG_STONE_POWER] = "ig_enable_powerstone",
	[IG_STONE_REALITY] = "ig_enable_realitystone",
	[IG_STONE_TIME] = "ig_enable_timestone",
	[IG_STONE_SPACE] = "ig_enable_spacestone",
	[IG_STONE_INFINITY] = "ig_enable_infinity",
}

function SWEP:UseStone(stoneID,abilityID)
	if !GetConVar(conVarChecks[stoneID]):GetBool() then self.Owner:ChatPrint("That stone is disabled!") return false end
	if not IG_ZCityAbilityAllowed(stoneID, abilityID) then return false end
	
	local stoneData = IG_StoneData[stoneID]
	if stoneData and stoneData.abilities[abilityID] then
		local ability = stoneData.abilities[abilityID]
		if IG_ZCityIsInfinityStoneRound() and ability.zcityCooldown then
			local cooldownEnd = self:GetZCityAbilityCooldownEnd(stoneID, abilityID)
			if cooldownEnd > CurTime() then
				if (self.zcityNextCooldownNotice or 0) <= CurTime() then
					self.zcityNextCooldownNotice = CurTime() + 1
					self.Owner:ChatPrint("Cooldown: " .. math.ceil(cooldownEnd - CurTime()) .. " seconds")
				end
				return false
			end

			self:SetNWFloat(IG_ZCityAbilityCooldownKey(stoneID, abilityID), CurTime() + ability.zcityCooldown)
		end

		local isChanneled = ability.isChanneled
		if isChanneled and self.channelingStones[stoneID] then
			return
		end
		if !ability.noGlow and !self.channelingStones[stoneID] then
			self:PerformStoneGlow(stoneID,isChanneled)
		end
		if isChanneled then
			self:StartChannelingStone(stoneID,abilityID)
		end
		if ability.Use then
			ability.Use(self,isChanneled and self.channelingStones[stoneID].data,ability)
		end
	end
end

function SWEP:StartChannelingStone(stoneID,abilityID)
	self.channelingStones[stoneID] = {
		id = abilityID,
		data = {}
	}
	local stoneData = IG_StoneData[stoneID]
	if !stoneData then return end
	local abilityData = stoneData.abilities[abilityID]
	if abilityData and !abilityData.noSound then
		self.channelSoundID = self.Owner:StartLoopingSound("IG_ChannelGem1")
	end
end

function SWEP:StopChannelingStone(stoneID)
	local stoneData = IG_StoneData[stoneID]
	if !stoneData or !self.channelingStones[stoneID] then return end
	local abilityData = stoneData.abilities[self.channelingStones[stoneID].id]
	if !abilityData then return end
	if abilityData.FinishChannel then
		abilityData.FinishChannel(self,self.channelingStones[stoneID].data)
	end
	self.channelingStones[stoneID] = nil
	if table.Count(self.channelingStones) > 0 then return end
	if !abilityData.noSound then
		self.Owner:StopLoopingSound(self.channelSoundID)
	end
	self:PerformStoneGlow(stoneID)
end

function SWEP:PerformStoneGlow(stoneID,isChanneled)
	if !IG_StoneData[stoneID] then return end
	self.Owner:EmitSound("xyz/infinitygauntlet/usestone.wav")
	net.Start("IG_StoneUsed")
	net.WriteEntity(self.Owner)
	net.WriteUInt(stoneID,4)
	net.WriteBool(isChanneled)
	net.Broadcast()
end

function SWEP:PrimaryAttack()
	if !self.selectedStone or !self.selectedAbility or (self.lastUse and self.lastUse == CurTime()) then return end
	if !self:HasStone(self.selectedStone) then
		self:DoPunch(50)
		return
	end
	if not IG_ZCityAbilityAllowed(self.selectedStone, self.selectedAbility) then
		self.selectedAbility = IG_ZCityFirstAllowedAbility(self.selectedStone)
		return
	end
	self.lastUse = CurTime()
	
	self:UseStone(self.selectedStone,self.selectedAbility)
end

function SWEP:SecondaryAttack()
	net.Start("IG_OpenAbilityMenu")
	net.Send(self.Owner)
end

function SWEP:Reload()
	net.Start("IG_OpenStoneMenu")
	net.Send(self.Owner)
end

hook.Add("PlayerSpawn","IG_ClearEffects",function(ply)
	net.Start("IG_ClearEntityEffect")
	net.WriteEntity(ply)
	net.Broadcast()
	ply.IG_effects = {}
end)

hook.Add("PlayerInitialSpawn","IG_SyncLaws",function(ply)
	timer.Simple(1,function()
		for k,v in pairs(IG_StoneData[IG_STONE_INFINITY].abilities[5].laws) do
			net.Start("IG_SyncLaw")
			net.WriteIGLaw(k,v)
			net.Send(ply)
		end
	end)
end)
