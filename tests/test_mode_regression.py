"""Execute the real registry, round selection/lifecycle and AFK timer with Lupa.

GMod engine spawning, rendering and networking are mocks, not in-game QA.
Only the two exercised GLua continue loops are translated to equivalent gotos;
any other reached continue fails the test instead of silently changing behavior.
"""
from pathlib import Path
import os
import re
from lupa.lua54 import LuaRuntime

ROOT = Path(os.environ.get("ZCITY_TEST_ROOT", Path(__file__).resolve().parents[1]))
BASE = ROOT / "addons/Z-City Korean Localization/gamemodes/zcity/gamemode"


def glua(source):
    pattern = r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|--\[\[[\s\S]*?\]\]|--[^\n]*|/\*[\s\S]*?\*/|//[^\n]*|!=|&&|\|\||!|\bcontinue\b'
    replacements = {"!=": "~=", "&&": "and", "||": "or", "!": "not ",
                    "continue": 'error("untranslated continue path reached")'}

    def replace(match):
        token = match[0]
        if token.startswith(("//", "/*")):
            return "\n" * token.count("\n")
        return replacements.get(token, token)

    return re.sub(pattern, replace, source)


def continue_loop(source, opening, ending):
    start = source.index(opening)
    end = source.index(ending, start)
    body = source[start + len(opening):end]
    body = re.sub(r"\bcontinue\b", "goto next_player", body)
    return (source[:start] + opening + "\n do" + body
            + "\n end\n ::next_player::" + source[end:])


lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
SERVER=true CLIENT=false TEAM_SPECTATOR=1002 TEAM_UNASSIGNED=1001
IN_ATTACK=1 IN_ATTACK2=2 IN_JUMP=4 IN_RELOAD=8 MOVETYPE_WALK=2 MOVETYPE_NOCLIP=8
HUD_PRINTTALK=3 SCREENFADE={OUT=1} now=100 players={} COMMANDS={}
zb={ROUND_STATE=0,Roundscount=0} hg={PluvTown={Active=false},achievements={SavePlayerAchievements=function() end}}
function CurTime() return now end
function IsValid(x) return type(x)=='table' and not x.invalid end
function isstring(x) return type(x)=='string' end
function isnumber(x) return type(x)=='number' end
function istable(x) return type(x)=='table' end
function isfunction(x) return type(x)=='function' end
function Color(...) return {...} end
function PrintMessage() end
function AddCSLuaFile() end
function print() end
function ApplyAppearance(ply) ply.appearance=true end
function RandomPairs(tbl) return pairs(tbl) end
math.Clamp=function(x,a,b) return math.max(a,math.min(b,x)) end
math.Rand=function(a,b) return a+(b-a)*math.random() end
table.Copy=function(t) local r={} for k,v in pairs(t) do r[k]=type(v)=='table' and table.Copy(v) or v end return r end
table.IsEmpty=function(t) return next(t)==nil end
table.Random=function(t) if #t>0 then return t[math.random(#t)] end end
string.GetFileFromFilename=function(s) return s:match('[^/]+$') end
string.StartWith=function(s,prefix) return s:sub(1,#prefix)==prefix end
player={GetAll=function() return players end,Iterator=function() return ipairs(players) end,
 GetCount=function() return #players end}
function player.GetHumans() local list={} for _,p in ipairs(players) do if not p:IsBot() then list[#list+1]=p end end return list end
function RunConsoleCommand(cmd) if cmd=='bot' then autoBotAdded=true end end
ents={FindByClass=function() return {} end}
game={GetMap=function() return 'gm_construct' end,CleanUpMap=function() cleanups=(cleanups or 0)+1 end}
hook={items={}}
function hook.Add(event,id,fn) hook.items[event]=hook.items[event] or {}; hook.items[event][id]=fn end
function hook.Call(event,gm,...)
 for _,fn in pairs(hook.items[event] or {}) do local result=fn(...); if result~=nil then return result end end
 if gm and gm[event] then return gm[event](gm,...) end
end
function hook.Run(event,...) return hook.Call(event,nil,...) end
timer={items={}}
function timer.Create(id,delay,reps,fn) timer.items[id]=fn end
function timer.Simple() end -- Deferred engine callbacks are outside this test's scope.
concommand={Add=function() end}
convars={}
function CreateConVar(name,default)
 local cv={value=default}
 function cv:GetString() return self.value end
 function cv:SetString(x) self.value=x end
 function cv:GetBool() return self.value=='1' end
 convars[name]=cv; return cv
end
function GetConVar(name) return convars[name] or CreateConVar(name,'0') end
net={receivers={},messages={}}
function net.Receive(name,fn) net.receivers[name]=fn end
function net.Start(name) net.current={name=name,values={}} end
function net.WriteString(x) table.insert(net.current.values,x) end
net.WriteInt=net.WriteString; net.WriteTable=net.WriteString
function net.Broadcast() table.insert(net.messages,net.current) end
net.Send=net.Broadcast
function net.ReadString() return table.remove(net.input,1) end
net.ReadBool=net.ReadString; net.ReadTable=net.ReadString
file={CreateDir=function() end,Read=function() end,Write=function() end,Exists=function() return true end}
util={AddNetworkString=function() end,JSONToTable=function() return {} end,TableToJSON=function() return '{}' end}
function hg.UpdateRoundTime(time,start,wait)
 zb.ROUND_TIME=time or zb.ROUND_TIME; zb.ROUND_START=start or now
end
local P={}; P.__index=P
function NewPlayer(spec,bot)
 return setmetatable({team=spec and TEAM_SPECTATOR or 0,bot=bot,alive=not spec,
  afkTime=900,afkTime2=900,organism={otrub=false},weapons={},streak=7,admin=true},P)
end
function P:Team() return self.team end
function P:SetTeam(x) self.team=x end
function P:IsBot() return self.bot end
function P:IsPlayer() return true end
function P:IsAdmin() return self.admin end
function P:Alive() return self.alive end
function P:Kill() self.alive=false; self.killed=true end
P.KillSilent=P.Kill
function P:Spawn()
 self.alive=true; self.spawns=(self.spawns or 0)+1
 if exerciseSpawnHooks then
  self.weapons={}; self.active=nil
  hook.Call('PlayerSpawn',GM,self)
 end
end
function P:KeyPressed(key) return ((self.pressed or 0) & key)~=0 end
function P:UnSpectate() self.observing=false end
function P:SetMoveType(value) self.move=value end
function P:SuppressHint() end
function InputFrame(ply,buttons)
 ply.pressed=buttons & (~(ply.buttons or 0)); ply.buttons=buttons
 return hook.Call('PlayerDeathThink',GM,ply)
end
function P:Kick() self.kicked=true end
function P:SetupTeam(x) self.team=x; self.setup=true end
function P:Freeze(x) self.frozen=x end
function P:Give(class) self.weapons[class]={}; return self.weapons[class] end
function P:SelectWeapon(class) self.active=class end
function P:Name() return 'fixture player' end
function P:ChatPrint() end
function P:GiveExp() end
function P:FlashlightIsOn() return false end
function P:SetPlayerClass() self.classReset=(self.classReset or 0)+1 end
function P:ScreenFade() end
function P:GetPData() return self.streak end
function P:GetNWInt() return self.streak end
function P:SetPData(_,v) self.streak=v end
function P:SetNWInt(_,v) self.streak=v end
function P:SetNetVar() end
function zb:AutoBalance() end -- Engine/team setup boundary; test participants keep their existing team.
function zb:BalancedChoice() return 1 end
function zb.tdm_checkpoints() end
function zb.CheckRTVVotes() return false end
function zb.StartRTV() rtvStarted=true end
function zb.RemoveFade() fadeRemoved=true end
''')

loader = (BASE / "loader.lua").read_text(encoding="utf-8")


def files(directory, _):
    if directory == "zcity/gamemode/modes/*":
        return lua.table(), lua.table_from(["test"])
    if directory == "zcity/gamemode/modes/test/*":
        return lua.table_from(sorted(p.name for p in (BASE / "modes/test").glob("*.lua"))), lua.table()
    return lua.table(), lua.table()


def include(path):
    path = BASE / path.removeprefix("zcity/gamemode/")
    lua.execute(glua(path.read_text(encoding="utf-8")))


lua.globals().file.Find = files
lua.globals().include = include
lua.execute(glua(loader))
rounds = (BASE / "libraries/sv_roundsystem.lua").read_text(encoding="utf-8")
# Scope translation to KillPlayers so its spectator/DontKillPlayer skips stay equivalent.
start = rounds.index('function zb:KillPlayers()')
end = rounds.index('\nif IsRoundModeDisabled(zb.forcemode)', start)
part = continue_loop(rounds[start:end], '\tfor i, ply in player.Iterator() do', '\n\tend\nend')
rounds = rounds[:start] + part + rounds[end:]
lua.execute(glua(rounds))
afk = (BASE / "libraries/sv_antiafk.lua").read_text(encoding="utf-8").split('--[[')[0]
afk = continue_loop(afk, '    for k,ply in player.Iterator() do', '\n    end\nend)')
lua.execute(glua(afk))
init = (BASE / "init.lua").read_text(encoding="utf-8")
spawn_start = init.index('function GM:PlayerInitialSpawn(ply)')
spawn_end = init.index('\nfunction GM:IsSpawnpointSuitable', spawn_start)
lua.execute('GM={}')
lua.execute(glua(init[spawn_start:spawn_end]))
for opening, ending in [
    ('function GM:PlayerSpawn(ply)', '\nfunction GM:PlayerDisconnected'),
    ('function GM:PlayerDeathThink(ply)', '\nfunction GM:PlayerDeath(ply)'),
]:
    start = init.index(opening)
    lua.execute(glua(init[start:init.index(ending, start)]))
can_spawn = re.search(r'function PLAYER:CanSpawn\(\).*?\nend', init, re.S)[0]
lua.execute('PLAYER=getmetatable(NewPlayer())')
lua.execute(glua(can_spawn))
lua.execute(r'''
testmode=zb.modes.test
assert(testmode and testmode.name=='test' and not testmode.base)
assert(#zb.GetModes()==1 and zb:GetMode('test')=='test')
-- A regular mode fixture exposes shared-system regressions without importing combat logic.
function AddRegularMode()
 zb.modes.hmcd={name='hmcd',PrintName='Regular',Chance=1,ROUND_TIME=300,start_time=0,
  CanLaunch=function() return true end,ShouldRoundEnd=function() return nil end}
end
AddRegularMode()
human=NewPlayer(false,false); spectator=NewPlayer(true,false); bot=NewPlayer(false,true)
players={human,spectator,bot}
local info
for _,v in ipairs(zb.GetModesInfo()) do if v.key=='test' then info=v end end
assert(info and info.name=='테스트 모드' and info.menuVisible and info.canlaunch==1)
assert(zb.GetActivePlayerCount()==2,'spectator counted or bot excluded')
-- Stale persisted chances and even a custom chance function cannot opt into auto-selection.
zb.ModesChances.test=100; testmode.ChanceFunction=function() return 100 end
assert(zb.GetChance('test')==0 and zb.GetChance('hmcd')==1)
for i=1,30 do
 zb.RerollChances(); assert(zb.nextround~='test')
 for _,name in ipairs(zb.RoundList) do assert(name~='test') end
end
testmode.ChanceFunction=nil
-- Normal administrator selection while waiting: exact id/parent and participant setup.
net.input={'setmode','test',false}; net.receivers.AdminSetGameMode(0,human)
assert(zb.CROUND=='test' and zb.CROUND_MAIN=='test' and CurrentRound()==testmode)
assert(human:Alive() and human.setup and human.active=='weapon_hands_sh' and human.frozen==false)
assert(not spectator.spawns and spectator:Team()==TEAM_SPECTATOR)
assert(human.afkTime==0 and spectator.afkTime==0 and bot.afkTime==0)
-- Empty waiting round remains selected, then one human alone can start.
players={spectator}; zb:PreRound(); assert(zb.ROUND_STATE==0 and zb.CROUND=='test')
players={human}; zb.Roundscount=50
zb:PreRound(); now=now+1; zb:PreRound()
assert(zb.ROUND_STATE==1 and not rtvStarted,'solo start failed or auto RTV interrupted')
local roundInfo
for _,message in ipairs(net.messages) do
 if message.name=='RoundInfo' and message.values[3]==1 then roundInfo=message.values end
end
assert(roundInfo[1]=='test' and roundInfo[2]=='test','incorrect network id/parent')
-- Actual mode dispatch must respawn only on a new left click during the active round.
exerciseSpawnHooks=true
clicker=NewPlayer(false,false); clicker.alive=false; clicker.observing=true; clicker.move=MOVETYPE_NOCLIP
local spectatorTicks=0
hook.Add('PlayerDeathThink','test_spectator_boundary',function() spectatorTicks=spectatorTicks+1 end)
InputFrame(clicker,0); assert(not clicker:Alive(),'death auto-respawned without input')
for _,button in ipairs({IN_ATTACK2,IN_JUMP,IN_RELOAD}) do
 InputFrame(clicker,button); assert(not clicker:Alive(),'non-left-click respawned')
end
InputFrame(clicker,0)
local before=spectatorTicks
assert(InputFrame(clicker,IN_ATTACK)==true and clicker:Alive(),'left click failed to respawn')
assert(clicker.spawns==1 and clicker.classReset==1 and clicker:Team()==0 and clicker.setup)
assert(not clicker.observing and clicker.move==MOVETYPE_WALK and clicker.frozen==false)
assert(clicker.active=='weapon_hands_sh' and clicker.weapons.weapon_hands_sh and clicker.afkTime==0)
assert(spectatorTicks==before,'spectator handler ran after respawn')
assert(zb.ROUND_STATE==1,'respawn ended the test round')
-- Holding fire through another death does not respawn; release/click works repeatedly.
clicker.alive=false
InputFrame(clicker,IN_ATTACK); assert(not clicker:Alive() and clicker.spawns==1)
for i=2,4 do
 InputFrame(clicker,0); InputFrame(clicker,IN_ATTACK)
 assert(clicker:Alive() and clicker.spawns==i and clicker.classReset==i,'repeat respawn failed')
 InputFrame(clicker,0); InputFrame(clicker,IN_ATTACK)
 assert(clicker.spawns==i,'living player respawned from click')
 clicker.alive=false
end
for _,state in ipairs({0,2,3}) do
 zb.ROUND_STATE=state; InputFrame(clicker,0); InputFrame(clicker,IN_ATTACK)
 assert(not clicker:Alive() and clicker.spawns==4,'respawn escaped active round')
end
zb.ROUND_STATE=1
for _,excluded in ipairs({NewPlayer(true,false),NewPlayer(false,true)}) do
 excluded.alive=false; InputFrame(excluded,IN_ATTACK)
 assert(not excluded:Alive() and not excluded.spawns,'spectator or bot respawned')
end
testmode:PlayerDeathThink({invalid=true})
-- Switching modes immediately disables the handler, without delayed respawns to leak.
zb.CROUND='hmcd'; zb.CROUND_MAIN='hmcd'
InputFrame(clicker,0); InputFrame(clicker,IN_ATTACK)
assert(not clicker:Alive() and clicker.spawns==4,'other mode inherited click respawn')
zb.CROUND='test'; zb.CROUND_MAIN='test'
InputFrame(clicker,0); InputFrame(clicker,IN_ATTACK)
assert(clicker:Alive() and clicker.spawns==5,'returning to test lost click respawn')
hook.items.PlayerDeathThink.test_spectator_boundary=nil
exerciseSpawnHooks=false
-- Long inactivity, all dead and zero remaining players must not end the round.
players={bot,spectator,human}; spectator.admin=false
for i=1,720 do now=now+10; timer.items.ZB_AntiAfkThink() end
assert(human:Alive() and human:Team()~=TEAM_SPECTATOR and not human.kicked)
assert(not spectator.kicked and bot:Alive())
human.alive=false; bot.alive=false
zb:PreRound(); zb:EndRoundThink(); assert(zb.ROUND_STATE==1)
players={}; zb:EndRoundThink(); assert(zb.ROUND_STATE==1)
-- The first human reconnecting to an empty test round must not trigger the helper bot/reset.
players={human}; GM:PlayerInitialSpawn(human)
assert(zb.ROUND_STATE==1 and not autoBotAdded,'first reconnect ended the test round')
-- Explicit queue preserves repeated manual-only modes, then manual end advances normally.
players={human}; human.alive=true
net.input={{'test','test','hmcd','not_a_mode'}}; net.receivers.AdminSetGameQueue(0,human)
assert(#zb.QueuedModes==3 and zb.QueuedModes[1]=='test' and zb.QueuedModes[2]=='test')
zb.SetRoundList({'test','test','hmcd'})
human.afkTime=1000; net.receivers.AdminEndRound(0,human)
assert(zb.ROUND_STATE==3 and human.afkTime==0 and human.streak==7)
zb:EndRoundThink(); now=now+6; zb:EndRoundThink()
assert(zb.ROUND_STATE==0 and zb.CROUND=='test' and human:Alive())
zb:PreRound(); now=now+1; zb:PreRound()
assert(zb.ROUND_STATE==1 and zb.CROUND=='test' and zb.nextround=='test')
-- Leaving restores the ordinary timeout, low-player and AFK rules.
NextRound('hmcd'); net.receivers.AdminEndRound(0,human)
zb:EndRoundThink(); now=now+6; zb:EndRoundThink()
assert(zb.CROUND=='hmcd' and human.afkTime==0)
zb.Roundscount=0; zb.ROUND_STATE=1; zb.ROUND_START=0; now=100000
assert(zb:ShouldRoundEnd() and zb.ShouldEndForLoneActivePlayer())
players={bot,spectator,human}; human.alive=true; bot.alive=true
timer.items.ZB_AntiAfkThink(); assert(human.afkTime==10 and human:Alive())
for i=1,30 do timer.items.ZB_AntiAfkThink() end
assert(human:Team()==TEAM_SPECTATOR and not human:Alive(),'regular AFK disabled after test')
assert(bot:Alive(),'bot no longer skipped')
players={human}; GM:PlayerInitialSpawn(human)
assert(autoBotAdded and zb.ROUND_STATE==3,'regular first-join behavior changed')
''')

# Registry/hook reload does not duplicate registration or leave replaced mode functions.
lua.execute(glua(loader))
lua.execute(glua(afk))
lua.execute("assert(#zb.GetModes()==1 and zb.modes.test~=testmode and zb.modesHooks.test.EndRound==zb.modes.test.EndRound)")
lua.execute("zb.CROUND='test'; zb.CROUND_MAIN=nil; zb.ROUND_STATE=1; CurrentRound(); players={human}; human.alive=true; human.team=0; timer.items.ZB_AntiAfkThink(); assert(human.afkTime==0)")
lua.execute("clicker.alive=false; InputFrame(clicker,0); InputFrame(clicker,IN_ATTACK); assert(clicker:Alive() and clicker.spawns==6, 'reload lost or duplicated respawn handler')")

# Client uses the same registry and existing RoundInfo route; HUD only dispatches in this mode.
lua.execute("SERVER=false CLIENT=true; fadeRemoved=false; drawCount=0; color_white={}; TEXT_ALIGN_CENTER=1; hudTexts={}; draw={SimpleText=function(text) drawCount=drawCount+1; hudTexts[text]=true end}; function ScrW() return 1920 end; function ScreenScale(x) return x end; function LocalPlayer() return human end")
lua.execute(glua(loader))
lua.execute(r'''
zb.CROUND='test'; zb.CROUND_MAIN='test'; zb.ROUND_STATE=1
zb.modes.test:RoundStart(); assert(fadeRemoved)
hook.Run('HUDPaint'); assert(drawCount==2 and not hudTexts['좌클릭으로 부활'])
human.alive=false; hudTexts={}; hook.Run('HUDPaint')
assert(drawCount==5 and hudTexts['좌클릭으로 부활'],'dead participant missing respawn hint')
human.team=TEAM_SPECTATOR; hudTexts={}; hook.Run('HUDPaint')
assert(drawCount==7 and not hudTexts['좌클릭으로 부활'],'voluntary spectator offered respawn')
zb.ROUND_STATE=3; hook.Run('HUDPaint'); assert(drawCount==7)
zb.CROUND_MAIN='hmcd'; hook.Run('HUDPaint'); assert(drawCount==7)
''')
print("PASS: registry/reload, direct/queued selection, solo start, random exclusion, unlimited duration, AFK immunity/reset, manual end/transition and client HUD isolation")
print("PASS: fresh left-click respawn, normal spawn/equipment, held-input rejection, repeated deaths, spectator/bot exclusion, round/mode isolation, reload and death hint")
