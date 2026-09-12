"""Exercise real gauntlet time/effect code and GMod's Lua net serializer with Lupa.

The bit stream, clock and drawing calls are simulated; this is not in-game QA.
"""
from pathlib import Path
import os
import re
from lupa.lua54 import LuaRuntime

ROOT = Path(os.environ.get('ZCITY_TEST_ROOT', Path(__file__).resolve().parents[1]))
ENGINE = Path(os.environ.get('ZCITY_ENGINE_ROOT', r'D:\server\steamapps\common\GarrysModDS\garrysmod'))
ADDON = ROOT / "addons/Thanos's Infinity Gauntlet SWEP and Model/lua"
SERVER = (ADDON / 'weapons/infinitygauntlet/init.lua').read_text(encoding='utf-8')
CLIENT = (ADDON / 'weapons/infinitygauntlet/cl_init.lua').read_text(encoding='utf-8')
SHARED = (ADDON / 'weapons/infinitygauntlet/shared.lua').read_text(encoding='utf-8')
RECORDER = (ADDON / 'autorun/ig_timerecorder.lua').read_text(encoding='utf-8')
NET = (ENGINE / 'lua/includes/extensions/net.lua').read_text(encoding='utf-8')


def section(source, start, end):
    begin = source.index(start)
    return source[begin:source.index(end, begin)]


def glua(source):
    pattern = r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|--[^\n]*|/\*[\s\S]*?\*/|//[^\n]*|!=|&&|\|\||!|\bcontinue\b'
    substitutions = {'!=': '~=', '&&': 'and', '||': 'or', '!': 'not ',
                     'continue': 'error("unexercised recorder/render loop reached")'}
    return re.sub(pattern, lambda m: '' if m[0].startswith(('/*', '//')) else substitutions.get(m[0], m[0]), source)


BOOT = r'''
SERVER=true CLIENT=false now=100 MAX_EDICT_BITS=13 MAX_PLAYER_BITS=8
TYPE_NIL=0 TYPE_BOOL=1 TYPE_NUMBER=3 TYPE_STRING=4 TYPE_TABLE=5 TYPE_ENTITY=9
TYPE_VECTOR=10 TYPE_ANGLE=11 TYPE_MATRIX=29
function IsValid(x) return type(x)=='table' and not x.invalid end
function istable(x) return type(x)=='table' and not x.entity end
function IsColor(x) return type(x)=='table' and x.color end
function TypeID(x)
 if x==nil then return TYPE_NIL end
 if type(x)=='boolean' then return TYPE_BOOL end
 if type(x)=='number' then return TYPE_NUMBER end
 if type(x)=='string' then return TYPE_STRING end
 return x.entity and TYPE_ENTITY or TYPE_TABLE
end
function Color(r,g,b,a) return {r=r,g=g,b=b,a=a or 255,color=true} end
function Material(x) return x end
function Vector(x,y,z) return {x=x or 0,y=y or 0,z=z or 0} end
function CurTime() return now end
ENT={}; PLY={}; ENT.__index=ENT
function FindMetaTable(name) return name=='Player' and PLY or ENT end
function ENT:IsValid() return not self.invalid end
function ENT:EntIndex() return self.id end
function ENT:IsPlayer() return self.kind=='player' end
function ENT:IsNPC() return self.kind=='npc' end
function ENT:IsRagdoll() return false end
function ENT:GetClass() return self.kind end
function ENT:HasInfinityStone() return self.timeStone or false end
function ENT:GetVelocity() return self.velocity end
function ENT:SetVelocity(v) self.velocity=v end
ENT.SetLocalVelocity=ENT.SetVelocity
function ENT:GetMoveType() return self.move end
function ENT:SetMoveType(v) self.move=v end
function ENT:Lock() self.locked=true end
function ENT:UnLock() self.locked=false end
function ENT:SetSchedule() self.schedules=(self.schedules or 0)+1 end
function ENT:SetCondition() end
function ENT:GetPhysicsObject() return NULL end
function ENT:GetPhysicsObjectCount() return 0 end
function ENT:GetCreationID() return self.id end
NULL=setmetatable({invalid=true,id=0},ENT)
entityByID={}; allEntities={}
function Entity(id) return entityByID[id] or NULL end
function NewEntity(id,kind,registered)
 local e=setmetatable({entity=true,id=id,kind=kind or 'player',move=2,velocity=Vector(1,2,3)},ENT)
 if registered then entityByID[id]=e end
 return e
end
ents={GetAll=function() return allEntities end}
player={GetAll=function() return {} end}
hook={items={}}
function hook.Add(event,id,fn) hook.items[event]=hook.items[event] or {}; hook.items[event][id]=fn end
function RunHook(event,...) for _,fn in pairs(hook.items[event] or {}) do fn(...) end end
table.Empty=function(t) for k in pairs(t) do t[k]=nil end end
net={messages={}}
function net.Start(name) net.name=name; net.bits={}; net.cursor=1 end
function net.WriteUInt(value,count)
 for i=0,count-1 do net.bits[#net.bits+1]=(value >> i) & 1 end
end
function net.ReadUInt(count)
 local value=0
 for i=0,count-1 do
  assert(net.cursor<=#net.bits,'read beyond message')
  value=value | (net.bits[net.cursor] << i); net.cursor=net.cursor+1
 end
 return value
end
function net.WriteBit(value) net.WriteUInt(value and 1 or 0,1) end
function net.ReadBit() return net.ReadUInt(1) end
function net.WriteString(value)
 for i=1,#value do net.WriteUInt(value:byte(i),8) end
 net.WriteUInt(0,8)
end
function net.ReadString()
 local result={}
 while true do local value=net.ReadUInt(8); if value==0 then break end; result[#result+1]=string.char(value) end
 return table.concat(result)
end
function net.WriteDouble(value)
 for c in string.pack('<d',value):gmatch('.') do net.WriteUInt(c:byte(),8) end
end
function net.ReadDouble()
 local bytes={}; for i=1,8 do bytes[i]=string.char(net.ReadUInt(8)) end
 return (string.unpack('<d',table.concat(bytes)))
end
function net.Broadcast() net.messages[#net.messages+1]=net.name end
function Deliver()
 net.cursor=1; net.Receivers[net.name:lower()]()
 assert(net.cursor==#net.bits+1,'receiver did not consume exactly the sent message')
end
globals={}
function SetGlobalBool(key,value) globals[key]=value end
function GetGlobalBool(key,default) if globals[key]==nil then return default end; return globals[key] end
timer={items={}}
function timer.GetTable() return timer.items end
function string.StartWith(value,prefix) return value:sub(1,#prefix)==prefix end
function timer.Remove(id) timer.items[id]=nil end
function timer.Create(id,delay,reps,fn) timer.items[id]={at=now+delay,fn=fn} end
function Advance(seconds)
 now=now+seconds
 for id,t in pairs(timer.items) do if t.at<=now then timer.items[id]=nil; t.fn() end end
end
function CreateConVar(_,default) return {GetInt=function() return tonumber(default) end,GetBool=function() return default~='0' end} end
function RunConsoleCommand(name,value) if name=='phys_timescale' then physicsScale=tonumber(value) end end
MOVETYPE_NONE=0 MOVETYPE_WALK=2 SCHED_NPC_FREEZE=99
surface={}
function surface.SetDrawColor(r,g,b,a) tint={r=r,g=g,b=b,a=a} end
function surface.DrawRect(x,y,w,h) rect={x=x,y=y,w=w,h=h}; drawCount=(drawCount or 0)+1 end
width=1920 height=1080
function ScrW() return width end
function ScrH() return height end
function LocalPlayer() return NULL end
function DrawColorModify() colorModifyCount=(colorModifyCount or 0)+1 end
'''


