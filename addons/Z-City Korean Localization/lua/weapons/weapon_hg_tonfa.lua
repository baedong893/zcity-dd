if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "경찰용 톤파"
SWEP.Instructions = "폭동 진압 및 자차 방어를 위해 법 집행관들에게 지급되는 측면 손잡이형 진압봉입니다. 긴 사거리와 묵직한 무게 덕분에 용의자를 제압하는 데 효과적입니다. 톤파는 보통 양손에 하나씩 짝을 지어 사용하여 적의 공격을 막고 타격합니다. 경찰 장비의 필수적인 요소이며, 숙련자의 손에 들리면 강력한 무기가 됩니다.\n\n마우스 왼쪽 버튼(LMB): 공격\n마우스 오른쪽 버튼(RMB): 방어"
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/w_jjife_t.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_hatchet.mdl"
SWEP.WorldModelExchange = "models/weapons/tacint_melee/w_tonfa.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "melee"
SWEP.weight = 0.6

SWEP.HoldPos = Vector(-12,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.275
SWEP.AnimTime1 = 1.2
SWEP.WaitTime1 = 0.9
SWEP.ViewPunch1 = Angle(1,1,0)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 0.7
SWEP.WaitTime2 = 0.7
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.AnimAlwaysBack = true

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(-0.3,0.5,-8)
SWEP.weaponAng = Angle(0,-90,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 16
SWEP.DamageSecondary = 13

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 3

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 12
SWEP.StaminaSecondary = 8

SWEP.AttackLen1 = 55
SWEP.AttackLen2 = 30

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}


if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_zac_hmcd_policebaton")
	SWEP.IconOverride = "entities/tacrp_m_tonfa.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "Plastic_Box.ImpactHard"
SWEP.Attack2Hit = "Plastic_Box.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "Plastic_Box.ImpactSoft"

SWEP.AttackPos = Vector(0,0,0)
--[[
function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return true
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"
    return true
end
]]

function SWEP:CanSecondaryAttack()
    return false
end

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 85
SWEP.AttackRads2 = 0

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0