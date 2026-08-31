if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_grenade_tpik"
SWEP.PrintName = "59식 수류탄"
SWEP.Instructions =
[[구소련의 RGD-5 공격용 수류탄을 저가형으로 복제한 중국제 수류탄입니다. 살상 반경은 3미터, 유효 파편 반경은 9미터입니다. 3.5~4.4초의 지연 신관이 작동합니다.

표면을 바라보며 RELOAD: 인계철선(트랩) 설치

[마우스 왼쪽 버튼(LMB): 상단 투척 준비]
- 준비 중 RMB: 안전 손잡이(Spoon) 제거
- 준비 중 RELOAD: 안전핀 다시 삽입

[마우스 오른쪽 버튼(RMB): 하단 투척 준비]
- 준비 중 LMB: 안전 손잡이(Spoon) 제거
- 준비 중 RELOAD: 안전핀 다시 삽입
]]--"тильда двуеточее три"
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 2
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "camera"
SWEP.ViewModel = ""
SWEP.WorkWithFake = true

SWEP.WorldModel = "models/weapons/w_jj_fraggrenade.mdl"
SWEP.WorldModelReal = "models/weapons/zcity/c_rgd5.mdl"
SWEP.WorldModelExchange = false

SWEP.ENT = "ent_hg_grenade_type59"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_oldgrenade")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_oldgrenade.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.AnimList = {
    -- self:PlayAnim( anim,time,cycling,callback,reverse,sendtoclient )
	["deploy"] = { "base_draw", 1, false },
    ["attack"] = { "throw", 0.8, false, false, function(self)

		if CLIENT then return end
		--local tr = self:GetEyeTrace()
		--self:Tie(tr)
		
		self:Throw(1200, self.SpoonTime or CurTime(),nil,Vector(2,4,0),Angle(-40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6,function()
			if not IsValid(self) then return end
			self.count = self.count - 1
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end
			self:PlayAnim("idle")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.65 },
	["attack2"] = { "lowthrow", 0.8, false, false, function(self)
		--local tr = self:GetEyeTrace()
		--self:Tie(tr)
		if CLIENT then return end
		self:Throw(600, self.SpoonTime or CurTime(),nil,Vector(0,4,-6),Angle(40,0,0))
		self.InThrowing = false
		self.ReadyToThrow = false
		self.IsLowThrow = false
		self.SpoonTime = false
		self.Spoon = true
		timer.Simple(0.6,function()
			if not IsValid(self) then return end
			self.count = self.count - 1
			if self.count < 1 then
				if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
					self:GetOwner():SelectWeapon("weapon_hands_sh")
				end
				self:Remove()
			end

			self:PlayAnim("idle")
			self:SetShowSpoon(true)
			self:SetShowGrenade(true)
			self:SetShowPin(true)
		end)
	end, 0.6 },
	["pullbackhigh"] = {"pullbackhigh", 1.5, false, false, function(self) 
		self:SetShowPin(false)
		--self:PlayAnim("attack")
		self.ReadyToThrow = true
	end,0.8},
	["pullbacklow"] = {"pullbacklow", 1.5, false, false, function(self) 
		--self:PlayAnim("attack2")
		self:SetShowPin(false)
		self.IsLowThrow = true
		self.ReadyToThrow = true
	end,0.8},
	["trapplace"] = {"pullbacklow", 1.8, false, false, function(self)
		self.ReadyToTrap = true
	end},
	["idle"] = {"draw", 1, false,false,function(self)
	end}
}

SWEP.HoldPos = Vector(2,0.2,-1.5)
SWEP.HoldAng = Angle(0,0,0)
SWEP.NoTrap = false

SWEP.ViewBobCamBase = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 50

SWEP.CallbackTimeAdjust = 0.1

SWEP.traceLen = 5

SWEP.ItemsBones = {
	["Grenade"] = {53},
	["Spoon"] = {52},
	["Pin"] = {54,55,56},
}


SWEP.spoon = "models/weapons/arc9/darsu_eft/skobas/rgd5_skoba.mdl"

SWEP.SpoonSounds = {
	[1] = {"snd_jack_spoonfling.ogg", 65},
	[2] = {"m9/m9_fp.wav", 70, 200, true}
}

SWEP.CoolDown = 0

function SWEP:DrawPostPostModel()
	if IsValid(self:GetOwner()) and not self.matcahnged then
		self:GetWM():SetMaterial("models/weapons/nam/type59")
		self.matcahnged = true
	end
end