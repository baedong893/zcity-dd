AddCSLuaFile()

SWEP.PrintName = "SCP-106 (Dreams)"
SWEP.Category = "Z 시티 SCP 모드"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Author = "eskill / reworked v10 swep only"
SWEP.Purpose = "Left - Use selected ability / hold Phase\nRight - Attack\nQ - Select ability"
SWEP.DisableDuplicator = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false

SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.UseHands = false

local ABILITIES = {
	{ id = "pocket", name = "Pocket Dimension", desc = "가까운 대상을 포켓 디멘션으로 끌고 갑니다." },
	{ id = "selfpd", name = "Enter / Exit PD", desc = "자기 자신이 포켓 디멘션에 들어가거나 나옵니다." },
	{ id = "phase", name = "Phase", desc = "마우스 왼쪽 버튼을 누르고 있는 동안 벽/바닥 속으로 스며듭니다." },
	{ id = "mark", name = "Mark Gate", desc = "바닥에 이동 표식을 설치합니다." },
	{ id = "teleport", name = "Teleport Gate", desc = "설치한 표식 위치로 이동합니다." },
}

local ATTACK_RANGE = 85
local ATTACK_DAMAGE = 75
local DREAM_ATTACK_RANGE = 300
local DREAM_ATTACK_DAMAGE = 50
local POCKET_RANGE = 90
local PHASE_SPEED = 120
local PHASE_AIR_FALL_SPEED = 180
local PHASE_DECAL_INTERVAL = 0.18
local PHASE_DECAL_MOVE_DIST = 36
local PHASE_SURFACE_TRACE = 64
local PHASE_GROUND_CHECK_DIST = 56
local PHASE_ENTER_TRACE_DIST = 54
local PHASE_ENTER_PUSH_DIST = 44
local MARK_RANGE = 1600
local MARK_LIFETIME = 300
local TELEPORT_COOLDOWN = 5
local TELEPORT_SINK_TIME = 0.55
local TELEPORT_RISE_TIME = 0.55
local TELEPORT_SINK_DEPTH = 70
local MARK_COOLDOWN = 1.5
local POCKET_COOLDOWN = 2
local SELF_PD_COOLDOWN = 5
local FLASH_SPEED_MULTIPLIER = 0.75

local PUDDLE_MARK_SMALL = 115
local PUDDLE_MARK_MEDIUM = 210
local PUDDLE_MARK_LARGE = 320
local PUDDLE_MARK_LIFETIME = 18

if SERVER then
	util.AddNetworkString("SCP106_Rebuilt_VisualPuddleMark")
end

if CLIENT then
	local visualPuddleMarks = visualPuddleMarks or {}
	local crackMat = Material("scp106/cracks")
	local puddleMat = Material("scp106/puddle")

	net.Receive("SCP106_Rebuilt_VisualPuddleMark", function()
		local pos = net.ReadVector()
		local normal = net.ReadVector()
		local size = net.ReadFloat()
		local lifeTime = net.ReadFloat()

		if normal:LengthSqr() <= 0 then
			normal = Vector(0, 0, 1)
		else
			normal:Normalize()
		end

		visualPuddleMarks[#visualPuddleMarks + 1] = {
			pos = pos + normal * 1.5,
			normal = normal,
			size = size,
			created = CurTime(),
			death = CurTime() + lifeTime,
			rot = math.Rand(0, 360)
		}
	end)

	hook.Add("PostDrawTranslucentRenderables", "SCP106_Rebuilt_DrawVisualPuddleMarks", function()
		local now = CurTime()

		for i = #visualPuddleMarks, 1, -1 do
			local mark = visualPuddleMarks[i]
			if not mark or mark.death <= now then
				table.remove(visualPuddleMarks, i)
			else
				local fadeIn = math.Clamp((now - mark.created) / 0.35, 0, 1)
				local fadeOut = math.Clamp((mark.death - now) / 2.0, 0, 1)
				local alpha = 255 * fadeIn * fadeOut
				local col = Color(255, 255, 255, alpha)

				render.SetMaterial(crackMat)
				render.DrawQuadEasy(mark.pos + mark.normal * 0.25, mark.normal, mark.size * 0.92, mark.size * 0.92, col, mark.rot)

				render.SetMaterial(puddleMat)
				render.DrawQuadEasy(mark.pos + mark.normal * 0.5, mark.normal, mark.size, mark.size, col, mark.rot + 37)
			end
		end
	end)
end

local function ServerChat(ply, msg)
	if SERVER and IsValid(ply) and ply:IsPlayer() then
		ply:ChatPrint(msg)
	end
end

local function ClampPhaseMoveInput(mv)
	-- v10: 여기서 이동 입력축을 0으로 비우면 W/A/S/D까지 같이 죽어서
	-- Phase 중 제자리 고정처럼 보일 수 있다.
	-- 기본 노클립 가속은 아래의 mv:SetVelocity(moveDir)와 속도 제한으로 제어한다.
end

local function RemoveJumpInput(mv, cmd)
	-- Phase 중 스페이스바 상승/점프를 막는다.
	-- CMoveData/CUserCmd 함수는 환경별 차이가 있어 가능한 방식들을 안전하게 시도한다.
	if mv and mv.GetButtons and mv.SetButtons then
		mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
	end

	if cmd and cmd.GetButtons and cmd.SetButtons then
		cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
	end

	if cmd and cmd.RemoveKey then
		cmd:RemoveKey(IN_JUMP)
	end
end


local abilitySelectionNet = "SCP106_SelectAbility"