def runtime():
    lua = LuaRuntime()
    lua.execute(BOOT)
    lua.execute(glua(NET))
    return lua


def network_tests():
    lua = runtime()
    sender = section(SERVER, 'function ENT:IG_EnableEffect(', 'net.Receive("IG_SelectedStone"')
    receiver = section(CLIENT, 'local activeEffects = {}', 'hook.Add("PostDrawTranslucentRenderables"')
    lua.execute(glua(sender))
    lua.execute('SendEffect=ENT.IG_EnableEffect; entityEffects={motion_disabled={Draw=function() end},soulbond={Draw=function() end}}')
    # Export only for inspection; production state and handlers are otherwise unchanged.
    lua.execute(glua(receiver) + '\nTestActive=activeEffects; TestWaiting=entityEffectsWaiting')
    lua.execute(r'''
for _,bits in ipairs({13,16}) do
 MAX_EDICT_BITS=bits
 for _,id in ipairs({1,123,8191}) do
  local server=NewEntity(id); local client=NewEntity(id,'player',true)
  SendEffect(server,'motion_disabled',{label='frozen',pose={left=0.25},active=true}); Deliver()
  local data=TestActive[client].motion_disabled
  assert(data.label=='frozen' and data.pose.left==0.25 and data.active)
  SendEffect(server,'motion_disabled',false); Deliver(); assert(not TestActive[client].motion_disabled)
  SendEffect(server,'motion_disabled',true); Deliver()
  net.Start('IG_ClearEntityEffect'); net.WriteEntity(server); net.Broadcast(); Deliver()
  assert(not TestActive[client])
 end
end
MAX_EDICT_BITS=13
local server=NewEntity(77)
SendEffect(server,'motion_disabled',{label='old'}); Deliver()
SendEffect(server,'motion_disabled',{label='latest'}); Deliver()
SendEffect(server,'soulbond',true); Deliver()
SendEffect(server,'motion_disabled',false); Deliver()
assert(TestWaiting[77].soulbond and not TestWaiting[77].motion_disabled)
local client=NewEntity(77,'player',true); RunHook('OnEntityCreated',client)
assert(TestActive[client].soulbond and not TestActive[client].motion_disabled and not TestWaiting[77])
RunHook('EntityRemoved',client); assert(not TestActive[client])
SendEffect(NewEntity(78),'motion_disabled',true); Deliver()
net.Start('IG_ClearEntityEffect'); net.WriteEntity(NewEntity(78)); net.Broadcast(); Deliver()
assert(not TestWaiting[78])
SendEffect(NewEntity(79),'motion_disabled',true); Deliver(); RunHook('PostCleanupMap')
assert(next(TestActive)==nil and next(TestWaiting)==nil)
''')
    # Deliberately reproduce the old 16-bit read against the actual writer's 13 bits.
    lua.execute(glua(receiver.replace('net.ReadUInt(MAX_EDICT_BITS)', 'net.ReadUInt(16)')))
    lua.execute(r'''
SendEffect(NewEntity(123),'motion_disabled',{label='frozen'})
local ok=pcall(Deliver)
assert(not ok,'negative control failed to catch the old bit-width mismatch')
''')
    print('PASS: real net serializer round trips at 13/16 bits; enable/disable/clear, delayed entities and cleanup; old header fails')


