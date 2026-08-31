if not SERVER then return end

local function IsAdminCaller(ply)
	return not IsValid(ply) or ply:IsAdmin()
end

local function PrintLine(ply, text)
	if IsValid(ply) then
		ply:ChatPrint(text)
	else
		print(text)
	end
end

local function GetRoundStateText(state)
	if state == 0 then return "waiting" end
	if state == 1 then return "running" end
	if state == 3 then return "ending" end
	return "unknown"
end

concommand.Add("zc_round_debug", function(ply)
	if not IsAdminCaller(ply) then return end

	local mode, roundKey = CurrentRound and CurrentRound()
	local players = player.GetAll()
	local activeCount = 0
	local aliveCount = 0
	local spectatorCount = 0

	for _, target in ipairs(players) do
		if target:Team() == TEAM_SPECTATOR then
			spectatorCount = spectatorCount + 1
		else
			activeCount = activeCount + 1
		end

		if target:Alive() then
			aliveCount = aliveCount + 1
		end
	end

	local state = zb and zb.ROUND_STATE or -1
	PrintLine(ply, "[ZC ROUND] mode=" .. tostring(mode and mode.name) .. " print=" .. tostring(mode and mode.PrintName) .. " key=" .. tostring(roundKey))
	PrintLine(ply, "[ZC ROUND] state=" .. tostring(state) .. " (" .. GetRoundStateText(state) .. ") players=" .. #players .. " active=" .. activeCount .. " alive=" .. aliveCount .. " spectators=" .. spectatorCount)
	PrintLine(ply, "[ZC ROUND] start_time=" .. tostring(zb and zb.START_TIME) .. " end_time=" .. tostring(zb and zb.END_TIME) .. " next=" .. tostring(zb and zb.nextround))
	PrintLine(ply, "[ZC ROUND] curtime=" .. tostring(CurTime()) .. " force=" .. tostring(GetConVar("zb_forcemode") and GetConVar("zb_forcemode"):GetString()))
end)

concommand.Add("zc_round_kickstart", function(ply)
	if not IsAdminCaller(ply) then return end
	if not zb then return end

	if zb.ROUND_STATE ~= 0 then
		PrintLine(ply, "[ZC ROUND] Not waiting. Current state=" .. tostring(zb.ROUND_STATE))
		return
	end

	local mode = CurrentRound and CurrentRound()
	local minPlayers = (mode and mode.AllowSoloActivePlayer) and 1 or 2
	local activePlayers = zb.GetActivePlayerCount and zb.GetActivePlayerCount() or player.GetCount()
	if activePlayers < minPlayers then
		PrintLine(ply, "[ZC ROUND] Need at least " .. tostring(minPlayers) .. " active players/bots to start. Active players=" .. tostring(activePlayers) .. ", total players=" .. tostring(player.GetCount()))
		return
	end

	zb.START_TIME = CurTime()
	PrintLine(ply, "[ZC ROUND] Start timer forced to now.")
end)
