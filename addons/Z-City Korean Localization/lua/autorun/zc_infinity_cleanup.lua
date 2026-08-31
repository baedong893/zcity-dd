if CLIENT then return end

local infinityRoundName = "infinitystone"

local cleanupEntityClasses = {
	"ig_gem_time",
	"ig_gem_power",
	"ig_gem_mind",
	"ig_gem_reality",
	"ig_gem_soul",
	"ig_gem_space",
	"ig_blackhole",
	"ig_energystorm",
	"ig_infinitybeam",
	"ig_meteorite",
	"ig_mindbarrier",
	"ig_mindbeam",
	"ig_playerillusion",
	"ig_pocketdimension",
	"ig_pocketwall",
	"ig_portal",
	"ig_powerbeam",
	"ig_powerbomb",
	"ig_soulmedic",
	"ig_soulmissile",
	"ig_soulsentry",
	"ig_vampbeam",
	"ig_worldsunder"
}

local cleanupTimerPrefixes = {
	"GiveInfinityStone",
	"IG_ExplodeCombineBall",
	"IG_GravityRevert",
	"IG_Law_MotionEnable",
	"IG_RemoveGlow",
	"IG_RemoveMindStoneGlow",
	"IG_RemoveRealityStoneGlow",
	"IG_RemoveSoulStoneGlow",
	"IG_ZCityTimeStop_"
}

local function IsInfinityRound()
	local round = CurrentRound and CurrentRound()
	return round and round.name == infinityRoundName
end

local function RemoveInfinityTimers()
	if timer.GetTable then
		for name in pairs(timer.GetTable()) do
			for _, prefix in ipairs(cleanupTimerPrefixes) do
				if string.StartWith(name, prefix) then
					timer.Remove(name)
					break
				end
			end
		end

		return
	end

	for _, prefix in ipairs(cleanupTimerPrefixes) do
		timer.Remove(prefix)
	end
end

local function SafeEnableInfinityMotion(ent)
	if not IsValid(ent) or not ent.IG_EnableMotion then return end
	if ent.IG_MotionEnabled and ent:IG_MotionEnabled() then return end

	if (ent:IsPlayer() or ent:IsNPC()) and not ent.IG_motionEnabledData then
		if ent:IsPlayer() then
			ent:Freeze(false)
			ent:SetMoveType(MOVETYPE_WALK)
			if ent.UnLock then ent:UnLock() end
		end

		return
	end

	local ok, err = pcall(function()
		ent:IG_EnableMotion(true)
	end)

	if not ok then
		print("[InfinityCleanup] IG_EnableMotion failed for " .. tostring(ent) .. ": " .. tostring(err))
	end
end

local function ClearInfinityPlayerState(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	ply.wasTimeFrozen = nil
	ply.IG_effects = {}
	ply.timeAnchor = nil
	ply.timeAnchorSave = nil
	ply.timeAnchorDeathloop = nil
	ply.ig_controlTarget = nil
	ply.ig_soulLinked = nil
	ply.ig_pocketRenderingMode = nil
	ply.ig_blewup = nil

	ply:Freeze(false)

	if util.NetworkStringToID and util.NetworkStringToID("IG_ClearEntityEffect") ~= 0 then
		net.Start("IG_ClearEntityEffect")
			net.WriteEntity(ply)
		net.Broadcast()
	end

	SafeEnableInfinityMotion(ply)
end

local function CleanupInfinityResidue()
	if IG_StopTimeRewind then
		IG_StopTimeRewind()
	end

	if IG_SetTimeFlow then
		IG_SetTimeFlow(true)
	end

	RunConsoleCommand("phys_timescale", "1")

	for _, gauntlet in ipairs(ents.FindByClass("infinitygauntlet")) do
		if IsValid(gauntlet) and IG_ZCityAbilityCooldownKey then
			gauntlet:SetNWFloat(IG_ZCityAbilityCooldownKey(IG_STONE_TIME, 1), 0)
		end
	end

	for _, ent in ipairs(ents.GetAll()) do
		if IsValid(ent) then
			ent.wasTimeFrozen = nil
			ent.ig_pocketRenderingMode = nil
			ent.ig_blewup = nil

			SafeEnableInfinityMotion(ent)
		end
	end

	for _, class in ipairs(cleanupEntityClasses) do
		for _, ent in ipairs(ents.FindByClass(class)) do
			if IsValid(ent) then
				ent:Remove()
			end
		end
	end

	for _, ply in player.Iterator() do
		ClearInfinityPlayerState(ply)
	end

	RemoveInfinityTimers()
end

hook.Add("ZB_PreRoundStart", "ZCityInfinityCleanupOnRoundEnd", function()
	if not IsInfinityRound() then return end
	CleanupInfinityResidue()
end)

hook.Add("ZB_EndRound", "ZCityInfinityCleanupImmediatelyOnRoundEnd", function()
	if not IsInfinityRound() then return end
	CleanupInfinityResidue()
end)

hook.Add("PostCleanupMap", "ZCityInfinityCleanupAfterMapCleanup", function()
	if not IsInfinityRound() then return end
	CleanupInfinityResidue()
end)

concommand.Add("zc_infinity_cleanup", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end
	CleanupInfinityResidue()
end)