function SWEP:IsFlashDisabled()
	return self:GetNWFloat("S106_DisabledUntil", 0) > CurTime()
end

function SWEP:GetSelectedAbility()
	local selectedId = self:GetNWString("S106_SelectedAbility", ABILITIES[1].id)
	for _, ability in ipairs(ABILITIES) do
		if ability.id == selectedId then return ability end
	end
	return ABILITIES[1]
end

local function GetAbility(ply)
	local weapon = IsValid(ply) and ply:GetWeapon("swep_106_pd")
	return IsValid(weapon) and weapon:GetSelectedAbility() or ABILITIES[1]
end

local function CanSelectAbility(ply, weapon)
	return IsValid(ply) and ply:IsPlayer() and ply:Alive()
		and IsValid(weapon) and weapon:GetClass() == "swep_106_pd"
		and weapon:GetOwner() == ply and ply:GetActiveWeapon() == weapon
		and not weapon:IsFlashDisabled()
		and (not zb or zb.ROUND_STATE == 1)
		and not (ply.organism and ply.organism.otrub)
end

if SERVER then
	util.AddNetworkString(abilitySelectionNet)
	net.Receive(abilitySelectionNet, function(_, ply)
		local weapon = net.ReadEntity()
		local abilityId = net.ReadString()
		if not CanSelectAbility(ply, weapon) then return end
		if (weapon.S106_NextAbilitySelection or 0) > CurTime() then return end
		weapon.S106_NextAbilitySelection = CurTime() + 0.15

		-- Keep Phase selected until the player has safely left the wall.
		if ply.S106_PhaseActive then
			ServerChat(ply, "[SCP-106] 벽 밖으로 나온 뒤 능력을 선택하세요.")
			return
		end

		for _, ability in ipairs(ABILITIES) do
			if ability.id == abilityId then
				weapon:SetNWString("S106_SelectedAbility", ability.id)
				ServerChat(ply, "[SCP-106] 능력 선택: " .. ability.name .. " / 좌클릭: 사용")
				ply:EmitSound("buttons/button15.wav")
				return
			end
		end
	end)
end

if CLIENT then
	local normalColor = Color(85, 35, 105, 190)
	local selectedColor = Color(165, 75, 200, 220)

	-- Use the same Q radial-menu extension as Vietnam's team abilities.
	hook.Add("HG_GetRadialMenuOverride", "SCP106_AbilitySelection", function(ply)
		local weapon = IsValid(ply) and ply:GetActiveWeapon()
		if not CanSelectAbility(ply, weapon) then return end

		local options = {}
		for _, ability in ipairs(ABILITIES) do
			local selected = weapon:GetSelectedAbility().id == ability.id
			options[#options + 1] = {
				function()
					if not CanSelectAbility(ply, weapon) then return end
					net.Start(abilitySelectionNet)
						net.WriteEntity(weapon)
						net.WriteString(ability.id)
					net.SendToServer()
				end,
				ability.name .. (selected and " [선택됨]" or "") .. "\n" .. ability.desc .. "\n선택 후 좌클릭으로 사용",
				nil, nil, nil,
				selected and selectedColor or normalColor,
				selectedColor
			}
		end
		options.S106Weapon = weapon
		return options
	end)

	hook.Add("Think", "SCP106_CloseAbilityMenu", function()
		local options = hg and hg.radialOptions
		if not options or not options.S106Weapon then return end
		if not IsValid(MENUPANELHUYHUY) then
			options.S106Weapon = nil
			return
		end
		if CanSelectAbility(LocalPlayer(), options.S106Weapon) then return end
		MENUPANELHUYHUY:Remove()
		table.Empty(options)
	end)
end

local function PlayerIsInsideWorld(ply)
	if not IsValid(ply) then return false end

	local tr = util.TraceHull({
		start = ply:GetPos(),
		endpos = ply:GetPos(),
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs(),
		filter = ply,
		mask = MASK_PLAYERSOLID
	})

	return tr.StartSolid or tr.AllSolid
end

local function PlayerHasGroundBelow(ply)
	if not IsValid(ply) then return false end
	if ply:IsOnGround() then return true end

	local tr = util.TraceHull({
		start = ply:GetPos(),
		endpos = ply:GetPos() - Vector(0, 0, PHASE_GROUND_CHECK_DIST),
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 8),
		filter = ply,
		mask = MASK_PLAYERSOLID
	})

	return tr.Hit and not tr.HitSky
end


local PlaceTraceDecal

