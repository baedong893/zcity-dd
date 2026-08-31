local player_GetAll = player.GetAll
zb.modes = zb.modes or {}
local winStreakPDataKey = "zb_win_streak"
local winStreakNWKey = "ZB_WinStreak"
local winStreakExcludedModes = {
	fear = true
}

util.AddNetworkString("FadeScreen")

function zb.SyncPlayerWinCount(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	local streak = tonumber(ply:GetPData(winStreakPDataKey, 0)) or 0
	ply:SetNWInt(winStreakNWKey, streak)
end

local function AddWinningPlayer(winners, ply)
	if not IsValid(ply) or not ply:IsPlayer() or ply:Team() == TEAM_SPECTATOR then return end
	winners[ply] = true
end

local function AddWinningTeam(winners, teamId)
	for _, ply in player.Iterator() do
		if ply:Team() == teamId then
			AddWinningPlayer(winners, ply)
		end
	end
end

local function AddEveryoneExcept(winners, exceptPly)
	for _, ply in player.Iterator() do
		if ply ~= exceptPly then
			AddWinningPlayer(winners, ply)
		end
	end
end

local function CollectRoundWinners(mode)
	local winners = {}
	if not mode then return winners end

	local saved = mode.saved or {}
	local winner = saved.Winner
	if winner == nil then winner = mode.Winner end

	if isnumber(winner) then
		AddWinningTeam(winners, winner)
	elseif winner == "homelander" then
		AddWinningPlayer(winners, saved.Homelander)
	elseif winner == "hunters" then
		AddEveryoneExcept(winners, saved.Homelander)
	elseif winner == "assassin" then
		AddWinningPlayer(winners, saved.Assassin)
	elseif winner == "citizens" then
		AddEveryoneExcept(winners, saved.Assassin)
	elseif winner == "scp" then
		AddWinningPlayer(winners, saved.SCP106)
	elseif winner == "mtf" then
		AddEveryoneExcept(winners, saved.SCP106)
	elseif winner == "zombies" or winner == "humans" then
		for _, ply in player.Iterator() do
			local isZombie = ply.IsCSZombie == true
			if winner == "zombies" and isZombie or winner == "humans" and not isZombie then
				AddWinningPlayer(winners, ply)
			end
		end
	elseif mode.CheckAlivePlayers then
		local alivePlayers = mode:CheckAlivePlayers()
		local _, firstValue = next(alivePlayers or {})

		if IsValid(firstValue) and firstValue:IsPlayer() then
			if #alivePlayers == 1 then
				AddWinningPlayer(winners, alivePlayers[1])
			end
		else
			local _, teamWinner = zb:CheckWinner(alivePlayers)
			if isnumber(teamWinner) then
				AddWinningTeam(winners, teamWinner)
			end
		end
	end

	return winners
end

function zb.AwardRoundWins(mode)
	if zb.LastWinAwardRoundCount == zb.Roundscount then return end
	zb.LastWinAwardRoundCount = zb.Roundscount
	if mode and winStreakExcludedModes[mode.name] then
		zb.RoundWinParticipants = nil
		return
	end

	local winners = CollectRoundWinners(mode)
	local participants = zb.RoundWinParticipants or {}

	for ply in pairs(winners) do
		participants[ply] = true
	end

	for ply in pairs(participants) do
		if not IsValid(ply) or not ply:IsPlayer() then continue end
		local streak = tonumber(ply:GetPData(winStreakPDataKey, ply:GetNWInt(winStreakNWKey, 0))) or 0

		if winners[ply] then
			streak = streak + 1
		else
			streak = 0
		end

		ply:SetPData(winStreakPDataKey, streak)
		ply:SetNWInt(winStreakNWKey, streak)
	end

	zb.RoundWinParticipants = nil
end

hook.Add("PlayerInitialSpawn", "ZB_SyncWinStreak", function(ply)
	timer.Simple(1, function()
		zb.SyncPlayerWinCount(ply)
	end)
end)

function zb.AddFade()
	net.Start("FadeScreen")
	net.Broadcast()
end

local forcemodeconvar = CreateConVar("zb_forcemode", "random", nil, "강제 모드 설정 (비활성화하려면 'random'으로 설정)")
forcemodeconvar:SetString("random")
local forcemode
zb.ActiveRoundWasForced = zb.ActiveRoundWasForced or false

function zb.IsRoundForced(round)
	if zb.ActiveRoundWasForced and zb.ROUND_STATE == 1 and (round == nil or round == zb.CROUND) then
		return true
	end

	return isstring(forcemode) and forcemode ~= "random" and (round == nil or round == forcemode)
end

local disabledRoundModes = {
	beacon = true,
	fear = true,
	soe2 = true,
	standard2 = true
}

local function IsRoundModeDisabled(round)
	return disabledRoundModes[tostring(round or "")] == true
end

local function SanitizeRoundMode(round)
	if IsRoundModeDisabled(round) then return "hmcd" end
	return round
end

function zb:GetMode(round)
	if IsRoundModeDisabled(round) then return end

	if zb.modes[round] then return round end

	local inheritedMatch

	for name, mode in pairs(zb.modes) do
		if mode.Types and mode.Types[round] then
			-- Derived modes receive a copy of their base mode's Types table.
			-- Prefer the base owner so newly added submodes cannot be claimed by
			-- an inheriting mode that forgot to remove the new key.
			if not mode.base then return name end

			inheritedMatch = inheritedMatch or name
		end
	end

	return inheritedMatch
end

function CurrentRound()
	if IsValid(ents.FindByClass( "trigger_changelevel" )[1]) then
		zb.nextround = "coop"
		zb.CROUND = zb.CROUND or "coop"
		return zb.modes["coop"]
	end

	zb.CROUND = zb.CROUND or "hmcd"
	if IsRoundModeDisabled(zb.CROUND) then
		zb.CROUND = "hmcd"
		zb.CROUND_MAIN = nil
		zb.LASTCROUND = nil
	end

	if not zb.CROUND_MAIN or (zb.LASTCROUND != zb.CROUND) then
		zb.CROUND_MAIN = zb:GetMode(zb.CROUND)
		zb.LASTCROUND = zb.CROUND
	end

	local round = zb.CROUND_MAIN
	
	return zb.modes[round], zb.CROUND
end

function NextRound(round)
	round = SanitizeRoundMode(round)

	if IsValid(ents.FindByClass( "trigger_changelevel" )[1]) then
		zb.nextround = "coop"
	else
		zb.nextround = round
	end
end

function zb.GetActivePlayerCount()
	local count = 0

	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:Team() ~= TEAM_SPECTATOR then
			count = count + 1
		end
	end

	return count
end

function zb.ShouldEndForLoneActivePlayer()
	if not zb or zb.ROUND_STATE ~= 1 then return false end

	local mode, round = CurrentRound()
	if zb.IsRoundForced(round) then return false end
	if mode and mode.AllowSoloActivePlayer then return false end

	return zb.GetActivePlayerCount() <= 1
end

local ACTIVE_SHOOTER_MIN_PLAYERS = 3

local function IsActiveShooterMode(mode, round)
	return round == "as" or (mode and mode.name == "as")
end

local function CanActiveShooterLaunch()
	-- player.GetCount includes bots, which are intended to count toward this limit.
	return player.GetCount() >= ACTIVE_SHOOTER_MIN_PLAYERS
end

local function CanCurrentRoundLaunch(mode, round)
	if not mode then return false end
	if IsRoundModeDisabled(round) then return false end
	if IsActiveShooterMode(mode, round) then return CanActiveShooterLaunch() end

	local subMode = mode.Types and mode.Types[round]
	if subMode and subMode.CanLaunch then
		return subMode:CanLaunch()
	end

	if subMode and subMode.MinPlayers then
		return zb.GetActivePlayerCount() >= subMode.MinPlayers
	end

	if mode.name == "hmcd" and subMode then
		return true
	end

	if mode.CanLaunch then
		return mode:CanLaunch()
	end

	return true
end

local function ResetWaitingRoundToFallback(reason)
	if zb.CROUND == "hmcd" then return end
	if (zb.NextWaitingRoundFallbackPrint or 0) < CurTime() then
		print("[ZC ROUND] " .. (reason or "current mode cannot launch") .. "; fallback to hmcd waiting room.")
		zb.NextWaitingRoundFallbackPrint = CurTime() + 5
	end

	zb.CROUND = "hmcd"
	zb.CROUND_MAIN = nil
	zb.LASTCROUND = nil
	zb.START_TIME = nil

	local mode = CurrentRound()
	net.Start("RoundInfo")
		net.WriteString(zb.CROUND or (mode and mode.name) or "hmcd")
		net.WriteString(mode and mode.name or "hmcd")
		net.WriteInt(zb.ROUND_STATE or 0, 4)
	net.Broadcast()
end

-- A mode selected while the server is already in the waiting state must become
-- the current round immediately.  Merely changing zb.nextround leaves the
-- waiting room on the old mode forever because RoundStart is what normally
-- consumes nextround.
local function ActivateWaitingRound(round)
	if zb.ROUND_STATE ~= 0 then return false end
	if not isstring(round) or round == "" or IsRoundModeDisabled(round) then return false end
	if not zb:GetMode(round) then return false end

	hook.Run("ZB_PreRoundStart")
	hook.Run("TTTPrepareRound")

	zb.CROUND = round
	zb.CROUND_MAIN = nil
	zb.LASTCROUND = nil
	zb.START_TIME = nil
	zb.END_TIME = nil

	local mode = CurrentRound()
	if not mode then return false end

	net.Start("RoundInfo")
		net.WriteString(round)
		net.WriteString(mode.name or zb:GetMode(round) or round)
		net.WriteInt(zb.ROUND_STATE, 4)
	net.Broadcast()

	if hg and hg.UpdateRoundTime then
		hg.UpdateRoundTime(mode.ROUND_TIME, CurTime(), CurTime() + (mode.start_time or 5))
	end

	if mode.shouldfreeze then zb:Freeze() end
	zb:KillPlayers()
	zb:AutoBalance()

	if hg.PluvTown and hg.PluvTown.Active then
		for _, ply in player.Iterator() do
			ply:SetNetVar("CurPluv", "pluv")
		end
	end

	mode.saved = {}
	if mode.Intermission then mode:Intermission() end
	if mode.GiveEquipment then mode:GiveEquipment() end

	return true
end

function zb:PreRound()
	local activePlayers = zb.GetActivePlayerCount()
	local mode, round = CurrentRound()
	local forcedRound = zb.IsRoundForced(round)
	local minPlayers = (forcedRound or (mode and mode.AllowSoloActivePlayer)) and 1 or 2

	if zb.ROUND_STATE == 0 and not forcedRound and not CanCurrentRoundLaunch(mode, round) then
		ResetWaitingRoundToFallback("waiting mode " .. tostring(round or (mode and mode.name)) .. " cannot launch")
		return
	end

	if ((((zb.Roundscount or 0) > 15) and !GetConVar("zb_dev"):GetBool()) or ( (activePlayers >= minPlayers) and zb.ROUND_STATE == 0 and zb.CheckRTVVotes() )) and !(zb.RoundsLeft and zb.CROUND == "cstrike") then
		zb.StartRTV(20)
		zb.ROUND_STATE = 0
		return
	end

	if zb.ROUND_STATE == 0 and activePlayers >= minPlayers then
		zb.END_TIME = nil

		zb.START_TIME = zb.START_TIME or CurTime() + (CurrentRound().start_time or 5)
		if zb.START_TIME < CurTime() then zb:RoundStart() end
	elseif zb.ROUND_STATE == 0 then
		zb.START_TIME = nil
	end
end

function zb:RoundThink()
	if zb.ROUND_STATE == 1 then
		if CurrentRound().RoundThink then CurrentRound():RoundThink(CurrentRound()) end
	end
end

hook.Add("CanListenOthers","RoundStartChat",function(output, input, isChat, teamonly, text)
	if zb.ROUND_STATE == 0 or zb.ROUND_STATE == 3 then return true, false end
end)

function zb:EndRound()
	zb.ROUND_STATE = 3
	zb.Roundscount = (zb.Roundscount or 0) + 1

	local mode, round = CurrentRound()

	net.Start("RoundInfo")
		net.WriteString(round or mode.name or "hmcd")
		net.WriteString(mode.name or "hmcd")
		net.WriteInt(zb.ROUND_STATE, 4)
	net.Broadcast()

	--PrintMessage(HUD_PRINTTALK, "Раунд закончен.")
	if mode and mode.EndRound then
		mode:EndRound()
	end

	zb.AwardRoundWins(mode)

	hook.Run("ZB_EndRound")
	zb.AddFade()

	hg.achievements.SavePlayerAchievements()
end

function zb:CheckWinner(tbl)
	local playerTable = table.Copy(tbl)
	for i, players in pairs(playerTable) do
		if table.Count(players) == 0 then
			playerTable[i] = nil
			continue
		end

		playerTable[i] = i
	end

	local winner = (table.Count(playerTable) == 1 and table.Random(playerTable)) or (table.Count(playerTable) == 0 and 3) or false
	local shouldendround = winner and true or nil
	return shouldendround, winner
end

zb.ROUND_TIME = zb.ROUND_TIME or 300

function zb:ShouldRoundEnd()
	local time = zb.ROUND_TIME
	local mode = CurrentRound()
	local shouldroundend = false

	if mode and mode.ShouldRoundEnd then
		shouldroundend = mode:ShouldRoundEnd()
	end

	if shouldroundend ~= false then
		local boringround = ((zb.ROUND_START or CurTime()) + time) < CurTime()

		if boringround and mode and mode.BoringRoundFunction then
			PrintMessage(HUD_PRINTTALK, "라운드가 너무 지루해서 중단합니다.")

			mode:BoringRoundFunction()
		end

		return (shouldroundend and true) or (boringround)
	else
		return false
	end
end

function zb:EndRoundThink()
	-- Let the active mode resolve and record its winner before the generic
	-- low-player fallback ends the round.
	if zb.ROUND_STATE == 1 and (zb:ShouldRoundEnd() or zb.ShouldEndForLoneActivePlayer()) then zb:EndRound() end
	if zb.ROUND_STATE == 3 then
		if !zb.END_TIME then
			zb.END_TIME = (CurTime() + (CurrentRound().end_time or 5))
			if zb.nextround == "coop" and GetGlobalVar("coop_first_round_timer", 0) == 0 then

				local devConVar = GetConVar("zb_dev")
				zb.END_TIME = CurTime() + (devConVar and devConVar:GetBool() and 5 or 60)
				SetGlobalVar("coop_first_round_timer", zb.END_TIME)
			end
		end
		
		zb.SHOULD_FADE = zb.SHOULD_FADE != nil and zb.SHOULD_FADE or true

		if zb.SHOULD_FADE and (zb.END_TIME < CurTime() + 1.5) then
			zb.SHOULD_FADE = false

			for _, ply in player.Iterator() do
				ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0), 1, 7)
			end
		end

		if zb.END_TIME < CurTime() then
			zb.ROUND_STATE = 0

			zb.SHOULD_FADE = true

			hook.Run("ZB_PreRoundStart")
			hook.Run("TTTPrepareRound") -- stormfox2 random_round_weather

			zb.CROUND = zb.nextround or "hmcd"
			if CurrentRound().shouldfreeze then zb:Freeze() end

			--PrintMessage(HUD_PRINTTALK, "Gamemode: " .. CurrentRound().PrintName or "None")

			local mode, round = CurrentRound()
			net.Start("RoundInfo")
				net.WriteString(round or mode.name or "hmcd")
				net.WriteString(mode.name or "hmcd")
				net.WriteInt(zb.ROUND_STATE, 4)
			net.Broadcast()

			hg.UpdateRoundTime(CurrentRound().ROUND_TIME, CurTime(), CurTime() + (CurrentRound().start_time or 5))

			self:KillPlayers()
			self:AutoBalance()

			if hg.PluvTown.Active then
				for _, ply in player.Iterator() do
					ply:SetNetVar("CurPluv", "pluv")
				end
			end

			local mode = CurrentRound()
			mode.saved = {}

			if mode.Intermission then
				mode:Intermission()
			end

			if mode.GiveEquipment then
				mode:GiveEquipment()
			end
		end
	end