def time_tests():
    lua = runtime()
    lua.execute(glua(section(SERVER, 'function ENT:IG_EnableMotion(', 'net.Receive("IG_SelectedStone"')))
    stone = section(SHARED, '\t[5] = { --Time Stone', '\t[6] = { --Mind Stone')
    lua.execute('IG_STONE_TIME=5; IG_StoneData={' + glua(stone) + '}')
    lua.execute("timer.Create('IG_ZCityTimeStop_12',2,1,function() IG_SetTimeFlow(true) end)")
    lua.execute(glua(RECORDER))
    lua.execute("assert(not timer.items.IG_ZCityTimeStop_12,'legacy timer survived migration')")
    overlay = section(CLIENT, 'hook.Add("PostDrawHUD", "IG_TimeStopOverlay"', 'local soulVisionMod')
    lua.execute(glua(overlay))
    lua.execute(r'''
local ability=IG_StoneData[5].abilities[1]
assert(ability.zcityDuration==5)
victim=NewEntity(1); caster=NewEntity(2); caster.timeStone=true
allEntities={victim,caster}
drawCount=0; RunHook('PostDrawHUD'); assert(drawCount==0)
ability.Use({},nil,ability); RunHook('Think'); RunHook('PostDrawHUD')
assert(GetGlobalBool('IG_TimeStopped') and not IG_IsTimeFlowing() and physicsScale==0)
assert(victim.locked and victim.move==MOVETYPE_NONE and not caster.locked)
assert(rect.x==0 and rect.y==0 and rect.w==1920 and rect.h==1080)
assert(tint.r==60 and tint.g==168 and tint.b==96 and tint.a>0 and tint.a<255)
width=3440; height=1440; RunHook('PostDrawHUD'); assert(rect.w==3440 and rect.h==1440)
Advance(2); ability.Use({},nil,ability) -- Second caster cannot extend the existing stop.
Advance(2.999); assert(GetGlobalBool('IG_TimeStopped'))
Advance(0.001); assert(not GetGlobalBool('IG_TimeStopped') and IG_IsTimeFlowing() and physicsScale==1)
assert(not victim.locked and victim.move==MOVETYPE_WALK and not victim.wasTimeFrozen and not victim.IG_motionEnabledData)
local before=drawCount; RunHook('PostDrawHUD'); assert(drawCount==before,'overlay persisted after five seconds')
for _,event in ipairs({'PreCleanupMap','ZB_EndRound','OnReloaded'}) do
 ability.Use({},nil,ability); RunHook('Think'); RunHook(event)
 assert(not GetGlobalBool('IG_TimeStopped') and next(timer.items)==nil and not victim.locked,event..' left time stopped')
end
-- An actual script reload must release the old recorder before replacing its local state.
ability.Use({},nil,ability); RunHook('Think')
assert(victim.locked)
''')
    lua.execute(glua(RECORDER))
    lua.execute(glua(overlay))
    lua.execute(r'''
assert(not GetGlobalBool('IG_TimeStopped') and next(timer.items)==nil and not victim.locked)
local hooks=0; for _ in pairs(hook.items.PostDrawHUD) do hooks=hooks+1 end; assert(hooks==1)
IG_StoneData[5].abilities[1].Use({},nil,IG_StoneData[5].abilities[1]); RunHook('Think')
drawCount=0; RunHook('PostDrawHUD'); assert(drawCount==1,'reload lost or duplicated overlay')
Advance(5); assert(not victim.locked and not GetGlobalBool('IG_TimeStopped'))
''')
    print('PASS: time-stone color/alpha fills multiple screen sizes; state sync, 5-second resume, recasts, round/map cleanup and reload')


if __name__ == '__main__':
    network_tests()
    time_tests()
