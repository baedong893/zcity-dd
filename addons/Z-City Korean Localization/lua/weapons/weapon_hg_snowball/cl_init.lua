include("shared.lua")

SWEP.PrintName = "눈덩이"
SWEP.Instructions =
[[
눈덩이는 눈으로 만든 구형의 물체입니다. 보통 손으로 눈을 긁어모아 압착하여 단단하게 뭉쳐서 만듭니다.
]]
SWEP.Category = "Weapons - Other"
SWEP.WorldModelReal = "models/mmod/weapons/c_bugbait.mdl"
SWEP.WorldModelExchange = "models/zerochain/props_christmas/snowballswep/zck_w_snowballswep.mdl"
SWEP.basebone = 39
SWEP.weaponPos = Vector(0,-0.5,0)
SWEP.modelscale = 1.1
SWEP.setlh = false
SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_snowball")
SWEP.IconOverride = "vgui/wep_jack_hmcd_snowball"
SWEP.BounceWeaponIcon = false
SWEP.AnimsEvents = {
	["draw"] = {
		[0.1] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",70)
		end,
	},
	["drawback"] = {
		[0.1] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",65)
		end,
	}
}