end

hook.Add("PlayerInitialSpawn", "zb_SendRoundInfo", function(ply)
	if zb.CROUND then
		local mode,round = CurrentRound()
		net.Start("RoundInfo")
			net.WriteString(round or mode.name or "hmcd")
			net.WriteString(mode.name or "hmcd")
			net.WriteInt(zb.ROUND_STATE, 4)
		net.Send(ply)
	end

	if ply.SyncVars then ply:SyncVars() end
end)

util.AddNetworkString("RoundInfo")
function zb:Think(time)
	if (zb.thinkTime or CurTime()) > time then return end
	zb.thinkTime = time + 1
	zb:PreRound()
	zb:RoundThink()
	zb:EndRoundThink()
end

hook.Add("Think", "zb-think", function() zb:Think(CurTime()) end)

function zb:KillPlayers()
	local mode = CurrentRound()
	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		ply:GiveExp(math.random(4,15))

		if ply:Alive() and mode.DontKillPlayer and mode:DontKillPlayer(ply) then
			hg.organism.Clear(ply.organism)
			hg.FakeUp(ply,true,true)

			continue
		end
		
		if ply:FlashlightIsOn() then ply:Flashlight(false) end

		ply:KillSilent()
		ply:Spawn()
		ply:SetPlayerClass()
	end
