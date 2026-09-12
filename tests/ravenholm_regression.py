"""Run the actual mode loader, round selection, BG lifecycle and defense spawn helpers.

Engine geometry, NPC AI and rendering are mocked; this does not replace in-game QA.
"""
from pathlib import Path
import os
import re
import wave
import json
from array import array
from lupa.lua54 import LuaRuntime

ROOT = Path(os.environ.get("ZCITY_TEST_ROOT", Path(__file__).resolve().parents[1]))
BASE = ROOT / "addons/Z-City Korean Localization/gamemodes/zcity/gamemode"
lua = LuaRuntime(unpack_returned_tuples=True)


def glua(source):
    pattern = r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|--\[\[[\s\S]*?\]\]|--[^\n]*|/\*[\s\S]*?\*/|//[^\n]*|!=|&&|\|\||!|\bcontinue\b'
    replace = {"!=": "~=", "&&": "and", "||": "or", "!": "not ",
               "continue": 'error("untranslated continue reached")'}
    return re.sub(pattern, lambda m: "\n" * m[0].count("\n") if m[0].startswith(("//", "/*")) else replace.get(m[0], m[0]), source)


def continue_loop(source, opening, ending):
    start = source.index(opening) + len(opening)
    end = source.index(ending, start)
    body = re.sub(r"\bcontinue\b", "goto next_item", source[start:end])
    return source[:start] + "\n do" + body + "\n end\n ::next_item::" + source[end:]


