if !SERVER then return end

local PLY = FindMetaTable("Player")
local ENT = FindMetaTable("Entity")

function ENT:IGUniqueID()
	return self.ig_uniqueID or self:GetCreationID()
end

local function DoesIGExist()
	for k,v in ipairs(player.GetAll()) do
		if v:HasInfinityStone(IG_STONE_TIME) then return true end
	end
	return false
end

local recordFPS = CreateConVar("ig_time_reverse_fps","25",FCVAR_ARCHIVE)
local recordMaxFrames = CreateConVar("ig_time_max_frames","500",FCVAR_ARCHIVE)
local recordBones = CreateConVar("ig_time_record_bones","1",FCVAR_ARCHIVE)
local recordFlex = CreateConVar("ig_time_record_flex","1",FCVAR_ARCHIVE)
local recordConstraints = CreateConVar("ig_time_record_constraints","0",FCVAR_ARCHIVE)

local lastRecorded = 0
local curFrame = 0
local deletingFrame = 0
local entityRecordings = {}
local recordedEvents = {}
local timeRecorderCoroute

local timeFlowing = true

local recording = true
local function Recording()
	return timeFlowing and recording and DoesIGExist()
end
local rewinding = false

local function RestoreEntity(current,set,new)
	if new != current then
		set(new)
	end
end

local function EntToID(ent)
	return ent:IsValid() and ent:IGUniqueID() or -1
end

local function IDToEnt(ID)
	if entityRecordings[ID] then
		return entityRecordings[ID][1]
	end
	return NULL
end

local function CorrectEntsToIDRecursive(tbl)
	for k,v in pairs(tbl) do
		if istable(v) then
			CorrectEntsToIDRecursive(v)
		elseif isentity(v) then
			tbl[k] = {__IsEntUID=true,[1]=EntToID(v)}
		end
	end
end

local function CorrectEntIDsToEntsRecursive(tbl)
	for k,v in pairs(tbl) do
		if istable(v) then
			if v.__IsEntUID then
				tbl[k] = IDToEnt(v[1])
			else
				CorrectEntIDsToEntsRecursive(v)
			end
		end
	end
end

local function RecursiveTableEqual(tbl1,tbl2)
	for k,v in pairs(tbl1) do
		if tbl2[k] == nil then return false end
		if istable(v) then
			if RecursiveTableEqual(v,tbl2[k]) == false then
				return false
			end
		elseif v != tbl2[k] then
			return false
		end
	end
	return true
end

local function RecursiveFrameCopy(dest,src)
	for k,v in pairs(dest) do
		if istable(v) and src[k] and RecursiveTableEqual(v,src[k]) then
			dest[k] = src[k]
		end
	end
end

local function RecursiveTableCopy(src,maxDepth,depth)
	depth = (depth or 0) + 1
	local dest = {}
	for k,v in pairs(src) do
		if istable(v) and (!maxDepth or depth < maxDepth) then
			dest[k] = RecursiveTableCopy(v,maxDepth,depth)
		else
			dest[k] = v
		end
	end
	return dest
end

/*
GLOB_IG_ORIGINALFUNC = GLOB_IG_ORIGINALFUNC or {}

local function RecordEvent(func,...)
	local data = {...}
	local entityIDd = {}
	CorrectEntsToIDRecursive(data)
	if !recordedEvents[curFrame] then
		recordedEvents[curFrame] = {}
	end
	
	recordedEvents[curFrame][#recordedEvents[curFrame]+1] = {
		func,
		data,
		entityIDd
	}
end

local function CatchFunctionEvent(tblName,tbl,funcName)
	local oldFunc = GLOB_IG_ORIGINALFUNC[tblName.."."..funcName] or tbl[funcName]
	GLOB_IG_ORIGINALFUNC[tblName.."."..funcName] = oldFunc
	assert(oldFunc)
	tbl[funcName] = function(...)
		oldFunc(...)
		if !Recording() then return end
		RecordEvent(oldFunc,...)
	end
end

local function CatchFunctionEventHooked(hookName,func)
	hook.Add(hookName,"!!!!11IG_TIMERECORDER",function(...)
		if !Recording() then return end
		RecordEvent(func,...)
	end)
end

if SERVER then
	CatchFunctionEvent("util",util,"Effect")
	CatchFunctionEventHooked("EntityFireBullets",function(ent,data)
		ent:FireBullets(data)
	end)
end*/

