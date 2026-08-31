include("shared.lua")

SWEP.PrintName = "'벌레미끼' 페로포드"
SWEP.Instructions = 
[[
페로포드는 개미귀신 경비병의 체내에서 발견되며 하급 개미귀신들을 통제하는 역할을 합니다. 이를 추출하면 개미귀신 경비병과 유사한 방식으로 개미귀신 군단을 통제할 수 있습니다.
]]
SWEP.Category = "Weapons - Other"
SWEP.WorldModelReal = "models/mmod/weapons/c_bugbait.mdl"
SWEP.WorldModelExchange = false
SWEP.setlh = false
SWEP.WepSelectIcon = Material("entities/zcity/bugbait.png")
SWEP.IconOverride = "entities/zcity/bugbait.png"
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

function SWEP:Reload()
	local time = CurTime()
	if self.SqueezeCD > time then return end

	self:PlayAnim("special", 0.6)
	self:EmitSound("weapons/mmod/bugbait/bugbait_squeeze1.wav",75)
	self.SqueezeCD = time + 2
end