lua.execute(r'''
SERVER=true CLIENT=false TEAM_SPECTATOR=1002 TEAM_UNASSIGNED=1001
HUD_PRINTTALK=3 SCREENFADE={OUT=1} now=100 players={} globals={} messages={} COMMANDS={}
CONTENTS_WATER=1 CONTENTS_SLIME=2 MASK_SOLID_BRUSHONLY=3 MASK_SOLID=4 MASK_PLAYERSOLID=5 MASK_BLOCKLOS=6
D_HT=1 D_NU=4 DMG_RADIATION=1
zb={ROUND_STATE=0,Roundscount=0} hg={PluvTown={Active=false},achievements={SavePlayerAchievements=function() end}}
function CurTime() return now end
function IsValid(x) return type(x)=='table' and not x.invalid end
function istable(x) return type(x)=='table' end
function isstring(x) return type(x)=='string' end
function isnumber(x) return type(x)=='number' end
function isfunction(x) return type(x)=='function' end
function Color(...) return {...} end
function PrintMessage(_,text) messages[#messages+1]=text end
function AddCSLuaFile() end
downloads={}; resource={AddFile=function(path) downloads[path]=true end}
function print() end
function RandomPairs(t) return pairs(t) end
function ApplyAppearance(p) p.appearance=true end
function Lerp(f,a,b) return a+(b-a)*f end
function LerpVector(f,a,b) return a+(b-a)*f end
math.Clamp=function(x,a,b) return math.max(a,math.min(b,x)) end
math.Round=function(x) return math.floor(x+0.5) end
math.Rand=function(a,b) return a+(b-a)*math.random() end
bit={band=function(a,b) return a & b end,bor=function(a,b) return a | b end}
local V={}; V.__index=V
function Vector(x,y,z) return setmetatable({x=x or 0,y=y or 0,z=z or 0},V) end
function V.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function V.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function V.__mul(a,b) return Vector(a.x*b,a.y*b,a.z*b) end
function V:LengthSqr() return self.x^2+self.y^2+self.z^2 end
function V:DistToSqr(b) return (self-b):LengthSqr() end
function V:Dot(b) return self.x*b.x+self.y*b.y+self.z*b.z end
function V:GetNormalized() return self*(1/math.sqrt(self:LengthSqr())) end
function isvector(x) return getmetatable(x)==V end
vector_origin=Vector()
function Angle() return {Forward=function() return Vector(1,0,0) end} end
table.Copy=function(t) if isvector(t) then return Vector(t.x,t.y,t.z) end
 local r={} for k,v in pairs(t) do r[k]=type(v)=='table' and table.Copy(v) or v end return r end
table.CopyFromTo=function(a,b) for k,v in pairs(table.Copy(a)) do b[k]=v end end
table.Inherit=function(a,b) for k,v in pairs(b) do if a[k]==nil then a[k]=v end end a.BaseClass=b end
table.IsEmpty=function(t) return next(t)==nil end
table.Empty=function(t) for k in pairs(t) do t[k]=nil end end
table.HasValue=function(t,v) for _,x in pairs(t) do if x==v then return true end end return false end
table.Random=function(t) if #t>0 then return t[math.random(#t)] end end
table.Shuffle=function() end
string.GetFileFromFilename=function(s) return s:match('[^/]+$') end
string.StartWith=function(s,prefix) return s:sub(1,#prefix)==prefix end
player={GetAll=function() return players end,Iterator=function() return ipairs(players) end,GetCount=function() return #players end}
function player.GetHumans() local t={} for _,p in ipairs(players) do if not p:IsBot() then t[#t+1]=p end end return t end
hook={items={}}
function hook.Add(event,id,fn) hook.items[event]=hook.items[event] or {}; hook.items[event][id]=fn end
function hook.Call(event,gm,...) for _,fn in pairs(hook.items[event] or {}) do local r=fn(...); if r~=nil then return r end end end
function hook.Run(event,...) return hook.Call(event,nil,...) end
timer={items={}}
function timer.Create(id,delay,reps,fn) timer.items[id]=fn end
function timer.Remove(id) timer.items[id]=nil end
function timer.Simple() end
concommand={Add=function() end} convars={}
function CreateConVar(name,default) local c={value=default}
 function c:GetString() return self.value end
 function c:SetString(x) self.value=x end
 function c:GetBool() return self.value=='1' end
 convars[name]=c; return c end
function GetConVar(name) return convars[name] or CreateConVar(name,'0') end
function RunConsoleCommand() end
net={receivers={},messages={}}
function net.Receive(n,f) net.receivers[n]=f end
function net.Start(n) net.current={name=n,values={}} end
function net.WriteString(v) table.insert(net.current.values,v) end
net.WriteInt=net.WriteString; net.WriteTable=net.WriteString
function net.Broadcast() table.insert(net.messages,net.current) end
net.Send=net.Broadcast
function net.ReadString() return table.remove(net.input,1) end
net.ReadBool=net.ReadString; net.ReadTable=net.ReadString
file={CreateDir=function() end,Read=function() end,Write=function() end,Exists=function() return true end}
util={AddNetworkString=function() end,JSONToTable=function() return {} end,TableToJSON=function() return '{}' end}
function util.IsInWorld() return not outside end
function util.PointContents() return water and CONTENTS_WATER or 0 end
function util.TraceHull() return {Hit=blocked,StartSolid=blocked,AllSolid=blocked} end
function util.TraceLine(t)
 if t.mask==MASK_BLOCKLOS then return {Hit=occluded,Fraction=occluded and 0.5 or 1} end
 if t.endpos.z>t.start.z then return {Hit=false} end
 return {Hit=true,HitPos=Vector(t.start.x,t.start.y,0),HitNormal=Vector(0,0,1)}
end
function util.Effect() end
function util.BlastDamage() explosions=(explosions or 0)+1 end
sound={Play=function() end}
function EffectData() return {SetOrigin=function() end} end
function DamageInfo() local t={} for _,k in ipairs({'Damage','DamageType','Attacker','Inflictor'}) do
 t['Set'..k]=function(self,v) self[k]=v end end return t end
function SetGlobalBool(k,v) globals[k]=v end
SetGlobalInt=SetGlobalBool; SetGlobalFloat=SetGlobalBool; SetGlobalVector=SetGlobalBool
SetGlobalString=SetGlobalBool
function GetGlobalString(k,default) return globals[k] or default end
function GetGlobalBool(k) return globals[k] or false end
function GetGlobalInt(k) return globals[k] or 0 end
GetGlobalFloat=GetGlobalInt
function GetGlobalVector(k) return globals[k] or vector_origin end
local E={}; E.__index=E
entities={}
function NewEntity(class) local e=setmetatable({class=class,pos=Vector(),health=100,keys={},relations={}},E)
 entities[#entities+1]=e; return e end
function E:GetClass() return self.class end
function E:GetPos() return self.pos end
function E:SetPos(v) self.pos=v end
function E:SetAngles() end
function E:SetModel(v) self.model=v end
function E:SetKeyValue(k,v) self.keys[k]=v end
function E:SetNWString(k,v) self.keys[k]=v end
function E:Spawn() self.spawned=true; self.alive=true end
function E:Activate() self.activated=true end
function E:Remove() hook.Run('EntityRemoved',self); self.invalid=true end
function E:GetOwner() return self.owner end
function E:Health() return self.health end
function E:SetHealth(v) self.health=v end
function E:SetMaxHealth(v) self.maxHealth=v end
function E:AddEntityRelationship(p,r) self.relations[p]=r end
function E:SetEnemy(p) self.enemy=p end
function E:UpdateEnemyMemory(p,pos) self.memory=p end
function E:Give(class) self.weapon=class end
function NewPlayer(spec,bot) local p=NewEntity('player'); p.team=spec and TEAM_SPECTATOR or 0
 p.bot=bot; p.alive=not spec; p.organism={owner=p}; p.admin=true; return p end
function E:Team() return self.team end
function E:SetTeam(v) self.team=v end
function E:SetupTeam(v) self.team=v; self.alive=true end
function E:IsBot() return self.bot end
function E:IsPlayer() return self.class=='player' end
function E:IsAdmin() return self.admin end
function E:Alive() return self.alive end
function E:Kill() self.alive=false end
E.KillSilent=E.Kill
function E:EyePos() return self.pos+Vector(0,0,64) end
function E:EyeAngles() return Angle() end
function E:GetPlayerName() return 'survivor' end
E.Name=E.GetPlayerName
E.Nick=E.GetPlayerName
function E:GetPData() return 0 end
function E:GetNWInt() return 0 end
function E:FlashlightIsOn() return false end
function E:TakeDamageInfo(d) self.damage=(self.damage or 0)+d.Damage end
for _,k in ipairs({'LocalVelocity','SuppressPickupNotices','Armor','PlayerClass','NetVar','PData','NWInt'}) do E['Set'..k]=function() end end
function E:SetNetVar(k,v) self.keys[k]=v end
function E:GetNetVar(k,default) if self.keys[k]==nil then return default end return self.keys[k] end
function E:SetPlayerClass(v) self.PlayerClassName=v or 'none' end
for _,k in ipairs({'GiveExp','GiveSkill','ChatPrint','Freeze','StripWeapons','RemoveAllAmmo','SyncArmor','GodDisable','SelectWeapon','ScreenFade'}) do E[k]=function() end end
ents={Create=function(c) return not failCreate and NewEntity(c) or nil end}
function ents.FindByClass(class) local t={} for _,e in ipairs(entities) do
 if IsValid(e) and (e.class==class or class=='npc_headcrab*' and e.class:sub(1,12)=='npc_headcrab') then t[#t+1]=e end
 end return t end
game={GetMap=function() return 'fixture_map' end,GetWorld=function() return {} end,CleanUpMap=function() hook.Run('PostCleanupMap') end}
weapons={Get=function() return nil end}
navAreas={} navmesh={GetAllNavAreas=function() return navAreas end}
function NewArea(x,y) return {IsValid=function() return true end,IsUnderwater=function() return false end,GetCenter=function() return Vector(x,y,0) end} end
points={} for i=1,40 do points[i]={pos=Vector((i%8)*180,(i//8)*180,0)} end
function zb.GetMapPoints() return points end
zb.ItemSpawnArea={ID='items',GetPolygon=function() return {} end,IsAllowed=function(pos,polygon) return not polygon.reject end}
function zb:AutoBalance() end
function zb:BalancedChoice() return 1 end
function zb.tdm_checkpoints() end
function zb.CheckRTVVotes() return false end
function zb.RemoveFade() end
function hg.CreateInv() end
function hg.UpdateRoundTime(time,start) zb.ROUND_TIME=time or zb.ROUND_TIME; zb.ROUND_START=start or now end
function hg.GenerateLoot() assert(CurrentRound().LootTable); return 'weapon_akm' end
''')