end

if IsRoundModeDisabled(zb.forcemode) then
	zb.forcemode = "random"
end
zb.forcemode = zb.forcemode or "random"

forcemode = zb.forcemode

function zb.GetModes()
	local newtbl = {}
	for name,tbl in pairs(zb.modes) do
		table.insert(newtbl,name)
	end
	return newtbl
end

ZBATTLE_BIGMAP = 5700

hook.Add("InitPostEntity", "loadbigmap", function()
	local filik = file.Read("zbattle/mapsizes.json", "DATA")

	if filik then
		local tbl = util.JSONToTable(filik)

		if tbl[game.GetMap()] then
			ZBATTLE_BIGMAP = tbl[game.GetMap()]
		end
	end
end)

COMMANDS.bigmap = {
	function(ply, args)
		if not ply:IsAdmin() then ply:ChatPrint("권한이 없습니다") return end
		ZBATTLE_BIGMAP = tonumber(args[1])
		ply:ChatPrint("대형 맵 판정 거리: " .. ZBATTLE_BIGMAP)
		zb.RerollChances()

		file.CreateDir("zbattle")

		local tbl = util.JSONToTable(file.Read("zbattle/mapsizes.json", "DATA") or util.TableToJSON({[game.GetMap()] = ZBATTLE_BIGMAP}))

		tbl[game.GetMap()] = ZBATTLE_BIGMAP

		file.Write("zbattle/mapsizes.json", util.TableToJSON(tbl))

		ply:ChatPrint("파일에 저장되었습니다")
	end,
	0
}


