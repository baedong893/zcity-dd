local MODE = MODE

MODE.name = "battlegrounds"
MODE.PrintName = "배틀그라운드"

MODE.MinPlayers = 4
MODE.Chance = 0.03
MODE.ForBigMaps = false
MODE.MenuVisible = true
MODE.ROUND_TIME = 360
MODE.start_time = 7
MODE.end_time = 7

MODE.randomSpawns = true
MODE.LootSpawn = true
MODE.LootOnTime = false
MODE.AmbientLootSpawn = false
MODE.noBoxes = true
MODE.GuiltDisabled = true
MODE.PoliceAllowed = false

MODE.FirstRedZoneDelay = 60
MODE.RedZoneInterval = 75
MODE.RedZoneWarningDelay = 7
MODE.RedZoneDuration = 25
MODE.FirstAirdropDelay = 70
MODE.AirdropInterval = 100
MODE.InitialFieldLootPerPlayer = 8
MODE.InitialFieldLootMinimum = 32
MODE.InitialFieldLootMaximum = 72

-- Each phase waits, then moves and shrinks the current circle. Damage is per
-- server round tick (roughly once per second).
MODE.ZonePhases = {
	{Wait = 45, Shrink = 45, Scale = 0.72, Damage = 3},
	{Wait = 30, Shrink = 40, Scale = 0.62, Damage = 5},
	{Wait = 25, Shrink = 35, Scale = 0.55, Damage = 8},
	{Wait = 20, Shrink = 30, Scale = 0.50, Damage = 12},
	{Wait = 15, Shrink = 25, Scale = 0.45, Damage = 18},
	{Wait = 10, Shrink = 20, Scale = 0.35, Damage = 25}
}

-- Kept on this mode rather than in the global loot generator. Other modes
-- continue using their own tables unchanged.
MODE.LootTable = {
	{25, {
		{14, "weapon_bandage_sh"},
		{10, "weapon_tourniquet"},
		{8, "weapon_bigbandage_sh"},
		{6, "weapon_painkillers"},
		{5, "weapon_morphine"},
		{12, "*ammo*"},
		{7, "weapon_pocketknife"},
		{5, "hg_flashlight"}
	}},
	{20, {
		{12, "*sight*"},
		{9, "*barrel*"},
		{8, "*attachments*"},
		{8, "ent_armor_vest2"},
		{7, "ent_armor_vest3"},
		{7, "ent_armor_helmet1"},
		{5, "ent_armor_helmet5"}
	}},
	{38, {
		{12, "weapon_glock17"},
		{10, "weapon_px4beretta"},
		{8, "weapon_hk_usp"},
		{8, "weapon_revolver2"},
		{7, "weapon_mp5"},
		{6, "weapon_uzi"},
		{5, "weapon_doublebarrel"},
		{5, "weapon_remington870"},
		{10, "*ammo*"}
	}},
	{14, {
		{10, "weapon_akm"},
		{10, "weapon_ar15"},
		{8, "weapon_ak74"},
		{7, "weapon_sks"},
		{6, "weapon_m4a1"},
		{5, "weapon_sg552"},
		{5, "ent_armor_vest4"},
		{8, "*ammo*"},
		{6, "*sight*"}
	}},
	{3, {
		{6, "weapon_m249"},
		{5, "weapon_sr25"},
		{3, "weapon_pkm"},
		{5, "weapon_medkit_sh"},
		{4, "ent_armor_vest1"},
		{4, "ent_armor_helmet7"},
		{5, "*attachments*"}
	}}
}

function MODE:CanLaunch()
	return zb.GetActivePlayerCount() >= self.MinPlayers
end

function MODE.GuiltCheck(attacker, victim, add, harm, amount)
	return 1, true
end
