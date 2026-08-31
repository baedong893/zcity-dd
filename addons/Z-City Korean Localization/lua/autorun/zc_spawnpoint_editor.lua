if SERVER then
	AddCSLuaFile()

	util.AddNetworkString("zc_spawnpoint_editor_action")
	util.AddNetworkString("zc_spawnpoint_editor_request")
	util.AddNetworkString("zc_spawnpoint_editor_points")

	local pointGroup = "Spawnpoint"
	local presetDir = "zc_spawnpoint_presets"
	local disabledFallback = {}
	local fallbackSpawnClasses = {
		"info_player_start",
		"info_player_deathmatch", "info_player_combine", "info_player_rebel",
		"info_player_counterterrorist", "info_player_terrorist", "info_player_axis",
		"info_player_allies", "gmod_player_start", "info_player_teamspawn",
		"ins_spawnpoint", "aoc_spawnpoint", "dys_spawn_point", "info_player_pirate",
		"info_player_viking", "info_player_knight", "diprip_start_team_blue", "diprip_start_team_red",
		"info_player_red", "info_player_blue", "info_player_coop", "info_player_human", "info_player_zombie",
		"info_player_zombiemaster", "info_player_fof", "info_player_desperado", "info_player_vigilante", "info_survivor_rescue"
	}

	local function EnsurePresetDir()
		if not file.Exists(presetDir, "DATA") then
			file.CreateDir(presetDir)
		end
	end

	local function SanitizePresetName(name)
		name = string.Trim(tostring(name or ""))
		name = string.gsub(name, "[^%w_%-]", "_")
		name = string.sub(name, 1, 32)
		if name == "" then name = "1" end
		return name
	end

	local function PresetPath(name)
		return presetDir .. "/" .. game.GetMap() .. "_" .. SanitizePresetName(name) .. ".json"
	end

	local function PointKey(pos)
		return math.Round(pos.x) .. ":" .. math.Round(pos.y) .. ":" .. math.Round(pos.z)
	end

	local function GetFallbackSpawnKeys()
		local keys = {}

		for _, class in ipairs(fallbackSpawnClasses) do
			for _, ent in ipairs(ents.FindByClass(class)) do
				if not IsValid(ent) then continue end
				keys[PointKey(ent:GetPos())] = true
			end
		end

		return keys
	end

	local function CopyPoint(point, fallback, key, savedIndex)
		return {
			pos = point.pos,
			ang = point.ang or Angle(0, 0, 0),
			fallback = fallback or false,
			key = key or PointKey(point.pos),
			savedIndex = savedIndex
		}
	end

	local function GetFallbackSpawnPoints(savedKeys)
		local points = {}
		local seen = {}

		for _, class in ipairs(fallbackSpawnClasses) do
			for _, ent in ipairs(ents.FindByClass(class)) do
				if not IsValid(ent) then continue end

				local pos = ent:GetPos()
				local key = PointKey(pos)
				if seen[key] or disabledFallback[key] or (savedKeys and savedKeys[key]) then continue end

				seen[key] = true
				points[#points + 1] = {
					pos = pos,
					ang = ent:GetAngles(),
					fallback = true,
					key = key,
					class = class
				}
			end
		end

		return points
	end

	local function GetSavedPoints()
		local points = zb.GetMapPoints and zb.GetMapPoints(pointGroup, true) or {}
		local out = {}
		local keys = {}
		local fallbackKeys = GetFallbackSpawnKeys()

		for savedIndex, point in ipairs(points or {}) do
			if point and isvector(point.pos) then
				local key = PointKey(point.pos)
				if fallbackKeys[key] then continue end

				keys[key] = true
				out[#out + 1] = CopyPoint(point, false, key, savedIndex)
			end
		end

		return out, keys
	end

	local function GetEditorPoints()
		local saved, keys = GetSavedPoints()
		local fallback = GetFallbackSpawnPoints(keys)
		local points = {}

		for _, point in ipairs(saved) do
			points[#points + 1] = point
		end

		for _, point in ipairs(fallback) do
			points[#points + 1] = point
		end

		return points
	end

	local function ListPresets()
		EnsurePresetDir()

		local slots = {}
		local prefix = game.GetMap() .. "_"
		local files = file.Find(presetDir .. "/*.json", "DATA")

		for _, name in ipairs(files or {}) do
			if string.StartWith(name, prefix) then
				local slot = string.sub(name, #prefix + 1, -6)
				slots[#slots + 1] = slot
			end
		end

		table.sort(slots)
		return slots
	end

	local function SendSpawnPoints(ply)
		if not IsValid(ply) then return end

		net.Start("zc_spawnpoint_editor_points")
			net.WriteTable(GetEditorPoints())
			net.WriteTable(ListPresets())
		net.Send(ply)
	end

	local function BuildVisibleRuntimePoints()
		local points = {}
		local seen = {}

		for _, point in ipairs(GetEditorPoints()) do
			if point and isvector(point.pos) then
				local key = PointKey(point.pos)
				if seen[key] then continue end

				seen[key] = true
				points[#points + 1] = {
					pos = point.pos,
					ang = point.ang or Angle(0, 0, 0)
				}
			end
		end

		return points
	end

	local function ApplyRuntimeSpawnPoints(points)
		if not zb or not zb.SaveMapPoints then return false end

		points = points or BuildVisibleRuntimePoints()
		zb.SaveMapPoints(pointGroup, points)
		zb.Points[pointGroup].Points = points

		if zb.RefreshRandomSpawns then zb.RefreshRandomSpawns() end
		if zb.SendPoints then zb.SendPoints() end
		return true
	end

	local function SaveVisiblePoints(name)
		if not zb or not zb.SaveMapPoints then return false end

		local points = BuildVisibleRuntimePoints()
		local disabled = {}

		for key in pairs(disabledFallback) do
			disabled[#disabled + 1] = key
		end

		table.sort(disabled)

		EnsurePresetDir()
		file.Write(PresetPath(name), util.TableToJSON({
			points = points,
			disabledFallback = disabled
		}, true))
		return ApplyRuntimeSpawnPoints(points)
	end

	local function LoadPreset(name)
		if not zb or not zb.SaveMapPoints then return false end

		local raw = file.Read(PresetPath(name), "DATA")
		local data = util.JSONToTable(raw or "") or {}
		if not istable(data) then return false end

		local points = data
		disabledFallback = {}

		if istable(data.points) then
			points = data.points

			for _, key in ipairs(data.disabledFallback or {}) do
				disabledFallback[tostring(key)] = true
			end
		end

		local clean = {}
		local seen = {}

		for _, point in ipairs(points or {}) do
			if point and isvector(point.pos) then
				local key = PointKey(point.pos)
				if seen[key] then continue end

				seen[key] = true
				clean[#clean + 1] = {
					pos = point.pos,
					ang = point.ang or Angle(0, 0, 0)
				}
			end
		end

		return ApplyRuntimeSpawnPoints(clean)
	end

	local function ResetToFallbackSpawns()
		if not zb or not zb.SaveMapPoints then return false end

		disabledFallback = {}
		zb.SaveMapPoints(pointGroup, {})
		zb.Points[pointGroup].Points = {}

		if zb.RefreshRandomSpawns then zb.RefreshRandomSpawns() end
		if zb.SendPoints then zb.SendPoints() end
		return true
	end

	net.Receive("zc_spawnpoint_editor_request", function(_, ply)
		if not IsValid(ply) or not ply:IsAdmin() then return end
		SendSpawnPoints(ply)
	end)

	net.Receive("zc_spawnpoint_editor_action", function(_, ply)
		if not IsValid(ply) or not ply:IsAdmin() then return end
		if not zb or not zb.CreateMapPoint or not zb.RemoveMapPoint then return end

		local action = net.ReadString()

		if action == "add" then
			local tr = util.TraceLine({
				start = ply:EyePos(),
				endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
				filter = ply
			})

			if not tr.Hit or tr.HitNormal.z < 0.7 then
				if ZCLang and ZCLang.ChatPrint then
					ZCLang.ChatPrint(ply, "spawn_msg_look_flat", "Look at a flat floor to add a spawn point.")
				else
					ply:ChatPrint("Look at a flat floor to add a spawn point.")
				end
				return
			end

			local ang = ply:EyeAngles()
			ang.x = 0
			ang.z = 0

			zb.CreateMapPoint(pointGroup, {
				pos = tr.HitPos + Vector(0, 0, 4),
				ang = ang
			}, true)

			ApplyRuntimeSpawnPoints()
			SendSpawnPoints(ply)
			if ZCLang and ZCLang.ChatPrint then
				ZCLang.ChatPrint(ply, "spawn_msg_added", "Spawn point added.")
			else
				ply:ChatPrint("Spawn point added.")
			end
			return
		end

		if action == "remove" then
			local index = net.ReadUInt(16)
			local points = GetEditorPoints()
			local point = points[index]
			if not point then return end

			if point.fallback then
				disabledFallback[point.key or PointKey(point.pos)] = true
			else
				local saved = zb.GetMapPoints and zb.GetMapPoints(pointGroup, true) or {}
				local savedIndex = point.savedIndex or index
				if not saved[savedIndex] then return end
				zb.RemoveMapPoint(pointGroup, savedIndex, true)
			end

			ApplyRuntimeSpawnPoints()
			SendSpawnPoints(ply)
			if ZCLang and ZCLang.ChatPrint then
				ZCLang.ChatPrint(ply, "spawn_msg_removed", "Spawn point removed from editor set.")
			else
				ply:ChatPrint("Spawn point removed from editor set.")
			end
			return
		end

		if action == "reset" then
			if ResetToFallbackSpawns() then
				SendSpawnPoints(ply)
				if ZCLang and ZCLang.ChatPrint then
					ZCLang.ChatPrint(ply, "spawn_msg_reset", "Spawn points reset to original map spawns.")
				else
					ply:ChatPrint("Spawn points reset to original map spawns.")
				end
			end
			return
		end

		if action == "save" then
			local name = net.ReadString()
			if SaveVisiblePoints(name) then
				SendSpawnPoints(ply)
				local safeName = SanitizePresetName(name)
				if ZCLang and ZCLang.PlayerT then
					ply:ChatPrint(ZCLang.PlayerT(ply, "spawn_msg_saved_prefix", "Spawn preset saved: ") .. safeName)
				else
					ply:ChatPrint("Spawn preset saved: " .. safeName)
				end
			end
			return
		end

		if action == "load" then
			local name = net.ReadString()
			if LoadPreset(name) then
				SendSpawnPoints(ply)
				local safeName = SanitizePresetName(name)
				if ZCLang and ZCLang.PlayerT then
					ply:ChatPrint(ZCLang.PlayerT(ply, "spawn_msg_loaded_prefix", "Spawn preset loaded: ") .. safeName)
				else
					ply:ChatPrint("Spawn preset loaded: " .. safeName)
				end
			else
				if ZCLang and ZCLang.ChatPrint then
					ZCLang.ChatPrint(ply, "spawn_msg_not_found", "Spawn preset not found.")
				else
					ply:ChatPrint("Spawn preset not found.")
				end
			end
			return
		end

		if action == "delete_preset" then
			local name = net.ReadString()
			local path = PresetPath(name)
			if file.Exists(path, "DATA") then
				file.Delete(path)
			end
			SendSpawnPoints(ply)
		end
	end)

	return
end

local editorCvar = CreateClientConVar("zc_spawnpoint_editor", "0", true, false, "ZCity spawnpoint editor", 0, 1)
local blue = Color(40, 150, 255, 230)
local fallbackColor = Color(255, 190, 60, 230)
local white = Color(255, 255, 255, 235)
local black = Color(0, 0, 0, 210)
local nextClick = 0
local editorPoints = {}
local presetSlots = {}
local editorMode = "add"
local editorPanel
local RefreshPanelSlots
local nextEditorToggle = 0

local function RequestSpawnPoints()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:IsAdmin() then return end

	net.Start("zc_spawnpoint_editor_request")
	net.SendToServer()
end

local function SendEditorAction(action, writer)
	net.Start("zc_spawnpoint_editor_action")
		net.WriteString(action)
		if writer then writer() end
	net.SendToServer()
end

net.Receive("zc_spawnpoint_editor_points", function()
	editorPoints = net.ReadTable() or {}
	presetSlots = net.ReadTable() or {}
	if IsValid(editorPanel) then
		RefreshPanelSlots(editorPanel.slotCombo)
	end
end)

local function DrawFlatCircle(pos, radius, color)
	local last
	local first

	for i = 0, 48 do
		local a = math.rad(i / 48 * 360)
		local p = pos + Vector(math.cos(a) * radius, math.sin(a) * radius, 3)

		if last then
			render.DrawLine(last, p, color, true)
		else
			first = p
		end

		last = p
	end

	if first and last then
		render.DrawLine(last, first, color, true)
	end
end

local function DrawSpawnPoints3D()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:IsAdmin() or not editorCvar:GetBool() then return end

	render.SetColorMaterial()

	for index, point in ipairs(editorPoints) do
		if not point or not isvector(point.pos) then continue end

		local color = point.fallback and fallbackColor or blue
		DrawFlatCircle(point.pos, 42, color)
		DrawFlatCircle(point.pos, 28, ColorAlpha(color, 150))
		render.DrawLine(point.pos + Vector(0, 0, 4), point.pos + Vector(0, 0, 80), color, true)
	end
end

local function DrawSpawnPointLabels()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:IsAdmin() or not editorCvar:GetBool() then return end

	for index, point in ipairs(editorPoints) do
		if not point or not isvector(point.pos) then continue end

		local screen = (point.pos + Vector(0, 0, 86)):ToScreen()
		if not screen.visible then continue end

		local label = (point.fallback and "map spawn #" or "spawn #") .. index
		local color = point.fallback and fallbackColor or blue

		surface.SetFont("ChatFont")
		local tw, th = surface.GetTextSize(label)
		surface.SetDrawColor(black)
		surface.DrawRect(screen.x - tw / 2 - 6, screen.y - th / 2 - 3, tw + 12, th + 6)
		draw.SimpleText(label, "ChatFont", screen.x, screen.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local function FindAimedSpawnPoint()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local tr = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
		filter = ply
	})

	local bestIndex
	local bestDist = 72

	if tr.Hit then
		for index, point in ipairs(editorPoints) do
			if not point or not isvector(point.pos) then continue end

			local dist = tr.HitPos:Distance(point.pos)
			if dist <= bestDist then
				bestIndex = index
				bestDist = dist
			end
		end
	end

	return bestIndex, tr
end

local function DoEditorClick()
	if CurTime() < nextClick then return end
	nextClick = CurTime() + 0.2

	if editorMode == "delete" then
		local index = FindAimedSpawnPoint()
		if not index then return end

		SendEditorAction("remove", function()
			net.WriteUInt(index, 16)
		end)
		return
	end

	SendEditorAction("add")
end

function RefreshPanelSlots(combo)
	if not IsValid(combo) then return end

	combo:Clear()
	for _, slot in ipairs(presetSlots) do
		combo:AddChoice(slot)
	end
end

local function EnsureEditorPanel()
	if IsValid(editorPanel) then return end
	local function T(key, fallback)
		return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback
	end

	editorPanel = vgui.Create("DFrame")
	editorPanel:SetTitle(T("spawn_editor_title", "Spawnpoint Editor"))
	editorPanel:SetSize(250, 214)
	editorPanel:SetPos(ScrW() - 270, 24)
	editorPanel:SetSizable(false)
	editorPanel:SetDeleteOnClose(false)
	editorPanel:ShowCloseButton(false)
	editorPanel:SetDraggable(true)
	editorPanel:SetMouseInputEnabled(true)
	editorPanel:SetKeyboardInputEnabled(false)

	local add = vgui.Create("DButton", editorPanel)
	add:SetText(T("spawn_editor_create", "Create"))
	add:SetPos(10, 30)
	add:SetSize(110, 26)
	add.DoClick = function()
		editorMode = "add"
	end

	local del = vgui.Create("DButton", editorPanel)
	del:SetText(T("spawn_editor_delete", "Delete"))
	del:SetPos(130, 30)
	del:SetSize(110, 26)
	del.DoClick = function()
		editorMode = "delete"
	end

	local entry = vgui.Create("DTextEntry", editorPanel)
	entry:SetPos(10, 66)
	entry:SetSize(110, 24)
	entry:SetText("1")
	entry:SetUpdateOnType(true)

	local combo = vgui.Create("DComboBox", editorPanel)
	combo:SetPos(130, 66)
	combo:SetSize(110, 24)
	combo:SetValue(T("spawn_editor_saved_slots", "saved slots"))
	combo.OnSelect = function(_, _, value)
		entry:SetText(value)
	end
	editorPanel.slotCombo = combo

	local save = vgui.Create("DButton", editorPanel)
	save:SetText(T("spawn_editor_save", "Save spawnpoints"))
	save:SetPos(10, 100)
	save:SetSize(230, 26)
	save.DoClick = function()
		SendEditorAction("save", function()
			net.WriteString(entry:GetValue())
		end)
	end

	local load = vgui.Create("DButton", editorPanel)
	load:SetText(T("spawn_editor_load", "Load"))
	load:SetPos(10, 136)
	load:SetSize(110, 26)
	load.DoClick = function()
		SendEditorAction("load", function()
			net.WriteString(entry:GetValue())
		end)
	end

	local deletePreset = vgui.Create("DButton", editorPanel)
	deletePreset:SetText(T("spawn_editor_delete_slot", "Delete slot"))
	deletePreset:SetPos(130, 136)
	deletePreset:SetSize(110, 26)
	deletePreset.DoClick = function()
		SendEditorAction("delete_preset", function()
			net.WriteString(entry:GetValue())
		end)
	end

	local reset = vgui.Create("DButton", editorPanel)
	reset:SetText(T("spawn_editor_reset", "Reset to map spawns"))
	reset:SetPos(10, 172)
	reset:SetSize(230, 26)
	reset.DoClick = function()
		SendEditorAction("reset")
	end
end

local function UpdateEditorPanel()
	local enabled = editorCvar:GetBool()

	if enabled then
		EnsureEditorPanel()
		editorPanel:SetVisible(true)
		gui.EnableScreenClicker(true)
		RefreshPanelSlots(editorPanel.slotCombo)
	else
		if IsValid(editorPanel) then
			editorPanel:SetVisible(false)
		end
		gui.EnableScreenClicker(false)
	end
end

concommand.Add("zc_toggle_spawnpoint_editor", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	if CurTime() < nextEditorToggle then return end
	nextEditorToggle = CurTime() + 0.3

	local enabled = not editorCvar:GetBool()
	RunConsoleCommand("zc_spawnpoint_editor", enabled and "1" or "0")
end)

hook.Add("PostDrawTranslucentRenderables", "ZCitySpawnPointEditorDraw", DrawSpawnPoints3D)
hook.Add("HUDPaint", "ZCitySpawnPointEditorLabels", DrawSpawnPointLabels)

hook.Add("PlayerButtonDown", "ZCitySpawnPointEditorClick", function(ply, button)
	if ply ~= LocalPlayer() or not editorCvar:GetBool() then return end
	if button ~= MOUSE_RIGHT then return end
	if vgui.CursorVisible() and gui.MouseX() > ScrW() - 300 and gui.MouseY() < 270 then return end

	DoEditorClick()
	return true
end)

cvars.AddChangeCallback("zc_spawnpoint_editor", function(_, _, new)
	if tobool(new) then
		RequestSpawnPoints()
	end

	timer.Simple(0, UpdateEditorPanel)
end, "ZCitySpawnPointEditor")

hook.Add("InitPostEntity", "ZCitySpawnPointEditorInitialRequest", function()
	timer.Simple(1, function()
		UpdateEditorPanel()
		if editorCvar:GetBool() then
			RequestSpawnPoints()
		end
	end)
end)

hook.Add("Think", "ZCitySpawnPointEditorPanelThink", function()
	if not editorCvar:GetBool() then return end
	EnsureEditorPanel()
	if not editorPanel:IsVisible() then editorPanel:SetVisible(true) end
end)

hook.Add("PopulateToolMenu", "ZCitySpawnPointEditorMenu", function()
	local function T(key, fallback)
		return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback
	end

	spawnmenu.AddToolMenuOption("Utilities", "ZCity", "ZCitySpawnPointEditor", T("spawn_editor_title", "Spawnpoint Editor"), "", "", function(panel)
		panel:ClearControls()
		panel:CheckBox(T("spawn_editor_menu_toggle", "Show spawnpoint editor"), "zc_spawnpoint_editor")
		panel:ControlHelp(T("spawn_editor_menu_help", "Blue circles are saved ZCity Spawnpoint points. Yellow circles are original map spawn entities. Use right click in Create/Delete mode. Reset restores the original yellow map spawns."))
		panel:Button(T("spawn_editor_refresh", "Refresh spawn points"), "zb_pointsupdate")
	end)
end)
