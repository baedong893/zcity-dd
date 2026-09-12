"""Role and mode isolation checks; run with Python + lupa (Lua 5.4)."""
from pathlib import Path
import os
from lupa.lua54 import LuaRuntime

root = Path(os.environ.get("ZCITY_TEST_ROOT", Path(__file__).resolve().parents[1]))
mode_dir = root / "addons/Z-City Korean Localization/gamemodes/zcity/gamemode"
trap = root / "addons/[Z-CITY] Pat's Bear Trap/lua/entities/ent_pat_beartrap/init.lua"
policy = (mode_dir / "modes/homicide/sv_weapon_recovery.lua").read_text(encoding="utf-8")
lua = LuaRuntime()
lua.execute('''
MODE={} ENT={} TEAM_SPECTATOR=1002
function IsValid(x) return type(x)=='table' and not x.invalid end
function AddCSLuaFile() end
function include() end
hook={}
function hook.Call() if veto then return false end end
function hook.Run(name,...) return hook.Call(name,nil,...) end
''')
lua.execute(policy)
# Only the unrelated Think scan uses GLua continue; Use and the policy are unchanged.
lua.execute(trap.read_text(encoding="utf-8").replace("then continue end", "then break end"))
lua.execute('''
zb={ROUND_STATE=1,CROUND_MAIN='hmcd',modes={hmcd=MODE},modesHooks={hmcd=MODE}}
''')
loader = (mode_dir / "loader.lua").read_text(encoding="utf-8")
lua.execute(loader[loader.index("zb.oldHook ="):].replace("!=", "~="))
lua.execute('''
local function attempt(role,traitor,options)
 options=options or {}
 local ply={SubRole=role,isTraitor=traitor,invalid=options.invalid}
 function ply:IsPlayer() return not options.npc end
 function ply:Alive() return not options.dead end
 function ply:Team() return options.spectator and TEAM_SPECTATOR or 0 end
 function ply:HasWeapon() return options.duplicate end
 function ply:Give(class)
  assert(class=='weapon_beartrap_homigrad'); self.gives=(self.gives or 0)+1
  if not options.giveFailed then return {} end
 end
 local ent=setmetatable({},{__index=ENT})
 function ent:Remove() self.removed=true end
 ent:Use(ply)
 return ent.removed==true,ply.gives or 0
end
assert(attempt('traitor_cannibal',true),'cannibal could not recover')
for _,role in ipairs({'traitor_default','traitor_chemist','innocent'}) do
 local removed,given=attempt(role,true)
 assert(not removed and given==0,'another role recovered the trap')
end
assert(not attempt('traitor_cannibal',false),'stale subrole granted access')
for _,flag in ipairs({'dead','spectator','npc','invalid','duplicate'}) do
 local removed,given=attempt('traitor_cannibal',true,{[flag]=true})
 assert(not removed and given==0,flag..' incorrectly recovered trap')
end
local removed,given=attempt('traitor_cannibal',true,{giveFailed=true})
assert(not removed and given==1,'failed Give destroyed the trap')
veto=true; assert(not attempt('traitor_cannibal',true),'bypassed another recovery veto'); veto=false
zb.ROUND_STATE=2; assert(not attempt('traitor_cannibal',true),'round-end state granted recovery')
zb.ROUND_STATE=1
assert(MODE:HG_CanRecoverPlacedWeapon({},'weapon_other')==nil,'restricted unrelated item')
-- Direct and queued submode dispatch both resolve their hmcd parent.
for _,submode in ipairs({'standard','wildwest','gunfreezone','soe'}) do
 zb.CROUND=submode
 assert(not attempt('traitor_default',true))
 assert(attempt('traitor_cannibal',true))
end
zb.CROUND_MAIN='tdm'; assert(attempt('innocent',false),'restricted TDM')
zb.CROUND_MAIN=nil; zb.CROUND='sandbox'; assert(attempt('innocent',false),'restricted sandbox')
zb.CROUND_MAIN='hmcd'; assert(not attempt('traitor_default',true),'mode re-entry lost policy')
''')
# Re-loading replaces the metadata/method without accumulating hooks or player state.
lua.execute(policy)
lua.execute("assert(MODE:HG_CanRecoverPlacedWeapon({invalid=true},'weapon_beartrap_homigrad')==false)")
print("PASS: cannibal-only recovery, denied roles/dead/spectators, failed Give preserves trap, mode transitions and reload")