local function TryEnterPhaseSurface(ply, mv)
	if not SERVER then return false end
	if not IsValid(ply) then return false end
	if PlayerIsInsideWorld(ply) then return true end
	if not mv:KeyDown(IN_FORWARD) then return false end
	if not PlayerHasGroundBelow(ply) then return false end

	local aim = mv:GetAngles():Forward()
	local flatAim = Vector(aim.x, aim.y, 0)
	if flatAim:LengthSqr() > 0 then flatAim:Normalize() end

	local traces = {}

	-- 아래를 보고 W를 누르면 바닥 속으로 스며든다.
	if aim.z < -0.18 then
		traces[#traces + 1] = {
			dir = Vector(0, 0, -1),
			tr = util.TraceLine({
				-- Trace from the feet: a 54-unit eye trace cannot reach a standing player's floor.
				start = mv:GetOrigin() + Vector(0, 0, 8),
				endpos = mv:GetOrigin() - Vector(0, 0, PHASE_ENTER_TRACE_DIST),
				filter = ply,
				mask = MASK_SOLID_BRUSHONLY
			})
		}
	end

	-- 수평으로 벽을 보고 W를 누르면 벽 속으로 스며든다.
	if flatAim:LengthSqr() > 0 then
		traces[#traces + 1] = {
			dir = flatAim,
			tr = util.TraceLine({
				start = ply:EyePos(),
				endpos = ply:EyePos() + flatAim * PHASE_ENTER_TRACE_DIST,
				filter = ply,
				mask = MASK_SOLID_BRUSHONLY
			})
		}
	end

	for _, data in ipairs(traces) do
		local tr = data.tr
		local dir = data.dir
		if tr and tr.Hit and not tr.HitSky then
			-- 하늘/허공에서는 Phase 진입 금지. 실제 표면을 맞춘 경우에만 노클립 전환.
			PlaceTraceDecal(tr)
			ply.S106_LastSafePos = ply:GetPos()
			ply:SetMoveType(MOVETYPE_NOCLIP)
			-- FinishMove commits CMoveData's origin; SetPos alone is overwritten this tick.
			mv:SetOrigin(mv:GetOrigin() + dir * PHASE_ENTER_PUSH_DIST)
			ply:SetGroundEntity(NULL)
			ply:SetAbsVelocity(vector_origin)
			ply:SetVelocity(vector_origin)
			-- 진입 직후 TraceHull이 아직 solid로 안 잡히는 틱이 있어도
			-- 이동 로직은 벽속 Phase로 계속 진행하게 한다.
			ply.S106_PhaseWasInside = true
			ply.S106_LastPhaseDecalPos = ply:GetPos()
			return true
		end
	end

	return false
end

local function SendVisualPuddleMark(pos, normal, size, lifeTime)
	if CLIENT then return false end
	if not pos then return false end

	normal = normal or Vector(0, 0, 1)
	if normal:LengthSqr() <= 0 then
		normal = Vector(0, 0, 1)
	else
		normal = normal:GetNormalized()
	end

	net.Start("SCP106_Rebuilt_VisualPuddleMark")
		net.WriteVector(pos)
		net.WriteVector(normal)
		net.WriteFloat(size or PUDDLE_MARK_SMALL)
		net.WriteFloat(lifeTime or PUDDLE_MARK_LIFETIME)
	net.Broadcast()

	return true
end

function PlaceTraceDecal(tr, size, lifeTime)
	if not tr or not tr.Hit or tr.HitSky then return false end

	-- 기본 util.Decal/Scorch를 쓰지 않는다.
	-- 기존 ent_106pd_puddle이 쓰는 scp106/cracks + scp106/puddle 재질을
	-- 클라이언트에서 표면 노멀 방향으로 직접 그린다.
	return SendVisualPuddleMark(tr.HitPos, tr.HitNormal, size or PUDDLE_MARK_SMALL, lifeTime or PUDDLE_MARK_LIFETIME)
end

local function PlaceNearestSurfaceDecal(ply)
	if not IsValid(ply) then return false end

	local eyeAng = ply:EyeAngles()
	local pos = ply:GetPos() + Vector(0, 0, 36)
	local dirs = {
		eyeAng:Forward(),
		eyeAng:Forward() * -1,
		eyeAng:Right(),
		eyeAng:Right() * -1,
		Vector(0, 0, -1),
		Vector(0, 0, 1),
	}

	for _, dir in ipairs(dirs) do
		local tr = util.TraceLine({
			start = pos,
			endpos = pos + dir * PHASE_SURFACE_TRACE,
			filter = ply,
			mask = MASK_SOLID_BRUSHONLY
		})

		if PlaceTraceDecal(tr) then return true end
	end

	return false
end

local function PlaceMoveDecal(ply, moveDir)
	if not IsValid(ply) then return false end
	if not moveDir or moveDir:LengthSqr() <= 0 then
		return PlaceNearestSurfaceDecal(ply)
	end

	moveDir = moveDir:GetNormalized()
	local pos = ply:GetPos() + Vector(0, 0, 36)

	local traces = {
		{ start = pos, endpos = pos + moveDir * PHASE_SURFACE_TRACE },
		{ start = pos, endpos = pos - moveDir * PHASE_SURFACE_TRACE },
		{ start = ply:GetPos() + Vector(0, 0, 24), endpos = ply:GetPos() - Vector(0, 0, 72) },
	}

	for _, data in ipairs(traces) do
		local tr = util.TraceLine({
			start = data.start,
			endpos = data.endpos,
			filter = ply,
			mask = MASK_SOLID_BRUSHONLY
		})

		if PlaceTraceDecal(tr) then return true end
	end

	return false
end

local function FindFloorTrace(ply, range)
	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * (range or MARK_RANGE),
		filter = ply,
		mask = MASK_SOLID_BRUSHONLY
	})

	if tr.Hit and not tr.HitSky and tr.HitNormal.z >= 0.65 then
		return tr
	end

	local down = util.TraceLine({
		start = ply:GetPos() + Vector(0, 0, 32),
		endpos = ply:GetPos() - Vector(0, 0, 160),
		filter = ply,
		mask = MASK_SOLID_BRUSHONLY
	})

	if down.Hit and not down.HitSky and down.HitNormal.z >= 0.65 then
		return down
	end

	return tr
end

