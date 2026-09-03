local MODE = MODE

MODE.base = "tdm"
MODE.name = "scp106raid"
MODE.PrintName = "SCP 습격"
MODE.Chance = 0.02
MODE.ForBigMaps = false
MODE.ROUND_TIME = 300
MODE.start_time = 0
MODE.buymenu = false
MODE.LootSpawn = false
MODE.AllowSoloActivePlayer = true

local primarySCPModel = "models/scp_106/scp_106_model.mdl"
local fallbackSCPModel = "models/cpthazama/scp/106_old.mdl"

if file.Exists(primarySCPModel, "GAME") then
	MODE.SCPModel = primarySCPModel
elseif file.Exists(fallbackSCPModel, "GAME") then
	MODE.SCPModel = fallbackSCPModel
else
	MODE.SCPModel = primarySCPModel
	if SERVER then
		ErrorNoHalt("[SCP106Raid] Missing SCP-106 models: " .. primarySCPModel .. " and " .. fallbackSCPModel .. "\n")
	end
end

MODE.SCPWeapon = "swep_106_pd"
MODE.MTFModel = "models/Kuge/Generic/SCP MTF ETA5/mtf-eta5_exp-pm.mdl"
MODE.AlphaModel = MODE.MTFModel
MODE.AlphaWeapon = "weapon_hk416"
MODE.OmegaModel = MODE.MTFModel
MODE.OmegaWeapon = "weapon_m249"
MODE.SupportDelay = 5
MODE.SCPReleaseDelay = 15
