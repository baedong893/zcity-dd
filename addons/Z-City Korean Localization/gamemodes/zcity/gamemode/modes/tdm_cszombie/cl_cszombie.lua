local MODE = MODE

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

local teams = {
	human = {
		name = "Human",
		nameKey = "role_human",
		color = Color(0, 120, 190),
		objective = "Buy weapons and survive the infection.",
		objectiveKey = "objective_cszombie_human"
	},
	zombie = {
		name = "Zombie",
		nameKey = "role_zombie",
		color = Color(60, 180, 60),
		objective = "Infect every human.",
		objectiveKey = "objective_cszombie_zombie"
	}
}

local function FormatClock(seconds)
	seconds = math.max(math.ceil(seconds), 0)
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

surface.CreateFont("ZB_CSZombieStatsTitle", {
	font = "Bahnschrift",
	size = ScreenScale(13),
	extended = true,
	weight = 700,
	antialias = true
})

surface.CreateFont("ZB_CSZombieStatsHeader", {
	font = "Bahnschrift",
	size = ScreenScale(8),
	extended = true,
	weight = 700,
	antialias = true
})

surface.CreateFont("ZB_CSZombieStatsText", {
	font = "Bahnschrift",
	size = ScreenScale(6),
	extended = true,
	weight = 500,
	antialias = true
})

surface.CreateFont("ZB_CSZombieHealthIcon", {
	font = "Arial",
	size = ScreenScale(14),
	extended = true,
	weight = 900,
	antialias = true
})

surface.CreateFont("ZB_CSZombieHealthText", {
	font = "Bahnschrift",
	size = ScreenScale(8),
	extended = true,
	weight = 700,
	antialias = true
})

local zombieStatsPanel

local function CloseZombieStats()
	if IsValid(zombieStatsPanel) then
		zombieStatsPanel:Remove()
	end

	zombieStatsPanel = nil
end

local function SortStats(stats, key)
	local sorted = table.Copy(stats or {})

	table.sort(sorted, function(a, b)
		return (a[key] or 0) > (b[key] or 0)
	end)

	return sorted
end

