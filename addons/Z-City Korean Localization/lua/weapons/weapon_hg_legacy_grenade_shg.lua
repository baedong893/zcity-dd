if SERVER then AddCSLuaFile() end

-- Compatibility SWEP for modes that still reference the legacy stick grenade.
-- The projectile entity is still shipped with Z-City; only its weapon wrapper was missing.
SWEP.Base = "weapon_hg_type59_tpik"
SWEP.PrintName = "Stick Grenade"
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ENT = "ent_hg_grenade_shg"