local function WritePhysicsDataToTable(phys,tbl)
	tbl.asleep = phys:IsAsleep()
	tbl.pos = phys:GetPos()
	tbl.vel = phys:GetVelocity()
	tbl.angles = phys:GetAngles()
	tbl.angVel = phys:GetAngleVelocity()
	tbl.motionEnabled = phys:IsMotionEnabled()
	tbl.collisionsEnabled = phys:IsCollisionEnabled()
	tbl.gravityEnabled = phys:IsGravityEnabled()
end

local function SetPhysicsDataFromTable(phys,tbl)
	phys:SetPos(tbl.pos)
	phys:SetAngles(tbl.angles)
	phys:EnableMotion(tbl.motionEnabled)
	phys:EnableCollisions(tbl.collisionsEnabled)
	phys:EnableGravity(tbl.gravityEnabled)
	if tbl.asleep then
		phys:Sleep()
	else
		phys:Wake()
		phys:AddVelocity(tbl.vel-phys:GetVelocity())
		phys:AddAngleVelocity(tbl.angVel-phys:GetAngleVelocity())
	end
end

local function ConstraintsFromTable(Constraint,EntityList )
	local Factory = duplicator.ConstraintType[ Constraint.Type ]
	if ( !Factory ) then return end
	local Args = {}
	for k, Key in pairs(Factory.Args) do
		local Val = Constraint[ Key ]
		
		for i=1, 6 do

			if ( Constraint.Entity[ i ] ) then

				if ( Key == "Ent"..i ) then
					--Val = EntityList[ Constraint.Entity[ i ].Index ]
					Val = EntityList[ i ]
					if ( Constraint.Entity[ i ].World ) then
						Val = game.GetWorld()
					end
				end

				if ( Key == "Bone" .. i ) then Val = Constraint.Entity[ i ].Bone or 0 end
				if ( Key == "LPos" .. i ) then Val = Constraint.Entity[ i ].LPos end
				if ( Key == "WPos" .. i ) then Val = Constraint.Entity[ i ].WPos end
				if ( Key == "Length" .. i ) then Val = Constraint.Entity[ i ].Length or 0 end

			end
		end
		
		-- If there's a missing argument then unpack will stop sending at that argument
		if ( Val == nil ) then Val = false end
		
		table.insert( Args, Val )
	
	end
	
	return Factory.Func( unpack(Args) )

end

