"""Exercise actual gauntlet ownership/deploy/conversion and appearance functions.

Run with Python + Lupa. Engine networking/rendering is mocked; model bodygroup
IDs are independently checked against the shipped MDL headers.
"""
from pathlib import Path
import os
import re
import struct
from lupa.lua54 import LuaRuntime

ROOT = Path(os.environ.get("ZCITY_TEST_ROOT", Path(__file__).resolve().parents[1]))
ADDON = ROOT / "addons/Thanos's Infinity Gauntlet SWEP and Model"
SHARED = (ADDON / "lua/weapons/infinitygauntlet/shared.lua").read_text(encoding="utf-8")
CLIENT = (ADDON / "lua/weapons/infinitygauntlet/cl_init.lua").read_text(encoding="utf-8")
EMPTY = (ADDON / "lua/weapons/infinitygauntlet_empty/shared.lua").read_text(encoding="utf-8")


def section(source, start, end):
    begin = source.index(start)
    return source[begin:source.index(end, begin)]


def glua(source):
    pattern = r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|--[^\n]*|!=|!'
    return re.sub(pattern, lambda m: {"!=": "~=", "!": "not "}.get(m[0], m[0]), source)


appearance = section(CLIENT, 'function SWEP:UpdateAppearence()', '--SWEP Constructer stuff')
# Equivalent next-iteration jumps for the two GLua glow loops, preserving their bodies.
pattern = r'(?m)^(\t+)for index,element in pairs\([^\n]+\) do$'
for match in reversed(list(re.finditer(pattern, appearance))):
    end = re.search(r'(?m)^' + match[1] + r'end$', appearance[match.end():])
    end_pos = match.end() + end.start()
    body = appearance[match.end():end_pos].replace('continue', 'goto next_element')
    appearance = (appearance[:match.end()] + '\n do' + body
                  + ' end\n ::next_element::\n' + appearance[end_pos:])

