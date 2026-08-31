SWEP.Base = "weapon_akm"
SWEP.Primary.Automatic = false

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.PrintName = "Vepr SOK-94-03"
SWEP.Author = "Vyatskiye Polyany Machine-Building Plant"
SWEP.Instructions = "SOK-94 카빈은 칼라시니코프 수동 기관총(RPK)을 기반으로 제작되었으며, 중대형 동물의 상업 및 취미 사냥용으로 설계되었습니다. .366 TKM 탄환을 사용합니다."
SWEP.Category = "Weapons - Carbines"
SWEP.ShockMultiplier = 1.5
SWEP.Ergonomics = 0.85
SWEP.Penetration = 3
SWEP.Primary.Force = 30

SWEP.CustomShell = "366tkm"

SWEP.MagModel = "models/weapons/arc9/darsu_eft/mods/mag_ak_custom_sawed_off_762x39_10.mdl"

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload_308",
	["reload_empty"] = "reload_308_empty",
}

SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.FakeBodyGroups = "09600074240000"
SWEP.Primary.Wait = 0.098

SWEP.ZoomPos = Vector(0, -0.0054, 4.6688)

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload_308",
	["reload_empty"] = "reload_308_empty",
}

SWEP.WepSelectIcon2 = Material("pwb/sprites/akm.png")
SWEP.IconOverride = "entities/rpk.png" --"entities/tfa_ins2_akm_r.png"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Ammo = ".366 TKM"

SWEP.Primary.Sound = {"weapons/ak74/ak74_tp.wav", 85, 90, 100}
SWEP.Primary.SoundFP = {"zcitysnd/sound/weapons/sks/sks_fp.wav", 85, 90, 100}