zb.BigMaps = {
	["mu_smallotown_v2_snow"] = true,
	["mu_smallotown_v2_13"] = true,
	["mu_smallotown_v2_13_night"] = true,
}

function zb.GetAvailableModes()
	zb.tdm_checkpoints()

	local newtbl = {}

	for i, name in pairs(zb.GetModes()) do

		local tbl = zb.modes[name]
		if name == "as" and not CanActiveShooterLaunch() then continue end
		if (
			( not tbl.ForBigMaps ) or
			( zb.GetWorldSize() > ZBATTLE_BIGMAP )
		) then
			if tbl.SubModes then
				for i, name2 in pairs(tbl:SubModes()) do
					local subMode = tbl.Types and tbl.Types[name2]
					local canLaunch = true

					if subMode and subMode.CanLaunch then
						canLaunch = subMode:CanLaunch()
					elseif subMode and subMode.MinPlayers then
						canLaunch = zb.GetActivePlayerCount() >= subMode.MinPlayers
					elseif tbl.name == "hmcd" and subMode then
						canLaunch = true
					elseif tbl.CanLaunch then
						local oldCround = zb.CROUND
						zb.CROUND = name2
						zb.CROUND_MAIN = nil
						zb.LASTCROUND = nil
						canLaunch = tbl:CanLaunch()
						zb.CROUND = oldCround
						zb.CROUND_MAIN = nil
						zb.LASTCROUND = nil
					end

					if canLaunch then
						table.insert(newtbl, name2)
					end
				end
			elseif tbl.CanLaunch and tbl:CanLaunch() then
				table.insert(newtbl, name)
			end
		end
	end

	return newtbl
end

zb.ModesPlaytime = zb.ModesPlaytime or {}

function zb.GetModesPlaytime()
	local tbl = zb.GetAvailableModes()
	local newtbl = {}
	local count = 0

	for i, name in ipairs(tbl) do
		local amt = zb.ModesPlaytime[name] or 0
		newtbl[name] = amt
		count = count + amt
	end

	return newtbl, count
end

function zb.GetModePlaytime(name)
	return zb.ModesPlaytime[name] or 0
end

function zb.SetModePlaytime(name, set)
	zb.ModesPlaytime[name] = set
end

function zb.AddModePlaytime(name, add)
	zb.ModesPlaytime[name] = (zb.ModesPlaytime[name] or 0) + add
end

local function GetRoundTokenKey(mode, round)
	if not mode then return round end
	if mode.Types and round and mode.Types[round] then return round end
	if mode.SubModes then return mode.Type or round or mode.name end
	return round or mode.name
end

function zb.AddCurrentModePlayed()
	if not CurrentRound() then return end
	local mode, round = CurrentRound()
	local name = GetRoundTokenKey(mode, round)
	if not name then return end

	zb.AddModePlaytime(name, 1)
end

function zb.GetChance(name, addtbl)
	if IsRoundModeDisabled(name) then return 0 end

	local mode = zb:GetMode(name)
	if not mode or not zb.modes[mode] then return 0 end

	local tbl = zb.modes[mode]

	local newtbl = tbl.Types and tbl.Types[name] or tbl

	return newtbl.ChanceFunction and newtbl:ChanceFunction(addtbl or {}) or zb.ModesChances[name] or newtbl.Chance or 0.1
end

function zb.GetModesChances()
	local tbl = zb.GetAvailableModes()
	local newtbl = {}

	for i, name in pairs(tbl) do
		newtbl[name] = zb.GetChance(name)
	end

	return newtbl
end

function zb.WeightedChanceMode(modes_chances)
	local weight = 0

	local newchancestbl = {}
	for name, chance in pairs(modes_chances) do
		local newchance = zb.GetChance(name, {rounds = zb.RoundList}) or chance
		newchancestbl[name] = newchance
		weight = weight + newchance * 100
	end

	local random = math.random(weight)

	local count = 0
	for name, chance in RandomPairs(modes_chances) do
		count = count + (newchancestbl[name] or chance) * 100

		if count >= random then
			return name
		end
	end

	return "hmcd"
end

local cachedWorldSize
local cachedWorldSizeMap

function zb.InvalidateWorldSizeCache()
	cachedWorldSize = nil
	cachedWorldSizeMap = nil
end

function zb.GetWorldSize()
	local mapName = game.GetMap()
	if cachedWorldSizeMap == mapName and cachedWorldSize ~= nil then
		return cachedWorldSize
	end

	/*
	local world = game.GetWorld()
	local worldMin = world:GetInternalVariable("m_WorldMins")
	local worldMax = world:GetInternalVariable("m_WorldMaxs")
	local size = worldMin:Distance(worldMax)

	return size + (zb.BigMaps[ game.GetMap() ] and 5000 or 0)
	*/

	local dist = 0
	local pts = zb.GetMapPoints( "RandomSpawns" )

	for _, pnt in pairs(pts) do
		for _, pnt2 in pairs(pts) do
			dist = math.max(dist, pnt.pos:DistToSqr(pnt2.pos))
		end
	end

	cachedWorldSize = math.sqrt(dist)
	cachedWorldSizeMap = mapName

	return cachedWorldSize
