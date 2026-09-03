local MODE = MODE

MODE.base = "tdm"
MODE.name = "vietnam"
MODE.PrintName = "베트남 전쟁"
MODE.Chance = 0.03
MODE.ForBigMaps = false
MODE.ROUND_TIME = 300
MODE.StartMoney = 0
MODE.BuyTime = 0
MODE.start_time = 0
MODE.buymenu = false
MODE.LootSpawn = false
MODE.noBoxes = true

MODE.USModels = {
	"models/US/Army/us_army_1_fritz.mdl",
	"models/US/Army/us_army_2_fritz.mdl",
	"models/US/Army/us_army_3_fritz.mdl",
	"models/US/Army/us_army_4_fritz.mdl",
	"models/US/Army/us_army_5_fritz.mdl"
}

MODE.VietnamModels = {
	"models/player/kerberos_risingstorm2.mdl",
	"models/player/kerberos_risingstorm3.mdl",
	"models/Vietnam/Humans/vc/gmod/VC_1.mdl",
	"models/Vietnam/Humans/vc/gmod/VC_5.mdl"
}

MODE.JungleModels = {
	"models/rising_storm/foliage/bamboo_wall01.mdl",
	"models/rising_storm/foliage/bamboo_wall02.mdl",
	"models/rising_storm/foliage/jungle_bush4.mdl",
	"models/rising_storm/foliage/jungle_tree01.mdl",
	"models/rising_storm/foliage/jungle_tree02.mdl",
	"models/rising_storm/foliage/jungle_tree04.mdl"
}

MODE.USWeapon = "weapon_m16a2"
MODE.USMachineGun = "weapon_m60"
MODE.USMine = "weapon-m2a1-mine"
MODE.USExplosive = "weapon_hg_grenade_tpik"
MODE.VietnamWeapon = "weapon_akm"
MODE.VietnamMachineGun = "weapon_rpk"
MODE.VietnamMine = "weapon-tnt-mine"
MODE.VietnamExplosive = "weapon_hg_pipebomb_tpik"
MODE.JunglePropCount = 220
MODE.RoleNWKey = "ZCityVietnamRole"
MODE.RoleMinimumBasePlayers = 2

-- 병과는 팀 안의 장비 구성만 바꾼다. 능력 권한은 아래 TeamAbilities가 소유하므로
-- 베트콩의 땅굴 능력은 어떤 병과를 배정받아도 동일하게 사용할 수 있다.
MODE.RoleDefinitions = {
	[0] = {
		vc_assault_rifleman = {
			Name = "베트콩 돌격소총병",
			Weapons = {{Class = "weapon_akm", Clips = 5, Select = true}},
			Items = {{Classes = {"weapon_hg_f1_tpik", "weapon_hg_rgd_tpik"}}}
		},
		vc_semi_rifleman = {
			Name = "베트콩 반자동소총병",
			Weapons = {{Class = "weapon_sks", Clips = 5, Select = true}},
			Items = {"weapon_hg_f1_tpik"}
		},
		vc_squad_leader = {
			Name = "베트콩 분대장",
			MinPlayers = 3,
			FixedCount = 1,
			Weapons = {
				{Class = "weapon_akm", Clips = 5, Select = true},
				{Class = "weapon_makarov", Clips = 3}
			},
			Items = {"weapon_hg_rgd_tpik"}
		},
		vc_machine_gunner = {
			Name = "베트콩 기관총 사수",
			MinPlayers = 5,
			PerPlayers = 5,
			Weapons = {
				{Class = "weapon_pkm", Clips = 6, Select = true},
				{Class = "weapon_tokarev", Clips = 2}
			}
		},
		vc_marksman = {
			Name = "베트콩 지정사수",
			MinPlayers = 6,
			PerPlayers = 6,
			Weapons = {
				{Class = "weapon_svd", Clips = 5, Select = true},
				{Class = "weapon_makarov", Clips = 2}
			}
		},
		vc_anti_tank_gunner = {
			Name = "베트콩 대전차 사수",
			MinPlayers = 7,
			PerPlayers = 7,
			Weapons = {
				{Class = "weapon_hg_rpg", Clips = 2},
				{Class = "weapon_sks", Clips = 4, Select = true}
			}
		},
		vc_tunnel_infiltrator = {
			Name = "베트콩 땅굴 침투병",
			MinPlayers = 5,
			PerPlayers = 5,
			Weapons = {{Class = "weapon_skorpion", Clips = 6, Select = true}},
			Items = {"weapon_hg_machete", "weapon_hg_molotov_tpik"}
		},
		vc_captured_rifleman = {
			Name = "베트콩 노획소총 사수",
			MinPlayers = 5,
			PerPlayers = 5,
			Weapons = {
				{Classes = {"weapon_mosin", "weapon_kar98"}, Clips = 5, Select = true},
				{Class = "weapon_tokarev", Clips = 2}
			}
		}
	},
	[1] = {
		us_rifleman = {
			Name = "미군 소총병",
			Weapons = {{Class = "weapon_m16a2", Clips = 5, Select = true}},
			Items = {"weapon_hg_grenade_tpik"}
		},
		us_squad_leader = {
			Name = "미군 분대장",
			MinPlayers = 3,
			FixedCount = 1,
			Weapons = {
				{Class = "weapon_m16a2", Clips = 5, Select = true},
				{Class = "weapon_m1911", Clips = 3}
			},
			Items = {"weapon_hg_grenade_tpik"}
		},
		us_machine_gunner = {
			Name = "미군 기관총 사수",
			MinPlayers = 5,
			PerPlayers = 5,
			Weapons = {
				{Class = "weapon_m60", Clips = 6, Select = true},
				{Class = "weapon_m1911", Clips = 2}
			}
		},
		us_shotgunner = {
			Name = "미군 전투 산탄총병",
			MinPlayers = 5,
			PerPlayers = 5,
			Weapons = {
				{Class = "weapon_remington870", Clips = 5, Select = true},
				{Class = "weapon_m1911", Clips = 2}
			}
		},
		us_medic = {
			Name = "미군 의무병",
			MinPlayers = 6,
			PerPlayers = 6,
			Weapons = {
				{Class = "weapon_m16a2", Clips = 4, Select = true},
				{Class = "weapon_m1911", Clips = 2}
			},
			Items = {"weapon_medkit_sh", "weapon_bigbandage_sh", "weapon_morphine"}
		},
		us_combat_engineer = {
			Name = "미군 전투공병",
			MinPlayers = 6,
			PerPlayers = 6,
			Weapons = {{Class = "weapon_m16a2", Clips = 4, Select = true}},
			Items = {"weapon_claymore", "weapon_hg_grenade_tpik"}
		},
		us_special_forces = {
			Name = "미군 특수작전병",
			MinPlayers = 8,
			PerPlayers = 8,
			Weapons = {
				{Class = "weapon_uzi", Clips = 6, Select = true},
				{Class = "weapon_browninghp", Clips = 3}
			},
			Items = {"weapon_hg_smokenade_tpik"}
		}
	}
}

