pd106 = pd106 or {}

local class_106 = {
	["npc_cpt_scp_106_old"] = true,
	["npc_cpt_scp_106"] = true,
	["npc_106"] = true,
	["drg_uescp106ver2"] = true,
	["drg_uescp106b2"] = true,
	["106"] = true,
	["npc_cpt_scpunity_106"] = true,
	["dughoo_scpcb_106"] = true,
	["drg_dughoo_old106"] = true,
	["dughoo_scpsl_scp106"] = true,
}

pd106.class_106 = class_106

local function IsPlayerBusyWithPD(ply)
	return IsValid(ply) and timer.Exists(ply:SteamID() .. "_106PD")
end

local function IsNPCBusyWithPD(ent)
	return IsValid(ent) and timer.Exists(ent:EntIndex() .. "_106PD")
end

local function SafeClosePuddle(puddle, delay)
	if not IsValid(puddle) then return end
	if puddle.Closing then return end

	if puddle.SetClosing then
		puddle:SetClosing(CurTime())
	end

	puddle.Closing = true
	SafeRemoveEntityDelayed(puddle, delay or 15)
end

function pd106.CreatePuddle(pos, className, grace)
	local puddle = ents.Create(className or "ent_106pd_puddle")
	if not IsValid(puddle) then return NULL end

	puddle:SetPos(pos)
	puddle:Spawn()
	puddle.PDCreated = true

	if grace then
		puddle.PuddleGrace = CurTime() + grace
	end

	return puddle
end

function pd106.CreateVisualPuddle(pos, className, lifeTime)
	local puddle = pd106.CreatePuddle(pos, className or "ent_106pd_puddle_md")
	if not IsValid(puddle) then return NULL end

	-- ent_106pd_puddle:StartTouch checks PuddleGrace first.
	-- math.huge makes this puddle visual-only, so it will not pull players into PD.
	puddle.PuddleGrace = math.huge
	puddle.S106_VisualOnly = true

	if lifeTime and lifeTime > 0 then
		SafeRemoveEntityDelayed(puddle, lifeTime)
	end

	return puddle
end

function pd106.PutInPD(ply, puddle)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if ply:IsDreaming() or IsPlayerBusyWithPD(ply) then return false end

	ply:EmitSound("scp106pd/corrision.wav")

	if not IsValid(puddle) then
		puddle = pd106.CreatePuddle(ply:GetPos(), "ent_106pd_puddle")
	end

	local oldPuddle = ply.PDOutPuddle
	if IsValid(oldPuddle) and oldPuddle ~= puddle and not oldPuddle.Closing and puddle.PDCreated then
		SafeClosePuddle(oldPuddle, 15)
	end

	ply.PDOutPos = ply:GetPos()
	ply.PDOutPuddle = puddle

	ply:SetMoveType(MOVETYPE_FLY)
	ply:Freeze(true)

	SafeRemoveEntityDelayed(puddle, 60 * 5)

	local startPos = ply:GetPos()
	local startTime = CurTime()
	local timerName = ply:SteamID() .. "_106PD"

	timer.Create(timerName, 0, 0, function()
		if not IsValid(ply) then
			timer.Remove(timerName)
			return
		end

		ply:SetMoveType(MOVETYPE_FLY)
		ply:Freeze(true)
		ply:SetPos(startPos - Vector(0, 0, 40 * (CurTime() - startTime)))
		ply:SetAbsVelocity(vector_origin)
		ply:SetNoTarget(true)
	end)

	timer.Simple(2, function()
		timer.Remove(timerName)
		if not IsValid(ply) then return end

		ply:SetNoTarget(false)
		ply:SetDream("scp106")

		timer.Simple(0.1, function()
			if not IsValid(ply) then return end
			ply:Freeze(false)
		end)
	end)

	return true
end

