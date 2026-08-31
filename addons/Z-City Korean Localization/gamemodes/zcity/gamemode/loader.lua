local function IncluderFunc(fileName)
	local baseName = string.GetFileFromFilename(fileName)

	if (string.StartWith(baseName, "sv_")) then
		if (SERVER) then
		include(fileName)
		end
	elseif (baseName == "shared.lua" or string.StartWith(baseName, "sh_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end

		include(fileName)
	elseif (string.StartWith(baseName, "cl_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		else
			include(fileName)
		end
	end
end

--прошу обратить внимание что файлы внутри папок загружаются первыми
local function LoadFromDir(directory)
	local files, folders = file.Find(directory .. "/*", "LUA")

	for _, v in ipairs(folders) do
		LoadFromDir(directory .. "/" .. v)
	end

	for _, v in ipairs(files) do
		IncluderFunc(directory .. "/" .. v)
	end
end

LoadFromDir("zcity/gamemode/libraries")

-- Lua auto-refresh does not remove keys from an existing table when a mode
-- directory is deleted. Keep only the per-mode saved data, then rebuild the
-- registry from the directories that actually exist now.
local previousModes = zb.modes or {}
zb.modesHooks = {}
zb.modes = {}

local function InitMode()
	if table.IsEmpty(MODE) then return end

	local name = MODE.name
	local saved = previousModes[name] and previousModes[name].saved or {} -- saved table is used for saving data between hotloads

	if MODE.base then
		table.Inherit(MODE, zb.modes[MODE.base])

		for i, tbl in pairs(MODE) do
			if istable(MODE[i]) and istable(zb.modes[MODE.base][i]) then
				local tbl2 = {}

				table.CopyFromTo(MODE[i], tbl2)

				MODE[i] = tbl2
			end
		end

		if MODE.AfterBaseInheritance then
			MODE:AfterBaseInheritance()
		end
	end

	MODE.RoundStart = MODE.RoundStart or function() end
	MODE.RoundThink = MODE.RoundThink or function() end
	MODE.EndRound = MODE.EndRound or function() end
	MODE.Intermission = MODE.Intermission or function() end
	MODE.GiveEquipment = MODE.GiveEquipment or function() end
	MODE.GiveWeapons = MODE.GiveWeapons or function() end
	MODE.ShouldRoundEnd = MODE.ShouldRoundEnd or function() return false end
	MODE.CanLaunch = MODE.CanLaunch or function() return true end

	zb.modes[name] = MODE
	zb.modes[name].saved = saved

	if SERVER then
		if MODE.SetupChances then
			MODE:SetupChances()
		else
			zb.ModesChances[name] = zb.ModesChances[name] or MODE.Chance
		end
	end

	zb.modesHooks[name] = zb.modesHooks[name] or {}

	for k, v2 in pairs(MODE) do
		if isfunction(v2) then
			zb.modesHooks[name][k] = v2
		end
	end
end

local chancesfile = "zbattle/modeschances.json"

if SERVER then
	file.CreateDir("zbattle")

	local function CanManageModeChances(ply)
		return not IsValid(ply) or ply:IsAdmin()
	end

	local function PrintModeChanceMessage(ply, message)
		if not IsValid(ply) then
			print(message)
		elseif ply.zChatPrint then
			ply:zChatPrint(message)
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, message)
		end
	end

	hook.Add("ShutDown", "savechances", function()
		file.Write(chancesfile, util.TableToJSON(zb.ModesChances or {}, true))
	end)

	concommand.Add("zb_getmodeschances", function(ply, cmd, args)
		if not CanManageModeChances(ply) then return end
		PrintModeChanceMessage(ply, util.TableToJSON(zb.ModesChances or {}, true))
	end)

	concommand.Add("zb_setmodechance", function(ply, cmd, args)
		if not CanManageModeChances(ply) then return end

		local mode = args[1]
		local chance = tonumber(args[2])

		if not mode or not zb.ModesChances or zb.ModesChances[mode] == nil then return end
		if not chance or chance ~= chance or chance == math.huge or chance == -math.huge then return end
		if chance < 0 or chance > 100 then return end

		zb.ModesChances[mode] = chance
	end)

	concommand.Add("zb_savemodeschances", function(ply, cmd, args)
		if not CanManageModeChances(ply) then return end
		file.Write(chancesfile, util.TableToJSON(zb.ModesChances or {}, true))
	end)
end

local function LoadModes()
	local directory = "zcity/gamemode/modes"
	local files, folders = file.Find(directory .. "/*", "LUA")

	if SERVER then
		zb.ModesChances = util.JSONToTable(file.Read(chancesfile,  "DATA") or "") or {}
	end

	for _, v in ipairs(files) do
		MODE = {}
		IncluderFunc(directory .. "/" .. v)
		InitMode()
		MODE = nil
	end

	for _, v in ipairs(folders) do
		MODE = {}
		LoadFromDir(directory .. "/" .. v)
		InitMode()
		MODE = nil
	end

	if SERVER and !file.Exists(chancesfile,  "DATA") then
		file.Write(chancesfile, util.TableToJSON(zb.ModesChances, true))
	end
end

LoadModes()

local function PruneRemovedModeState()
	local knownModes = {}

	for name, mode in pairs(zb.modes) do
		knownModes[name] = true

		if mode.Types then
			for subModeName in pairs(mode.Types) do
				knownModes[subModeName] = true
			end
		end
	end

	local function IsKnown(name)
		return isstring(name) and knownModes[name] == true
	end

	local function PruneList(list)
		local result = {}
		if not istable(list) then return result end

		for _, name in ipairs(list) do
			if IsKnown(name) then
				result[#result + 1] = name
			end
		end

		return result
	end

	zb.RoundList = PruneList(zb.RoundList)
	zb.QueuedModes = PruneList(zb.QueuedModes)

	if zb.nextround and not IsKnown(zb.nextround) then
		zb.nextround = nil
	end

	if zb.forcemode and zb.forcemode ~= "random" and not IsKnown(zb.forcemode) then
		zb.forcemode = "random"
		forcemode = "random"
	end

	for _, stateTable in ipairs({zb.ModesChances, zb.ModesPlaytime, zb.ModeTokens}) do
		if istable(stateTable) then
			for name in pairs(stateTable) do
				if not IsKnown(name) then
					stateTable[name] = nil
				end
			end
		end
	end

	if SERVER then
		file.Write(chancesfile, util.TableToJSON(zb.ModesChances or {}, true))

		timer.Simple(0, function()
			if not zb.SendModesInfoToClient or not zb.SendRoundListToClient then return end

			for _, ply in player.Iterator() do
				if ply:IsAdmin() then
					zb.SendModesInfoToClient(ply)
					zb.SendRoundListToClient(ply)
				end
			end
		end)
	end
end

PruneRemovedModeState()

print("Z-City 모드를 불러왔습니다!")

zb.oldHook = zb.oldHook or hook.Call
local oldHook = zb.oldHook

function hook.Call(name, gm, ...)
	local Current = zb.CROUND_MAIN or zb.CROUND or "tdm"

	local modesHooks = zb.modesHooks[Current]

	if modesHooks then -- technically an unnecessary nil check but i don't trust legacy code
		local hookFunc = modesHooks[name]
		if hookFunc then
			local ModeTable = zb.modes[Current]

			local a, b, c, d, e, f = hookFunc(ModeTable, ...)

			if (a != nil) then
				return a, b, c, d, e, f
			end
		end
	end

	return oldHook(name, gm, ...)
end