MODE.RoleSpecialOrder = {
	[0] = {"vc_squad_leader", "vc_machine_gunner", "vc_marksman", "vc_anti_tank_gunner", "vc_tunnel_infiltrator", "vc_captured_rifleman"},
	[1] = {"us_squad_leader", "us_machine_gunner", "us_medic", "us_shotgunner", "us_combat_engineer", "us_special_forces"}
}

MODE.RoleFallbackOrder = {
	[0] = {"vc_assault_rifleman", "vc_assault_rifleman", "vc_semi_rifleman"},
	[1] = {"us_rifleman"}
}

MODE.TunnelDoorModel = "models/props_phx/construct/wood/wood_panel1x1.mdl"
MODE.MaxTunnelNetworks = 8
MODE.TunnelTravelCooldown = 5
MODE.TunnelDoorHealth = 100
MODE.TunnelUSFatalChance = 0.05
MODE.TunnelUSSevereInjuryChance = 0.1
MODE.TunnelUSInjuryChance = 0.35
MODE.TunnelUSInjuryDamage = {8, 16}
MODE.TunnelUSSevereInjuryDamage = {35, 55}

MODE.Abilities = {
	["recon"] = {
		Name = "공중 정찰",
		Description = "2초간 적 위치 표시",
		Cooldown = 30,
		Duration = 2,
		Teams = {[1] = true}
	},
	["tunnel"] = {
		Name = "땅굴",
		Description = "5초 후 설치·최대 8쌍·미군: 즉사 5%·중상 10%·부상 35%·무사 50%",
		Cooldown = 45,
		Duration = 5,
		Teams = {[0] = true}
	},
	["ambush"] = {
		Name = "매복",
		Description = "무음·반투명, 달리면 해제",
		Cooldown = 25,
		Duration = 5,
		Teams = {[0] = true, [1] = true}
	},
	["supply"] = {
		Name = "공중 보급",
		Description = "조준 지점에 탄약·의약품·전술 장비 투하 (미군 공유)",
		Cooldown = 120,
		SharedTeamCooldown = true,
		Teams = {[1] = true}
	}
}

MODE.TeamAbilities = {
	[0] = {"tunnel", "ambush"},
	[1] = {"recon", "ambush", "supply"}
}
