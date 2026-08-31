if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "납 파이프"
SWEP.Instructions = "납 파이프의 일부입니다. 이걸로 누군가를 두들겨 패기에 좋으며, 폭동 상황에서 아주 유용한 물건입니다.\n\n마우스 왼쪽 버튼(LMB): 공격\n마우스 오른쪽 버튼(RMB): 방어"
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/tfa_nmrih/w_me_pipe_lead.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_pipe_lead.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""

SWEP.bloodID = 3

SWEP.HoldType = "melee"
SWEP.weight = 1.5

SWEP.HoldPos = Vector(-13,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.35
SWEP.AnimTime1 = 1.3
SWEP.WaitTime1 = 0.95
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,0)
SWEP.weaponAng = Angle(0,0,0)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/tfa_nmrih_lpipe")
	SWEP.IconOverride = "vgui/hud/tfa_nmrih_lpipe.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft2.wav"

SWEP.AttackPos = Vector(0,0,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 25
SWEP.DamageSecondary = 9

SWEP.PenetrationPrimary = 3
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 3

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 25
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 55
SWEP.AttackLen2 = 30

SWEP.NoHolster = true

function SWEP:CanSecondaryAttack()
    return false
end

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 85
SWEP.AttackRads2 = 0

SWEP.SwingAng = 180
SWEP.SwingAng2 = 0

SWEP.MinSensivity = 0.5