function pd106.PutNPCInPD(ent, puddle)
	if not IsValid(ent) or not ent:IsNPC() then return false end
	if IsNPCBusyWithPD(ent) then return false end

	ent:EmitSound("scp106pd/corrision.wav")

	if not IsValid(puddle) then
		puddle = pd106.CreatePuddle(ent:GetPos(), "ent_106pd_puddle")
	end

	ent:SetMoveType(MOVETYPE_NONE)
	SafeRemoveEntityDelayed(puddle, 60 * 5)

	local startPos = ent:GetPos()
	local startTime = CurTime()
	local timerName = ent:EntIndex() .. "_106PD"

	timer.Create(timerName, 0, 0, function()
		if not IsValid(ent) then
			timer.Remove(timerName)
			return
		end

		ent:SetPos(startPos - Vector(0, 0, 40 * (CurTime() - startTime)))
		ent:SetAbsVelocity(vector_origin)
	end)

	timer.Simple(3, function()
		timer.Remove(timerName)
		SafeRemoveEntity(ent)
	end)

	return true
end

function pd106.ExitPDSWEP(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if IsPlayerBusyWithPD(ply) or not ply:IsDreaming() then return false end

	local startPos = ply:GetDreamPos()
	local startTime = CurTime()
	local timerName = ply:SteamID() .. "_106PD"

	timer.Create(timerName, 0, 0, function()
		if not IsValid(ply) then
			timer.Remove(timerName)
			return
		end

		ply:Freeze(true)
		ply:SetDreamPos(startPos - Vector(0, 0, 40 * (CurTime() - startTime)))
		ply:SetAbsVelocity(vector_origin)
	end)

	timer.Simple(2, function()
		timer.Remove(timerName)
		if not IsValid(ply) then return end

		pd106.ExitPD(ply, false, true)

		if not IsValid(ply.PDOutPuddle) and ply.PDOutPos then
			local puddle = pd106.CreatePuddle(ply.PDOutPos, "ent_106pd_puddle", 12)
			ply.PDOutPuddle = puddle
		end
	end)

	return true
end

function pd106.ExitPD(ply, trick, dontclose)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if IsPlayerBusyWithPD(ply) then return false end

	ply:SetMoveType(MOVETYPE_FLY)
	ply:Freeze(true)
	ply:SetDream(0)
	ply:EmitSound("scp106pd/decay.wav")

	local startPos = (ply.PDOutPos or ply:GetPos()) - Vector(0, 0, 65)
	local startTime = CurTime()
	local outPuddle = ply.PDOutPuddle

	if IsValid(outPuddle) then
		if not dontclose and outPuddle.PDCreated then
			SafeClosePuddle(outPuddle, 15)
		else
			outPuddle.PuddleGrace = CurTime() + 12
		end
	end

	local timerName = ply:SteamID() .. "_106PD"

	timer.Create(timerName, 0, 0, function()
		if not IsValid(ply) then
			timer.Remove(timerName)
			return
		end

		ply:SetMoveType(MOVETYPE_FLY)
		ply:Freeze(true)
		ply:SetPos(startPos + Vector(0, 0, 40 * (CurTime() - startTime)))
		ply:SetAbsVelocity(vector_origin)
	end)

	timer.Simple(2, function()
		timer.Remove(timerName)
		if not IsValid(ply) then return end

		ply:Freeze(false)
		ply:SetNoTarget(false)
		ply:SetMoveType(MOVETYPE_WALK)
	end)

	return true
end

hook.Add("EntityTakeDamage", "SCP106_PD", function(target, dmg)
	local attacker = IsValid(dmg:GetAttacker()) and dmg:GetAttacker() or dmg:GetInflictor()
	if not IsValid(target) or not IsValid(attacker) then return end
	if not class_106[attacker:GetClass()] then return end
	if not (target:IsPlayer() or target:IsNPC()) then return end

	if target:IsNPC() then
		pd106.PutNPCInPD(target)
		return true
	end

	if target:IsDreaming() then return true end

	pd106.PutInPD(target)
	return true
end)