lua = LuaRuntime()
lua.execute(r'''
SERVER=true CLIENT=false SWEP={Primary={},Secondary={}} now=100 oldModel=false
function IsValid(x) return type(x)=='table' and not x.invalid end
function istable(x) return type(x)=='table' end
function UsingOldModel() return oldModel end
function FrameTime() return 0.01 end
function CurTime() return now end
timer={pending={}}
function timer.Simple(_,fn) table.insert(timer.pending,fn) end
IG_StoneData={}
for i,name in ipairs({'soul','reality','space','power','time','mind'}) do IG_StoneData[i]={element=name..'_glow'} end
local W={}
function W:IsValid() return not self.invalid end
function W:NetworkVar(_,_,name)
 self['Get'..name]=function(self) return self.state[name] or false end
 self['Set'..name]=function(self,v) self.state[name]=v; self.writes=self.writes+1 end
end
function W:SetHoldType() end
function W:SetDeploySpeed() end
function W:DoAnim() end
function W:SendWeaponAnim() end
function NewWeapon(base,owner)
 local w=setmetatable({Owner=owner,state={},writes=0,channelingStones={},VElements={},WElements={}},
  {__index=function(_,key) return base[key] or W[key] end})
 w:SetupDataTables()
 w.VElements.gauntlet={bodygroup={}}; w.WElements.gauntlet={bodygroup={}}
 for _,stone in pairs(IG_StoneData) do
  w.VElements[stone.element]={color={a=255}}; w.WElements[stone.element]={color={a=255}}
 end
 return w
end
owner={vm={bodygroup={}}}
function owner.vm:IsValid() return not self.invalid end
function owner.vm:SetBodygroup(id,value) self.bodygroup[id]=value end
function owner:IsPlayer() return true end
function owner:GetViewModel() return self.vm end
function owner:ChatPrint() end
function owner:Give(class)
 assert(SERVER,'client attempted to give a weapon')
 assert(class=='infinitygauntlet'); self.weapon=self.weapon or NewWeapon(gauntlet,self)
 self.weapon:Deploy() -- Engine auto-deploy may happen before Give returns.
 return self.weapon
end
function owner:SelectWeapon(class) self.weapon:Deploy() end
function NewEmpty()
 return setmetatable({Owner=owner,Remove=function(self) self.invalid=true end,IsValid=function(self) return not self.invalid end}, {__index=empty})
end
function AssertStones(weapon,only)
 for i=1,6 do assert(weapon:HasStone(i)==(i==only),'unexpected owned stone '..i) end
end
''')
lua.execute('\n'.join(re.findall(r'^IG_STONE_\w+ = \d+', SHARED, re.M)))
lua.execute(glua(section(SHARED, 'function SWEP:HasStone(', 'function SWEP:UpdateNextIdle()')))
lua.execute(glua(section(SHARED, 'function SWEP:SetupDataTables()', 'function SWEP:Think()')))
lua.execute(glua(section(SHARED, 'local seenOptions =', 'function SWEP:CanPrimaryAttack()')))
lua.execute(glua(appearance))
lua.execute('gauntlet=SWEP; SWEP={Primary={},Secondary={}}')
lua.execute(glua(EMPTY))
lua.execute(r'''
empty=SWEP
-- Server defaults: regular version is full; empty wrapper clears it even after auto-deploy.
full=NewWeapon(gauntlet,owner); full:Deploy(); assert(full:HasStone(7))
holder=NewEmpty(); holder:Initialize(); holder:Deploy()
for _,fn in ipairs(timer.pending) do fn() end
assert(holder.invalid); AssertStones(owner.weapon)
owner.weapon:Deploy(); AssertStones(owner.weapon)
owner.weapon:SetHasStone(4,true); owner.weapon:Deploy(); AssertStones(owner.weapon,4)
-- The client's initial state must not be overwritten on first deploy or reconnection.
SERVER=false CLIENT=true
clientWeapon=NewWeapon(gauntlet,owner); clientWeapon:Deploy()
AssertStones(clientWeapon); assert(clientWeapon.writes==0,'client wrote authoritative stone flags')
clientHolder=NewEmpty(); clientHolder:Deploy(); assert(not clientHolder.invalid)
-- Simulated server update/pickup, then holster/redeploy: preserve exactly that one stone.
clientWeapon.state.HasPowerStone=true; clientWeapon:Deploy(); AssertStones(clientWeapon,4)
-- Both shipped model variants and both held-model views track the same ownership flags.
for _,legacy in ipairs({false,true}) do
 oldModel=legacy; owner.vm.invalid=false
 clientWeapon:UpdateAppearence()
 for i=1,6 do
  local expected=i==4 and 0 or 1
  local firstPerson=legacy and clientWeapon.VElements.gauntlet.bodygroup or owner.vm.bodygroup
  assert(firstPerson[i]==expected,'viewmodel stone '..i..' mismatched')
  assert(clientWeapon.WElements.gauntlet.bodygroup[i]==expected,'world model stone '..i..' mismatched')
 end
 -- Remote players may not have a valid viewmodel; their world model must still update.
 owner.vm.invalid=true; clientWeapon.state.HasPowerStone=false
 clientWeapon:UpdateAppearence()
 for i=1,6 do assert(clientWeapon.WElements.gauntlet.bodygroup[i]==1,'remote empty model showed stone') end
 clientWeapon.state.HasPowerStone=true
end
''')

# Validate the bodygroup mapping independently from the Lua's numeric stone loop.
expected = ['Soulgem', 'Realitygem', 'Spacegem', 'Powergem', 'Timegem', 'Mindgem']
for path in ['weapons/v_infinitygauntlet.mdl', 'props/infinity_gauntlet_new.mdl', 'props/infinity_gauntlet.mdl']:
    data = (ADDON / 'models/xyz' / path).read_bytes()
    count, offset = struct.unpack_from('<ii', data, 232)
    assert count >= 7
    for index, name in enumerate(expected, 1):
        pos = offset + index * 16
        name_offset, choices = struct.unpack_from('<ii', data, pos)
        start = pos + name_offset
        assert data[start:data.index(b'\0', start)].decode() == name and choices == 2
print('PASS: regular/full vs empty conversion, authoritative client state, repeated deploy/pickup, old/new view/world models and remote model updates')