local function FindSafeTeleportPos(pos)
	local offsets = {
		Vector(0, 0, 8),
		Vector(32, 0, 8), Vector(-32, 0, 8), Vector(0, 32, 8), Vector(0, -32, 8),
		Vector(48, 0, 8), Vector(-48, 0, 8), Vector(0, 48, 8), Vector(0, -48, 8),
		Vector(64, 0, 8), Vector(-64, 0, 8), Vector(0, 64, 8), Vector(0, -64, 8),
	}

	for _, offset in ipairs(offsets) do
		local testPos = pos + offset
		local tr = util.TraceHull({
			start = testPos,
			endpos = testPos,
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 72),
			mask = MASK_PLAYERSOLID
		})

		if not tr.StartSolid and not tr.AllSolid then
			return testPos
		end
	end

	return nil
end

local function FindPhaseAttackTarget(owner)
	if not IsValid(owner) then return end

	local eyePos = owner:EyePos()
	local aim = owner:EyeAngles():Forward()
	local bestEnt
	local bestScore = -math.huge
	local range = ATTACK_RANGE + 65

	for _, ent in ipairs(ents.FindInSphere(eyePos, range)) do
		if ent == owner then continue end
		if not (ent:IsPlayer() or ent:IsNPC()) then continue end
		if ent:IsPlayer() and (not ent:Alive() or ent:Team() == TEAM_SPECTATOR) then continue end

		local targetPos = ent:WorldSpaceCenter()
		local toTarget = targetPos - eyePos
		local dist = toTarget:Length()
		if dist <= 0 then continue end

		local dir = toTarget:GetNormalized()
		local dot = dir:Dot(aim)
		if dot < 0.35 then continue end

		local score = dot * 1000 - dist
		if score > bestScore then
			bestScore = score
			bestEnt = ent
		end
	end

	return bestEnt
end

local function EndPhase(ply, force)
	if not SERVER then return end
	if not IsValid(ply) or not ply.S106_PhaseActive then return end

	local insideWorld = PlayerIsInsideWorld(ply)

	-- 마우스 왼쪽 버튼을 뗐는데 아직 벽/바닥 안이면 밖으로 튕겨내지 않는다.
	-- 그 자리에서 정지하고, 마우스 왼쪽 버튼을 다시 누르면 이어서 움직인다.
	if insideWorld and not force then
		ply.S106_PhasePaused = true
		ply:SetMoveType(MOVETYPE_NOCLIP)
		ply:SetAbsVelocity(vector_origin)
		ply:SetVelocity(vector_origin)
		return
	end

	-- Forced interruptions must not restore WALK while the player is inside solid geometry.
	if insideWorld and force and ply.S106_LastSafePos then
		ply:SetPos(ply.S106_LastSafePos)
	end
	PlaceNearestSurfaceDecal(ply)

	ply.S106_PhaseActive = false
	ply.S106_PhasePaused = nil
	ply.S106_PhaseWeapon = nil
	ply.S106_PhaseWasInside = nil
	ply.S106_NextPhaseDecal = nil
	ply.S106_LastPhaseDecalPos = nil
	ply.S106_LastSafePos = nil

	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetAbsVelocity(vector_origin)
	ply:SetVelocity(vector_origin)
end

function SWEP:CancelActiveAbilities(owner)
	if not SERVER then return end
	owner = owner or self:GetOwner()
	if self.S106_CancelPDEntry then self.S106_CancelPDEntry() end
	if not IsValid(owner) then return end
	EndPhase(owner, true)
	owner.S106_PhaseExitLock = nil
	if self.S106_TeleportReturnPos then
		timer.Remove(owner:SteamID() .. "_S106Teleport")
		owner:SetPos(self.S106_TeleportReturnPos)
		owner:SetMoveType(MOVETYPE_WALK)
		owner:Freeze(false)
		owner:SetAbsVelocity(vector_origin)
		self.S106_TeleportReturnPos = nil
	end
end

function SWEP:ResetSCP106State(owner)
	if not SERVER then return end
	self:CancelActiveAbilities(owner)
	self:SetNWFloat("S106_DisabledUntil", 0)
	self:SetNWFloat("S106_BlindUntil", 0)
end

function SWEP:ApplyFlashDisable(duration, blindDuration)
	if not SERVER then return false end
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:Alive() then return false end
	self:CancelActiveAbilities()
	blindDuration = blindDuration or duration
	local now = CurTime()
	self:SetNWFloat("S106_DisabledUntil", now + duration)
	self:SetNWFloat("S106_BlindUntil", now + blindDuration)
	ServerChat(owner, string.format("[SCP-106] 섬광으로 %g초간 시야가 차단됩니다. %g초간 이동속도가 25%% 감소하고 능력과 무기가 차단됩니다.", blindDuration, duration))
	return true
end

function SWEP:Deploy()
	self:SetHoldType("normal")

	if SERVER then
		local owner = self:GetOwner()
		if IsValid(owner) then
			owner.S106_SelectedAbility = nil -- Retire the old player-local selection.
			ServerChat(owner, "[SCP-106] Q 메뉴: 능력 선택 / 좌클릭: 선택 능력 사용 / 우클릭: 공격")
			ServerChat(owner, "[SCP-106] 현재 능력: " .. GetAbility(owner).name)
		end
	end

	return true
end

function SWEP:Holster()
	if SERVER then
		local owner = self:GetOwner()
		if IsValid(owner) and owner.S106_PhaseActive and PlayerIsInsideWorld(owner) then
			ServerChat(owner, "[SCP-106] 벽 안에서는 무기를 바꿀 수 없습니다. 좌클릭으로 먼저 밖으로 나오세요.")
			return false
		end

		self:CancelActiveAbilities()
	end
	return true
end

