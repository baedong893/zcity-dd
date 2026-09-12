"""Run with Python + lupa (Lua 5.4). Engine geometry/prediction still needs GMod QA.

Loads the real SWEPs and raid mode. Raid player loops preserve GLua `continue`
semantics; reaching an untranslated `continue` in an untested SWEP path fails.
"""
from pathlib import Path
import os
import re
from lupa.lua54 import LuaRuntime

ROOT = Path(os.environ.get("ZCITY_TEST_ROOT", Path(__file__).resolve().parents[1]))
SCP = ROOT / "addons/scp106 world/lua/weapons/swep_106_pd.lua"
FLASH = SCP.with_name("weapon_scp106_flash.lua")


def lua_source(path):
    source = path.read_text(encoding="utf-8")
    if path.name == "sv_scp106raid.lua":
        def player_loop(match):
            indent, body = match[1], match[2]
            body = re.sub(r"\bcontinue\b", "goto next_player", body)
            return (indent + "for _, ply in player.Iterator() do\n do\n" + body
                    + " end\n ::next_player::\n" + indent + "end")
        source = re.sub(r"(?m)^([\t ]*)for _, ply in player.Iterator\(\) do\n([\s\S]*?)^\1end", player_loop, source)
    # Preserve quoted strings/comments while translating GLua operators.
    pattern = r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|--[^\n]*|!=|&&|\|\||!|\bcontinue\b'
    replacements = {"!=": "~=", "&&": "and", "||": "or", "!": "not ", "continue": 'error("untranslated continue reached")'}
    return re.sub(pattern, lambda m: replacements.get(m[0], m[0]), source)