end

function zb.GetRoundName(name)
	local mode = zb:GetMode(name)
	if not mode or not zb.modes[mode] then return end
	local modeData = zb.modes[mode]
	if modeData.Types and modeData.Types[name] then
		return (modeData.PrintName or modeData.name or mode) .. "/" .. name
	end
	return modeData.PrintName or modeData.name or name
end

zb.RoundList = zb.RoundList or {}
zb.QueuedModes = zb.QueuedModes or {}
zb.ModeTokens = zb.ModeTokens or {}
zb.RoundListManual = zb.RoundListManual or false

local modeTokenMax = 10
local modeTokenBase = {
	standard = 2,
	wildwest = 2,
	bang = 2
}

local function GetModeTokenBase(name)
	return modeTokenBase[name] or 0
end

local function IsModeTokenEligible(name)
	if IsRoundModeDisabled(name) then return false end
	return (zb.GetChance(name) or 0) > 0
end

local function IsKnownEnabledRoundMode(name)
	if not isstring(name) or name == "" or #name > 64 then return false end
	if IsRoundModeDisabled(name) then return false end

	local modeName = zb:GetMode(name)
	local mode = modeName and zb.modes[modeName]
	return mode ~= nil
end

local function IsSelectableRoundMode(name)
	if not IsKnownEnabledRoundMode(name) then return false end

	local modeName = zb:GetMode(name)
	local mode = modeName and zb.modes[modeName]

	local ok, canLaunch = pcall(CanCurrentRoundLaunch, mode, name)
	return ok and canLaunch == true
end