function SWEP:OnRemove()
	if SERVER then
		self:ResetSCP106State()
	end
end

function SWEP:OnDrop()
	self:ResetSCP106State()
end

function SWEP:Initialize()
	self:SetHoldType("normal")
	if SERVER and not pd106 then
		print("[SCP-106 SWEP] WARNING: pd106 is not loaded. PD abilities will fail until includes/scp106/pd106.lua is loaded.")
	end
end

function SWEP:ShouldDrawViewModel()
	return false
end

function SWEP:SecondaryAttack()
	if CLIENT or self:IsFlashDisabled() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	self:SetNextSecondaryFire(CurTime() + 0.85)

	if owner:IsDreaming() then
		if owner.DreamRoom and not owner.DreamRoom.notvalid and owner.GetDream and owner:GetDream() then
			local trply = owner:GetDream():TracePlayers(owner.DreamRoom.name, owner:GetDreamPos() + Vector(0, 0, 64), owner:EyeAngles():Forward(), DREAM_ATTACK_RANGE, {[owner] = true})
			if IsValid(trply) then
				trply:TakeDamage(DREAM_ATTACK_DAMAGE, owner, self)
				owner:EmitSound("npc/zombie/claw_strike" .. math.random(1, 3) .. ".wav")
			end
		end
		return
	end

	local ent

	if owner.S106_PhaseActive then
		ent = FindPhaseAttackTarget(owner)
	else
		local tr = owner:GetEyeTraceNoCursor()
		ent = tr.Entity

		if not IsValid(ent) then return end
		if tr.HitPos:DistToSqr(owner:EyePos()) > ATTACK_RANGE * ATTACK_RANGE then return end
	end

	if not IsValid(ent) then return end
	if not (ent:IsPlayer() or ent:IsNPC()) then return end

	ent:TakeDamage(ATTACK_DAMAGE, owner, self)
	owner:EmitSound("npc/zombie/claw_strike" .. math.random(1, 3) .. ".wav")
end

function SWEP:PrimaryAttack()
	if CLIENT or self:IsFlashDisabled() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local ability = GetAbility(owner)

	if ability.id == "pocket" then
		self:UsePocket(owner)
	elseif ability.id == "selfpd" then
		self:UseSelfPD(owner)
	elseif ability.id == "phase" then
		self:StartPhase(owner)
	elseif ability.id == "mark" then
		self:UseMark(owner)
	elseif ability.id == "teleport" then
		self:UseTeleport(owner)
	end
end

function SWEP:Reload()
	-- Abilities use primary fire; reload has no action.
end

function SWEP:Think()
	if CLIENT then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local blindUntil = self:GetNWFloat("S106_BlindUntil", 0)
	if blindUntil ~= 0 and blindUntil <= CurTime() then
		self:SetNWFloat("S106_BlindUntil", 0)
	end
	if self:IsFlashDisabled() then return end
	if self:GetNWFloat("S106_DisabledUntil", 0) ~= 0 then
		self:SetNWFloat("S106_DisabledUntil", 0)
	end

	-- 벽 밖으로 나온 뒤 마우스 왼쪽 버튼을 계속 누르고 있으면 다시 Phase가 시작되는 것을 막는다.
	-- 마우스 왼쪽 버튼을 한 번 떼면 다음 Phase 사용 가능.
	if owner.S106_PhaseExitLock and not owner:KeyDown(IN_ATTACK) then
		owner.S106_PhaseExitLock = nil
	end

	if owner.S106_PhaseActive and not owner:KeyDown(IN_ATTACK) then
		EndPhase(owner, false)
	elseif owner.S106_PhaseActive and owner:KeyDown(IN_ATTACK) and owner.S106_PhasePaused then
		owner.S106_PhasePaused = nil
		owner:SetMoveType(MOVETYPE_NOCLIP)
	end
end

function SWEP:UsePocket(owner)
	if self:IsFlashDisabled() then return end
	if not IsValid(owner) or owner:IsDreaming() then return end
	if self.NextPocket and self.NextPocket > CurTime() then return end
	self.NextPocket = CurTime() + POCKET_COOLDOWN

	if not pd106 or not pd106.PutInPD then
		ServerChat(owner, "[SCP-106] pd106가 로드되지 않아 PD 능력을 사용할 수 없습니다.")
		return
	end

	local tr = owner:GetEyeTraceNoCursor()
	local ent = tr.Entity

	if not IsValid(ent) or not ent:IsPlayer() then
		ServerChat(owner, "[SCP-106] 가까운 플레이어를 바라봐야 합니다.")
		return
	end

	if tr.HitPos:DistToSqr(owner:EyePos()) > POCKET_RANGE * POCKET_RANGE then
		ServerChat(owner, "[SCP-106] 대상이 너무 멉니다.")
		return
	end

	pd106.PutInPD(ent)
	owner:EmitSound("scp106pd/corrision.wav")
end

function SWEP:UseSelfPD(owner)
	if self:IsFlashDisabled() then return end
	if not IsValid(owner) then return end
	if self.NextSelfPD and self.NextSelfPD > CurTime() then return end
	self.NextSelfPD = CurTime() + SELF_PD_COOLDOWN

	if not pd106 or not pd106.PutInPD or not pd106.ExitPDSWEP then
		ServerChat(owner, "[SCP-106] pd106가 로드되지 않아 PD 능력을 사용할 수 없습니다.")
		return
	end

	if owner:IsDreaming() then
		pd106.ExitPDSWEP(owner)
		return
	end

	if not owner:IsOnGround() then
		ServerChat(owner, "[SCP-106] 바닥에 서 있어야 PD에 들어갈 수 있습니다.")
		return
	end

	pd106.PutInPD(owner, nil, self)
