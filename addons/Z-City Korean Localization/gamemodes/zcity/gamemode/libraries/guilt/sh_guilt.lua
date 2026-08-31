zb = zb or {}
zb.MaximumHarm = 10
zb.MaxKarma = 100

function zb.IsKarmaDisabledForCurrentRound()
	local roundKey = zb.CROUND
	local mode = zb.modes and (zb.modes[zb.CROUND_MAIN] or zb.modes[roundKey])
	if not mode and CurrentRound then
		mode, roundKey = CurrentRound()
	end
	if not mode then return false end
	if mode.KarmaDisabled or mode.GuiltDisabled then return true end

	local typeData = mode.Types and (mode.Types[roundKey] or mode.Types[mode.Type])
	return typeData and (typeData.KarmaDisabled or typeData.GuiltDisabled) or false
end
