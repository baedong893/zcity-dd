--;; ===================================
--;; RTV Modded RTVded :troll:
--;; ===================================
util.AddNetworkString("ZB_RockTheVote_start")
util.AddNetworkString("ZB_RockTheVote_vote")
util.AddNetworkString("ZB_RockTheVote_voteCLreg")
util.AddNetworkString("ZB_RockTheVote_end")
zb = zb or {}
local cooldown = {}
local votes = {}
zb.votestarted = false
local playervote = {}

local mappull = {}
local playerVoteWeight = {}

local function GetMapFamily(map)
    if string.find(string.lower(map), "smalltown") then
        return "smalltown"
    end
    return nil
end

local function GetFamilyMaps(family)
    local familyMaps = {}
    for _, map in ipairs(mappull) do
        if GetMapFamily(map) == family then
            table.insert(familyMaps, map)
        end
    end
    return familyMaps
end

local blacklist = {
    ["gm_construct"] = true, ["gm_flatgrass"] = true, ["gm_altarskforest"] = true, ["gm_renostruct_v2"] = true,
    ["gm_renostruct_v2_night"] = true, ["gm_city_of_silence"] = true, ["ttt_hogwarts"] = true,
    ["gm_russia"] = true, ["rp_southside"] = true,
    ["gm_herbalcity"] = true, ["gm_adit"] = true, ["gm_apartments_hl2"] = true,
    ["gm_section_nine"] = true, ["gm_sentimental98v1"] = true,
}

local function IsMapBlacklisted(map)
    if not map then return false end
    local lowerMap = string.lower(map)
    if blacklist[lowerMap] then return true end

    local isSmallTown = string.find(lowerMap, "smalltown", 1, true) or string.find(lowerMap, "smallotown", 1, true)
    if isSmallTown then
        return string.find(lowerMap, "xmas", 1, true)
            or string.find(lowerMap, "christmas", 1, true)
            or string.find(lowerMap, "snow", 1, true)
    end

    return false
end

local allowedPrefix = {
    ["ttt"] = true, ["hmcd"] = true, ["mu"] = true, ["ze"] = false,
    ["zs"] = true, ["tdm"] = true, ["zb"] = false, ["zbattle"] = false,
    ["gm"] = true, ["ph"] = true, ["cs"] = true, ["de"] = true, ["ds"] = true
}

local prefixWeights = {
    ["ttt"] = 18, ["hmcd"] = 19, ["mu"] = 18, ["ze"] = 0,
    ["zs"] = 9,  ["tdm"] = 5,  ["zb"] = 0,  ["zbattle"] = 0,
    ["gm"] = 20, ["ph"] = 11, ["cs"] = 1,  ["de"] = 1, ["ds"] = 7
}

local function GetSafeServerName()
    local hostname = GetConVar("hostname"):GetString() or "unknown"
    hostname = hostname:gsub("[^%w_-]", "_"):sub(1, 20)
    return hostname
end


local function GetDataPath(fileName)
    local serverName = GetSafeServerName()
    return "zbattle/" .. serverName .. "/" .. fileName
end


local function EnsureDataDirectory()
    local serverName = GetSafeServerName()
    if not file.Exists("zbattle", "DATA") then
        file.CreateDir("zbattle")
    end
    if not file.Exists("zbattle/" .. serverName, "DATA") then
        file.CreateDir("zbattle/" .. serverName)
    end
end


EnsureDataDirectory()

local mapPopularity = {}
local popularityPath = GetDataPath("MapPopularity.json")
if file.Exists(popularityPath, "DATA") then
    local data = file.Read(popularityPath, "DATA")
    mapPopularity = util.JSONToTable(data) or {}
end

