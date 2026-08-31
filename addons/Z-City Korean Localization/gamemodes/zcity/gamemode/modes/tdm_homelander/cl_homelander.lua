local MODE = MODE
local homelanderWaitingKey = "ZB_HomelanderWaiting"

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

hook.Add("HUDPaint", "HomelanderArrivalTimer", function()
	local round = CurrentRound and CurrentRound()
	if not round or round.name ~= "homelander" then return end

	local buyTime = round.BuyTime or MODE.BuyTime or 40
	local timeLeft = math.max((zb.ROUND_START or CurTime()) + buyTime - CurTime(), 0)
	if timeLeft <= 0 then return end

	local sw, sh = ScrW(), ScrH()
	local font = "ZB_HomicideMedium"
	local lply = LocalPlayer()

	if IsValid(lply) and lply:GetNWBool(homelanderWaitingKey, false) then
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, sw, sh)
        local title = T("mode_homelander_wait_title", "You will spawn when the countdown ends.")
        local subtitle = T("mode_homelander_wait_subtitle", "Rest while waiting.")
		local timerText = string.FormattedTime(timeLeft, "%02i:%02i")

		draw.SimpleText(title, font, sw * 0.5, sh * 0.48, Color(190, 190, 190), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(subtitle, font, sw * 0.5, sh * 0.52, Color(160, 160, 160), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(timerText, font, sw * 0.5, sh * 0.58, Color(255, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return
	end

    local text = T("mode_homelander_timer", "Homelander arrives in: ") .. string.FormattedTime(timeLeft, "%02i:%02i")

	draw.SimpleText(text, font, sw * 0.02 + 2, sh * 0.95 + 2, Color(0, 0, 0, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(text, font, sw * 0.02, sh * 0.95, Color(255, 70, 70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end)
