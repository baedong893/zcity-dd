if SERVER then AddCSLuaFile() end

-- Compatibility SWEP for Slug Arena's impact-grenade loadout.
-- Its original impact projectile entity remains present in this addon.
SWEP.Base = "weapon_hg_grenade_tpik"
SWEP.PrintName = "Impact Grenade"
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ENT = "ent_hg_grenade_impact"