local function SanitizeRoundModeList(list, maxItems)
	local sanitized = {}
	if not istable(list) then return sanitized end

	for _, name in ipairs(list) do
		if #sanitized >= (maxItems or 64) then break end
		if IsSelectableRoundMode(name) then
			sanitized[#sanitized + 1] = name
		end
	end

	return sanitized
end

function zb.EnsureModeToken(name)
	if not name then return 0 end

	if not isnumber(zb.ModeTokens[name]) then
		local baseToken = GetModeTokenBase(name)
		zb.ModeTokens[name] = baseToken > 0 and baseToken or math.random(1, modeTokenMax)
	end

	local baseToken = GetModeTokenBase(name)
	zb.ModeTokens[name] = math.Clamp(math.floor(zb.ModeTokens[name]), baseToken, modeTokenMax)
	return zb.ModeTokens[name]
end

function zb.EnsureModeTokens()
	for _, name in ipairs(zb.GetAvailableModes()) do
		zb.EnsureModeToken(name)
	end
end

function zb.AdvanceModeTokens(playedMode)
	zb.EnsureModeTokens()

	for _, name in ipairs(zb.GetAvailableModes()) do
		if IsModeTokenEligible(name) then
			zb.ModeTokens[name] = math.Clamp((zb.ModeTokens[name] or math.random(1, modeTokenMax)) + 1, 0, modeTokenMax)
		end
	end

	if playedMode then
		zb.ModeTokens[playedMode] = GetModeTokenBase(playedMode)
	end
end

local function PickModeByTokens(tokenState)
	local available = zb.GetAvailableModes()
	local total = 0
	local candidates = {}

	for _, name in ipairs(available) do
		if IsModeTokenEligible(name) then
			local token = math.Clamp(tokenState[name] or zb.EnsureModeToken(name), 0, modeTokenMax)
			local chance = math.max(tonumber(zb.GetChance(name, {rounds = zb.RoundList})) or 0, 0)
			local weight = token * chance
			if weight > 0 then
				candidates[#candidates + 1] = {name = name, weight = weight}
				total = total + weight
			end
		end
	end

	if total <= 0 then
		local fallback = {}
		for _, name in ipairs(available) do
			if IsModeTokenEligible(name) then
				fallback[#fallback + 1] = name
			end
		end

		return table.Random(fallback) or "hmcd"
	end

	local roll = math.Rand(0, total)
	local count = 0

	for _, item in ipairs(candidates) do
		count = count + item.weight
		if count >= roll then
			return item.name
		end
	end

	return candidates[#candidates] and candidates[#candidates].name or "hmcd"
end

function zb.CheckChances()
	if #zb.RoundList == 0 then
		zb.RerollChances()
	end

	local nextrnd = zb.nextround or zb.RoundList[1]
	print("다음 라운드: "..zb.GetRoundName(nextrnd).." ("..nextrnd..")")

	if #zb.QueuedModes > 0 then
		print("Queued game modes:")
		for i=1, #zb.QueuedModes do
			print("  "..i..": "..zb.GetRoundName(zb.QueuedModes[i]).." ("..zb.QueuedModes[i]..")")
		end
	else
		for i=1,#zb.RoundList do
			print((i+1) .. "라운드는 " .. zb.GetRoundName(zb.RoundList[i]) .. " (" .. zb.RoundList[i] .. ") 모드로 진행될 예정입니다.")
		end
	end
end

function zb.RerollChances()
	zb.RoundList = {}
	zb.EnsureModeTokens()

	local simulatedTokens = table.Copy(zb.ModeTokens)

	for i = 1, 20 do
		local round = PickModeByTokens(simulatedTokens)

		zb.RoundList[i] = round

		for _, name in ipairs(zb.GetAvailableModes()) do
			if IsModeTokenEligible(name) then
				simulatedTokens[name] = math.Clamp((simulatedTokens[name] or math.random(1, modeTokenMax)) + 1, 0, modeTokenMax)
			end
		end

		simulatedTokens[round] = GetModeTokenBase(round)
	end

	zb.nextround = table.remove(zb.RoundList, 1)
end

function zb.GetModesInfo()
	local modesInfo = {}

	local function CanModeLaunch(mode, subMode, subModeName)
		if IsActiveShooterMode(mode, subModeName) then
			return CanActiveShooterLaunch()
		end

		if subMode and subMode.CanLaunch then
			local ok, result = pcall(subMode.CanLaunch, subMode)
			return ok and result and true or false
		end

		if subMode and subMode.MinPlayers then
			return zb.GetActivePlayerCount() >= subMode.MinPlayers
		end

		if mode and mode.name == "hmcd" and subMode then
			return true
		end

		if mode and mode.CanLaunch then
			local ok, result = pcall(mode.CanLaunch, mode)
			return ok and result and true or false
		end

		return true
	end

	for name, mode in pairs(zb.modes) do
		if IsRoundModeDisabled(name) or IsRoundModeDisabled(mode.name) then continue end

		if mode.Types and not mode.HideTypesInMenu then
			for name2, mode2 in pairs(mode.Types) do
				if IsRoundModeDisabled(name2) then continue end

				table.insert(modesInfo, {
					key = name2,
					name = (mode.PrintName or mode.name or name).."/"..name2,
					description = mode.Description or "",
					forBigMaps = mode.ForBigMaps or false,
					menuVisible = mode2.MenuVisible == true or mode.MenuVisible == true,
					canlaunch = (CanModeLaunch(mode, mode2, name2) and 1 or 0)
				})
			end
		else
			table.insert(modesInfo, {
				key = name,
				name = mode.PrintName or mode.name or name,
				description = mode.Description or "",
				forBigMaps = mode.ForBigMaps or false,
				menuVisible = mode.MenuVisible == true,
				canlaunch = (CanModeLaunch(mode, nil, name) and 1 or 0)
			})
		end
	end

	return modesInfo
end


function zb.SetRoundList(newList)
	local newLista = SanitizeRoundModeList(newList, 64)
	if #newLista > 0 then
		zb.nextround = table.remove(newLista, 1)
		zb.RoundList = newLista
		zb.RoundListManual = true

		ActivateWaitingRound(zb.nextround)
	else
		zb.RoundListManual = false
		zb.RerollChances()
	end
end


util.AddNetworkString("ZB_SendModesInfo")
util.AddNetworkString("ZB_SendRoundList")
util.AddNetworkString("ZB_RequestRoundList")
util.AddNetworkString("ZB_UpdateRoundList")
util.AddNetworkString("ZB_NotifyRoundListChange")


function zb.SendModesInfoToClient(ply)
	net.Start("ZB_SendModesInfo")
		net.WriteTable(zb.GetModesInfo())
	net.Send(ply)
end


function zb.SendRoundListToClient(ply)
	-- A generated/manual list may have been built while more players were
	-- connected. Revalidate it before showing it so modes below their current
	-- minimum-player requirement do not remain in the queue UI.
	zb.RoundList = SanitizeRoundModeList(zb.RoundList, 64)

	net.Start("ZB_SendRoundList")
		net.WriteTable(zb.RoundList)
		net.WriteString(zb.nextround or "")
	net.Send(ply)
end


hook.Add("PlayerInitialSpawn", "ZB_SendModesOnSpawn", function(ply)
	if ply:IsAdmin() then
		timer.Simple(1, function()
			if IsValid(ply) then
				zb.SendModesInfoToClient(ply)
				zb.SendRoundListToClient(ply)
			end
		end)
	end
end)


net.Receive("ZB_RequestRoundList", function(len, ply)
	if IsValid(ply) and ply:IsAdmin() then
		zb.SendModesInfoToClient(ply)
		zb.SendRoundListToClient(ply)
	end
end)

net.Receive("ZB_UpdateRoundList", function(len, ply)
	if not IsValid(ply) or not ply:IsAdmin() then return end
	if len > 65536 then return end
	if (ply.ZBNextRoundListUpdate or 0) > CurTime() then return end
	ply.ZBNextRoundListUpdate = CurTime() + 0.5

	local newList = net.ReadTable()
	local forceUpdate = net.ReadBool()

	zb.SetRoundList(newList)

	net.Start("ZB_NotifyRoundListChange")
		net.WriteString(ply:Nick())
	net.Send(zb.GetAllAdmins())

	for _, admin in ipairs(zb.GetAllAdmins()) do
		zb.SendRoundListToClient(admin)
	end
end)

function zb:RoundStart()
	if CurrentRound().shouldfreeze then zb:Unfreeze() end

	zb.ROUND_STATE = 1
	zb.START_TIME = nil

	local mode, round = CurrentRound()

	VFIRE_DISABLED = (mode.name == "coop")

	zb.ROUND_BEGIN = CurTime()
	hg.UpdateRoundTime()

	net.Start("RoundInfo")
		net.WriteString(round or mode.name or "hmcd")
		net.WriteString(mode.name or "hmcd")
		net.WriteInt(zb.ROUND_STATE, 4)
	net.Broadcast()

	if forcemodeconvar:GetString() != "" then
		forcemode = forcemodeconvar:GetString()
		if IsRoundModeDisabled(forcemode) then
			forcemode = "random"
			forcemodeconvar:SetString("random")
		end
	end

	-- "다음 모드 강제 설정"은 한 라운드만 우회한다. 시작된 라운드는
	-- ActiveRoundWasForced로 기억해 솔로 테스트 제한은 계속 우회하되,
	-- 다음 예약부터는 대기열/랜덤 순환으로 즉시 복귀한다.
	zb.ActiveRoundWasForced = isstring(forcemode) and forcemode ~= "random" and round == forcemode
	if zb.ActiveRoundWasForced then
		forcemode = "random"
		zb.forcemode = "random"
		forcemodeconvar:SetString("random")
	end

	local currentMode = GetRoundTokenKey(mode, round)

	zb.AddCurrentModePlayed()
	zb.AdvanceModeTokens(currentMode)

	if mode.RoundStart then
		mode:RoundStart()
	end

	zb.RoundWinParticipants = {}
	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:IsPlayer() and ply:Team() ~= TEAM_SPECTATOR then
			zb.RoundWinParticipants[ply] = true
		end
	end

	local nextMode

	if forcemode == "random" then
		local rerolledRoundList = false
		local hadQueuedModes = #zb.QueuedModes > 0

		while #zb.QueuedModes > 0 and not nextMode do
			local queuedMode = table.remove(zb.QueuedModes, 1)
			if IsSelectableRoundMode(queuedMode) then
				nextMode = queuedMode
			end
		end

		if hadQueuedModes then
			if zb.SyncQueueToAdmins then zb.SyncQueueToAdmins() end
			if #zb.QueuedModes == 0 and zb.NotifyQueueEmptied then zb.NotifyQueueEmptied() end
		end

		if not nextMode and (not zb.RoundListManual or #zb.RoundList == 0) then
			zb.RoundListManual = false
			zb.RerollChances()
			rerolledRoundList = true
		end

		if nextMode then
			-- An explicit administrator queue takes priority over the generated/manual list.
		elseif rerolledRoundList then
			nextMode = zb.nextround
		else
			nextMode = table.remove(zb.RoundList, 1)
		end

		if not nextMode or not IsSelectableRoundMode(nextMode) then
			zb.RerollChances()
			nextMode = zb.nextround
		end
	else
		-- A force request made during this RoundStart tick is reserved for the
		-- following round. Normally this branch is only reached by external code.
		nextMode = forcemode
	end

	if not nextMode or not zb:GetMode(nextMode) then nextMode = "hmcd" end
	print("다음 게임 모드는 " .. tostring(nextMode) .. "입니다.")

	NextRound(nextMode)

	if CurrentRound().RoundStartPost then
		CurrentRound():RoundStartPost()
	end

	hook.Run("ZB_StartRound")

	//zb.GetAllPoints(true)

	for _, admin in ipairs(zb.GetAllAdmins()) do
		zb.SendRoundListToClient(admin)
	end
end

concommand.Add("zb_checkchances",function(ply) if ply:IsAdmin() then zb.CheckChances() end end)
concommand.Add("zb_rerollchances",function(ply) if ply:IsAdmin() then zb.RerollChances() zb.CheckChances() end end)

function zb.NotifyQueueEmptied()
	net.Start("QueueEmptiedNotification")
	net.Send(zb.GetAllAdmins())
end

hook.Add("PlayerInitialSpawn", "SendGameModesToClient", function(ply)
	if ply:IsAdmin() then
		local modesToSend = {}
		for key, mode in pairs(zb.modes) do
			table.insert(modesToSend, {key = key, name = mode.PrintName or mode.name})
		end

		net.Start("SendAvailableModes")
			net.WriteTable(modesToSend)
		net.Send(ply)
	end
end)

net.Receive("AdminSetGameMode", function(len, ply)
	if not ply:IsAdmin() then return end

	local command = net.ReadString()
	local modeKey = net.ReadString()
	local addToQueue = net.ReadBool() or false

	if command == "setmode" then
		if IsRoundModeDisabled(modeKey) then
			ply:ChatPrint("비활성화된 게임 모드입니다: " .. modeKey)
			return
		end

		NextRound(modeKey)
		ply:ChatPrint("게임 모드가 다음으로 설정되었습니다: " .. modeKey)

		if addToQueue then
			table.insert(zb.QueuedModes, modeKey)
			zb.NotifyQueueModified(ply, modeKey .. " 모드를 대기열에 추가했습니다")

			zb.SyncQueueToAdmins()
		end
	elseif command == "setforcemode" then
		if IsRoundModeDisabled(modeKey) then
			ply:ChatPrint("비활성화된 게임 모드입니다: " .. modeKey)
			return
		end

		forcemode = modeKey
		NextRound(forcemode)
		ply:ChatPrint("강제 모드가 다음으로 설정됨: " .. modeKey)

		if addToQueue then
			table.insert(zb.QueuedModes, modeKey)
			zb.NotifyQueueModified(ply, modeKey .. " 모드를 대기열에 추가했습니다")

			zb.SyncQueueToAdmins()
		end
	end
end)

net.Receive("AdminEndRound", function(len, ply)
	if not ply:IsAdmin() then return end

	ply:ChatPrint("라운드가 종료되었습니다!")
	zb:EndRound()
end)

function zb.SyncQueueToAdmins()
	timer.Simple(0.1, function()
		net.Start("SendGameQueue")
		net.WriteTable(zb.QueuedModes)
		net.Send(zb.GetAllAdmins())
	end)
end

net.Receive("AdminSetGameQueue", function(len, ply)
	if not ply:IsAdmin() then return end

	local modeQueue = net.ReadTable()
	zb.QueuedModes = modeQueue

	if #modeQueue == 0 then
		ply:ChatPrint("게임 모드 대기열이 초기화되었습니다")
		zb.NotifyQueueModified(ply, "cleared")


		timer.Simple(0.2, function()
			net.Start("QueueEmptiedNotification")
			net.Send(zb.GetAllAdmins())
		end)
	else
		ply:ChatPrint("게임 모드 대기열에 " .. #modeQueue .. "개의 모드가 설정되었습니다")
		zb.NotifyQueueModified(ply, "updated")
	end

	zb.SyncQueueToAdmins()
end)

function zb.NotifyQueueModified(ply, action)
	local admins = zb.GetAllAdmins()

	local recipients = {}
	for _, admin in ipairs(admins) do
		if admin ~= ply then
			table.insert(recipients, admin)
		end
	end


	if #recipients > 0 then
		net.Start("QueueModifiedNotification")
		net.WriteString(IsValid(ply) and ply:Nick() or "Server")
		net.WriteString(action)
		net.Send(recipients)
	end
end

function zb:Unfreeze()
	for i, ply in player.Iterator() do
		if ply:Alive() then ply:Freeze(false) end
	end
end


function zb:Freeze()
	for i, ply in player.Iterator() do
		if ply:Alive() then ply:Freeze(true) end
	end
end

function zb.GetAllAdmins()
	local admins = {}
	for _, ply in player.Iterator() do
		if ply:IsAdmin() then
			table.insert(admins, ply)
		end
	end
	return admins
end

COMMANDS.setmode = {
	function(ply, args)
		if not ply:IsAdmin() then ply:ChatPrint("권한이 없습니다.") return end
		if not args[1] or (not zb:GetMode(args[1]) and args[1]~="random") then return end
		if IsRoundModeDisabled(args[1]) then ply:ChatPrint("비활성화된 게임 모드입니다: " .. args[1]) return end
		ply:ChatPrint(args[1])
		NextRound(args[1])
	end,
	0
}

COMMANDS.setforcemode = {
	function(ply, args)
		if not ply:IsAdmin() then ply:ChatPrint("권한이 없습니다.") return end
		if not args[1] or (not zb:GetMode(args[1]) and args[1]~="random") then return end
		if IsRoundModeDisabled(args[1]) then ply:ChatPrint("비활성화된 게임 모드입니다: " .. args[1]) return end
		ply:ChatPrint(args[1])
		forcemode = args[1]
		forcemodeconvar:SetString(args[1])
		if args[1] ~= "random" then
			NextRound(args[1])
		end
	end, 0
}

COMMANDS.endround = {
	function(ply, args)
		if not ply:IsAdmin() then
			ply:ChatPrint("권한이 없습니다.")
			return
		end
	 	zb:EndRound()
	end, 0
}

if SERVER then
	util.AddNetworkString("SendAvailableModes")
	util.AddNetworkString("AdminSetGameMode")
	util.AddNetworkString("AdminEndRound")
	util.AddNetworkString("AdminSetGameQueue")
	util.AddNetworkString("RequestGameQueue")
	util.AddNetworkString("SendGameQueue")
	util.AddNetworkString("QueueEmptiedNotification")
	util.AddNetworkString("QueueModifiedNotification")

	hook.Add("PlayerInitialSpawn", "SendGameModesToClient", function(ply)
		if ply:IsAdmin() then
			local modesToSend = {}
			for key, mode in pairs(zb.modes) do
				table.insert(modesToSend, {key = key, name = mode.PrintName or mode.name})
			end

			net.Start("SendAvailableModes")
				net.WriteTable(modesToSend)
			net.Send(ply)
		end
	end)

	net.Receive("AdminSetGameMode", function(len, ply)
		if not ply:IsAdmin() then return end
		if (ply.ZBNextAdminModeRequest or 0) > CurTime() then return end
		ply.ZBNextAdminModeRequest = CurTime() + 0.5

		local command = net.ReadString()
		local modeKey = net.ReadString()
		local addToQueue = net.ReadBool() or false

		if command ~= "setmode" and command ~= "setforcemode" then return end

		-- A forced mode is an administrator override.  It must still name a real,
		-- enabled mode, but it deliberately bypasses CanLaunch/MinPlayers so modes
		-- can be tested on the current map or with a small player count.
		if modeKey ~= "random" then
			local modeName = zb:GetMode(modeKey)
			if not modeName or not zb.modes[modeName] or IsRoundModeDisabled(modeKey) then
				ply:ChatPrint("존재하지 않거나 비활성화된 게임 모드입니다: " .. tostring(modeKey))
				return
			end

		end

		if command == "setmode" and modeKey ~= "random" and not IsSelectableRoundMode(modeKey) then
			ply:ChatPrint("현재 인원으로 시작할 수 없는 게임 모드입니다: " .. modeKey)
			return
		end

		if addToQueue and (modeKey == "random" or #zb.QueuedModes >= 64 or not IsSelectableRoundMode(modeKey)) then
			ply:ChatPrint("이 모드는 대기열에 추가할 수 없습니다.")
			return
		end

		if command == "setmode" then
			if modeKey == "random" then
				zb.RerollChances()
				NextRound(zb.nextround or "hmcd")
			else
				NextRound(modeKey)
				ActivateWaitingRound(modeKey)
			end
			ply:ChatPrint("게임 모드가 다음으로 설정되었습니다: " .. modeKey)

			if addToQueue then
				table.insert(zb.QueuedModes, modeKey)
				zb.NotifyQueueModified(ply, modeKey .. " 모드를 대기열에 추가했습니다")

				zb.SyncQueueToAdmins()
			end
		elseif command == "setforcemode" then
			forcemode = modeKey
			zb.forcemode = modeKey
			forcemodeconvar:SetString(modeKey)
			if modeKey ~= "random" then
				NextRound(forcemode)
				ActivateWaitingRound(modeKey)
			end
			ply:ChatPrint("강제 모드가 다음으로 설정되었습니다: " .. modeKey)

			if addToQueue then
				table.insert(zb.QueuedModes, modeKey)
				zb.NotifyQueueModified(ply, modeKey .. " 모드를 대기열에 추가했습니다")

				zb.SyncQueueToAdmins()
			end
		end
	end)

	function zb.SyncQueueToAdmins()
		timer.Simple(0.1, function()
			zb.QueuedModes = SanitizeRoundModeList(zb.QueuedModes, 64)

			net.Start("SendGameQueue")
			net.WriteTable(zb.QueuedModes)
			net.Send(zb.GetAllAdmins())
		end)
	end

	net.Receive("AdminSetGameQueue", function(len, ply)
		if not ply:IsAdmin() then return end
		if (ply.ZBNextAdminQueueRequest or 0) > CurTime() then return end
		ply.ZBNextAdminQueueRequest = CurTime() + 0.5

		local modeQueue = net.ReadTable()
		zb.QueuedModes = SanitizeRoundModeList(modeQueue, 64)

		modeQueue = zb.QueuedModes

		if #modeQueue == 0 then
            ply:ChatPrint("게임 모드 대기열이 초기화되었습니다")
            zb.NotifyQueueModified(ply, "대기열을 초기화했습니다")


			timer.Simple(0.2, function()
				net.Start("QueueEmptiedNotification")
				net.Send(zb.GetAllAdmins())
			end)
		else
            ply:ChatPrint("게임 모드 대기열에 " .. #modeQueue .. "개의 모드가 설정되었습니다")
            zb.NotifyQueueModified(ply, "대기열을 업데이트했습니다")
		end

		zb.SyncQueueToAdmins()
	end)

end