end

function SWEP:StartPhase(owner)
	if self:IsFlashDisabled() then return end
	if not IsValid(owner) or owner:IsDreaming() then return end

	-- 밖으로 나온 직후 마우스 왼쪽 버튼을 계속 누르고 있는 동안에는 재진입 금지.
	if owner.S106_PhaseExitLock then return end

	if owner.S106_PhaseActive then
		owner.S106_PhasePaused = nil

		-- 이미 벽/바닥 안에 있거나 NOCLIP Phase 상태일 때만 재개한다.
		-- 밖에 서 있는 상태에서 마우스 왼쪽 버튼이 반복 호출되면 여기서 NOCLIP으로 바꾸지 않는다.
		if PlayerIsInsideWorld(owner) or owner:GetMoveType() == MOVETYPE_NOCLIP then
			owner:SetMoveType(MOVETYPE_NOCLIP)
			owner:SetAbsVelocity(vector_origin)
			owner:SetVelocity(vector_origin)
		end

		return
	end

	owner:EmitSound("scp106pd/laugh.wav")
	PlaceNearestSurfaceDecal(owner)

	local insideWorld = PlayerIsInsideWorld(owner)

	owner.S106_PhaseActive = true
	owner.S106_PhasePaused = nil
	owner.S106_PhaseWeapon = self
	owner.S106_PhaseWasInside = insideWorld
	owner.S106_LastSafePos = owner:GetPos()
	owner.S106_NextPhaseDecal = 0
	owner.S106_LastPhaseDecalPos = owner:GetPos()

	-- 밖에서는 바로 노클립을 켜지 않는다.
	-- 실제로 벽/바닥 표면을 향해 스며드는 순간에만 SetupMove에서 MOVETYPE_NOCLIP으로 전환한다.
	if insideWorld then
		owner:SetMoveType(MOVETYPE_NOCLIP)
		owner:SetAbsVelocity(vector_origin)
		owner:SetVelocity(vector_origin)
	else
		owner:SetMoveType(MOVETYPE_WALK)
		-- 밖에 있을 때는 현재 WALK 이동 속도를 죽이지 않는다.
		-- 여기서 속도를 0으로 만들면 마우스 왼쪽 버튼을 누른 순간 앞으로 가려 해도 고정된다.
	end
end

function SWEP:UseMark(owner)
	if self:IsFlashDisabled() then return end
	if not IsValid(owner) or owner:IsDreaming() then return end
	if self.NextMark and self.NextMark > CurTime() then return end
	self.NextMark = CurTime() + MARK_COOLDOWN

	local tr = FindFloorTrace(owner, MARK_RANGE)
	if not tr.Hit or tr.HitSky or tr.HitNormal.z < 0.65 then
		ServerChat(owner, "[SCP-106] 표식은 바닥에만 설치할 수 있습니다.")
		return
	end

	owner.S106_GatePos = tr.HitPos + tr.HitNormal * 4
	owner.S106_GateNormal = tr.HitNormal

	if IsValid(owner.S106_GatePuddle) then
		SafeRemoveEntity(owner.S106_GatePuddle)
	end

	if pd106 and pd106.CreateVisualPuddle then
		owner.S106_GatePuddle = pd106.CreateVisualPuddle(tr.HitPos, "ent_106pd_puddle_md", MARK_LIFETIME)
	end

	PlaceTraceDecal(tr, PUDDLE_MARK_MEDIUM, MARK_LIFETIME)
	owner:EmitSound("npc/ichthyosaur/water_growl5.wav")
	ServerChat(owner, "[SCP-106] 이동 표식을 설치했습니다.")
end

function SWEP:UseTeleport(owner)
	if self:IsFlashDisabled() then return end
	if not IsValid(owner) or owner:IsDreaming() then return end
	if self.NextTeleport and self.NextTeleport > CurTime() then return end
	if timer.Exists(owner:SteamID() .. "_S106Teleport") then return end
	self.NextTeleport = CurTime() + TELEPORT_COOLDOWN

	if not owner.S106_GatePos then
		ServerChat(owner, "[SCP-106] 설치된 이동 표식이 없습니다.")
		return
	end

	local safePos = FindSafeTeleportPos(owner.S106_GatePos)
	if not safePos then
		ServerChat(owner, "[SCP-106] 표식 주변에 안전한 이동 위치가 없습니다.")
		return
	end

	local startPos = owner:GetPos()
	self.S106_TeleportReturnPos = startPos
	local startTime = CurTime()
	local timerName = owner:SteamID() .. "_S106Teleport"
	local switchedToExit = false

	PlaceNearestSurfaceDecal(owner)
	owner:EmitSound("scp106pd/decay.wav")
	owner:SetMoveType(MOVETYPE_FLY)
	owner:Freeze(true)
	owner:SetAbsVelocity(vector_origin)
	owner:SetVelocity(vector_origin)

	timer.Create(timerName, 0, 0, function()
		if not IsValid(owner) then
			timer.Remove(timerName)
			return
		end

		if not IsValid(self) then
			owner:SetPos(startPos)
			owner:SetMoveType(MOVETYPE_WALK)
			owner:Freeze(false)
			timer.Remove(timerName)
			return
		end
		if not owner:Alive() or self:IsFlashDisabled() or owner:GetActiveWeapon() ~= self then
			self:CancelActiveAbilities()
			return
		end

		owner:SetMoveType(MOVETYPE_FLY)
		owner:Freeze(true)
		owner:SetAbsVelocity(vector_origin)
		owner:SetVelocity(vector_origin)

		local elapsed = CurTime() - startTime
		if elapsed < TELEPORT_SINK_TIME then
			local progress = math.Clamp(elapsed / TELEPORT_SINK_TIME, 0, 1)
			owner:SetPos(startPos - Vector(0, 0, TELEPORT_SINK_DEPTH * progress))
			return
		end

		if not switchedToExit then
			switchedToExit = true
			self.S106_TeleportReturnPos = safePos
			PlaceNearestSurfaceDecal(owner)
			owner:SetPos(safePos - Vector(0, 0, TELEPORT_SINK_DEPTH))
			owner:EmitSound("scp106pd/laugh.wav")
		end

		local riseElapsed = elapsed - TELEPORT_SINK_TIME
		if riseElapsed < TELEPORT_RISE_TIME then
			local progress = math.Clamp(riseElapsed / TELEPORT_RISE_TIME, 0, 1)
			owner:SetPos(safePos - Vector(0, 0, TELEPORT_SINK_DEPTH * (1 - progress)))
			return
		end

		self.S106_TeleportReturnPos = nil
		owner:SetPos(safePos)
		owner:SetMoveType(MOVETYPE_WALK)
		owner:Freeze(false)
		owner:SetAbsVelocity(vector_origin)
		owner:SetVelocity(vector_origin)
		PlaceNearestSurfaceDecal(owner)
		timer.Remove(timerName)
	end)
