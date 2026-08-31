local MODE = MODE

MODE.name = "quarantinefailure"
MODE.PrintName = "Containment Failure"
MODE.Description = "One carrier starts an outbreak while a doctor, a soldier and citizens try to contain it."
MODE.Chance = 0.02
MODE.MinPlayers = 4
MODE.ForBigMaps = false
MODE.ROUND_TIME = 300
MODE.start_time = 0
MODE.end_time = 5
MODE.GuiltDisabled = true
MODE.randomSpawns = true
MODE.noBoxes = true
MODE.LootSpawn = false
MODE.AllowSoloActivePlayer = true

MODE.PhoneWeapon = "weapon_ied_arabic"
MODE.BiohazardWeapon = "weapon_biohazardball"
MODE.CureWeapon = "weapon_cure"
MODE.ZombieWeapon = "weapon_zombie"
MODE.SoldierWeapon = "weapon_m4a1"
MODE.SoldierFallbackWeapon = "weapon_glock26"
MODE.InfectionDelay = 6
MODE.AttackGraceTime = 8
MODE.ReportDuration = 20

function MODE:HG_MovementCalc_2(mul, ply, cmd, mv)
	if (zb.ROUND_START or 0) + self.AttackGraceTime <= CurTime() or not cmd then return end

	cmd:RemoveKey(IN_ATTACK)
	cmd:RemoveKey(IN_ATTACK2)
	if mv then
		mv:RemoveKey(IN_ATTACK)
		mv:RemoveKey(IN_ATTACK2)
	end
end

function MODE:PlayerCanLegAttack(ply)
	if (zb.ROUND_START or 0) + self.AttackGraceTime > CurTime() then
		return false
	end
end
