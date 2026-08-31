local MODE = MODE

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

MODE.name = "scp106raid"

local roleKey = "ZC_SCP106Raid_Role"
local waitingKey = "ZC_SCP106Raid_Waiting"
local roleData = {
	scp = {
		name = "SCP-106",
		objective = "기동특무부대의 모든 지원을 제거하십시오.",
		color = Color(180, 80, 220)
	},
	alpha = {
		name = "알파 기동특무부대",
		objective = "SCP-106을 격리하십시오. 전멸하면 추가 지원이 투입됩니다.",
		color = Color(80, 170, 255)
	},
	omega = {
		name = "오메가 기동특무부대",
		objective = "마지막 지원입니다. SCP-106을 반드시 격리하십시오.",
		color = Color(255, 180, 60)
	}
}

function MODE:HUDPaint()
	self:AddHudPaint()

	local startTime = zb.ROUND_START or CurTime()
	local fade = math.Clamp(startTime + 8 - CurTime(), 0, 1)
	local time = string.FormattedTime(math.max(startTime + (zb.ROUND_TIME or 300) - CurTime(), 0), "%02i:%02i:%02i")
	local sw, sh = ScrW(), ScrH()
	local roleId = LocalPlayer():GetNWString(roleKey, "alpha")
	local role = roleData[roleId] or roleData.alpha
	local rolePhraseKey = roleId == "scp" and "mode_scp_title" or (roleId == "omega" and "role_omega_mtf" or "role_alpha_mtf")
	local objectivePhraseKey = roleId == "scp" and "scp_obj_scp" or (roleId == "omega" and "scp_obj_omega" or "scp_obj_alpha")
	local waiting = LocalPlayer():GetNWBool(waitingKey, false)

	draw.SimpleText(time, "ZB_HomicideMedium", sw * 0.5, sh * 0.95, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if waiting then
		local waitLeft = math.max(startTime + (self.SCPReleaseDelay or 15) - CurTime(), 0)

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, sw, sh)
		draw.SimpleText("SCP-106", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.42, Color(180, 80, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(T("mode_scp_release_timer", "Containment opens in ") .. string.FormattedTime(waitLeft, "%02i:%02i"), "ZB_HomicideMedium", sw * 0.5, sh * 0.52, Color(210, 210, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return
	end

	if fade <= 0 then return end

	draw.SimpleText(T("mode_name_scp106raid", "SCP Raid"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.18, Color(230, 230, 230, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T("common_your_role", "Your role: ") .. T(rolePhraseKey, role.name), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, Color(role.color.r, role.color.g, role.color.b, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(T(objectivePhraseKey, role.objective), "ZB_HomicideMedium", sw * 0.5, sh * 0.72, Color(220, 220, 220, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function MODE:RenderScreenspaceEffects()
	if not LocalPlayer():GetNWBool(waitingKey, false) then return end

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
end

local function IsSCP106RaidRound()
	local round = CurrentRound and CurrentRound()
	return round and round.name == "scp106raid"
end

local function ClearSCP106PuddleMarks()
	local hooks = hook.GetTable()
	local drawHooks = hooks and hooks.PostDrawTranslucentRenderables
	local drawFunc = drawHooks and drawHooks.SCP106_Rebuilt_DrawVisualPuddleMarks
	if not isfunction(drawFunc) or not debug or not debug.getupvalue then return end

	for i = 1, 20 do
		local name, value = debug.getupvalue(drawFunc, i)
		if not name then break end

		if name == "visualPuddleMarks" and istable(value) then
			table.Empty(value)
			return
		end
	end
end

local function ResetSCP106RenderState(strong, force)
	if not force and not IsSCP106RaidRound() then return end

	render.SuppressEngineLighting(false)
	render.OverrideBlend(false)
	render.MaterialOverride(nil)
	render.SetBlend(1)
	render.SetColorModulation(1, 1, 1)

	if strong then
		render.ResetModelLighting(1, 1, 1)
		render.SetAmbientLight(1, 1, 1)
		render.SetLocalModelLights()
		render.FogMode(MATERIAL_FOG_NONE)
	end
end

hook.Add("PreRender", "ZCity_SCP106Raid_ResetLeakedRenderState", function()
	ResetSCP106RenderState(false)
end)
hook.Add("PostRender", "ZCity_SCP106Raid_ResetLeakedRenderState", function()
	ResetSCP106RenderState(false)
end)

local resetUntil = 0

local function ResetSCP106RenderStateAfterExit()
	if resetUntil <= CurTime() then return end
	ResetSCP106RenderState(true)
end

local function PatchSCP106DreamEnd()
	if not Dreams or not Dreams.NameToID or not Dreams.List then return end

	local dreamID = Dreams.NameToID.scp106
	local dream = dreamID and Dreams.List[dreamID]
	if not dream or dream.ZCitySCP106RaidEndPatched then return end

	local oldEnd = dream.End
	dream.End = function(self, ply)
		if oldEnd then oldEnd(self, ply) end

		resetUntil = CurTime() + 2
		timer.Simple(0, function() ResetSCP106RenderState(true) end)
		timer.Simple(0.05, function() ResetSCP106RenderState(true) end)
		timer.Simple(0.2, function() ResetSCP106RenderState(true) end)
	end

	dream.ZCitySCP106RaidEndPatched = true
end

hook.Add("DREAMS_INIT_DONE", "ZCity_SCP106Raid_PatchDreamEnd", PatchSCP106DreamEnd)
hook.Add("InitPostEntity", "ZCity_SCP106Raid_PatchDreamEnd", function()
	timer.Simple(1, PatchSCP106DreamEnd)
end)
hook.Add("Think", "ZCity_SCP106Raid_ResetRenderStateAfterDreamExit", ResetSCP106RenderStateAfterExit)

function MODE:EndRound()
	ClearSCP106PuddleMarks()
	ResetSCP106RenderState(true, true)
end

local wasSCP106RaidRound = false
hook.Add("Think", "ZCity_SCP106Raid_ClearPuddleMarksAfterModeChange", function()
	local isSCP106RaidRound = IsSCP106RaidRound()

	if wasSCP106RaidRound and not isSCP106RaidRound then
		ClearSCP106PuddleMarks()
		ResetSCP106RenderState(true, true)
	end

	wasSCP106RaidRound = isSCP106RaidRound
end)