defense = (BASE / "modes/defense/sv_defense_waves.lua").read_text(encoding="utf-8")
# Execute the real provider helpers, without unrelated NPC-wave scheduling.
defense = defense[:defense.index("function MODE:StartNewWave()")]
for opening, ending in [
    ("    for _, ply in player.Iterator() do", "\n    end\n\n    return false"),
    ("    for i = 1, attempts do", "\n    end\n\n    return nil"),
    ("    for _, area in ipairs(areas) do", "\n    end\n\n    if #candidates"),
]:
    defense = continue_loop(defense, opening, ending)


def files(directory, _):
    if directory == "zcity/gamemode/modes/*":
        return lua.table(), lua.table_from(["battlegrounds", "battlegrounds_ravenholm", "defense"])
    if directory == "zcity/gamemode/modes/defense/*":
        return lua.table_from(["sh_fixture.lua", "sv_defense_waves.lua"]), lua.table()
    path = BASE / directory.removeprefix("zcity/gamemode/").removesuffix("/*")
    if "modes/" in directory:
        return lua.table_from(sorted(p.name for p in path.glob("*.lua"))), lua.table()
    return lua.table(), lua.table()


def include(path):
    if path.endswith("defense/sh_fixture.lua"):
        lua.execute("MODE.name='defense'; MODE.Chance=0; MODE.CanLaunch=function() return true end")
    elif path.endswith("defense/sv_defense_waves.lua"):
        lua.execute(glua(defense))
    else:
        lua.execute(glua((BASE / path.removeprefix("zcity/gamemode/")).read_text(encoding="utf-8")))