local function FormatStatTime(seconds)
	seconds = math.max(math.floor(seconds or 0), 0)
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function AddRankColumn(parent, title, stats, key, suffix, formatter, width)
	local column = vgui.Create("DPanel", parent)
	column:Dock(LEFT)
	column:SetWide(width)
	column:DockMargin(6, 0, 6, 0)
	column.Paint = function(_, w, h)
		surface.SetDrawColor(8, 12, 14, 230)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(70, 170, 105, 180)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end

	local header = vgui.Create("DLabel", column)
	header:Dock(TOP)
	header:SetTall(38)
	header:SetFont("ZB_CSZombieStatsHeader")
	header:SetText(title)
	header:SetTextColor(Color(120, 235, 150))
	header:SetContentAlignment(5)

	local sorted = SortStats(stats, key)
	for i = 1, math.min(#sorted, 8) do
		local data = sorted[i]
		local value = formatter and formatter(data[key]) or tostring(data[key] or 0) .. (suffix or "")

		local row = vgui.Create("DLabel", column)
		row:Dock(TOP)
		row:SetTall(30)
		row:DockMargin(10, 0, 10, 0)
		row:SetFont("ZB_CSZombieStatsText")
		row:SetText(i .. ". " .. data.name .. "  -  " .. value)
		row:SetTextColor(i == 1 and Color(255, 225, 120) or Color(235, 240, 235))
		row:SetContentAlignment(4)
	end
end

local function OpenZombieStats(stats)
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end

	CloseZombieStats()
	timer.Remove("CSZombieCloseStats")

	zombieStatsPanel = vgui.Create("DFrame")
	zombieStatsPanel:SetSize(math.min(ScrW() * 0.82, 980), math.min(ScrH() * 0.62, 520))
	zombieStatsPanel:Center()
	zombieStatsPanel:SetTitle("")
	zombieStatsPanel:SetDraggable(false)
	zombieStatsPanel:ShowCloseButton(false)
	zombieStatsPanel:SetMouseInputEnabled(false)
	zombieStatsPanel:SetKeyboardInputEnabled(false)
	zombieStatsPanel.Paint = function(_, w, h)
		Derma_DrawBackgroundBlur(zombieStatsPanel, zombieStatsPanel.m_fCreateTime or SysTime())
		surface.SetDrawColor(5, 7, 8, 245)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(40, 190, 85, 220)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		draw.SimpleText(T("mode_cszombie_results", "Zombie Results"), "ZB_CSZombieStatsTitle", w * 0.5, 34, Color(235, 255, 240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local body = vgui.Create("DPanel", zombieStatsPanel)
	body:Dock(FILL)
	body:DockMargin(22, 70, 22, 22)
	body:SetMouseInputEnabled(false)
	body:SetKeyboardInputEnabled(false)
	body.Paint = nil

	local columnWidth = (zombieStatsPanel:GetWide() - 44) / 3 - 12
	AddRankColumn(body, "Damage", stats, "damage", "", nil, columnWidth)
	AddRankColumn(body, "Infections", stats, "infections", "x", nil, columnWidth)
	AddRankColumn(body, "Survival Time", stats, "survival", nil, FormatStatTime, columnWidth)

	timer.Create("CSZombieCloseStats", 12, 1, CloseZombieStats)
end

hook.Add("RoundInfoCalled", "CSZombieCloseStatsOnRoundInfo", function()
	CloseZombieStats()
	timer.Remove("CSZombieCloseStats")
end)

function MODE:RoundStart()
	CloseZombieStats()
	timer.Remove("CSZombieCloseStats")
end

net.Receive("zb_cszombie_round_stats", function()
	local stats = {}
	local count = net.ReadUInt(7)

	for i = 1, count do
		stats[#stats + 1] = {
			name = net.ReadString(),
			damage = net.ReadUInt(20),
			infections = net.ReadUInt(10),
			survival = net.ReadUInt(16)
		}
	end

	OpenZombieStats(stats)
end)

function MODE:AddHudPaint()
end

function MODE:HUDPaint()
	local sw, sh = ScrW(), ScrH()
	local startTime = zb.ROUND_START or CurTime()
	local buyEnd = zb.ROUND_BEGIN or (startTime + (self.BuyTime or 20))
	local lply = LocalPlayer()

	if IsValid(lply) and lply:Alive() and lply:GetNWBool("CSZombie_IsZombie", false) then
		local hp = math.max(math.ceil(lply:Health()), 0)
		local x = ScreenScale(12)
		local y = sh - ScreenScale(34)

		draw.SimpleTextOutlined("+", "ZB_CSZombieHealthIcon", x, y, Color(60, 230, 95), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 230))
		draw.SimpleTextOutlined("HP " .. hp, "ZB_CSZombieHealthText", x + ScreenScale(16), y + 1, Color(185, 255, 195), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 230))
	end

	if buyEnd > CurTime() then
		draw.SimpleText(FormatClock(buyEnd - CurTime()), "ZB_HomicideMedium", sw * 0.5, sh * 0.94, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(T("mode_cszombie_buy", "Press F3 to buy weapons"), "ZB_HomicideMedium", sw * 0.5, sh * 0.86, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		local time = FormatClock(startTime + (zb.ROUND_TIME or 240) - CurTime())
		draw.SimpleText(time, "ZB_HomicideMedium", sw * 0.5, sh * 0.95, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if startTime + 8 < CurTime() then return end
	if not lply:Alive() then return end

	zb.RemoveFade()

	local fade = math.Clamp(startTime + 8 - CurTime(), 0, 1)
	local role = lply:GetNWBool("CSZombie_IsZombie", false) and teams.zombie or teams.human
	local roleColor = Color(role.color.r, role.color.g, role.color.b, 255 * fade)

	draw.SimpleText("ZBattle | " .. T("mode_name_cszombie", "CS Zombie"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0, 162, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T("common_role_english", "Role: ") .. T(role.nameKey, role.name), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.42, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T(role.objectiveKey, role.objective), "ZB_HomicideMedium", sw * 0.5, sh * 0.56, Color(255, 255, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