BOOT = r'''
SERVER=true CLIENT=false now=100
function CurTime() return now end
firstPrediction=true
function IsFirstTimePredicted() return SERVER or firstPrediction end
function AddCSLuaFile() end
function IsValid(x) return type(x)=="table" and not x.invalid end
NULL={invalid=true}
MOVETYPE_WALK=2 MOVETYPE_NOCLIP=8 MOVETYPE_FLY=4
IN_ATTACK=1 IN_ATTACK2=2 IN_FORWARD=4 IN_BACK=8 IN_MOVERIGHT=16
IN_MOVELEFT=32 IN_DUCK=64 IN_JUMP=128 IN_RELOAD=256
MASK_PLAYERSOLID=1 MASK_SOLID_BRUSHONLY=2 MASK_SHOT=3
TEAM_SPECTATOR=1002 ACT_VM_DRAW=1 ACT_VM_PRIMARYATTACK=2 PLAYER_ATTACK1=1
bit={band=function(a,b) return a & b end,bnot=function(a) return ~a end}
math.Clamp=function(x,a,b) return math.max(a,math.min(b,x)) end
math.Rand=function(a,b) return a end
local V={}; V.__index=V
function Vector(x,y,z) return setmetatable({x=x or 0,y=y or 0,z=z or 0},V) end
function V.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function V.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function V.__mul(a,b) return Vector(a.x*b,a.y*b,a.z*b) end
function V.__div(a,b) return a*(1/b) end
function V:LengthSqr() return self.x*self.x+self.y*self.y+self.z*self.z end
function V:Length() return math.sqrt(self:LengthSqr()) end
function V:Normalize() local n=self:Length(); if n>0 then self.x=self.x/n self.y=self.y/n self.z=self.z/n end end
function V:GetNormalized() local v=Vector(self.x,self.y,self.z); v:Normalize(); return v end
function V:DistToSqr(v) return (self-v):LengthSqr() end
function V:Dot(v) return self.x*v.x+self.y*v.y+self.z*v.z end
vector_origin=Vector()
function Angle(p,y,r)
 return {Forward=function() return Vector(math.cos(math.rad(p)),0,-math.sin(math.rad(p))) end,
 Right=function() return Vector(0,1,0) end}
end
function Color(...) return {...} end
function Material(x) return x end
hook={items={}}
function hook.Add(event,id,fn) hook.items[event]=hook.items[event] or {}; hook.items[event][id]=fn end
function RunHook(event,...) for _,fn in pairs(hook.items[event] or {}) do fn(...) end end
function MovementMultiplier(ply,base)
 local mul={base or 1}; RunHook('HG_MovementCalc_2',mul,ply); return mul[1]
end
net=setmetatable({Receive=function() end},{__index=function() return function() end end})
timer={items={}}
function timer.Create(id,delay,reps,fn) timer.items[id]=fn end
function timer.Remove(id) timer.items[id]=nil end
function timer.Exists(id) return timer.items[id]~=nil end
function timer.Simple() end
players={} entities={}
player={GetAll=function() return players end}
ents={FindByClass=function(class) local result={} for _,w in ipairs(entities) do if w:GetClass()==class then result[#result+1]=w end end return result end}
function EffectData()
 return {SetOrigin=function(self,pos) self.pos=pos end,GetOrigin=function(self) return self.pos end,
  SetRadius=function(self,radius) self.radius=radius end,GetRadius=function(self) return self.radius end,
  SetEntity=function(self,ent) self.entity=ent end,GetEntity=function(self) return self.entity end}
end
effects={}; registeredEffects={}; lights={}
function effects.Register(definition,name) registeredEffects[name]=definition end
function DynamicLight(id) lights[id]={}; return lights[id] end
traceKind='floor'; blocked=false
util={AddNetworkString=function() end,Effect=function(name,data)
 effects[#effects+1]=name; lastEffect=data
 if CLIENT then
  assert(registeredEffects[name], 'received unregistered effect: '..name)
  local instance=setmetatable({EntIndex=function() return 456 end},{__index=registeredEffects[name]})
  instance:Init(data); lastEffectInstance=instance
 end
end}
function util.TraceLine(t)
 if t.mask==MASK_SHOT then return {Hit=blocked,StartSolid=false,Entity=blocked and NULL or nil,HitPos=t.endpos} end
 local hit=false; pos=t.endpos; normal=Vector(0,0,1)
 if traceKind=='floor' and t.start.z>=0 and t.endpos.z<=0 then
  hit=true; local f=t.start.z/(t.start.z-t.endpos.z); pos=t.start+(t.endpos-t.start)*f
 elseif traceKind=='wall' and t.start.x<40 and t.endpos.x>=40 then
  hit=true; pos=Vector(40,0,t.start.z); normal=Vector(-1,0,0)
 end
 return {Hit=hit,HitSky=false,HitPos=pos,HitNormal=normal,StartSolid=false}
end
function util.TraceHull(t)
 local inside=(traceKind=='floor' and t.start.z<0) or (traceKind=='wall' and t.start.x>40)
 return {StartSolid=inside,AllSolid=inside,Hit=inside or (traceKind=='floor' and t.endpos.z<=0),HitSky=false}
end
local P={}; P.__index=P
function NewPlayer()
 return setmetatable({pos=Vector(),pitch=80,height=64,alive=true,weapons={},move=MOVETYPE_WALK},P)
end
function P:IsPlayer() return true end
function P:Alive() return self.alive end
function P:GetWeapon(id) return self.weapons[id] or NULL end
function P:GetActiveWeapon() return self.active or NULL end
function P:GetPos() return self.pos end
function P:SetPos(v) self.pos=v end
function P:EyePos() return self.pos+Vector(0,0,self.height) end
P.GetShootPos=P.EyePos
function P:WorldSpaceCenter() return self.pos+Vector(0,0,36) end
function P:NearestPoint(origin)
 return Vector(math.Clamp(origin.x,self.pos.x-16,self.pos.x+16),
  math.Clamp(origin.y,self.pos.y-16,self.pos.y+16),math.Clamp(origin.z,self.pos.z,self.pos.z+72))
end
function P:EyeAngles() return Angle(self.pitch,0,0) end
function P:GetAimVector() return self:EyeAngles():Forward() end
function P:IsOnGround() return self.pos.z==0 end
function P:SetGroundEntity(e) self.ground=e end
function P:OBBMins() return Vector(-16,-16,0) end
function P:OBBMaxs() return Vector(16,16,72) end
function P:SetMoveType(n) self.move=n end
function P:GetMoveType() return self.move end
function P:SetAbsVelocity(v) self.vel=v end
P.SetVelocity=P.SetAbsVelocity
function P:KeyDown(k) return ((self.buttons or 0)&k)~=0 end
function P:EmitSound(s) self.sound=s end
function P:ChatPrint(s) self.chat=s end
function P:IsDreaming() return self.dream or false end
function P:GetNoDraw() return self.hidden or false end
function P:Freeze(v) self.frozen=v end
function P:IsFrozen() return self.frozen or false end
function P:SteamID() return 'test' end
function P:SetAnimation() end
function P:SelectWeapon(id) self.active=self:GetWeapon(id) end
function P:Team() return self.team or 0 end
local W={}
function W:GetOwner() return self.owner or NULL end
function W:GetClass() return self.class end
function W:EntIndex() return 123 end
function W:GetNWFloat(k,d) return self.nw[k] or d end
W.GetNWString=W.GetNWFloat
function W:SetNWFloat(k,v) self.nw[k]=v end
W.SetNWString=W.SetNWFloat
function W:SetNextPrimaryFire(t) self.nextFire=t end
function W:GetNextPrimaryFire() return self.nextFire or 0 end
function W:SetNextSecondaryFire(t) self.nextSecondary=t end
function W:EmitSound(s) self.sound=s; self.soundCount=(self.soundCount or 0)+1 end
function W:SendWeaponAnim() end
function W:SetHoldType() end
function NewWeapon(base,p,class)
 local w=setmetatable({owner=p,class=class,nw={}},{__index=function(_,k) return base[k] or W[k] end})
 p.weapons[class]=w; p.active=w; entities[#entities+1]=w; return w
end
function NewMove(p,buttons)
 local mv={origin=p.pos,buttons=buttons,vel=Vector()}
 function mv:GetOrigin() return self.origin end
 function mv:SetOrigin(v) self.origin=v end
 function mv:GetAngles() return p:EyeAngles() end
 function mv:KeyDown(k) return (self.buttons&k)~=0 end
 function mv:GetButtons() return self.buttons end
 function mv:SetButtons(b) self.buttons=b end
 function mv:RemoveKey(k) self.buttons=self.buttons&(~k) end
 function mv:SetVelocity(v) self.vel=v end
 function mv:SetMaxClientSpeed() end
 function mv:SetMaxSpeed() end
 return mv
end
surface={GetTextureID=function() return 1 end,SetDrawColor=function() end,DrawRect=function() drawn=(drawn or 0)+1 end}
function ScrW() return 1920 end function ScrH() return 1080 end
function LocalPlayer() return localPlayer end
SWEP={Primary={},Secondary={}}
'''