lua.globals().file.Find = files
lua.globals().include = include
loader = glua((BASE / "loader.lua").read_text(encoding="utf-8"))
lua.execute(loader)
rounds = (BASE / "libraries/sv_roundsystem.lua").read_text(encoding="utf-8")
start = rounds.index('function zb:KillPlayers()')
end = rounds.index('\nif IsRoundModeDisabled(zb.forcemode)', start)
part = continue_loop(rounds[start:end], '\tfor i, ply in player.Iterator() do', '\n\tend\nend')
lua.execute(glua(rounds[:start] + part + rounds[end:]))
# Exercise the actual attachment -> transformed-class -> organism-reset lifecycle.
lua.execute("function FindMetaTable() return getmetatable(NewPlayer(false,false)) end")
lua.execute(glua((ROOT / "addons/Z-City Korean Localization/lua/homigrad/organism/sv_headcrab.lua").read_text(encoding="utf-8")))
lua.execute(r'''
math.randomseed(124)
r=zb.modes.ravenholm; b=zb.modes.battlegrounds; d=zb.modes.defense
assert(#zb.GetModes()==3 and zb:GetMode('ravenholm')=='ravenholm')
assert(r.name=='ravenholm' and r.base=='battlegrounds' and r.PrintName=='레이븐홈 / 17번 지구')
assert(not zb.modes.city17 and #r.VariantOrder==2 and not r.Types)
assert(r.saved~=b.saved and r.ZonePhases~=b.ZonePhases and r.LootTable~=b.LootTable)
assert(r.LootSpawn and r.randomSpawns and r.ROUND_TIME==b.ROUND_TIME)
assert(not r.EnableAirdrops and not r.EnableRedZones and not r.EnableSafeZone and b.EnableSafeZone and b.EnableAirdrops and b.EnableRedZones)
human=NewPlayer(false,false); spectator=NewPlayer(true,false); bot=NewPlayer(false,true)
players={human,bot,NewPlayer(false,false),spectator}
assert(zb.GetActivePlayerCount()==3 and not r:CanLaunch() and not b:CanLaunch())
players[#players+1]=NewPlayer(false,false)
assert(zb.GetActivePlayerCount()==4 and r:CanLaunch() and b:CanLaunch())
local entries=0
for _,entry in ipairs(zb.GetModesInfo()) do if entry.key=='ravenholm' then
 entries=entries+1; assert(entry.name==r.PrintName and entry.menuVisible and entry.canlaunch==1) end end
assert(entries==1)
-- Direct administrator selection uses the exact new id through the real lifecycle.
net.input={'setmode','ravenholm',false}; net.receivers.AdminSetGameMode(0,human)
assert(CurrentRound()==r and zb.CROUND_MAIN=='ravenholm' and zb.CROUND=='ravenholm')
assert(not r.saved.Zone and not spectator.spawned and r:GetVariant())
assert(globals.ZC_HLS_Variant==r.saved.VariantId and globals.ZC_HLS_IntroStart==now+0.5)
zb.RoundList={'ravenholm'}; zb.RoundListManual=true
zb:RoundStart()
assert(zb.ROUND_STATE==1 and not globals.ZC_BG_Active and #r.saved.FieldLoot==6)
assert(not table.HasValue(messages,'['..r:GetRoundPrintName()..'] '..r:GetStartMessage()),'intro briefing leaked into chat')
while timer.items.ZC_BG_FieldLootSpawn do timer.items.ZC_BG_FieldLootSpawn() end
assert(#r.saved.FieldLoot==32 and not b.saved.FieldLoot)
assert(r.saved.NextAirdrop==nil and r.saved.NextRedZone==nil)
assert(r:ShouldRoundEnd()==nil)
-- Real provider rejects visible, underwater and blocked NPC positions; accepts hidden ones.
for _,p in ipairs(players) do p.pos=Vector() end
occluded=false; water=false; blocked=false
assert(d:IsSpawnVisibleToAnyPlayer(Vector(700,0,0)))
assert(not d:IsSpawnVisibleToAnyPlayer(Vector(-700,0,0)))
assert(d:IsSpawnVisibleToAnyPlayer(Vector(-200,0,0)))
navAreas={NewArea(-900,0),NewArea(900,0),NewArea(-100,0),NewArea(-1600,0)}
local pos=d:FindNavMeshSpawnPoint(Vector(),600,1400)
assert(pos and pos.x==-900)
water=true; assert(not d:FindNavMeshSpawnPoint(Vector(),600,1400)); water=false
blocked=true; assert(not d:FindNavMeshSpawnPoint(Vector(),600,1400)); blocked=false
-- Start delay, nearby spawning, hostility to participants, and neutral spectators.
now=109; r:RoundThink(); assert(#r.saved.Zombies==0)
now=110; r:RoundThink(); assert(#r.saved.Zombies==2)
local first=r.saved.Zombies[1]
assert(first.pos.x==-900 and first.spawned and first.activated and first.maxHealth==first.health)
assert(first.relations[human]==D_HT and first.relations[bot]==D_HT and first.relations[spectator]==D_NU)
assert(first.enemy and first.memory and not first.IsDefenseWaveNPC and not d.DefenseWaveEntities)
for i=1,15 do now=now+4; r:RoundThink() end
assert(#r.saved.Zombies==16,'per-player NPC cap failed')
assert(#r.saved.Airdrops==0 and not r.saved.RedZone and not globals.ZC_BG_RedActive)
assert(not r.saved.Zone and not globals.ZC_BG_Active,'safe zone remained enabled')
local formerPos=human.pos; human.pos=Vector(50000,0,0); human.damage=0
r:RoundThink(); assert(human.damage==0,'safe zone damaged a distant survivor'); human.pos=formerPos
-- Invalid creation and missing navmesh are bounded; the real defense fallback still works.
r:ClearZombies(); navAreas={}; occluded=true; now=now+4; r:RoundThink()
assert(#r.saved.Zombies>0 and #r.saved.Zombies<=2)
for _,npc in ipairs(r.saved.Zombies) do assert(npc.pos:DistToSqr(Vector())>=600^2 and npc.pos:DistToSqr(Vector())<=1400^2) end
r:ClearZombies(); failCreate=true; now=now+4; r:RoundThink(); assert(#r.saved.Zombies==0); failCreate=false
water=true; now=now+4; r:RoundThink(); assert(#r.saved.Zombies==0); water=false
navAreas={NewArea(-900,0)}; now=now+4; r:RoundThink()
local parent=r.saved.Zombies[1]
local crab=NewEntity('npc_headcrab_poison'); crab.owner=parent
parent:Remove(); assert(table.HasValue(r.saved.Zombies,crab),'released child lost on parent removal')
now=now+1; r:RoundThink(); assert(crab.enemy and crab.relations[human]==D_HT)
crab.pos=Vector(5000,0,0); now=now+1; r:RoundThink(); assert(not IsValid(crab))
-- Victory excludes spectators and incapacitated participants. End cleans entities and HUD state.
for _,p in ipairs(players) do if p~=human then p.alive=false end end
spectator.alive=true
assert(r:ShouldRoundEnd()==true and r.saved.Winner==human)
human.organism.incapacitated=true; assert(#r:CheckAlivePlayers()==0); human.organism.incapacitated=false
-- Attached and fully transformed players remain Alive(), but neither is a human survivor.
local previousPlayers=players
local healthy=NewPlayer(false,false); local healthyBot=NewPlayer(false,true)
local attached=NewPlayer(false,false); local transformed=NewPlayer(false,true)
local dead=NewPlayer(false,false); dead.alive=false
local down=NewPlayer(false,false); down.organism.incapacitated=true
players={healthy,healthyBot,attached,transformed,dead,down,spectator}
attached:AddHeadcrab('models/nova/w_headcrab.mdl')
transformed:SetPlayerClass('headcrabzombie'); transformed:SetNetVar('headcrab',false)
assert(attached:Alive() and transformed:Alive())
local survivors=r:CheckAlivePlayers()
assert(#survivors==2 and survivors[1]==healthy and survivors[2]==healthyBot,'zombie counted as a survivor')
assert(globals.ZC_HLS_SurvivorCount==2,'HUD count differs from winner candidates')
assert(#b:CheckAlivePlayers()==4,'original BG survivor rules changed')
assert(not r:IsSurvivor(nil) and not r:IsSurvivor(NewEntity('npc_zombie')))
healthy.alive=false
assert(r:ShouldRoundEnd()==true and r.saved.Winner==healthyBot,'zombie prevented a human victory')
healthyBot:AddHeadcrab('models/nova/w_headcrab.mdl')
assert(r:ShouldRoundEnd()==true and r.saved.Winner==nil and globals.ZC_HLS_SurvivorCount==0,'infected player won the round')
-- Execute the real 60-second transformation; it clears attachment without becoming human again.
local pmeta=getmetatable(attached)
pmeta.EmitSound=function() end
hg.StunPlayer=function() end; hg.FakeUp=function() end
function FrameTime() return 1/60 end
function LerpAngle(_,_,angle) return angle end
function AngleRand() return Angle() end
attached.EyeAngles=function() return setmetatable({}, {__add=function(_,angle) return angle end}) end
attached.SetEyeAngles=function() end
attached.organism.alive=true; attached.organism.brain=1; attached.organism.painadd=0
attached.organism.headcrabon=now-61
hook.items['Org Think'].Headcrab(attached,attached.organism,now)
assert(attached.PlayerClassName=='headcrabzombie' and not attached:GetNetVar('headcrab'))
assert(not r:IsSurvivor(attached),'completed transformation restored survivor status')
-- Existing spawn/organism reset restores normal eligibility without a mode-local infection cache.
hook.Run('Org Clear',healthyBot.organism)
attached:SetPlayerClass(); hook.Run('Org Clear',attached.organism)
assert(r:IsSurvivor(healthyBot) and r:IsSurvivor(attached))
assert(#r:CheckAlivePlayers()==2 and globals.ZC_HLS_SurvivorCount==2)
players=previousPlayers; r.saved.Winner=human
local owned={} for _,e in ipairs(r.saved.Zombies) do owned[#owned+1]=e end
for _,e in ipairs(r.saved.FieldLoot) do owned[#owned+1]=e end
r:EndRound()
for _,e in ipairs(owned) do assert(not IsValid(e)) end
assert(not timer.items.ZC_BG_FieldLootSpawn and #r.saved.Zombies==0 and not r.saved.NextZombieSpawn)
assert(not globals.ZC_BG_Active and not globals.ZC_BG_RedActive)
assert(globals.ZC_HLS_Variant=='' and globals.ZC_HLS_IntroStart==0 and not r.saved.VariantId)
assert(globals.ZC_HLS_SurvivorCount==0,'round end retained survivor count')
-- A second round uses fresh ownership and does not allow an old callback to spawn loot into BG.
for _,p in ipairs(players) do p.alive=true end
r:Intermission(); r:RoundStart(); local oldBatch=timer.items.ZC_BG_FieldLootSpawn
local second=r.saved.Zombies; r:EndRound()
zb.CROUND='battlegrounds'; zb.CROUND_MAIN='battlegrounds'; oldBatch()
assert(#r.saved.FieldLoot==0 and r.saved.Zombies~=second)
b:Intermission(); b:RoundStart(); while timer.items.ZC_BG_FieldLootSpawn do timer.items.ZC_BG_FieldLootSpawn() end
assert(table.HasValue(messages,'['..b:GetRoundPrintName()..'] '..b:GetStartMessage()),'ordinary BG start announcement was removed')
assert(#b.saved.FieldLoot==32 and b.saved.NextAirdrop and b.saved.NextRedZone)
now=now+71; b:RoundThink()
assert(#b.saved.Airdrops==1 and b.saved.RedZone and globals.ZC_BG_RedActive)
now=now+8; b:RoundThink(); assert(explosions>0)
b:EndRound(); assert(#b.saved.Airdrops==0 and not globals.ZC_BG_RedActive)
-- Explicit admin queue preserves the variant id and selects the same table next round.
now=now+1; net.input={{'ravenholm','battlegrounds'}}; net.receivers.AdminSetGameQueue(0,human)
assert(zb.QueuedModes[1]=='ravenholm')
b:Intermission(); zb:RoundStart(); assert(zb.nextround=='ravenholm')
NextRound('ravenholm'); net.receivers.AdminEndRound(0,human)
zb:EndRoundThink(); now=now+8; zb:EndRoundThink()
assert(CurrentRound()==r and zb.CROUND=='ravenholm' and zb.CROUND_MAIN=='ravenholm')
zb:RoundStart(); assert(#r.saved.FieldLoot==6 and not r.saved.NextAirdrop)
-- Map-area updates apply to both family members, not an unrelated mode.
hook.Run('ZB_Area2DSaved',zb.ItemSpawnArea.ID,{reject=true})
assert(r.saved.ItemSpawnPolygon.reject and b.saved.ItemSpawnPolygon.reject and not d.saved.ItemSpawnPolygon)
saved=r.saved; oldMode=r; zb.modes.ghost={saved={}}; zb.modesHooks.ghost={}
''')