function ENT:IG_GetTimeFrameData()
	local frameData = {
		pos = self:GetPos(),
		model = self:GetModel(),
		health = self:Health(),
		velocity = self:GetVelocity(),
		table = self:GetTable(),
		netVars = self.GetNetworkVars and self:GetNetworkVars(),
		collisionGroup = self:GetCollisionGroup(),
		sequence = self:GetSequence(),
		cycle = self:GetCycle(),
		parent = EntToID(self:GetParent()),
		owner = EntToID(self:GetOwner()),
		flexScale = self:GetFlexScale(),
		scale = self:GetModelScale(),
		onFire = self:IsOnFire(),
		gravity = self:GetGravity(),
		color = self:GetColor(),
		mat = self:GetMaterial(),
		noDraw = self:GetNoDraw()
	}
	
	if recordFlex:GetBool() and self:GetFlexNum() > 0 then
		frameData.flexWeights = {}
		for i=0,self:GetFlexNum()-1 do
			frameData.flexWeights[i] = self:GetFlexWeight(i)
		end
	end
	
	if recordBones:GetBool() and self:GetBoneCount() > 1 then
		frameData.bonePositions = {}
		frameData.boneAngles = {}
		frameData.boneScales = {}
		for i=0,self:GetBoneCount()-1 do
			frameData.bonePositions[i] = self:GetManipulateBonePosition(i)
			frameData.boneAngles[i] = self:GetManipulateBoneAngles(i)
			frameData.boneScales[i] = self:GetManipulateBoneScale(i)
		end
	end
	
	if self:IsNPC() or self:IsPlayer() then
		if self:GetActiveWeapon():IsValid() then
			frameData.activeWeapon = self:GetActiveWeapon():GetClass()
		end
		if self:IsNPC() then
			frameData.npcState = self:GetNPCState()
			frameData.movementActivity = self:GetMovementActivity()
			frameData.capabilities = self:CapabilitiesGet()
			for c=0,100 do
				if self:HasCondition(c) then
					frameData.condition = c
					break
				end
			end
		end
	end
	
	if self:IsPlayer() then
		frameData.alive = self:Alive()
		frameData.angles = self:EyeAngles()
		frameData.vehicle = EntToID(self:GetVehicle())
		frameData.viewEnt = EntToID(self:GetViewEntity())
		if self:Crouching() then
			frameData.crouching = true
		end
		if self:KeyDown(IN_ZOOM) then
			frameData.zooming = true
		end
	else
		frameData.angles = self:GetAngles()
		
		if recordConstraints:GetBool() then
			frameData.constraints = constraint.GetTable(self)
			if #frameData.constraints > 0 then
				frameData.constraintedEnts = {}
				for k,v in pairs(frameData.constraints) do
					frameData.constraintedEnts[k] = {
						v.Ent1,
						v.Ent2
					}
				end
			end
		end
		
		if self:GetPhysicsObjectCount() <= 1 then
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				frameData.asleep = phys:IsAsleep()
				frameData.pos = phys:GetPos()
				frameData.vel = phys:GetVelocity()
				frameData.angles = phys:GetAngles()
				frameData.angVel = phys:GetAngleVelocity()
				frameData.motionEnabled = phys:IsMotionEnabled()
				frameData.collisionsEnabled = phys:IsCollisionEnabled()
				frameData.gravityEnabled = phys:IsGravityEnabled()
			end
		else
			frameData.physObjects = {}
			for i=0,self:GetPhysicsObjectCount()-1 do
				local phys = self:GetPhysicsObjectNum(i)
				if phys:IsValid() then
					frameData.physObjects[i] = {
						asleep = phys:IsAsleep(),
						pos = phys:GetPos(),
						vel = phys:GetVelocity(),
						angles = phys:GetAngles(),
						angVel = phys:GetAngleVelocity(),
						motionEnabled = phys:IsMotionEnabled(),
						collisionsEnabled = phys:IsCollisionEnabled(),
						gravityEnabled = phys:IsGravityEnabled(),
					}
				end
			end
		end
		
		if self:IsWeapon() then
			frameData.weaponActivity = self:GetActivity()
			frameData.clip1 = self:Clip1()
			frameData.clip2 = self:Clip2()
		end
	end
	
	return frameData
end

local function IG_RecordInfo(data)
	local ent = data[1]
	if ent:IsValid() then
		data[3][curFrame] = ent:IG_GetTimeFrameData()
	end
	if deletingFrame >= 0 then
		data[3][deletingFrame] = nil
	end
end

local entityTableBlacklist = {
	Base = true,
	Spawnable = true,
	PrintName = true,
	Instructions = true,
	Folder = true,
	Type = true,
	Name = true,
	ClassName = true,
	Contact = true,
	Purpose = true,
	AdminOnly = true,
	BaseClass = true,
	dt = true,
	Entity = true,
	Author = true,
}

