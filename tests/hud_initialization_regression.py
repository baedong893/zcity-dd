"""Execute the real HUD callbacks before player initialization and after reconnect.

Run with Python + lupa (Lua 5.4). Engine drawing and VGUI are mocked.
"""
from pathlib import Path
import os
import re
from lupa.lua54 import LuaRuntime

ROOT = Path(os.environ.get("ZCITY_TEST_ROOT", Path(__file__).resolve().parents[1]))
HUD = ROOT / "addons/Z-City Korean Localization/lua/homigrad/cl_hud.lua"
source = HUD.read_text(encoding="utf-8")
tokens = r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|--\[\[[\s\S]*?\]\]|--[^\n]*|//[^\n]*|!=|&&|\|\||!|\bcontinue\b'
operators = {"!=": "~=", "&&": "and", "||": "or", "!": "not ",
             "continue": 'error("untranslated continue reached")'}
source = re.sub(tokens, lambda m: "" if m[0].startswith("//") else operators.get(m[0], m[0]), source)
lua = LuaRuntime()
lua.execute(r'''
function IsValid(x) return type(x)=='table' and not rawget(x,'invalid') end
NULL=setmetatable({invalid=true},{__index=function() error('indexed an invalid entity') end})
function LocalPlayer() return currentPlayer end
function Color(r,g,b,a) return {r=r,g=g,b=b,a=a} end
function Vector(x,y,z) return {x=x,y=y,z=z} end
function Material(x) return x end
function ScreenScale(x) return x end
function ScrW() return 1920 end function ScrH() return 1080 end
function CurTime() return 100 end
function ConVarExists() return false end
function CreateClientConVar(_,value) return {GetString=function() return value end,GetBool=function() return value=='1' end} end
function istable(x) return type(x)=='table' end
function isfunction(x) return type(x)=='function' end
function SortedPairs(t) return pairs(t or {}) end
function RunConsoleCommand() end
table.Empty=function(t) for k in pairs(t) do t[k]=nil end end
engine={ActiveGamemode=function() return 'zcity' end}
game={SinglePlayer=function() return false end}
surface={CreateFont=function() end}; draw={}; render={}
input={IsKeyDown=function() return false end,IsMouseDown=function() return false end,
 SetCursorPos=function() end}
hg={GetCurrentCharacter=function(p) return p end,eyeTrace=function() return nil end}
hook={items={}}
function hook.Add(event,id,fn) hook.items[event]=hook.items[event] or {}; hook.items[event][id]=fn end
function hook.GetTable() return hook.items end
function hook.Call(event,gm,...)
 for _,fn in pairs(hook.items[event] or {}) do local r=fn(...); if r~=nil then return r end end
end
function hook.Run(event,...) return hook.Call(event,nil,...) end
local P={}; P.__index=P
function NewPlayer(class) return setmetatable({PlayerClassName=class},P) end
function P:Alive() return true end
function P:GetNetVar(_,default) return default end
function P:GetActiveWeapon() return NULL end
function P:IsAdmin() return true end
vgui={Create=function()
 local panel={alpha=0}
 for _,name in ipairs({'SetPos','SetSize','MakePopup','SetKeyboardInputEnabled'}) do panel[name]=function() end end
 function panel:SetAlpha(a) self.alpha=a end
 function panel:GetAlpha() return self.alpha end
 function panel:AlphaTo(a,_,_,fn) self.alpha=a; if fn then fn() end end
 function panel:Remove() self.invalid=true end
 return panel
end}
function RunPlayerCallbacks()
 hook.Run('HUDPaint'); hook.Run('Think'); hook.Run('radialOptions')
 hook.Run('HUDWeaponPickedUp',NULL); hook.Run('HUDAmmoPickedUp','SMG1',1)
 hook.Run('HUDItemPickedUp','item_healthkit'); hook.Run('HUDDrawPickupHistory')
end
''')
lua.execute(source)
lua.execute(r'''
local visibility=hook.items.HUDShouldDraw.homigrad
-- The reported path queries an unhidden HUD element before InitPostEntity.
lply=nil; currentPlayer=nil
assert(visibility('CHudAmmo')==nil)
assert(visibility('CHudHealth')==false,'default health HUD became visible during startup')
RunPlayerCallbacks(); hg.CreateRadialMenu()
assert(not IsValid(MENUPANELHUYHUY),'menu opened before a player existed')
assert(hook.Run('PlayerBindPress',nil,'+menu',true)==nil)
-- NULL and a stale global player must never be indexed.
currentPlayer=NULL; lply=NULL
assert(visibility('CHudAmmo')==nil); RunPlayerCallbacks(); hg.CreateRadialMenu()
assert(hook.Run('PlayerBindPress',NULL,'+menu',true)==nil)
-- A valid current player works even when the legacy global was never initialized.
currentPlayer=NewPlayer(); lply=nil
RunPlayerCallbacks()
for _,name in ipairs({'HUDWeaponPickedUp','HUDAmmoPickedUp','HUDItemPickedUp','HUDDrawPickupHistory'}) do
 assert(hook.items[name].HidePickedStuff()==false,'ordinary pickup HUD changed')
end
currentPlayer.PlayerClassName='Gordon'
for _,name in ipairs({'HUDWeaponPickedUp','HUDAmmoPickedUp','HUDItemPickedUp','HUDDrawPickupHistory'}) do
 assert(hook.items[name].HidePickedStuff()==nil,'Gordon pickup HUD lost its exception')
end
assert(visibility('CHudAmmo')==nil and visibility('CHudHealth')==false)
-- The Q override still reaches the real menu builder without a global lply.
local options={{function() end,'SCP ability'}}
hook.Add('HG_GetRadialMenuOverride','fixture',function(p) assert(p==currentPlayer); return options end)
assert(hook.Run('PlayerBindPress',currentPlayer,'+menu',true)==true)
assert(IsValid(MENUPANELHUYHUY) and hg.radialOptions==options)
local oldPlayer=currentPlayer; oldPlayer.invalid=true; currentPlayer=NULL
MENUPANELHUYHUY:Paint(1920,1080)
assert(not IsValid(MENUPANELHUYHUY),'menu retained an invalid player after reconnect')
currentPlayer=NewPlayer(); hg.CreateRadialMenu()
assert(IsValid(MENUPANELHUYHUY),'normal Q menu did not recover after reconnect')
local normalPanel=MENUPANELHUYHUY
currentPlayer.invalid=true; normalPanel:Think()
assert(not IsValid(normalPanel),'normal menu retained an invalid player')
currentPlayer=NewPlayer(); hg.CreateRadialMenu(options)
oldPanel=MENUPANELHUYHUY
oldVisibility=visibility
hook.Add('HUDShouldDraw','other_addon',function() return nil end)
''')
lua.execute(source)
lua.execute(r'''
assert(not IsValid(oldPanel),'Lua refresh left the old panel open')
assert(hook.items.HUDShouldDraw.homigrad~=oldVisibility,'refresh retained the previous callback')
assert(hook.items.HUDShouldDraw.other_addon,'refresh removed another addon hook')
local count=0; for _ in pairs(hook.items.HUDShouldDraw) do count=count+1 end
assert(count==2,'refresh registered duplicate HUD hooks')
lply=nil; currentPlayer=NULL
assert(hook.items.HUDShouldDraw.homigrad('CHudAmmo')==nil)
RunPlayerCallbacks()
''')
print("PASS: HUD startup with nil/NULL players, normal/Gordon visibility, Q override, reconnect cleanup and Lua refresh")