lua.execute(loader)
lua.execute(r'''
r=zb.modes.ravenholm; b=zb.modes.battlegrounds
assert(r~=oldMode and r.saved==saved and not zb.modes.ghost and not zb.modesHooks.ghost)
assert(#zb.GetModes()==3 and CurrentRound()==r and zb.modesHooks.ravenholm.RoundThink==r.RoundThink)
assert(not timer.items.ZC_BG_FieldLootSpawn)
r:EndRound(); r:Intermission()
for _,p in ipairs(players) do p.pos=Vector() end
r:RoundStart(); now=now+11; r:RoundThink()
assert(#r.saved.Zombies==2)
local previous=r.saved.Zombies[1]; hook.Run('PostCleanupMap')
assert(not IsValid(previous) and #r.saved.Zombies==0)
r:EndRound()
-- Defense creation retains ordinary NPC equipment and aggressive key values.
local soldier=zb.modes.defense:SpawnHostileNPC({type='npc_combine_s',weapon='weapon_ar2',model='fixture',keyvalues={custom='1'}},Vector())
assert(soldier.weapon=='weapon_ar2' and soldier.model=='fixture' and soldier.keys.custom=='1')
local zombie=zb.modes.defense:SpawnHostileNPC({type='npc_zombie',aggressive=true},Vector())
assert(zombie.keys.aggressivebehavior=='1' and zombie.keys.incominghate=='1' and zombie.keys.spawnflags=='256')
-- Only the randomly selected variant's NPC pool is used, including baton-only CP.
local seen={}
for attempt=1,16 do
 r:Intermission(); local id=r.saved.VariantId; seen[id]=true
 for _,p in ipairs(players) do p.pos=Vector() end
 r:RoundStart(); assert(r.saved.VariantId==id,'variant rerolled after intermission')
 now=now+11; r:RoundThink(); assert(#r.saved.Zombies==2)
 for _,npc in ipairs(r.saved.Zombies) do
  if id=='city17' then assert(npc.class=='npc_metropolice' and npc.weapon=='weapon_stunstick')
  else assert(npc.class=='npc_zombie' or npc.class=='npc_fastzombie' or npc.class=='npc_poisonzombie') end
 end
 r:BoringRoundFunction(); assert(not r.saved.Winner,'timeout arbitrarily awarded the first player')
 r:EndRound()
end
assert(seen.ravenholm and seen.city17)
zb.ROUND_STATE=0; r:Intermission()
hook.Run('ZB_PreRoundStart')
assert(not r.saved.VariantId and globals.ZC_HLS_Variant=='' and globals.ZC_HLS_IntroStart==0)
globals.ZC_HLS_Variant='city17'; assert(not r:GetVariant(),'server took stale replicated client state')
globals.ZC_HLS_Variant=''; zb.ROUND_STATE=1
-- NPC population boundaries: solo forced testing has a floor, large servers have a ceiling.
for _,fixture in ipairs({{1,8},{10,32}}) do
 players={}; for i=1,fixture[1] do players[i]=NewPlayer(false,false) end
 human=players[1]; r:Intermission(); for _,p in ipairs(players) do p.pos=Vector() end
 r:RoundStart(); navAreas={NewArea(-900,0)}
 for i=1,22 do now=now+4; r:RoundThink() end
 assert(#r.saved.Zombies==fixture[2],'population boundary failed')
 r:EndRound()
end
players={spectator}; spectator.alive=true; r:Intermission(); r:RoundStart(); now=now+11; r:RoundThink()
assert(#r.saved.Zombies==0,'spectator triggered NPC spawning'); r:EndRound()
''')