end

hook.Add("SetupMove", "SCP106_Rebuilt_PhaseMove", function(ply, mv, cmd)
	if CLIENT then return end
	if not IsValid(ply) or not ply.S106_PhaseActive then return end

	-- Phase 키를 누르는 동안 스페이스바 점프/상승은 항상 차단한다.
	RemoveJumpInput(mv, cmd)

	local wep = ply.S106_PhaseWeapon
	if not IsValid(wep) or ply:GetActiveWeapon() ~= wep then
		if PlayerIsInsideWorld(ply) then
			ply:SelectWeapon("swep_106_pd")
			return
		end

		EndPhase(ply, true)
		return
	end

	local insideWorld = PlayerIsInsideWorld(ply)

	if ply.S106_PhasePaused or not mv:KeyDown(IN_ATTACK) then
		mv:SetVelocity(vector_origin)
		mv:SetMaxClientSpeed(1)
		mv:SetMaxSpeed(1)
		return
	end

	-- 밖에서는 노클립 비행을 허용하지 않는다.
	-- 표면을 향해 실제로 스며들 때만 노클립으로 바꾸고, 그 전에는 일반 이동 상태를 유지한다.
	if not insideWorld and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
		-- 아직 표면 안에 들어가지 않은 상태에서는 일반 WALK 이동을 살려둔다.
		-- 여기서 입력축을 0으로 만들면 마우스 왼쪽 버튼을 누른 순간 바닥에 고정되는 문제가 생긴다.
		ply:SetMoveType(MOVETYPE_WALK)
		if TryEnterPhaseSurface(ply, mv) then
			insideWorld = true
		else
			return
		end
	end

	-- 실제 NOCLIP Phase에 들어간 뒤에만 기본 노클립 입력을 지운다.
	-- 우리가 아래에서 계산한 moveDir 속도는 그대로 적용된다.
	ClampPhaseMoveInput(mv)

	local ang = mv:GetAngles()
	local aim = ang:Forward()
	local flatAim = Vector(aim.x, aim.y, 0)
	if flatAim:LengthSqr() > 0 then flatAim:Normalize() end

	local right = ang:Right()
	right.z = 0
	if right:LengthSqr() > 0 then right:Normalize() end

	local moveDir = Vector(0, 0, 0)

	local hasGroundBelow = PlayerHasGroundBelow(ply)

	if mv:KeyDown(IN_FORWARD) then
		if insideWorld then
			moveDir = moveDir + aim
		elseif hasGroundBelow then
			-- 밖에서는 비행 금지. 수평 이동만 하되, 아래를 보면 바닥 속으로만 스며들 수 있다.
			local outsideAim = Vector(aim.x, aim.y, math.min(aim.z, 0))
			if outsideAim:LengthSqr() > 0 then outsideAim:Normalize() end
			moveDir = moveDir + outsideAim
		end
	end

	if mv:KeyDown(IN_BACK) then
		if insideWorld then
			moveDir = moveDir - aim
		elseif hasGroundBelow then
			moveDir = moveDir - flatAim
		end
	end

	if mv:KeyDown(IN_MOVERIGHT) and (insideWorld or hasGroundBelow) then
		moveDir = moveDir + right
	end

	if mv:KeyDown(IN_MOVELEFT) and (insideWorld or hasGroundBelow) then
		moveDir = moveDir - right
	end

	if insideWorld then
		-- 스페이스바 상승은 금지. 위/아래 이동은 시야 방향 + W/S로만 한다.
		if mv:KeyDown(IN_DUCK) then moveDir.z = moveDir.z - 0.55 end
	else
		if hasGroundBelow then
			if mv:KeyDown(IN_DUCK) then moveDir.z = moveDir.z - 0.55 end
			ply.S106_LastSafePos = ply:GetPos()
		else
			-- 공중에서는 노클립 비행처럼 움직이지 말고 아래로만 떨어지게 한다.
			moveDir = Vector(0, 0, -PHASE_AIR_FALL_SPEED / PHASE_SPEED)
		end
	end

	if moveDir:LengthSqr() > 0 then
		moveDir:Normalize()
		moveDir = moveDir * PHASE_SPEED
	end

	mv:SetVelocity(moveDir)
	mv:SetMaxClientSpeed(PHASE_SPEED)
	mv:SetMaxSpeed(PHASE_SPEED)

	if insideWorld and not ply.S106_PhaseWasInside then
		PlaceNearestSurfaceDecal(ply)
	elseif not insideWorld and ply.S106_PhaseWasInside then
		-- 벽/바닥 밖으로 나온 순간 즉시 Phase를 종료한다.
		-- 마우스 왼쪽 버튼을 계속 누르고 있어도 더 이상 노클립 상태로 움직이지 않는다.
		PlaceNearestSurfaceDecal(ply)
		ply.S106_PhaseExitLock = true
		EndPhase(ply, true)
		mv:SetVelocity(vector_origin)
		mv:SetMaxClientSpeed(1)
		mv:SetMaxSpeed(1)
		return
	end

	ply.S106_PhaseWasInside = insideWorld

	-- 정지 중에는 흔적을 계속 만들지 않는다.
	-- 마우스 왼쪽 버튼을 처음 누를 때 한 번, 벽/바닥 입출입 때 한 번, 실제로 움직인 거리마다 한 번만 생성한다.
	if moveDir:LengthSqr() > 0 and CurTime() >= (ply.S106_NextPhaseDecal or 0) then
		local lastDecalPos = ply.S106_LastPhaseDecalPos
		local movedEnough = not lastDecalPos or ply:GetPos():DistToSqr(lastDecalPos) >= PHASE_DECAL_MOVE_DIST * PHASE_DECAL_MOVE_DIST

		if movedEnough then
			ply.S106_NextPhaseDecal = CurTime() + PHASE_DECAL_INTERVAL
			ply.S106_LastPhaseDecalPos = ply:GetPos()
			PlaceMoveDecal(ply, moveDir:GetNormalized())
		end
	end
end)

