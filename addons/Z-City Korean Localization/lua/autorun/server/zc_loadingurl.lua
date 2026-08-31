local loadingUrl = CreateConVar("zc_loadingurl", "", FCVAR_ARCHIVE, "Z-City custom loading screen URL. Must be an http or https URL.")

local function ApplyLoadingUrl()
	local url = string.Trim(loadingUrl:GetString() or "")
	if url == "" then return end
	if not string.StartWith(url, "http://") and not string.StartWith(url, "https://") then
		print("[ZCity] zc_loadingurl ignored: URL must start with http:// or https://")
		return
	end

	RunConsoleCommand("sv_loadingurl", url)
	print("[ZCity] sv_loadingurl set to " .. url)
end

hook.Add("Initialize", "ZCityApplyLoadingUrl", ApplyLoadingUrl)
cvars.AddChangeCallback("zc_loadingurl", function()
	timer.Simple(0, ApplyLoadingUrl)
end, "ZCityApplyLoadingUrl")