# Fresh client registry: variant intro, audio, and the regular in-round HUD.
lua.execute(r'''
SERVER=false CLIENT=true
hook.items={} -- Server Think hooks do not exist in the client Lua realm.
function Material(x) return x end
function ScreenScale(x) return x end
function ScrW() return screenWidth or 1920 end
function ScrH() return screenHeight or 1080 end
function LocalPlayer() return human end
rects={}; renderCalls={}
surface={CreateFont=function() end,SetDrawColor=function(r,g,b,a) lastColor={r,g,b,a} end,
 DrawRect=function(x,y,w,h)
  rects[#rects+1]={x,y,w,h,lastColor}
  renderCalls[#renderCalls+1]={kind='rect',x=x,y=y,w=w,h=h,color=lastColor}
 end}
drawn={}; draw={}
function draw.SimpleText(text,font,x,y,color)
 drawn[#drawn+1]=text
 renderCalls[#renderCalls+1]={kind='text',text=text,font=font,x=x,y=y,color=color}
end
function draw.DrawText(text,font,x,y,color)
 drawn[#drawn+1]=text
 renderCalls[#renderCalls+1]={kind='multiline',text=text,font=font,x=x,y=y,color=color}
end
render={SetMaterial=function() end,DrawSphere=function() spheres=(spheres or 0)+1 end,DrawBeam=function() beams=(beams or 0)+1 end}
string.FormattedTime=function() return '00:10' end
color_white=Color(255,255,255); TEXT_ALIGN_CENTER=1
zb.modes={}; zb.modesHooks={}
sounds={}
function CreateSound(ply,path)
 if failSound then return nil end
 local s={path=path}; sounds[#sounds+1]=s
 function s:SetSoundLevel(level) self.level=level end
 function s:PlayEx(volume,pitch) self.plays=(self.plays or 0)+1; self.playing=true end
 function s:Stop() self.playing=false end
 return s
end
audioErrors={}
function ErrorNoHalt(message) audioErrors[#audioErrors+1]=message end
function file.Exists(path)
 if path:sub(1,6)=='sound/' then return not missingSound end
 return true
end
''')
lua.execute(loader)
lua.execute(r'''
r=zb.modes.ravenholm; b=zb.modes.battlegrounds
assert(r and r.name=='ravenholm' and r.HUDPaint~=b.HUDPaint)
zb.CROUND='ravenholm'; zb.CROUND_MAIN='ravenholm'; zb.ROUND_STATE=1
globals.ZC_HLS_Variant='city17'; globals.ZC_HLS_IntroStart=now+0.5
globals.ZC_BG_Active=false; globals.ZC_BG_RedActive=false
''')
# Use the real Z-City camera callback. Its custom RenderView explicitly draws HUDPaint;
# the outer RenderScene returns true and skips the default post-HUD render path.
camera = (ROOT / "addons/Z-City Korean Localization/lua/homigrad/cl_camera.lua").read_text(encoding="utf-8")
camera = camera[camera.rindex("local hook_Run = hook.Run"):camera.index("local vector_zero = Vector(0,0,0)")]
lua.execute(r'''
function GetRenderTarget() return {} end
function CreateMaterial() return {} end
CreateClientConVar=CreateConVar
function isangle(v) return type(v)=='table' end
function CalcView(ply,pos,angle,fov) return {origin=pos,angles=angle,fov=fov} end
function FindMetaTable() return {EyePos=function(ply) return ply:GetPos() end,EyeAngles=function() return Angle() end} end
render.RenderView=function(view)
 assert(view.drawhud and view.dopostprocess,'camera skipped the normal HUD')
 hook.Run('HUDPaint')
end
''')
lua.execute(glua(camera))
lua.execute(r'''
-- The camera lazily captures render.RenderView on its first frame.
hook.Run('RenderScene',vector_origin,Angle(),90)
assert(hook.Run('RenderScene',vector_origin,Angle(),90)==true)
assert(#renderCalls==4 and renderCalls[1].kind=='rect' and renderCalls[2].text=='ZBattle | 17번 지구',
 'Z-City camera did not show the title/subtitle/description over a black HUD backdrop')
assert(not r.PostDrawHUD,'intro still relies on the separate post-HUD path')
hook.Run('Think')
assert(#sounds==0 and #rects==1 and rects[1][3]==1920 and rects[1][4]==1080 and rects[1][5][4]==255)
now=now+0.51; hook.Run('Think'); hook.Run('Think')
assert(#sounds==1 and sounds[1].path==r.Variants.city17.IntroSound and sounds[1].plays==1 and sounds[1].level==0)
hook.Run('HUDPaint'); hook.Run('PostDrawTranslucentRenderables',false,false,false)
assert(table.HasValue(drawn,'ZBattle | 17번 지구') and not spheres and not beams)
''')
lua.execute(loader)
lua.execute(r'''
r=zb.modes.ravenholm
hook.Run('Think'); assert(#sounds==1 and sounds[1].playing,'reload restarted or lost sound')
now=now+3.3; hook.Run('Think'); assert(not sounds[1].playing)
now=now+0.3; hook.Run('HUDPaint'); assert(lastColor[4]>0 and lastColor[4]<255)
now=now+0.31; local count=#rects; hook.Run('HUDPaint'); assert(#rects==count)
assert(table.HasValue(drawn,'17번 지구'),'regular round HUD did not return after the intro')
-- Fresh clients may not yet know player classes; display the server's survivor count.
globals.ZC_HLS_SurvivorCount=2; drawn={}; hook.Run('HUDPaint')
assert(drawn[2]:find('생존 2명',1,true),'HUD independently counted zombies after reconnect')
-- Ravenholm starts the full track; switching away still stops it immediately.
globals.ZC_HLS_Variant='ravenholm'; globals.ZC_HLS_IntroStart=now
hook.Run('Think'); assert(#sounds==2 and sounds[2].path==r.Variants.ravenholm.IntroSound)
zb.CROUND='defense'; zb.CROUND_MAIN='defense'; hook.Run('Think'); assert(not sounds[2].playing)
zb.CROUND='ravenholm'; zb.CROUND_MAIN='ravenholm'; now=now+10
hook.Run('Think'); assert(#sounds==2,'reconnect replayed a finished intro')
globals.ZC_HLS_Variant=''; globals.ZC_HLS_IntroStart=0; hook.Run('Think')
count=#rects; hook.Run('HUDPaint'); assert(#rects==count)
zb.ROUND_STATE=3; count=#drawn; hook.Run('HUDPaint'); assert(#drawn==count)
-- An absent client asset must not consume the one-shot trigger. Recheck when it appears.
zb.ROUND_STATE=0; globals.ZC_HLS_Variant='ravenholm'; globals.ZC_HLS_IntroStart=now
missingSound=true; local before=#sounds
hook.Run('Think'); hook.Run('Think')
assert(#sounds==before,'missing asset was marked played instead of retried')
assert(#audioErrors==1 and not zb.RavenholmIntroState.startedAt)
missingSound=false; now=now+0.3; hook.Run('Think')
assert(#sounds==before+1 and sounds[#sounds].playing,'newly available asset did not play')
-- A failed sound-handle creation likewise must be retryable.
now=now+5; globals.ZC_HLS_IntroStart=now; failSound=true
before=#sounds; hook.Run('Think'); assert(#sounds==before and not zb.RavenholmIntroState.startedAt)
failSound=false; now=now+0.3; hook.Run('Think'); assert(#sounds==before+1)
-- Delayed initialization at one second starts the full music under the title card.
now=now+5; local eventStart=now; globals.ZC_HLS_IntroStart=eventStart
human.invalid=true; before=#sounds; hook.Run('Think'); assert(#sounds==before)
now=eventStart+1; human.invalid=false; hook.Run('Think')
assert(#sounds==before+1 and sounds[#sounds].playing,'live intro was skipped after 0.75 seconds')
now=eventStart+2.1; hook.Run('Think'); hook.Run('HUDPaint')
assert(sounds[#sounds].playing and lastColor[4]==255,'late-started clip or blackout was cut short')
local music=sounds[#sounds]
zb.ROUND_STATE=1; now=eventStart+8; hook.Run('Think')
local rectangles=#rects; hook.Run('HUDPaint')
assert(music.playing and #rects==rectangles,'ending the black screen stopped music or left the screen black')
now=eventStart+1+50.755918367347-0.001; hook.Run('Think')
assert(music.playing,'full Ravenholm track was truncated')
now=now+0.002; hook.Run('Think'); assert(not music.playing,'finished track did not release its handle')
zb.ROUND_STATE=0
-- Switching or cleanup cancels the sound and its extended blackout together.
now=now+5; globals.ZC_HLS_IntroStart=now; hook.Run('Think'); assert(sounds[#sounds].playing)
globals.ZC_HLS_IntroStart=0; hook.Run('Think'); assert(not sounds[#sounds].playing and next(zb.RavenholmIntroState)==nil)
count=#rects; hook.Run('HUDPaint'); assert(#rects==count)
-- Both variants use the existing title/subtitle/objective layout ABOVE the black fill.
introFrames={}
for _,resolution in ipairs({{1280,720},{1920,1080},{2560,1080}}) do
 screenWidth=resolution[1]; screenHeight=resolution[2]
 for _,id in ipairs({'ravenholm','city17'}) do
  globals.ZC_HLS_Variant=id; globals.ZC_HLS_IntroStart=now+0.5; zb.fade=7
  renderCalls={}; hook.Run('HUDPaint')
  assert(#renderCalls==4 and renderCalls[1].kind=='rect','intro text is hidden behind the black fill')
  assert(renderCalls[2].text=='ZBattle | '..r.Variants[id].PrintName)
  assert(renderCalls[3].text==r.Variants[id].IntroSubtitle and renderCalls[3].text~='')
  assert(renderCalls[4].text==r.Variants[id].IntroDescription and renderCalls[4].text~='')
  assert(renderCalls[2].y<renderCalls[3].y and renderCalls[3].y<renderCalls[4].y)
  for i=2,4 do assert(renderCalls[i].x==screenWidth/2 and renderCalls[i].color[4]==255) end
  introFrames[#introFrames+1]={width=screenWidth,height=screenHeight,id=id,calls=renderCalls}
 end
end
-- The shared seven-second transition may outlast the clip; text lasts until that fade clears.
globals.ZC_HLS_IntroStart=now-5; zb.fade=2; renderCalls={}; hook.Run('HUDPaint'); assert(#renderCalls==4)
zb.fade=0.4; renderCalls={}; hook.Run('HUDPaint')
for i=1,4 do assert(renderCalls[i].color[4]==102) end
zb.fade=0; renderCalls={}; hook.Run('HUDPaint'); assert(#renderCalls==0)
globals.ZC_HLS_IntroStart=now; globals.ZC_HLS_Variant=''; hook.Run('HUDPaint'); assert(#renderCalls==0)
globals.ZC_HLS_Variant='city17'; zb.ROUND_STATE=3; hook.Run('HUDPaint'); assert(#renderCalls==0)
screenWidth=nil; screenHeight=nil
''')