def run_server():
    lua = LuaRuntime()
    lua.execute(BOOT)
    lua.execute(lua_source(SCP))
    lua.execute('scpBase=SWEP; SWEP={Primary={},Secondary={}}')
    lua.execute(lua_source(FLASH))
    lua.execute(lua_source(ROOT / "addons/scp106 world/lua/includes/dreams/scp106/pd106.lua"))
    lua.execute(r'''
flashBase=SWEP
-- Standing/crouching floor entry: actual movement hook commits a below-floor origin.
for _,height in ipairs({64,36}) do
 p=NewPlayer(); p.height=height; w=NewWeapon(scpBase,p,'swep_106_pd')
 p.buttons=IN_FORWARD|IN_ATTACK
 w:StartPhase(p)
 mv=NewMove(p,p.buttons)
 hook.items.SetupMove.SCP106_Rebuilt_PhaseMove(p,mv,mv)
 assert(p.move==MOVETYPE_NOCLIP and mv.origin.z<0 and mv.vel.z<0,'floor entry failed')
 -- FinishMove uses mv.origin; flash must now safely restore the saved outside position.
 p.pos=mv.origin
 assert(w:ApplyFlashDisable(5))
 assert(p.pos.z==0 and p.move==MOVETYPE_WALK and not p.S106_PhaseActive,'unsafe phase cancellation')
 assert(w:IsFlashDisabled())
 for _,method in ipairs({'UsePocket','UseSelfPD','StartPhase','UseMark','UseTeleport'}) do w[method](w,p) end
 w:PrimaryAttack(); w:SecondaryAttack()
 assert(not p.S106_PhaseActive and not w.NextPocket and not w.NextTeleport,'ability escaped disable')
 cmd=NewMove(p,IN_FORWARD|IN_ATTACK|IN_ATTACK2|IN_RELOAD)
 hook.items.StartCommand.SCP106_FlashBlockWeapons(p,cmd)
 assert(cmd.buttons==IN_FORWARD,'weapons not blocked or movement incorrectly blocked')
 assert(hook.items.EntityFireBullets.SCP106_FlashBlockBullets(p)==false)
 now=now+4.999; assert(w:IsFlashDisabled(),'disable ended early')
 now=now+0.002; assert(not w:IsFlashDisabled(),'disable lasted beyond five seconds')
 assert(hook.items.EntityFireBullets.SCP106_FlashBlockBullets(p)==nil)
 w:Think(); assert(w:GetNWFloat('S106_DisabledUntil',0)==0)
end
-- Looking straight ahead does not enter the floor; airborne use cannot fly.
for _,case in ipairs({{pitch=0,z=0},{pitch=80,z=100}}) do
 p=NewPlayer(); p.pitch=case.pitch; p.pos=Vector(0,0,case.z)
 w=NewWeapon(scpBase,p,'swep_106_pd'); p.buttons=IN_FORWARD|IN_ATTACK; w:StartPhase(p)
 mv=NewMove(p,p.buttons); hook.items.SetupMove.SCP106_Rebuilt_PhaseMove(p,mv,mv)
 assert(p.move==MOVETYPE_WALK and mv.origin.z==case.z,'phase entered without surface/downward aim')
end
traceKind='wall'; p=NewPlayer(); p.pitch=0; w=NewWeapon(scpBase,p,'swep_106_pd')
p.buttons=IN_FORWARD|IN_ATTACK; w:StartPhase(p); mv=NewMove(p,p.buttons)
hook.items.SetupMove.SCP106_Rebuilt_PhaseMove(p,mv,mv)
assert(mv.origin.x>40 and p.move==MOVETYPE_NOCLIP,'wall entry regressed')
traceKind='floor'
-- Teleport interruption before and after changing destination restores a safe WALK position.
for _,elapsed in ipairs({0.2,0.7}) do
 p=NewPlayer(); w=NewWeapon(scpBase,p,'swep_106_pd'); p.S106_GatePos=Vector(500,0,0)
 w:UseTeleport(p); assert(timer.Exists('test_S106Teleport'))
 now=now+elapsed; timer.items.test_S106Teleport()
 w:ApplyFlashDisable(5)
 assert(not timer.Exists('test_S106Teleport') and not p.frozen and p.move==MOVETYPE_WALK)
 assert(p.pos.z>=0 and (elapsed<0.55 and p.pos.x==0 or elapsed>0.55 and p.pos.x==500))
end
-- The lit area includes off-aim targets and body parts reaching its radius boundary.
owner=NewPlayer(); owner.pitch=0; gun=NewWeapon(flashBase,owner,'weapon_scp106_flash')
target=NewPlayer(); target.pos=Vector(300,0,28); targetWeapon=NewWeapon(scpBase,target,'swep_106_pd')
local lightOrigin=gun:GetFlashOrigin(owner)
assert(lightOrigin.x==256 and lightOrigin.z==64)
for _,pos in ipairs({Vector(300,350,28),Vector(220,-400,28),Vector(-200,0,28),Vector(784,0,28)}) do
 target.pos=pos; assert(gun:CanExpose(target,owner,lightOrigin),'illuminated body missed')
end
for _,pos in ipairs({Vector(784.01,0,28),Vector(-300,0,28),Vector(300,550,28)}) do
 target.pos=pos; assert(not gun:CanExpose(target,owner,lightOrigin),'outside radius was exposed')
end
target.pos=Vector(300,350,28)
blocked=true; assert(not gun:CanExpose(target,owner,lightOrigin)); blocked=false
for _,field in ipairs({'hidden','dream'}) do target[field]=true; assert(not gun:CanExpose(target,owner,lightOrigin)); target[field]=false end
target.alive=false; assert(not gun:CanExpose(target,owner,lightOrigin)); target.alive=true
target.team=TEAM_SPECTATOR; assert(not gun:CanExpose(target,owner,lightOrigin)); target.team=0
assert(not gun:CanExpose(owner,owner,lightOrigin))
assert(not gun:CanExpose(NewPlayer(),owner,lightOrigin))
assert(not gun:CanExpose(NULL,owner,lightOrigin))
-- Visibility rays start at the light, and a visible head counts behind partial cover.
local realTrace=util.TraceLine
util.TraceLine=function(t)
 assert(t.start==lightOrigin,'visibility traced from aim instead of light')
 return {StartSolid=false,Hit=t.endpos.z<90,Entity=NULL}
end
assert(gun:CanExpose(target,owner,lightOrigin),'partially illuminated target missed')
util.TraceLine=function() return {StartSolid=false,Hit=true,HitPos=Vector(100,0,64),HitNormal=Vector(-1,0,0)} end
local wallOrigin=gun:GetFlashOrigin(owner)
assert(wallOrigin.x==98,'light was placed inside/on the struck wall')
util.TraceLine=function(t) return {StartSolid=false,Hit=t.start.x<100 and t.endpos.x>=100,Entity=NULL} end
target.pos=Vector(50,200,28); assert(gun:CanExpose(target,owner,wallOrigin))
target.pos=Vector(150,200,28); assert(not gun:CanExpose(target,owner,wallOrigin),'flash passed through wall')
util.TraceLine=function() return {StartSolid=true} end
assert(gun:GetFlashOrigin(owner)==nil,'flash started inside solid geometry')
util.TraceLine=realTrace
-- One area flash affects multiple SCP-106s without directly aiming at either one.
target.pos=Vector(300,350,28)
secondTarget=NewPlayer(); secondTarget.pos=Vector(220,-400,28)
secondWeapon=NewWeapon(scpBase,secondTarget,'swep_106_pd')
players={owner,target,secondTarget,NewPlayer()}
gun:PrimaryAttack()
assert(effects[#effects]=='scp106_flash' and gun.sound=='NPC_CScanner.TakePhoto')
assert(lastEffect.pos:DistToSqr(lightOrigin)==0 and lastEffect.radius==512 and lastEffect.entity==gun,'visual area differed from exposure area')
assert(gun.soundCount==1,'server flash sound missing or duplicated')
assert(targetWeapon:GetNWFloat('S106_DisabledUntil',0)==now+5)
assert(secondWeapon:GetNWFloat('S106_DisabledUntil',0)==now+5,'second illuminated SCP was missed')
assert(targetWeapon:GetNWFloat('S106_BlindUntil',0)==now+2,'irradiator blindness is not two seconds')
assert(secondWeapon:GetNWFloat('S106_BlindUntil',0)==now+2,'second illuminated SCP has wrong blindness duration')
local count=#effects; gun:PrimaryAttack(); assert(#effects==count and gun.soundCount==1,'recharge bypassed')
now=now+8; gun:PrimaryAttack(); assert(#effects==count+1 and gun.soundCount==2)
-- Slowdown composes with walking/running modifiers and shares the five-second expiry.
for _,base in ipairs({0.4,1,1.2}) do
 assert(math.abs(MovementMultiplier(target,base)-base*0.75)<0.00001,'flash did not slow by 25%')
 assert(MovementMultiplier(owner,base)==base,'ordinary player slowed')
end
now=now+2; targetWeapon:Think()
assert(targetWeapon:GetNWFloat('S106_BlindUntil',0)==0,'expired blindness not cleared during ability lock')
assert(targetWeapon:IsFlashDisabled() and MovementMultiplier(target)==0.75,'vision recovery ended other impairments')
targetWeapon:ApplyFlashDisable(5,2)
assert(targetWeapon:GetNWFloat('S106_BlindUntil',0)==now+2,'repeated flash did not refresh blindness')
assert(MovementMultiplier(target)==0.75,'repeated flash stacked slowdown')
now=now+4.999; assert(MovementMultiplier(target)==0.75,'slowdown expired early')
now=now+0.001; assert(MovementMultiplier(target)==1,'slowdown persisted after expiry')
targetWeapon:ApplyFlashDisable(5); target.alive=false
assert(MovementMultiplier(target)==1,'dead player retained slowdown'); target.alive=true
-- Cleanup on death, spawn, drop, map cleanup and Lua auto-refresh.
for _,event in ipairs({'PlayerDeath','PlayerSpawn','PlayerDisconnected','PlayerDroppedWeapon','PreCleanupMap','OnReloaded'}) do
 targetWeapon:ApplyFlashDisable(5,2)
 RunHook(event,target,targetWeapon)
 assert(not targetWeapon:IsFlashDisabled(),event..' left disable state')
 assert(targetWeapon:GetNWFloat('S106_BlindUntil',0)==0,event..' left blindness state')
 assert(MovementMultiplier(target)==1,event..' left movement slowdown')
end
-- A self-PD entry canceled by a flash cannot enter the dream two seconds later.
local P=getmetatable(NewPlayer())
function P:SetNoTarget(v) self.noTarget=v end
function P:SetDream(v) self.dream=v end
delayed={}
function timer.Simple(delay,fn) delayed[#delayed+1]=fn end
function SafeRemoveEntityDelayed() end
pd106.CreatePuddle=function() return {PDCreated=true} end
p=NewPlayer(); w=NewWeapon(scpBase,p,'swep_106_pd')
w:UseSelfPD(p); assert(timer.Exists('test_106PD') and w.S106_CancelPDEntry)
now=now+0.3; timer.items.test_106PD(); assert(p.pos.z<0)
w:ApplyFlashDisable(5)
assert(p.pos.z==0 and not p.frozen and not p.noTarget and not timer.Exists('test_106PD'))
for _,fn in ipairs(delayed) do fn() end
assert(not p:IsDreaming() and not w.S106_CancelPDEntry,'canceled entry ran later')
-- Uncontrolled entries for normal victims retain the original transition.
p=NewPlayer(); delayed={}; pd106.PutInPD(p)
delayed[1](); assert(p:IsDreaming()=='scp106','ordinary PD entry regressed')
''')
    print("PASS: floor/wall entry, air rejection, 5-second input lock, phase/teleport interruption, area flash/radius/cover, multiple targets, recharge and cleanup")
    print("PASS: canceled self-PD entry cannot run later; ordinary victim entry still works")
    lua.execute(r'''
MODE={}; file={Exists=function() return true end}; function ErrorNoHalt() end
''')
    mode_dir = ROOT / "addons/Z-City Korean Localization/gamemodes/zcity/gamemode/modes/tdm_scp106raid"
    lua.execute(lua_source(mode_dir / "sh_scp106raid.lua"))
    lua.execute(lua_source(mode_dir / "sv_scp106raid.lua"))
    lua.execute(r'''
assert(MODE.name=='scp106raid' and MODE.MTFSpecialWeapon=='weapon_scp106_flash')
function istable(x) return type(x)=='table' end
local P=getmetatable(NewPlayer())
function P:SetupTeam(n) self.team=n end
function P:Spawn() self.alive=true; self.spawnCount=(self.spawnCount or 0)+1 end
function P:StripWeapons() self.weapons={}; self.given={} end
function P:Give(id) self.given[id]=(self.given[id] or 0)+1; return NULL end
function P:SetMaxHealth(n) self.maxHP=n end
function P:GetMaxHealth() return self.maxHP end
function P:SetNWString(k,v) self[k]=v end
P.SetNWBool=P.SetNWString
function P:GetNWString(k,d) if self[k]~=nil then return self[k] end return d end
P.GetNWBool=P.GetNWString
for _,name in ipairs({'RemoveAllAmmo','SetNoDraw','SetNotSolid','SetSuppressPickupNotices','SetModel','SetSkin','SetSubMaterial','SetPlayerColor','SetNWVector','SetHealth'}) do P[name]=function() end end
zb={GiveRole=function() end}; hg={}
player.Iterator=function() return ipairs(players) end
function PrintMessage() end
activeMode=MODE
function CurrentRound() return activeMode end
function table.Random(list)
 assert(#list>0,'attempted random selection without eligible players')
 randomCalls=(randomCalls or 0)+1
 return list[randomIndex or 1]
end
local function RaidPlayer(team,bot)
 local p=NewPlayer(); p.team=team or 0; p.bot=bot; p.given={}; return p
end
local function CheckLoadout(mtf,wave,recipient)
 local count=0
 for _,p in ipairs(mtf) do
  local flashes=p.given.weapon_scp106_flash or 0
  count=count+flashes
  assert(flashes==(p==recipient and 1 or 0),'flash issued to wrong MTF or duplicated')
  assert(p.given[wave==2 and MODE.OmegaWeapon or MODE.AlphaWeapon]==1,'primary weapon changed')
  for _,id in ipairs({'weapon_hands_sh','weapon_bandage_sh','weapon_tourniquet','weapon_walkie_talkie'}) do
   assert(p.given[id]==1,'common MTF equipment missing')
  end
 end
 assert(count==(#mtf>0 and 1 or 0),'deployment must issue exactly one irradiator')
end
-- Each initial/alpha/omega deployment: zero/one/many MTF, spectators before
-- and between participants, bots eligible, and every possible random recipient.
for _,wave in ipairs({0,1,2}) do
 for _,size in ipairs({0,1,2,9}) do
  for selected=1,math.max(size,1) do
   local scp=RaidPlayer(1); local spectator=RaidPlayer(TEAM_SPECTATOR)
   players={spectator,scp}; local mtf={}
   for i=1,size do
    local p=RaidPlayer(0,i==size); p.alive=false
    mtf[#mtf+1]=p; players[#players+1]=p
   end
   MODE.saved={SCP106=scp}; randomIndex=selected; randomCalls=0
   assert(MODE:SpawnMTFWave(wave)==size,'wrong deployment size')
   assert(randomCalls==(size>0 and 1 or 0),'recipient selected more than once')
   CheckLoadout(mtf,wave,mtf[selected])
   assert(next(scp.given)==nil and next(spectator.given)==nil,'SCP/spectator received equipment')
  end
 end
end
-- Execute the real initial equipment callback and automatic support lifecycle,
-- then repeat with fresh participants to reject stale recipient state.
for round=1,2 do
 local spectator=RaidPlayer(TEAM_SPECTATOR); local scp=RaidPlayer()
 local mtf={RaidPlayer(),RaidPlayer(),RaidPlayer(0,true)}
 players={spectator,scp,mtf[1],RaidPlayer(TEAM_SPECTATOR),mtf[2],mtf[3]}
 MODE.saved={}; delayed={}; randomIndex=1
 MODE:GiveEquipment(); delayed[1]()
 assert(MODE.saved.SCP106==scp,'spectator filtering or SCP selection regressed')
 CheckLoadout(mtf,0,mtf[1])
 assert(scp.given.weapon_scp106_flash==nil and next(spectator.given)==nil)
 assert(timer.Exists('ZC_SCP106RaidRelease'),'SCP release timer missing')
 timer.items.ZC_SCP106RaidRelease()
 assert(scp.given[MODE.SCPWeapon]==1,'SCP release loadout changed')
 for wave=1,2 do
  for _,p in ipairs(mtf) do p.alive=false end
  assert(MODE:ShouldRoundEnd()==false,'round ended before reinforcement')
  now=MODE.saved.NextSupportTime; MODE.saved.NextPocketDamage=now+100
  randomIndex=wave+1; MODE:RoundThink()
  CheckLoadout(mtf,wave,mtf[wave+1])
  assert(MODE.saved.SupportWave==wave and MODE.saved.NextSupportTime==nil)
 end
 for _,p in ipairs(mtf) do p.alive=false end
 assert(MODE:ShouldRoundEnd()==true and MODE.saved.Winner=='scp')
 MODE:EndRound()
 assert(not timer.Exists('ZC_SCP106RaidRelease'))
end
-- A pending start cannot distribute equipment after switching modes.
delayed={}; MODE:GiveEquipment(); activeMode={name='tdm'}
local spawnCount=players[3].spawnCount; delayed[1]()
assert(players[3].spawnCount==spawnCount,'pending raid equipped players after a mode switch')
activeMode=MODE
-- Execute real EndRound cleanup on a flashed player, including repeat invocation.
targetWeapon:ApplyFlashDisable(5,2); players={target}
MODE.saved={}
MODE:EndRound(); MODE:EndRound()
assert(not targetWeapon:IsFlashDisabled(),'round end left flash active')
assert(targetWeapon:GetNWFloat('S106_BlindUntil',0)==0,'round end left blindness active')
assert(MovementMultiplier(target)==1,'round end left movement slowdown')
''')
    print("PASS: exactly one random MTF per deployment, zero/one/many candidates, bots/spectators, actual start and reinforcement lifecycle, repeated rounds and mode switch")
    print("PASS: repeated round cleanup clears flash impairment")


