local MODE = MODE

MODE.base = "tdm"

MODE.name = "gravtdm"
MODE.PrintName = "Gravity Gun Team Deathmatch"
MODE.Chance = 0
MODE.BuyTime = 0
MODE.StartMoney = 0
MODE.buymenu = false

function MODE:SetupChances()
	zb.ModesChances[self.name] = 0
end
