if not ulx then return end

local CATEGORY_NAME = "Voting"

if SERVER then
    util.AddNetworkString("ulx_votemode")
end

local function voteModeDone(t)
    local results = t.results
    local winner
    local winnernum = 0
    for id, numvotes in pairs(results) do
        if numvotes > winnernum then
            winner = id
            winnernum = numvotes
        end
    end

    local str
    if not winner then
        str = "투표 결과: 투표에 참여한 사람이 없어 당선된 모드가 없습니다!"
    else
        local mode = zb.modes[t.options[winner]]
        if mode and mode.CanLaunch and mode:CanLaunch() then
            str = "투표 결과 : '" .. t.options[winner] .. "' 모드가 당선되었습니다. (" .. winnernum .. "/" .. t.voters .. ")"
            NextRound(t.options[winner])
        else
            str = "투표 결과 : '" .. t.options[winner] .. "' 모드를 실행할 수 없습니다."
        end
    end
    ULib.tsay(_, str)
    ulx.logString(str)
    Msg(str .. "\n")
end

function ulx.votemode(calling_ply, ...)
    calling_ply.CoolDownVote = calling_ply.CoolDownVote or 0
    if calling_ply.CoolDownVote > CurTime() then -- if calling_ply.CoolDownVote or 0 > CurTime() then Useless wtf
        ULib.tsayError(calling_ply, "새 투표를 만들기 전까지".. ( math.Round( calling_ply.CoolDownVote - CurTime(), 1 ) ) .."초 더 기다려 주세요.", true)    
    return end
    calling_ply.CoolDownVote = CurTime() + 180

    local argv = {...}

    if ulx.voteInProgress then
        ULib.tsayError(calling_ply, "이미 진행 중인 투표가 있습니다. 현재 투표가 끝날 때까지 기다려 주세요.", true)
        return
    end

    for i = 2, #argv do
        if ULib.findInTable(argv, argv[i], 1, i - 1) then
            ULib.tsayError(calling_ply, argv[i] .. " 모드가 두 번 입력되었습니다. 다시 시도해 주세요.")
            return
        end
    end

    for _, modeName in ipairs(argv) do
        local mode = zb.modes[modeName]
        if not (mode and mode.CanLaunch and mode:CanLaunch()) then
            ULib.tsayError(calling_ply, "'" .. modeName .. "' 모드를 실행할 수 없습니다.")
            return
        end
    end

    if #argv > 1 then
        ulx.doVote("모드 변경 대상..", argv, voteModeDone, _, _, _, argv, calling_ply)
        ulx.fancyLogAdmin(calling_ply, "#A님이 다음 항목으로 모드 투표를 시작했습니다:" .. string.rep(" #s", #argv), ...)
    elseif #argv == 1 then
        ulx.doVote("모드를 " .. argv[1] .. "(으)로 변경하시겠습니까?", {"예", "아니요"}, function(t)
            local yesVotes = t.results[1] or 0
            local noVotes = t.results[2] or 0
            if yesVotes > noVotes then
                voteModeDone({results = {[1] = yesVotes}, options = argv, voters = t.voters})
            else
                ULib.tsay(_, "투표 결과: '" .. argv[1] .. "' 모드로의 변경이 거부되었습니다.")
                ulx.logString("투표 결과: '" .. argv[1] .. "' 모드로의 변경이 거부되었습니다.")
                Msg("Vote results: Mode change to '" .. argv[1] .. "' was rejected.\n")
            end
        end, _, _, _, argv, calling_ply)
        ulx.fancyLogAdmin(calling_ply, "#A님이 #s 모드 변경 투표를 시작했습니다", argv[1])
    else
        ULib.tsayError(calling_ply, "투표를 위해 최소 하나 이상의 항목을 입력해야 합니다.", true)
    end
end

local votemode = ulx.command(CATEGORY_NAME, "ulx votemode", ulx.votemode, "!votemode")
votemode:addParam{type = ULib.cmds.StringArg, completes = {"tdm", "gwars", "riot", "criresp", "defense", "hl2dm", "dm", "cstrike" }, hint = "mode", ULib.cmds.restrictToCompletes, ULib.cmds.takeRestOfLine, repeat_min = 1, repeat_max = 10}
votemode:defaultAccess(ULib.ACCESS_ADMIN)
votemode:help("공개 모드 투표를 시작합니다.")

if SERVER then ulx.convar("votemodeSuccessratio", "0.5", _, ULib.ACCESS_ADMIN) end
if SERVER then ulx.convar("votemodeMinvotes", "3", _, ULib.ACCESS_ADMIN) end