def run_client():
    lua = LuaRuntime()
    lua.execute(BOOT + "SERVER=false CLIENT=true")
    lua.execute(lua_source(SCP))
    lua.execute(r'''
localPlayer=NewPlayer(); w=NewWeapon(SWEP,localPlayer,'swep_106_pd')
w:SetNWFloat('S106_DisabledUntil',now+5)
w:SetNWFloat('S106_BlindUntil',now+2)
assert(MovementMultiplier(localPlayer)==0.75,'client did not predict slowdown')
assert(hook.items.HG_GetRadialMenuOverride.SCP106_AbilitySelection(localPlayer)==nil,'disabled Q selection allowed')
for _,offset in ipairs({0,1.999}) do
 now=100+offset; drawn=0; RunHook('PostDrawHUD'); assert(drawn==1,'blindness ended early')
end
for _,offset in ipairs({2,4.999}) do
 now=100+offset; drawn=0; RunHook('PostDrawHUD'); assert(drawn==0,'blindness lasted beyond two seconds')
 assert(MovementMultiplier(localPlayer)==0.75,'vision recovery cleared slowdown')
 assert(hook.items.HG_GetRadialMenuOverride.SCP106_AbilitySelection(localPlayer)==nil,'vision recovery unlocked abilities')
end
now=105
assert(MovementMultiplier(localPlayer)==1,'client slowdown persisted after five seconds')
assert(#hook.items.HG_GetRadialMenuOverride.SCP106_AbilitySelection(localPlayer)==5,'Q abilities did not recover')
now=100; localPlayer.alive=false; drawn=0; RunHook('PostDrawHUD'); assert(drawn==0,'dead player still blinded')
assert(MovementMultiplier(localPlayer)==1,'client slowed dead player')
''')
    print("PASS: irradiator blindness lasts exactly 2 seconds; abilities and slowdown last 5 seconds; death clears overlay")
    print("PASS: 25% movement slowdown on server/client, repeated hits do not stack, expiry/death/round cleanup restores speed")
    lua.execute('SWEP={Primary={},Secondary={}}')
    lua.execute(lua_source(FLASH))
    lua.execute("assert(registeredEffects.scp106_flash, 'weapon refresh left the flash effect unregistered')")
    lua.execute(r'''
zb={ROUND_STATE=1}
localPlayer=NewPlayer(); gun=NewWeapon(SWEP,localPlayer,'weapon_scp106_flash')
gun:PrimaryAttack()
assert(gun.sound=='NPC_CScanner.TakePhoto' and gun.soundCount==1,'shooter cannot hear flash')
assert(#effects==0,'client duplicated server flash effect')
gun:PrimaryAttack(); assert(gun.soundCount==1,'cooldown replayed sound')
-- Prediction can replay the same input with a rewound next-fire value.
firstPrediction=false; gun.nextFire=0; gun:PrimaryAttack()
assert(gun.soundCount==1,'prediction replay duplicated shutter')
firstPrediction=true; now=now+8; gun:PrimaryAttack()
assert(gun.soundCount==2,'next valid flash was silent')
''')
    print("PASS: shooter shutter sound, cooldown silence and prediction replay deduplication")
    # Only refresh the already-loaded weapon, as on a client connected before this update.
    lua.execute('oldFlashDefinition=registeredEffects.scp106_flash')
    lua.execute(lua_source(FLASH))
    lua.execute(r'''
assert(registeredEffects.scp106_flash~=oldFlashDefinition,'refresh retained stale effect code')
local registrations=0; for _ in pairs(registeredEffects) do registrations=registrations+1 end
assert(registrations==1,'refresh duplicated effect registration')
local data=EffectData(); data:SetOrigin(Vector(98,20,64)); data:SetRadius(512); data:SetEntity(gun)
util.Effect('scp106_flash',data,true,true)
local light=lights[gun:EntIndex()]
assert(light.Size==512 and light.Pos.x==98 and light.Pos.y==20 and light.Pos.z==64)
assert(light.r==255 and light.g==255 and light.b==255 and light.Brightness==10)
assert(light.DieTime==now+0.02 and lastEffectInstance:Think()==false,'flash light persisted')
data:SetRadius(256); util.Effect('scp106_flash',data,true,true)
assert(lights[gun:EntIndex()].Size==256,'effect ignored supplied radius')
data:SetEntity(NULL); util.Effect('scp106_flash',data,true,true)
assert(lights[456].Size==256,'removed weapon prevented the received flash')
''')
    print("PASS: weapon load/refresh registers one effect; received flashes create light at server origin/radius and expire")


if __name__ == "__main__":
    run_server()
    run_client()