local function LoadFrameData(data,frame)
	local frameData = data[3][frame]
	if !frameData then return end
	local ent = data[1]
	--Don't rewind gauntlet users or revive NPCs with 0 HP.
	if (ent:HasInfinityStone(IG_STONE_TIME) and ent:Alive()) or (data[6] and frameData.health <= 0) then return end
	if !ent:IsValid() then --Remake it.
		ent = ents.Create(data[4]) --Use saved class
		ent:SetModel(frameData.model)
		ent:SetPos(frameData.pos)
		ent:SetAngles(frameData.angles)
		ent:Spawn()
		ent:Activate()
		--ent.ig_uniqueID = data[5]
		data[1] = ent
	end
	
	if ent:IsValid() then
		if frameData.alive and ent:IsPlayer() and !ent:Alive() then
			ent:Spawn()
		end
		
		if !frameData.onFire then
			if ent:IsOnFire() then
				ent:Extinguish()
			end
		else
			ent:Ignite(50)
		end
		
		RestoreEntity(ent:GetNoDraw(),function(val)
			ent:SetNoDraw(val)
		end,frameData.noDraw)
		
		if frameData.model then
			RestoreEntity(ent:GetModel(),function(val)
				ent:SetModel(val)
				ent:SetModelName(val)
			end,frameData.model)
		end
		
		RestoreEntity(ent:GetMaterial(),function(val)
			ent:SetMaterial(val)
		end,frameData.mat)
		
		RestoreEntity(ent:GetColor(),function(val)
			ent:SetColor(val)
		end,frameData.color)
		
		RestoreEntity(ent:GetGravity(),function(val)
			ent:SetGravity(val)
		end,frameData.gravity)
		
		RestoreEntity(ent:GetTable(),function(val)
			local tbl = ent:GetTable()
			for k,v in pairs(val) do
				if !entityTableBlacklist[k] and !isfunction(v) then
					tbl[k] = v
				end
			end
		end,frameData.table)
		
		if frameData.netVars and table.Count(frameData.netVars) > 0 then
			ent:RestoreNetworkVars(frameData.netVars)
		end
		
		RestoreEntity(ent:GetCollisionGroup(),function(val)
			ent:SetCollisionGroup(val)
		end,frameData.collisionGroup)
		
		RestoreEntity(ent:GetModelScale(),function(val)
			ent:SetModelScale(val)
		end,frameData.scale)
		
		if frameData.owner >= 0 then
			RestoreEntity(ent:GetOwner(),function(val)
				ent:SetOwner(val)
			end,IDToEnt(frameData.owner))
		end
		
		if frameData.parent >= 0 then
			RestoreEntity(ent:GetParent(),function(val)
				ent:SetParent(val)
			end,IDToEnt(frameData.parent))
		end
		
		RestoreEntity(ent:Health(),function(val)
			ent:SetHealth(val)
		end,frameData.health)
		
		RestoreEntity(ent:GetFlexScale(),function(val)
			ent:SetFlexScale(val)
		end,frameData.flexScale)
		
		RestoreEntity(ent:GetSequence(),function(val)
			ent:SetSequence(val)
		end,frameData.sequence)
		
		RestoreEntity(ent:GetCycle(),function(val)
			ent:SetCycle(val)
		end,frameData.cycle)
		
		if frameData.flexWeights and ent:GetFlexNum() > 0 then
			for i=0,ent:GetFlexNum()-1 do
				RestoreEntity(ent:GetFlexWeight(frameData.flexWeights[i]),function(val)
					ent:SetFlexWeight(i,val)
				end,frameData.flexWeights[i])
			end
		end
		
		if frameData.bonePositions and ent:GetBoneCount() > 0 then
			for i=0,math.min(ent:GetBoneCount(),table.Count(frameData.bonePositions))-1 do
				local pos = ent:GetManipulateBonePosition(i)
				RestoreEntity(pos,function(val)ent:ManipulateBonePosition(i,val)end,frameData.bonePositions[i])
				RestoreEntity(ent:GetManipulateBoneAngles(i),function(val)ent:ManipulateBoneAngles(i,val)end,frameData.boneAngles[i])
				RestoreEntity(ent:GetManipulateBoneScale(i),function(val)ent:ManipulateBoneScale(i,val)end,frameData.boneScales[i])
			end
		end
		
		ent:SetLocalVelocity(frameData.velocity)
		
		if ent:IsNPC() or ent:IsPlayer() then
			if frameData.activeWeapon then
				RestoreEntity(ent:GetActiveWeapon():IsValid() and ent:GetActiveWeapon():GetClass(),function(val)
					if ent:IsPlayer() and ent:GetWeapon(val):IsValid() then
						ent:SelectWeapon(val)
					else
						ent:Give(val)
						if ent:IsPlayer() then
							ent:SelectWeapon(val)
						end
					end
				end,frameData.activeWeapon)
			end
		end
		
		if ent:IsPlayer() then
			ent:SetEyeAngles(frameData.angles)
			if frameData.viewEnt >= 0 then
				RestoreEntity(ent:GetViewEntity(),function(val)
					ent:SetViewEntity(val)
				end,IDToEnt(frameData.viewEnt))
			end
			
			if frameData.vehicle >= 0 then
				RestoreEntity(ent:GetVehicle(),function(val)
					if ent:InVehicle() then
						ent:ExitVehicle()
					end
					ent:EnterVehicle(val)
				end,IDToEnt(frameData.parent))
			else
				if ent:InVehicle() then
					ent:ExitVehicle()
				end
			end
			if ent:InVehicle() then return end
		else
			if recordConstraints:GetBool() and frameData.constraintedEnts then
				CorrectEntIDsToEntsRecursive(frameData.constraints)
				for k,v in ipairs(frameData.constraints) do
					ConstraintsFromTable(v,{v.Ent1,v.Ent2})
				end
			end
			
			if !ent:IsNPC() then
				ent:SetAngles(frameData.angles)
				if ent:GetPhysicsObjectCount() <= 1 then
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						SetPhysicsDataFromTable(phys,frameData)
					end
				elseif frameData.physObjects then
					for i,curPhysData in pairs(frameData.physObjects) do
						local curPhys = ent:GetPhysicsObjectNum(i)
						if curPhys:IsValid() then
							SetPhysicsDataFromTable(curPhys,curPhysData)
						end
					end
				end
				
				if ent:IsWeapon() then
					RestoreEntity(ent:Clip1(),function(val)
						ent:SetClip1(val)
					end,frameData.clip1)
					RestoreEntity(ent:Clip2(),function(val)
						ent:SetClip2(val)
					end,frameData.clip2)
					RestoreEntity(ent:GetActivity(),function(val)
						ent:SendWeaponAnim(val)
					end,frameData.weaponActivity)
				end
			else
				RestoreEntity(ent:GetNPCState(),function(val)
					ent:SetNPCState(val)
				end,frameData.npcState)
				RestoreEntity(ent:GetMovementActivity(),function(val)
					ent:SetMovementActivity(val)
				end,frameData.movementActivity)
				RestoreEntity(ent:CapabilitiesGet(),function(val)
					ent:CapabilitiesClear()
					ent:CapabilitiesAdd(val)
				end,frameData.capabilities)
				if frameData.condition then
					ent:SetCondition(frameData.condition)
				end
			end
		end
		
		ent:SetPos(frameData.pos)
	end