if os.environ.get("ZCITY_INTRO_QA_DIR"):
    def to_python(value):
        if hasattr(value, "items"):
            entries = list(value.items())
            if entries and all(isinstance(k, int) for k, _ in entries):
                return [to_python(value[k]) for k in sorted(k for k, _ in entries)]
            return {k: to_python(v) for k, v in entries}
        return value
    output = Path(os.environ["ZCITY_INTRO_QA_DIR"])
    output.mkdir(parents=True, exist_ok=True)
    (output / "intro_draw_calls.json").write_text(json.dumps(to_python(lua.globals().introFrames), ensure_ascii=False), "utf-8")

for name, duration in [("ravenholm_intro_full.wav", 50.755918367347), ("city17_welcome_v2.wav", 3.3)]:
    path = ROOT / "addons/Z-City Korean Localization/sound/zcity/hl_survival" / name
    with wave.open(str(path), "rb") as wav:
        assert wav.getframerate() == 44100 and wav.getsampwidth() == 2 and wav.getnchannels() == 2
        assert abs(wav.getnframes() / wav.getframerate() - duration) < 0.001
        samples = array("h", wav.readframes(wav.getnframes()))
        peak = max(abs(x) for x in samples)
        assert peak > 1000, f"silent or inaudible intro: {name}"
        assert sum(abs(x) >= 32767 for x in samples) / len(samples) < 0.001
    assert lua.globals().downloads["sound/zcity/hl_survival/" + name]
sound_dir = ROOT / "addons/Z-City Korean Localization/sound/zcity/hl_survival"
def rms_and_peak(path):
    with wave.open(str(path), "rb") as wav:
        data = array("h", wav.readframes(wav.getnframes()))
        return (sum(x * x for x in data) / len(data)) ** 0.5, max(abs(x) for x in data)
old_rms, _ = rms_and_peak(sound_dir / "city17_welcome.wav")
new_rms, new_peak = rms_and_peak(sound_dir / "city17_welcome_v2.wav")
assert new_rms > old_rms * 2, "City 17 dialogue was not made audibly louder"
assert new_peak / 32768 < 0.9, "boosted dialogue has insufficient peak headroom"
print("PASS: full 50.76-second Ravenholm music continues after the title card; City 17 dialogue gains over 6 dB without clipping")
print("PASS: single registry, random variants, direct/queue, limits, loot without zone damage, zombies/baton CP, cleanup/reload, black-screen audio timing, WAV assets, and unchanged original BG events")