hook.Add("PlayerSwitchWeapon", "SCP106_Rebuilt_EndPhaseSwitch", function(ply, oldWep, newWep)
	if not IsValid(ply) then return end
	local weapon = ply:GetWeapon("swep_106_pd")
	if IsValid(weapon) and weapon:IsFlashDisabled() then return true end
	if not ply.S106_PhaseActive then return end

	if PlayerIsInsideWorld(ply) then
		ply:SelectWeapon("swep_106_pd")
		ServerChat(ply, "[SCP-106] 벽 안에서는 무기를 바꿀 수 없습니다. 좌클릭으로 먼저 밖으로 나오세요.")
		return true
	end

	EndPhase(ply, true)
end)

local function GetDisabledWeapon(ply)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	local weapon = ply:GetWeapon("swep_106_pd")
	if IsValid(weapon) and weapon:IsFlashDisabled() then return weapon end
end

-- Use the shared movement multiplier after mode rules, before inertia applies speed.
-- Slowdown shares the ability-lock expiry; repeated hits refresh it without stacking.
hook.Add("HG_MovementCalc_2", "SCP106_FlashSlowMovement", function(mul, ply)
	if not GetDisabledWeapon(ply) then return end
	mul[1] = mul[1] * FLASH_SPEED_MULTIPLIER
end)

hook.Add("StartCommand", "SCP106_FlashBlockWeapons", function(ply, cmd)
	if not GetDisabledWeapon(ply) then return end
	cmd:RemoveKey(IN_ATTACK)
	cmd:RemoveKey(IN_ATTACK2)
	cmd:RemoveKey(IN_RELOAD)
end)

hook.Add("EntityFireBullets", "SCP106_FlashBlockBullets", function(ent)
	if GetDisabledWeapon(ent) then return false end
end)

if SERVER then
	local function ResetPlayer(ply)
		local weapon = IsValid(ply) and ply:GetWeapon("swep_106_pd")
		if IsValid(weapon) then weapon:ResetSCP106State() end
	end
	-- Reuse stable hook IDs so auto-refresh replaces the previous callbacks.
	hook.Add("PlayerDeath", "SCP106_Rebuilt_EndPhaseDeath", ResetPlayer)
	hook.Add("PlayerDisconnected", "SCP106_Rebuilt_EndPhaseDisconnect", ResetPlayer)
	hook.Add("PlayerSpawn", "SCP106_ResetAbilities", ResetPlayer)
	hook.Add("PlayerDroppedWeapon", "SCP106_ResetAbilities", function(ply, weapon)
		if IsValid(weapon) and weapon:GetClass() == "swep_106_pd" then
			weapon:ResetSCP106State(ply)
		end
	end)
	local function ResetAll()
		for _, weapon in ipairs(ents.FindByClass("swep_106_pd")) do
			weapon:ResetSCP106State()
		end
	end
	hook.Add("PreCleanupMap", "SCP106_ResetAbilities", ResetAll)
	hook.Add("OnReloaded", "SCP106_ResetAbilities", ResetAll)
end

if CLIENT then
	hook.Add("PostDrawHUD", "SCP106_FlashBlindness", function()
		local ply = LocalPlayer()
		if not IsValid(ply) or not ply:Alive() then return end
		local weapon = ply:GetWeapon("swep_106_pd")
		if not IsValid(weapon) or weapon:GetNWFloat("S106_BlindUntil", 0) <= CurTime() then return end
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end)
end
