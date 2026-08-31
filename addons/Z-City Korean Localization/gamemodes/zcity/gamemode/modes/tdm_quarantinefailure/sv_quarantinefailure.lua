local MODE = MODE

local ROLE_COLORS = {
	carrier = Color(205, 60, 60),
	doctor = Color(70, 210, 130),
	soldier = Color(70, 145, 255),
	citizen = Color(185, 185, 185),
	infected = Color(115, 210, 65)
}

local ROLE_NAMES = {
	carrier = "Patient Zero",
	doctor = "Doctor",
	soldier = "Soldier",
	citizen = "Citizen",
	infected = "Infected"
}

local ZOMBIE_MODEL = "models/player/zombie_classic.mdl"
local REPORT_DISTANCE_SQR = 2500 * 2500
local REPORT_TIME = 3

local function IsQuarantineRound()
	local round = CurrentRound and CurrentRound()
	return round and round.name == "quarantinefailure" and zb.ROUND_STATE == 1
end

local function RoundPlayers(excluded)
	local players = {}

	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:IsPlayer() and ply ~= excluded and ply:Team() ~= TEAM_SPECTATOR then
			players[#players + 1] = ply
		end
	end

	return players
end

local function Shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end

	return tbl
end

local function PlayerTimerKey(prefix, ply)
	local steamID64 = IsValid(ply) and ply:SteamID64() or "0"
	local entIndex = IsValid(ply) and ply:EntIndex() or 0
	return "ZC_QF_" .. prefix .. "_" .. steamID64 .. "_" .. entIndex
end

function MODE:CanLaunch()
	return #RoundPlayers() >= self.MinPlayers
end

function MODE:CreateTrackedTimer(name, delay, repetitions, callback)
	self.saved.TimerNames = self.saved.TimerNames or {}
	self.saved.TimerNames[name] = true

	timer.Create(name, delay, repetitions, function()
		if repetitions == 1 and self.saved and self.saved.TimerNames then
			self.saved.TimerNames[name] = nil
		end

		callback()
	end)
end

function MODE:RemoveTrackedTimer(name)
	if timer.Exists(name) then timer.Remove(name) end
	if self.saved and self.saved.TimerNames then self.saved.TimerNames[name] = nil end
end

function MODE:RemoveAllTrackedTimers()
	for name in pairs((self.saved and self.saved.TimerNames) or {}) do
		if timer.Exists(name) then timer.Remove(name) end
	end

	if self.saved then self.saved.TimerNames = {} end
end

function MODE:GetRole(ply)
	if not IsValid(ply) then return "" end
	return ply:GetNWString("ZC_QuarantineRole", "")
end

function MODE:IsRole(ply, role)
	return self:GetRole(ply) == role
end

function MODE:SetRole(ply, role)
	if not IsValid(ply) then return end

	ply:SetNWString("ZC_QuarantineRole", role or "")
	ply:SetTeam((role == "carrier" or role == "infected") and 1 or 0)

	if role and role ~= "" then
		zb.GiveRole(ply, ROLE_NAMES[role] or role, ROLE_COLORS[role] or color_white)
	end
end

function MODE:GetInfectionState(ply)
	if not IsValid(ply) then return "" end
	return ply:GetNWString("ZC_QuarantineInfectionState", "healthy")
end

function MODE:SetInfectionState(ply, state, conversionTime)
	if not IsValid(ply) then return end

	ply:SetNWString("ZC_QuarantineInfectionState", state or "healthy")
	ply:SetNWFloat("ZC_QuarantineConversionTime", conversionTime or 0)
	ply:SetNWBool("ZC_QuarantineInfected", state == "infected")
	ply:SetNWBool("ZC_QuarantineExposed", state == "exposed")
end

local function GiveWeapon(ply, class, spareMagazines)
	if not IsValid(ply) or not class or not weapons.GetStored(class) then
		print("[Containment Failure] missing weapon class: " .. tostring(class))
		return
	end

	local wep = ply:Give(class)
	if not IsValid(wep) then return end

	wep.WorkWithFake = true
	wep.ZC_QuarantineWeapon = true

	local ammoType = wep:GetPrimaryAmmoType()
	local maxClip = wep:GetMaxClip1()
	if spareMagazines and spareMagazines > 0 and ammoType and ammoType >= 0 and maxClip and maxClip > 0 then
		ply:GiveAmmo(maxClip * spareMagazines, ammoType, true)
	end

	return wep
end

function MODE:GiveWeaponDelayed(ply, class, delay, selectAfter, spareMagazines)
	local timerName = PlayerTimerKey("give_" .. tostring(class), ply)
	self:CreateTrackedTimer(timerName, delay or 0.25, 1, function()
		if not IsQuarantineRound() or not IsValid(ply) or not ply:Alive() then return end

		local wep = GiveWeapon(ply, class, spareMagazines)
		if selectAfter and IsValid(wep) then
			ply:SelectWeapon(class)
		end
	end)
end

function MODE:ClearLoadout(ply)
	if not IsValid(ply) then return end
	ply:StripWeapons()
	ply:RemoveAllAmmo()
end

function MODE:GiveRoleLoadout(ply, role, selectPrimary)
	if not IsValid(ply) or not ply:Alive() then return end

	self:ClearLoadout(ply)
	GiveWeapon(ply, "weapon_hands_sh")

	if role == "carrier" then
		self:GiveWeaponDelayed(ply, self.BiohazardWeapon, 0.25, selectPrimary)
	elseif role == "doctor" then
		if not self.saved.CureSpent then
			self:GiveWeaponDelayed(ply, self.CureWeapon, 0.25, selectPrimary)
		end
	elseif role == "soldier" then
		local soldierWeapon = weapons.GetStored(self.SoldierWeapon) and self.SoldierWeapon or self.SoldierFallbackWeapon
		self:GiveWeaponDelayed(ply, soldierWeapon, 0.25, selectPrimary, 1)
		ply:SetArmor(75)
		if hg and hg.AddArmor then hg.AddArmor(ply, {"vest3", "helmet1"}) end
	elseif role == "citizen" then
		local phone = GiveWeapon(ply, self.PhoneWeapon)
		if selectPrimary and IsValid(phone) then ply:SelectWeapon(self.PhoneWeapon) end
	elseif role == "infected" then
		local zombie = GiveWeapon(ply, self.ZombieWeapon)
		if IsValid(zombie) then ply:SelectWeapon(self.ZombieWeapon) end
	end
end

function MODE:ClearPlayerState(ply, restoreAppearance)
	if not IsValid(ply) then return end

	self:RemoveTrackedTimer(PlayerTimerKey("infect", ply))
	self:RemoveTrackedTimer(PlayerTimerKey("report", ply))
	self:RemoveTrackedTimer(PlayerTimerKey("report_expire", ply))

	ply:Freeze(false)
	ply.ZC_QuarantineReporting = nil
	ply.ZC_QuarantineReportTarget = nil
	ply:SetNWBool("ZC_QuarantineReporting", false)
	ply:SetNWBool("ZC_QuarantineReported", false)
	self:SetInfectionState(ply, "healthy", 0)
	ply:SetNWString("ZC_QuarantineRole", "")
	if ply:Team() ~= TEAM_SPECTATOR then ply:SetTeam(0) end

	if restoreAppearance and self.saved and self.saved.OriginalModels and self.saved.OriginalModels[ply] then
		ply:SetModel(self.saved.OriginalModels[ply])
	end

	ply:SetMaxHealth(100)
	if ply:Alive() then ply:SetHealth(math.min(math.max(ply:Health(), 1), 100)) end
	ply:SetArmor(0)
end

function MODE:AssignRoles(players)
	players = Shuffle(players or RoundPlayers())
	if #players < self.MinPlayers then
		self.saved.RolesReady = false
		return false
	end

	self.saved.Carrier = players[1]
	self.saved.Doctor = players[2]
	self.saved.Soldier = players[3]
	self.saved.RolesReady = true

	return true
end

function MODE:Intermission()
	game.CleanUpMap()
	self:RemoveAllTrackedTimers()

	self.saved.Winner = nil
	self.saved.OutbreakStarted = false
	self.saved.CureSpent = false
	self.saved.ReportedTarget = nil
	self.saved.TimerNames = {}
	self.saved.OriginalRoles = {}
	self.saved.OriginalModels = {}
	self.saved.RoundEntities = {}

	local players = RoundPlayers()
	for _, ply in ipairs(players) do
		ApplyAppearance(ply)
		ply:SetupTeam(0)
		self:ClearPlayerState(ply, false)
		self.saved.OriginalModels[ply] = ply:GetModel()
	end

	self:AssignRoles(players)
end

function MODE:RoundStart()
	if not self.saved.RolesReady and not self:AssignRoles(RoundPlayers()) then return end

	for _, ply in ipairs(RoundPlayers()) do
		if ply:Alive() then
			ply:SetSuppressPickupNotices(true)
			ply.noSound = true
			ply:SetMaxHealth(100)
			ply:SetHealth(100)
			ply:SetArmor(0)
			if ply.organism then ply.organism.allowholster = true end
			self:SetInfectionState(ply, "healthy", 0)

			local role = "citizen"
			if ply == self.saved.Carrier then
				role = "carrier"
			elseif ply == self.saved.Doctor then
				role = "doctor"
			elseif ply == self.saved.Soldier then
				role = "soldier"
			end

			self:SetRole(ply, role)
			self.saved.OriginalRoles[ply] = role
			self.saved.OriginalModels[ply] = self.saved.OriginalModels[ply] or ply:GetModel()
			self:GiveRoleLoadout(ply, role, true)

			if role == "carrier" then
				ply:ChatPrint("당신은 최초 감염원입니다. 바이오볼을 먹거나 던져 감염을 시작하세요.")
			elseif role == "doctor" then
				ply:ChatPrint("당신은 의사입니다. 치료제는 단 한 번만 사용할 수 있습니다.")
			elseif role == "soldier" then
				ply:ChatPrint("당신은 격리군입니다. 시민의 신고를 확인하고 감염자를 저지하세요.")
			else
				ply:ChatPrint("당신은 시민입니다. 휴대폰으로 수상한 사람을 신고하세요.")
			end

			local noticeTimer = PlayerTimerKey("notices", ply)
			self:CreateTrackedTimer(noticeTimer, 0.35, 1, function()
				if not IsValid(ply) then return end
				ply.noSound = false
				ply:SetSuppressPickupNotices(false)
			end)
		end
	end
end

function MODE:BeginInfection(ply, source)
	if not IsQuarantineRound() or not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return false end
	if ply:Team() == TEAM_SPECTATOR then return false end

	local state = self:GetInfectionState(ply)
	if state == "exposed" or state == "infected" then return false end

	local role = self:GetRole(ply)
	if role == "" or role == "soldier_dead" then return false end

	self.saved.OutbreakStarted = true
	self.saved.OriginalRoles[ply] = self.saved.OriginalRoles[ply] or role
	self.saved.OriginalModels[ply] = self.saved.OriginalModels[ply] or ply:GetModel()

	local conversionTime = CurTime() + self.InfectionDelay
	self:SetInfectionState(ply, "exposed", conversionTime)
	ply:ChatPrint("감염되었습니다. " .. self.InfectionDelay .. "초 안에 치료받아야 합니다.")

	local timerName = PlayerTimerKey("infect", ply)
	self:RemoveTrackedTimer(timerName)
	self:CreateTrackedTimer(timerName, self.InfectionDelay, 1, function()
		if not IsQuarantineRound() or not IsValid(ply) or not ply:Alive() then return end
		if self:GetInfectionState(ply) ~= "exposed" then return end
		self:TransformInfected(ply, source)
	end)

	return true
end

function MODE:TransformInfected(ply, source)
	if not IsValid(ply) or not ply:Alive() then return false end

	self:SetInfectionState(ply, "infected", 0)
	self:SetRole(ply, "infected")
	ply:SetModel(ZOMBIE_MODEL)
	ply:SetMaxHealth(150)
	ply:SetHealth(150)
	ply:SetArmor(0)
	self:GiveRoleLoadout(ply, "infected", true)
	ply:EmitSound("npc/zombie/zo_attack" .. math.random(1, 2) .. ".wav")
	ply:ChatPrint("좀비로 변이했습니다. 생존자를 공격해 감염시키세요.")

	return true
end

function MODE:TryCure(ply, doctor)
	if not IsQuarantineRound() or not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return false end

	local state = self:GetInfectionState(ply)
	if state ~= "exposed" and state ~= "infected" then return false end

	self:RemoveTrackedTimer(PlayerTimerKey("infect", ply))
	local originalRole = self.saved.OriginalRoles[ply] or "citizen"
	if originalRole == "carrier" then originalRole = "citizen" end

	self:SetInfectionState(ply, "healthy", 0)
	self:SetRole(ply, originalRole)
	if self.saved.OriginalModels[ply] then ply:SetModel(self.saved.OriginalModels[ply]) end
	ply:SetMaxHealth(100)
	ply:SetHealth(100)
	ply:SetArmor(0)
	self.saved.OriginalRoles[ply] = originalRole
	self:GiveRoleLoadout(ply, originalRole, false)
	ply:ChatPrint("치료되었습니다.")

	if IsValid(doctor) and doctor ~= ply then
		doctor:ChatPrint(ply:Nick() .. " 님을 치료했습니다.")
	end

	return true
end

function MODE:RefundBiohazardBall(carrier)
	if not IsQuarantineRound() or self.saved.OutbreakStarted then return end
	if not IsValid(carrier) or not carrier:Alive() or not self:IsRole(carrier, "carrier") then return end

	local timerName = PlayerTimerKey("ball_refund", carrier)
	if timer.Exists(timerName) then return end

	self:CreateTrackedTimer(timerName, 5, 1, function()
		if not IsQuarantineRound() or self.saved.OutbreakStarted then return end
		if not IsValid(carrier) or not carrier:Alive() or not self:IsRole(carrier, "carrier") then return end
		if carrier:HasWeapon(self.BiohazardWeapon) then return end

		local ball = GiveWeapon(carrier, self.BiohazardWeapon)
		if IsValid(ball) then carrier:SelectWeapon(self.BiohazardWeapon) end
		carrier:ChatPrint("빗나간 바이오볼이 다시 지급되었습니다.")
	end)
end

function MODE:CanPhoneReport(reporter, target)
	if not IsQuarantineRound() then return false end
	if not IsValid(reporter) or not reporter:Alive() or not self:IsRole(reporter, "citizen") then
		return false, "시민만 휴대폰으로 신고할 수 있습니다."
	end
	if not IsValid(target) or not target:IsPlayer() or not target:Alive() or reporter == target then return false end
	if target:Team() == TEAM_SPECTATOR or self:IsRole(target, "soldier") then
		return false, "격리군은 신고 대상이 아닙니다."
	end
	if reporter:EyePos():DistToSqr(target:EyePos()) > REPORT_DISTANCE_SQR then
		return false, "신고 대상이 너무 멉니다."
	end

	return true
end

function MODE:StartReport(reporter, target)
	local allowed, reason = self:CanPhoneReport(reporter, target)
	if not allowed then
		if reason and IsValid(reporter) then reporter:ChatPrint(reason) end
		return false
	end
	if reporter.ZC_QuarantineReporting then return false end

	reporter.ZC_QuarantineReporting = true
	reporter.ZC_QuarantineReportTarget = target
	reporter:SetNWBool("ZC_QuarantineReporting", true)
	reporter:Freeze(true)

	local timerName = PlayerTimerKey("report", reporter)
	self:CreateTrackedTimer(timerName, REPORT_TIME, 1, function()
		if not IsValid(reporter) then return end

		reporter.ZC_QuarantineReporting = nil
		reporter:SetNWBool("ZC_QuarantineReporting", false)
		reporter:Freeze(false)

		local reportTarget = reporter.ZC_QuarantineReportTarget
		reporter.ZC_QuarantineReportTarget = nil
		if reportTarget ~= target then return end

		local stillAllowed = self:CanPhoneReport(reporter, target)
		if not stillAllowed then return end

		if IsValid(self.saved.ReportedTarget) then
			self.saved.ReportedTarget:SetNWBool("ZC_QuarantineReported", false)
		end

		self.saved.ReportedTarget = target
		target:SetNWBool("ZC_QuarantineReported", true)
		reporter:ChatPrint("신고가 접수되었습니다.")

		if IsValid(self.saved.Soldier) then
			self.saved.Soldier:ChatPrint("시민 신고: " .. target:Nick() .. " 님이 표시되었습니다.")
		end

		local expireName = PlayerTimerKey("report_expire", target)
		self:RemoveTrackedTimer(expireName)
		self:CreateTrackedTimer(expireName, self.ReportDuration, 1, function()
			if IsValid(target) then target:SetNWBool("ZC_QuarantineReported", false) end
			if self.saved.ReportedTarget == target then self.saved.ReportedTarget = nil end
		end)
	end)

	return true
end

function MODE:PlayerCanPickupWeapon(ply, wep)
	if not IsValid(ply) or not IsValid(wep) then return end

	local class = wep:GetClass()
	if class == self.BiohazardWeapon and not self:IsRole(ply, "carrier") then return false end
	if class == self.CureWeapon and not self:IsRole(ply, "doctor") then return false end
	if self:GetInfectionState(ply) == "infected" and class ~= self.ZombieWeapon then return false end
end

function MODE:GetRoundCounts()
	local healthy = 0
	local infectionThreats = 0
	local active = 0

	for _, ply in ipairs(RoundPlayers()) do
		if ply:Alive() then
			active = active + 1

			local state = self:GetInfectionState(ply)
			local role = self:GetRole(ply)
			if state == "exposed" or state == "infected" then
				infectionThreats = infectionThreats + 1
			elseif role ~= "carrier" then
				healthy = healthy + 1
			end
		end
	end

	return healthy, infectionThreats, active
end

function MODE:ResolveWinner()
	if self.saved.Winner or not self.saved.RolesReady then return self.saved.Winner end

	local healthy, infectionThreats, active = self:GetRoundCounts()
	if active <= 0 then
		self.saved.Winner = "draw"
	elseif healthy <= 0 and (self.saved.OutbreakStarted or infectionThreats > 0) then
		self.saved.Winner = "infected"
	elseif self.saved.OutbreakStarted and infectionThreats <= 0 then
		self.saved.Winner = "survivors"
	elseif not self.saved.OutbreakStarted and (not IsValid(self.saved.Carrier) or not self.saved.Carrier:Alive()) then
		self.saved.Winner = "survivors"
	end

	return self.saved.Winner
end

function MODE:ShouldRoundEnd()
	return self:ResolveWinner() and true or false
end

function MODE:RoundThink()
	if self.saved.Winner then return end

	if CurTime() >= (zb.ROUND_START or CurTime()) + self.ROUND_TIME then
		local healthy = self:GetRoundCounts()
		self.saved.Winner = healthy > 0 and "survivors" or "infected"
		zb:EndRound()
	end
end

function MODE:PlayerDeath(ply)
	self:RemoveTrackedTimer(PlayerTimerKey("infect", ply))
	self:RemoveTrackedTimer(PlayerTimerKey("report", ply))
	ply:Freeze(false)
	ply:SetNWBool("ZC_QuarantineReporting", false)
	ply:SetNWBool("ZC_QuarantineReported", false)
end

function MODE:PromoteReplacementCarrier(disconnected)
	if not IsQuarantineRound() or self.saved.OutbreakStarted then return end

	local candidates = {}
	for _, ply in ipairs(RoundPlayers(disconnected)) do
		if ply:Alive() and not self:IsRole(ply, "doctor") and not self:IsRole(ply, "soldier") then
			candidates[#candidates + 1] = ply
		end
	end

	local replacement = table.Random(candidates)
	if not IsValid(replacement) then
		self.saved.Winner = "survivors"
		return
	end

	self.saved.Carrier = replacement
	self.saved.OriginalRoles[replacement] = "carrier"
	self:SetRole(replacement, "carrier")
	self:GiveRoleLoadout(replacement, "carrier", true)
	replacement:ChatPrint("최초 감염원이 이탈하여 당신이 새 감염원이 되었습니다.")
end

function MODE:CleanupRound()
	self:RemoveAllTrackedTimers()

	for ent in pairs((self.saved and self.saved.RoundEntities) or {}) do
		if IsValid(ent) then ent:Remove() end
	end

	for _, ply in player.Iterator() do
		for _, wep in ipairs(ply:GetWeapons()) do
			if IsValid(wep) and wep.ZC_QuarantineWeapon then wep:Remove() end
		end
		self:ClearPlayerState(ply, true)
	end

	if self.saved then
		self.saved.ReportedTarget = nil
		self.saved.RoundEntities = {}
	end
end

function MODE:EndRound()
	local winner = self.saved.Winner or "draw"
	self:CleanupRound()

	if winner == "infected" then
		PrintMessage(HUD_PRINTTALK, "감염자 승리: 격리가 실패했습니다.")
	elseif winner == "survivors" then
		PrintMessage(HUD_PRINTTALK, "생존자 승리: 감염을 저지했습니다.")
	else
		PrintMessage(HUD_PRINTTALK, "격리 실패 라운드가 무승부로 끝났습니다.")
	end

	timer.Simple(2, function()
		net.Start("tdm_roundend")
		net.Broadcast()
	end)
end

hook.Add("ZC_BiohazardBallSelfUse", "ZCityQuarantineBallSelfUse", function(ply, wep)
	if not IsQuarantineRound() then return end
	local round = CurrentRound()
	if not round:IsRole(ply, "carrier") then return true, false end
	if CurTime() < (zb.ROUND_START or 0) + round.AttackGraceTime then
		ply:ChatPrint("준비 시간이 끝난 뒤 감염을 시작할 수 있습니다.")
		return true, false
	end

	return true, round:BeginInfection(ply, ply)
end)

hook.Add("ZC_BiohazardBallCanThrow", "ZCityQuarantineBallCanThrow", function(ply, wep)
	if not IsQuarantineRound() then return end
	local round = CurrentRound()
	if not IsValid(ply) or not round:IsRole(ply, "carrier") then return true, false end
	if CurTime() < (zb.ROUND_START or 0) + round.AttackGraceTime then
		ply:ChatPrint("준비 시간이 끝난 뒤 감염을 시작할 수 있습니다.")
		return true, false
	end

	return true, true
end)

hook.Add("ZC_BiohazardBallThrown", "ZCityQuarantineBallThrown", function(wep, ent, owner)
	if not IsQuarantineRound() or not IsValid(ent) or not IsValid(owner) then return end
	local round = CurrentRound()
	if not round:IsRole(owner, "carrier") then return end

	ent.ZC_QuarantineEntity = true
	ent.ZC_QuarantineSource = owner
	round.saved.RoundEntities[ent] = true
	ent:CallOnRemove("ZCityQuarantineRefund", function(removed)
		round.saved.RoundEntities[removed] = nil
		if not removed.ZC_QuarantineResolved then round:RefundBiohazardBall(owner) end
	end)
end)

hook.Add("ZC_BiohazardBallImpact", "ZCityQuarantineBallImpact", function(ent, target, owner)
	if not IsQuarantineRound() or not IsValid(ent) or not ent.ZC_QuarantineEntity then return end
	local round = CurrentRound()
	ent.ZC_QuarantineResolved = true

	local infected = IsValid(target) and target:IsPlayer() and round:BeginInfection(target, IsValid(owner) and owner or ent.ZC_QuarantineSource)
	if not infected then round:RefundBiohazardBall(IsValid(owner) and owner or ent.ZC_QuarantineSource) end
	return true
end)

hook.Add("ZC_BiohazardZombieInfect", "ZCityQuarantineZombieInfect", function(attacker, target, wep)
	if not IsQuarantineRound() then return end
	local round = CurrentRound()
	if IsValid(attacker) and round:GetInfectionState(attacker) == "infected" then
		round:BeginInfection(target, attacker)
	end

	return true
end)

hook.Add("ZC_CureThrown", "ZCityQuarantineCureThrown", function(wep, ent, owner)
	if not IsQuarantineRound() or not IsValid(ent) or not IsValid(owner) then return end
	local round = CurrentRound()
	if not round:IsRole(owner, "doctor") then return end

	round.saved.CureSpent = true
	ent.ZC_QuarantineEntity = true
	ent.ZC_QuarantineDoctor = owner
	round.saved.RoundEntities[ent] = true
	ent:CallOnRemove("ZCityQuarantineCureCleanup", function(removed)
		round.saved.RoundEntities[removed] = nil
	end)
end)

hook.Add("ZC_CureCanThrow", "ZCityQuarantineCureCanThrow", function(ply, wep)
	if not IsQuarantineRound() then return end
	local round = CurrentRound()
	return true, IsValid(ply) and round:IsRole(ply, "doctor") and not round.saved.CureSpent
end)

hook.Add("ZC_CureImpact", "ZCityQuarantineCureImpact", function(ent, target, owner)
	if not IsQuarantineRound() or not IsValid(ent) or not ent.ZC_QuarantineEntity then return end
	local round = CurrentRound()
	if IsValid(target) and target:IsPlayer() then
		round:TryCure(target, IsValid(owner) and owner or ent.ZC_QuarantineDoctor)
	end

	return true
end)

hook.Add("ZC_CureSelfUse", "ZCityQuarantineCureSelfUse", function(ply, wep)
	if not IsQuarantineRound() then return end
	local round = CurrentRound()
	if not round:IsRole(ply, "doctor") then return true, false end

	round.saved.CureSpent = true
	round:TryCure(ply, ply)
	return true, true
end)

hook.Add("PlayerDisconnected", "ZCityQuarantineCarrierDisconnect", function(ply)
	if not IsQuarantineRound() then return end
	local round = CurrentRound()
	if round.saved.Carrier == ply and not round.saved.OutbreakStarted then
		round:PromoteReplacementCarrier(ply)
	end
end)

hook.Add("ZB_PreRoundStart", "ZCityQuarantinePreRoundCleanup", function()
	if IsQuarantineRound() then return end
	for _, ply in player.Iterator() do
		if ply:GetNWString("ZC_QuarantineRole", "") ~= "" then
			MODE:ClearPlayerState(ply, true)
		end
	end
end)