local function getmaps()
    table.Empty(mappull)

    local maps = file.Find("maps/*.bsp", "GAME")

    --[[ 
    if hg and hg.xmas then
        table.Empty(mappull)
        mappull = {
            "cs_office",
            "cs_drugbust_winter",
            "gm_zabroshka_winter",
            "mu_smallotown_v2_snow",
            "ttt_clue_xmas",
            "ttt_cosy_winter",
            "ttt_winterplant_v4"
        }
        return 
    end
    ]]

    for _, map in ipairs(maps) do
        map = map:sub(1, -5)
        if not IsMapBlacklisted(map) then
            table.insert(mappull, map)
        end
    end

    local currentMap = game.GetMap()
    if currentMap and currentMap ~= "" and not IsMapBlacklisted(currentMap) and not table.HasValue(mappull, currentMap) then
        table.insert(mappull, currentMap)
    end
end

local function getWeightedRandomMapPrefix()
    local totalWeight = 0
    for prefix, weight in pairs(prefixWeights) do
        totalWeight = totalWeight + weight
    end

    local randomWeight = math.random() * totalWeight
    for prefix, weight in pairs(prefixWeights) do
        if randomWeight < weight then
            return prefix
        end
        randomWeight = randomWeight - weight
    end
end

local function getMapsByPrefix(prefix)
    local prefixMaps = {}
    for _, map in ipairs(mappull) do
        if map:StartWith(prefix) then
            table.insert(prefixMaps, map)
        end
    end
    return prefixMaps
end

hook.Add("InitPostEntity", "zb_GetMaps", function()
    zb.votestarted = false
    getmaps()
end)

net.Receive("ZB_RockTheVote_vote", function(len, ply)
    if not zb.votestarted then return end
    if cooldown[ply:EntIndex()] and cooldown[ply:EntIndex()] > CurTime() then return end

    cooldown[ply:EntIndex()] = CurTime() + 1

    local playerIdx = ply:EntIndex()

    if playervote[playerIdx] and votes[playervote[playerIdx]] then
        votes[playervote[playerIdx]] = votes[playervote[playerIdx]] - (playerVoteWeight[playerIdx] or 1)
    end

    local map = net.ReadString()
    if not map or map == "" then return end
    if map ~= "random" and not table.HasValue(mappull, map) then return end
    playervote[playerIdx] = map

    playerVoteWeight[playerIdx] = 1

    votes[map] = (votes[map] or 0) + playerVoteWeight[playerIdx]

    net.Start("ZB_RockTheVote_voteCLreg")
        net.WriteTable(votes)
    net.Broadcast()
end)


local endStarted = false

