local collectionUrl = "https://steamcommunity.com/sharedfiles/filedetails/?id=3737337586"
local timerName = "ZCityWorkshopCollectionAd"
local interval = 300

local messages = {
	"[ZCity] 모음집 구독해주세요: " .. collectionUrl,
	"[ZCity] Please subscribe to the collection: " .. collectionUrl,
}

local function BroadcastCollectionAd()
	if #player.GetHumans() <= 0 then return end

	for _, message in ipairs(messages) do
		PrintMessage(HUD_PRINTTALK, message)
	end
end

timer.Remove(timerName)
timer.Create(timerName, interval, 0, BroadcastCollectionAd)
