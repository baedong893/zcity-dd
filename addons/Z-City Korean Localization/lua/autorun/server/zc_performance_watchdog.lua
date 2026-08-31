if not SERVER then return end

local enabled = CreateConVar("zc_perf_watchdog", "1", FCVAR_ARCHIVE, "Log long server frame stalls")
local threshold = CreateConVar("zc_perf_watchdog_threshold", "0.10", FCVAR_ARCHIVE, "Seconds before a server frame is considered stalled", 0.05, 30)

-- Migrate the original coarse default so shorter red-count hitches are recorded.
if math.abs(threshold:GetFloat() - 0.75) < 0.001 then
	threshold:SetFloat(0.10)
end

local LOG_PATH = "zc_performance_watchdog.log"
local lastFrame = SysTime()
local lastReport = 0
local cleanupStarted

local function CountEntries(tbl)
	if not istable(tbl) then return 0 end

	local count = 0
	for _ in pairs(tbl) do count = count + 1 end
	return count
end

local function GetModeName()
	if not CurrentRound then return "unknown" end

	local ok, mode = pcall(CurrentRound)
	if not ok or not istable(mode) then return "unknown" end
	return tostring(mode.name or mode.PrintName or "unknown")
end

local function BuildStateText()
	local entityCount = 0
	local ragdollCount = 0
	local weaponCount = 0
	local npcCount = 0

	for _, ent in ipairs(ents.GetAll()) do
		entityCount = entityCount + 1
		if ent:IsWeapon() then
			weaponCount = weaponCount + 1
		elseif ent:IsNPC() or ent:IsNextBot() then
			npcCount = npcCount + 1
		elseif ent:GetClass() == "prop_ragdoll" then
			ragdollCount = ragdollCount + 1
		end
	end

	return string.format(
		"mode=%s round_state=%s players=%d humans=%d entities=%d ragdolls=%d weapons=%d npcs=%d organisms=%d lua_kb=%.0f",
		GetModeName(),
		tostring(zb and zb.ROUND_STATE or "nil"),
		#player.GetAll(),
		#player.GetHumans(),
		entityCount,
		ragdollCount,
		weaponCount,
		npcCount,
		CountEntries(hg and hg.organism and hg.organism.list),
		collectgarbage("count")
	)
end

local function Report(kind, seconds)
	local line = string.format("[%s] %s %.3fs %s", os.date("%Y-%m-%d %H:%M:%S"), kind, seconds, BuildStateText())
	print("[ZCity Perf] " .. line)
	file.Append(LOG_PATH, line .. "\n")
end

hook.Add("Think", "ZCityPerformanceWatchdog", function()
	local now = SysTime()
	local frameGap = now - lastFrame
	lastFrame = now

	if not enabled:GetBool() or #player.GetHumans() <= 0 then return end
	if frameGap < threshold:GetFloat() or now - lastReport < 0.5 then return end

	lastReport = now
	Report("FRAME_STALL", frameGap)
end)

hook.Add("PreCleanupMap", "ZCityPerformanceWatchdog", function()
	cleanupStarted = SysTime()
end)

hook.Add("PostCleanupMap", "ZCityPerformanceWatchdog", function()
	if not cleanupStarted then return end

	local elapsed = SysTime() - cleanupStarted
	cleanupStarted = nil
	if enabled:GetBool() and elapsed >= threshold:GetFloat() then
		Report("MAP_CLEANUP", elapsed)
	end
end)