function zb.EndRTV()
    if endStarted then return end

    local winmap = table.GetWinningKey(votes)
    if not winmap then return end

    if winmap == "random" then
        winmap = mappull[math.random(#mappull)]
    end

    if not winmap then
        winmap = "gm_construct"
    end

    local currentMap = game.GetMap()

    if winmap == currentMap then
        endStarted = true

        net.Start("ZB_RockTheVote_end")
            net.WriteString(currentMap)
        net.Broadcast()

        for _, ply in player.Iterator() do
            ply:ChatPrint("현재 맵을 다시 시작합니다. 라운드가 처음부터 재시작됩니다.")
        end

        timer.Simple(3, function()
            table.Empty(votes)
            table.Empty(playervote)
            table.Empty(playerVoteWeight)

            zb.ClearRTVVotes()

            RunConsoleCommand("changelevel", currentMap)
        end)

        return
    end

    local mapFamily = GetMapFamily(winmap)

    mapPopularity[winmap] = math.min((mapPopularity[winmap] or 0) + 5, 100)

    local PlayedMaps = {}
    local playedMapsPath = GetDataPath("PlayedMaps.json")
    if file.Exists(playedMapsPath, "DATA") then
        PlayedMaps = util.JSONToTable(file.Read(playedMapsPath, "DATA")) or {}
    end

    if not table.HasValue(PlayedMaps, winmap) then
        table.insert(PlayedMaps, 1, winmap)

        if mapFamily then
            local familyMaps = GetFamilyMaps(mapFamily)
            for _, familyMap in ipairs(familyMaps) do
                if familyMap ~= winmap and not table.HasValue(PlayedMaps, familyMap) then
                    table.insert(PlayedMaps, 1, familyMap)
                    mapPopularity[familyMap] = math.min((mapPopularity[familyMap] or 0) + 5, 100)
                end
            end
        end

        if #PlayedMaps > 20 then
            local lastFiveMaps = {}
            for i = math.max(1, #PlayedMaps - 5 + 1), #PlayedMaps do
                if i > 1 then
                    table.insert(lastFiveMaps, PlayedMaps[i])
                end
            end

            PlayedMaps = {winmap}
            for _, map in ipairs(lastFiveMaps) do
                table.insert(PlayedMaps, map)
            end
        end

        file.Write(playedMapsPath, util.TableToJSON(PlayedMaps))
    end

    for map, pop in pairs(mapPopularity) do
        if map ~= winmap and not table.HasValue(PlayedMaps, map) then
            mapPopularity[map] = math.max(pop - 2, 0)
        end
    end

    file.Write(popularityPath, util.TableToJSON(mapPopularity))

    net.Start("ZB_RockTheVote_end")
        net.WriteString(winmap)
    net.Broadcast()

    endStarted = true

    timer.Simple(3, function()
        table.Empty(votes)
        table.Empty(playervote)
        table.Empty(playerVoteWeight)

        zb.ClearRTVVotes()

        RunConsoleCommand("changelevel", winmap)
    end)
end

local rtvtime = 0
function zb.ThinkRTV()
    if not zb.votestarted then return end
    if rtvtime < CurTime() then
        zb.EndRTV()
    end
end

--;; ===================================
--;; ВЕЛИКАЯ МЕГА СИСТЕМА ГОВНА:
--;; Функция для выбора "уникальных" префиксов
--;; с учётом того, что у них есть >=4 доступных карт
--;; (т. е. не в PlayedMaps)
--;; ===================================
local function getUniquePrefixes(playedMaps)
    local chosen = {}
    local attempts = 0

    while #chosen < 3 do
        local prefix = getWeightedRandomMapPrefix()
        if prefix then
            if not table.HasValue(chosen, prefix) then
                local prefixMaps = getMapsByPrefix(prefix)
                local validCount = 0
                for _, m in ipairs(prefixMaps) do
                    if not table.HasValue(playedMaps, m) then
                        validCount = validCount + 1
                    end
                end

                if validCount >= 4 then
                    table.insert(chosen, prefix)
                end
            end
        end

        attempts = attempts + 1
        if attempts > 300 then
            break
        end
    end

    return chosen
end

local function getMapWeight(map)
    local pop = mapPopularity[map] or 0
    return 1 - (pop / 100) 
end

function zb.StartRTV(time)
    if zb.votestarted then return end
    
    getmaps()

    rtvtime = CurTime() + (time or 45)

    local finalmaps = {}
    local availableMaps = table.Copy(mappull)

    local function addWeightedMapFrom(pool)
        if #pool == 0 then return false end

        local totalWeight = 0
        for _, m in ipairs(pool) do
            totalWeight = totalWeight + getMapWeight(m)
        end

        local rnd = math.random() * totalWeight
        local selectedIndex = #pool
        for idx, m in ipairs(pool) do
            local weight = getMapWeight(m)
            if rnd < weight then
                selectedIndex = idx
                break
            end
            rnd = rnd - weight
        end

        table.insert(finalmaps, pool[selectedIndex])
        table.remove(pool, selectedIndex)
        return true
    end

    while #finalmaps < 12 and addWeightedMapFrom(availableMaps) do end

    if #finalmaps == 0 and #mappull > 0 then
        table.insert(finalmaps, mappull[math.random(#mappull)])
    end

    if #finalmaps == 0 then
        table.insert(finalmaps, "gm_construct")
    end

    local currentMap = game.GetMap()
    if currentMap and currentMap ~= "" and not IsMapBlacklisted(currentMap) and not table.HasValue(finalmaps, currentMap) then
        table.insert(finalmaps, 1, currentMap)
    end

    table.insert(finalmaps, "random")

    net.Start("ZB_RockTheVote_start")
        net.WriteTable(finalmaps)
        net.WriteFloat(rtvtime)
    net.Broadcast()

    zb.votestarted = true


    hook.Add("Think", "RTVThink", zb.ThinkRTV)
end

util.AddNetworkString("RTVMenu")
function zb.RTVMenu(ply)
    net.Start("RTVMenu")
    net.Send(ply)
end


COMMANDS.forcertv = {function(ply, args)
    if not ply:IsAdmin() then ply:ChatPrint("권한이 없습니다.") return end
        zb.StartRTV(20)
    end,
    0
}

--;; чут чут переписал 
local rtvVotes = {} -- Dagestani fleas heard lezginka and trampled a cat to death
local rtvTimeout = nil


function zb.ClearRTVVotes()
    rtvVotes = {}
    if rtvTimeout then
        timer.Remove("RTVTimeout")
        rtvTimeout = nil
    end
end

-- ДЕКА КАК ТЫ ТАК СМОГ СДЕЛАТЬ, ЧТО ОНО СРЕТ БЕЗ ОСТНАОВКИ МНЕ ПРИНТОМ, ЧТО РТВ СОСТОИТСЯ, ГДЕ ТЫ НАСРАЛ 
function zb.CheckRTVVotes(needPrint)
    local votesNeeded = math.ceil(#player.GetAll() / 2)
    local votes = table.Count(rtvVotes)
    
    if votes >= votesNeeded then
        if needPrint then
            for _, v in player.Iterator() do
                v:ChatPrint("맵 변경을 위한 충분한 표가 모였습니다. 다음 라운드에 RTV가 진행됩니다.")
            end
        end
        
        return true
    end
    
    return false
end

COMMANDS.rtv = {function(ply, args)
    --print(zb.votestarted)
	if zb.votestarted then
		zb.RTVMenu(ply)
		return
	end

    local steamID = ply:SteamID()
    
    if rtvVotes[steamID] then
        rtvVotes[steamID] = nil
        ply:ChatPrint("맵 변경 투표를 취소했습니다.")
        
        local votesNeeded = math.ceil(#player.GetAll() / 2)
        local votes = table.Count(rtvVotes)
        local remaining = votesNeeded - votes
        
        --for _, v in pairs(player.GetAll()) do
        --    if v ~= ply then БЕСМЫСЛЕННЫЙ СПАМ
        --        v:ChatPrint(ply:Nick() .. " canceled their vote for map change. " .. remaining .. " more votes needed.")
        --    end
        --end
        
        return
    end
    --;; Дебилы
    --[[if table.Count(rtvVotes) == 0 and not rtvTimeout then
        rtvTimeout = true
        timer.Create("RTVTimeout", 1800, 1, function()
            if table.Count(rtvVotes) > 0 then
                for _, v in pairs(player.GetAll()) do
                    v:ChatPrint("Map change votes have been reset due to timeout (30 minutes).")
                end
                zb.ClearRTVVotes()
            end
        end)
    end--]]
	
    rtvVotes[steamID] = true
    
    local votesNeeded = math.ceil(#player.GetAll() / 2)
    local votes = table.Count(rtvVotes)
    local remaining = votesNeeded - votes
    
    for _, v in player.Iterator() do
        if remaining != 0 then
            v:ChatPrint(
                ply:Nick() .. "님이 맵 변경에 투표했습니다. " .. 
                remaining .. "표가 더 필요합니다. 투표를 취소하려면 !rtv를 다시 입력하십시오."
            )
        end
    end

    if zb.CheckRTVVotes(true) then
        return
    end
end, 0}

hook.Add("ShutDown", "ResetRTVVotesOnMapChange", zb.ClearRTVVotes)
hook.Add("PostGamemodeLoaded", "InitializeRTVSystem", function()
    zb.ClearRTVVotes()
end)

hook.Add("PlayerDisconnected", "CheckRTVAfterDisconnect", function(ply)
    if rtvVotes[ply:SteamID()] then
        rtvVotes[ply:SteamID()] = nil
        
        --for _, v in pairs(player.GetAll()) do
        --   v:ChatPrint(ply:Nick() .. " left the server (their RTV vote was removed).")
        --end
        
        timer.Simple(0.1, zb.CheckRTVVotes)
    end
end)
