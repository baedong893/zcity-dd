local MODE = MODE

MODE.base = "tdm"

MODE.PrintName = "CS Zombie"
MODE.name = "cszombie"
MODE.DisableSeparatedTeamSpawns = true

MODE.ZombieModels = {
	"models/player/zombie_classic.mdl",
	"models/player/zombie_fast.mdl",
	"models/player/zombie_soldier.mdl"
}

for _, modelPath in ipairs(MODE.ZombieModels) do
	util.PrecacheModel(modelPath)
end

function MODE:HG_MovementCalc_2()
end
