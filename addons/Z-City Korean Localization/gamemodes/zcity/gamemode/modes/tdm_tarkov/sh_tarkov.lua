local MODE = MODE

MODE.name = "tarkov"
MODE.PrintName = "Tarkov Raid"

MODE.MinPlayers = 4
MODE.Chance = 0.03
MODE.ForBigMaps = false
MODE.MenuVisible = true
MODE.ROUND_TIME = 360
MODE.ScavArrivalDelay = 180
MODE.ScavMaxCount = 4

MODE.OverideSpawnPos = true
MODE.LootSpawn = false

function MODE:CanLaunch()
	return zb.GetActivePlayerCount() >= self.MinPlayers
end

function MODE.GuiltCheck(attacker, victim, add, harm, amount)
	return 1, true
end