end

local function IG_RewindInfo(data)
	if recordFPS:GetInt() > 0 and CurTime() >= (lastRecorded + 1/recordFPS:GetInt()) then
		LoadFrameData(data,curFrame)
	end
end

local allowedClasses = {
	rpg_missile = true,
}

local blacklistedClasses = {
	ig_pocketdimension = true,
	ig_pocketwall = true,
}

function ENT:IG_RecordingEligible()--SetSolidMask to check if nextbot
	if blacklistedClasses[self:GetClass()] then return false end
	if (!allowedClasses[self:GetClass()] and !self.SetSolidMask) and !self:GetPhysicsObject():IsValid() then
		if !self:IsWeapon() then
			return false
		elseif self:GetParent():IsValid() then--If they weapon is being held, do not record.
			if self:GetParent():IsPlayer() or self:GetParent():IsNPC() then --Make sure it's a living being holding it.
				return false
			end
		end
	end
	return true
end

function ENT:IG_GetRecordingTable(ignorePreviousRecording)
	if self.GetCreationID and !self:IsWorld() and (ignorePreviousRecording or !entityRecordings[self:IGUniqueID()]) then
		if self:IG_RecordingEligible() then
			local ID = self:IGUniqueID()
			self.ig_uniqueID = ID
			return {
				self,
				curFrame, --Creation frame
				{}, --Frame data
				self:GetClass(), --Class
				ID, -- ID
				self:IsNPC(), --Is NPC
			},ID
		end
	end
end

function ENT:IG_ClearTimeData()
	local ID = self:IGUniqueID()
	if ID and entityRecordings[ID] then
		entityRecordings[ID].terminate = true
	end
end

function IG_GetTimeSaveState()
	local state = {
		frame = curFrame,
		recordingsData = {}
	}
	
	for id,data in pairs(entityRecordings) do --Depth of 2 copies references to all the frames, since frames themselves never get modified.
		data = RecursiveTableCopy(data,2)
		if data[1]:IsValid() then
			data[3][curFrame] = data[1]:IG_GetTimeFrameData()
		end
		state.recordingsData[id] = data
	end
	
	return state
end

function IG_LoadTimeSaveState(state)
	curFrame = state.frame
	table.Empty(entityRecordings)
	for k,v in pairs(state.recordingsData) do
		entityRecordings[k] = RecursiveTableCopy(v,2)
		LoadFrameData(v,curFrame)
	end
	for k,v in ipairs(ents.GetAll()) do --Delete entities that exist in the future.
		if v.GetCreationID and !v:IsWorld() then
			local data = entityRecordings[v:IGUniqueID()]
			if !data and v:IG_RecordingEligible() then
				v:Remove()
			end
		end
	end
end

if SERVER then
	function IG_StartTimeRewind()
		recording = false
		rewinding = true
		RunConsoleCommand("phys_timescale","0")
	end

	function IG_StopTimeRewind()
		recording = true
		rewinding = false
		RunConsoleCommand("phys_timescale","1")
	end

	local timeStopBlacklist = {
		["worlspawn"] = true,
		["sky_camera"] = true,
		["ai_ally_speech_manager"] = true,
	}
	function IG_SetTimeFlow(bool)
		timeFlowing = bool
		if bool then
			RunConsoleCommand("phys_timescale","1")
			for k,v in ipairs(ents.GetAll()) do
				if v.wasTimeFrozen then
					v.wasTimeFrozen = nil
					if !v:IG_MotionEnabled() then
						v:IG_EnableMotion(true)
					end
				end
			end
		else
			RunConsoleCommand("phys_timescale","0")
		end
	end
	
	function IG_IsTimeFlowing()
		return timeFlowing
	end
	
	local function IG_TimeRecorder()
		if !IG_IsTimeFlowing() then
			for k,v in ipairs(ents.GetAll()) do
				if !timeStopBlacklist[v:GetClass()] and (v:IG_MotionEnabled()) and !v:HasInfinityStone(IG_STONE_TIME) and (v:IsPlayer() or v:IsNPC() or v:GetPhysicsObject():IsValid()) then
					v:IG_EnableMotion(false)
					v.wasTimeFrozen = true
				elseif v:IsNPC() then
					v:SetSchedule(SCHED_NPC_FREEZE)
				end
			end
			return
		end
		
		local isRecording = Recording()
		
		if isRecording or curFrame > 0 then
			if recordFPS:GetInt() > 0 and CurTime() >= (lastRecorded + 1/recordFPS:GetInt()) then
				deletingFrame = curFrame-recordMaxFrames:GetInt()
				for k,v in ipairs(ents.GetAll()) do
					local data,id = v:IG_GetRecordingTable()
					if data then
						entityRecordings[id] = data
					end
				end
				
				for ID,data in pairs(entityRecordings) do
					if data.terminate then
						entityRecordings[ID] = nil
						continue
					end
					
					if curFrame < data[2] then --current frame is before the entity's creation, remove it.
						if data[1]:IsValid() then
							data[1]:Remove()
						end
						entityRecordings[ID] = nil
						continue
					end
					
					if isRecording then
						IG_RecordInfo(data)
						if table.Count(data[3]) == 0 then --This should only happen if the entity doesn't exist, as existing entities constantly have new frames added.
							entityRecordings[ID] = nil
						end
					elseif rewinding then
						IG_RewindInfo(data)
					end
				end
				
				/*if SERVER and rewinding and recordedEvents[curFrame] then
					for k,event in pairs(recordedEvents[curFrame]) do
						CorrectEntIDsToEntsRecursive(event[2])
						event[1](unpack(event[2])) --Run the event function with the same arguments.
					end
				end*/
				
				lastRecorded = CurTime()
				curFrame = curFrame + (rewinding and -1 or 1)
			end
		elseif rewinding then
			IG_StopTimeRewind()
		end
	end

	hook.Add("InitPostEntity","IG_TimeRecorder",IG_TimeRecorder)
	hook.Add("Think","IG_TimeRecorder",IG_TimeRecorder)
	
	hook.Add("PlayerTick","IG_TimeRecorder",function(ply,mv)
		if rewinding then
			if ply:HasInfinityStone(IG_STONE_TIME) then return end
			local data = entityRecordings[ply:IGUniqueID()]
			if data then
				local frameData = data[3][curFrame]
				if frameData then
					if frameData.crouching then
						if !mv:KeyDown(IN_DUCK) then
							mv:SetButtons(bit.bor(mv:GetButtons(),IN_DUCK))
						end
					end
				end
			end
		end
	end)
	
	hook.Add("StartCommand","IG_TimeRecorder",function(ply,cmd)
		local data = entityRecordings[ply:IGUniqueID()]
		if data then
			local frameData = data[3][curFrame-1]
			if frameData then
				if rewinding then
					if frameData.zooming then
						if !cmd:KeyDown(IN_ZOOM) then
							cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ZOOM))
						end
					end
					--cmd:SetButtons(frameData.buttons)
				--else
				--	frameData.buttons = cmd:GetButtons()
				end
			end
		end
	end)
end
