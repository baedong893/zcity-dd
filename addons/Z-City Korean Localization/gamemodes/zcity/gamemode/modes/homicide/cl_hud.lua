local MODE = MODE

local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

local vgui_color_main = Color(150, 80, 0, 255)
local vgui_color_warning = Color(150, 0, 0, 255)
local vgui_color_bg = Color(50, 50, 50, 255)
local vgui_color_ready = Color(0, 150, 50, 255)
local vgui_color_notready = Color(0, 50, 0, 255)
local vgui_color_text_main = Color(150, 50, 0, 255)
local vgui_color_text_shadow = Color(0, 0, 0, 255)

local mat_gradientdown = Material("vgui/gradient_down")

local function draw_shadow_text(text, cx, cy)
	draw.DrawText(text, "HomigradFontMedium", cx + 1, cy + 1, vgui_color_text_shadow, TEXT_ALIGN_CENTER)
	draw.DrawText(text, "HomigradFontMedium", cx, cy, vgui_color_text_main, TEXT_ALIGN_CENTER)
end

local vector_one = Vector(1, 1, 1)

local function draw_RotatedText(text, font, x, y, color, ang, scale)
	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)

	local m = Matrix()
	
	m:Translate(Vector(x, y, 0))
	m:Rotate(Angle(0, ang, 0))
	m:Scale(vector_one * (scale or 1))

	surface.SetFont(font)
	
	local w, h = surface.GetTextSize(text)

	m:Translate(Vector(-w / 2, -h / 2, 0))

	cam.PushModelMatrix(m, true)
		draw.DrawText(text, font, 0, 0, color)
	cam.PopModelMatrix()

	render.PopFilterMag()
	render.PopFilterMin()
end

hook.Add("HUDPaint", "HMCD_SubRoles_Abilities", function()
	local ply = LocalPlayer()
	local aim_ent, other_ply, trace = MODE.GetPlayerTraceToOther(ply)
	local after_text_offset = 5
	local y_offset = 30
	y_offset = y_offset + ScreenScale(15)
	
	surface.SetFont("HomigradFontMedium")
	
	if(ply:Alive())then
		if(ply.isTraitor)then
			if(ply.SubRole == "traitor_infiltrator" or ply.SubRole == "traitor_infiltrator_soe")then
				local text = "(HOLD)[ALT + E] 목 부러트리기"
				local tw, th = surface.GetTextSize(text)
				local cx, cy = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
				cy = cy + y_offset
				
				if((IsValid(aim_ent) and other_ply and MODE.CanPlayerBreakOtherNeck(ply, aim_ent)) or ply.Ability_NeckBreak)then
					draw_shadow_text(text, cx, cy)
					
					if(ply.Ability_NeckBreak)then
						local frac = ply.Ability_NeckBreak.Progress / 100
						
						surface.SetDrawColor(vgui_color_text_main)
						surface.DrawRect(cx - tw / 2, cy, tw * frac, th)
					end
				
					y_offset = y_offset + th + after_text_offset
				end
				
				if(IsValid(aim_ent))then
					if(aim_ent:IsRagdoll())then
						local text = "[ALT + R] 의상 바꾸기"
						local tw, th = surface.GetTextSize(text)
						local cx, cy = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
						
						draw_shadow_text(text, cx, cy + y_offset)
						
						y_offset = y_offset + th + after_text_offset
					end
				end
			end
			
			if(ply.SubRole == "traitor_assasin" or ply.SubRole == "traitor_assasin_soe" or ply.PlayerClassName == "sc_infiltrator")then
				local aim_ent, other_ply, trace = MODE.GetPlayerTraceToOther(ply, nil, MODE.DisarmReach)
				local text = "(HOLD)[ALT + E] 무장 해제하기"
				local tw, th = surface.GetTextSize(text)
				local cx, cy = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
				cy = cy + y_offset
				
				if((IsValid(aim_ent) and other_ply and MODE.CanPlayerDisarmOtherPly(ply, other_ply, MODE.DisarmReach) and MODE.CanPlayerDisarmOther(ply, aim_ent, MODE.DisarmReach)) or ply.Ability_Disarm)then
					draw_shadow_text(text, cx, cy)
					
					if(ply.Ability_Disarm)then
						local frac = ply.Ability_Disarm.Progress / 100
						
						surface.SetDrawColor(vgui_color_text_main)
						surface.DrawRect(cx - tw / 2, cy, tw * frac, th)
					end
					
					y_offset = y_offset + th + after_text_offset
				end
			end
			
			if(ply.SubRole == "traitor_chemist")then
				local after_side_bar_offset = 5
				local bar_border = 5
				local bar_width = ScreenScale(20)
				local bar_height = ScreenScale(80)
				local bar_y = (ScrH() - bar_height) / 2
				local bar_x = ScrW() - after_side_bar_offset
				ply.PassiveAbility_ChemicalAccumulation = ply.PassiveAbility_ChemicalAccumulation or {}
				ply.PassiveAbility_VGUI_ChemicalAccumulation = ply.PassiveAbility_VGUI_ChemicalAccumulation or {}
				
				for chemical_name, amt in pairs(ply.PassiveAbility_ChemicalAccumulation) do
					ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] = ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] or 0
					ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] = Lerp(FrameTime() * 3, ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name], amt)
					if(ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] > 0.1)then
						surface.SetDrawColor(vgui_color_bg)
						surface.DrawRect(bar_x - bar_width, bar_y, bar_width, bar_height)
						
						local frac = math.min(ply.PassiveAbility_VGUI_ChemicalAccumulation[chemical_name] / 100, 1)
						local y_end = bar_y + bar_border + bar_height - bar_border * 2
						local y_start = y_end - ((bar_height - bar_border * 2) * frac)
						local height = y_end - y_start
						
						surface.SetDrawColor(vgui_color_main)
						surface.DrawRect(bar_x - bar_width + bar_border, y_start, bar_width - bar_border * 2, height)
						
						render.SetScissorRect(bar_x - bar_width + bar_border, y_start, bar_x - bar_border, y_start + height, true)
							surface.SetDrawColor(vgui_color_warning)
							surface.SetMaterial(mat_gradientdown)
							surface.DrawTexturedRect(bar_x - bar_width + bar_border, bar_y + bar_border, bar_width - bar_border * 2, bar_height - bar_border * 2)
						render.SetScissorRect(0, 0, 0, 0, false)
						
						local tcx, tcy = bar_x - bar_width / 2, bar_y + bar_height / 2
						
						draw_RotatedText(chemical_name, "HomigradFontMedium", tcx, tcy, vgui_color_text_shadow, 90, 1)
						
						bar_x = bar_x - bar_width - after_side_bar_offset
					end
				end
			end
		end
		
		--\\Professions
		
		--//
	end
end)


--// Я ебал это делать

surface.CreateFont("TraitorPanelTitle", {
	font = "coolvetica",
	size = 22,
	weight = 500,
	antialias = true
})

surface.CreateFont("TraitorPanelText", {
	font = "coolvetica",
	size = 19,
	weight = 500,
	antialias = true
})

surface.CreateFont("TraitorPanelWords", {
	font = "coolvetica",
	size = 24,
	weight = 700,
	antialias = true,
	italic = false
})



local traitor_panel = {
    assistants = {},
    dead_anim = {}, 
    width = 300,
    height = 280,
    assist_height = 200,
	bang_height = 300,
    spacing = 26,
    padding = 15,
    left_padding = 90, 
    avatar_size = 24, 
    fade_speed = 3,
    instance = nil,
    visible = true,
    target_x = 0,
    smooth_toggle = 0,
    alpha = 255,
    last_toggle_time = 0,
    toggle_cooldown = 0.3,
    assistant_status_cache = {},
    assistant_avatars = {}, 
    avatar_materials = {}, 
    colors = {
        bg = Color(30, 0, 0, 230),
        border = Color(180, 0, 0, 255),
        border_inner = Color(90, 0, 0, 150),
        title = Color(255, 255, 255, 255),
        words = Color(255, 80, 80, 255),
        assistant = Color(200, 70, 70, 255)
    }
}

local function IsBangInfoPanelAvailable(ply)
	if MODE.Type ~= "bang" or not isstring(ply.BangRole) or ply.BangRole == "" then return false end
	return MODE.BangRoleObjectives and MODE.BangRoleObjectives[ply.BangRole] ~= nil
end

local function GetBangSpectatorTarget(ply)
	if MODE.Type ~= "bang" or not IsValid(ply) or ply:Alive() then return end

	local target = ply:GetNWEntity("spect", NULL)
	if not IsValid(target) or not target:IsPlayer() or not target:Alive() then return end

	local characterID = target:GetNWString("HMCD_BangCharacter", "")
	if characterID == "" or not MODE.BangCharacterInfo or not MODE.BangCharacterInfo[characterID] then return end

	return target, characterID
end

local function GetBangPanelSubject(ply)
	local spectated, characterID = GetBangSpectatorTarget(ply)
	if IsValid(spectated) then
		return spectated, nil, characterID, true
	end

	if not IsBangInfoPanelAvailable(ply) then return end

	local characterID = ply.BangCharacter or ply:GetNWString("HMCD_BangCharacter", "")
	return ply, MODE.BangRoleObjectives[ply.BangRole], characterID, false
end

local function HideTraitorPanelAvatars()
	for _, avatar in pairs(traitor_panel.assistant_avatars) do
		if IsValid(avatar) then avatar:SetVisible(false) end
	end
end

local function WrapPanelText(text, font, maxWidth)
	surface.SetFont(font)

	local lines = {}
	local line = ""
	for word in string.gmatch(tostring(text or ""), "%S+") do
		local candidate = line == "" and word or line .. " " .. word
		local width = surface.GetTextSize(candidate)
		if width > maxWidth and line ~= "" then
			lines[#lines + 1] = line
			line = word
		else
			line = candidate
		end
	end

	if line ~= "" then lines[#lines + 1] = line end
	return lines
end

local function DrawPanelWrappedText(text, font, x, y, color, maxWidth, lineHeight)
	for _, line in ipairs(WrapPanelText(text, font, maxWidth)) do
		draw.SimpleText(line, font, x, y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		y = y + lineHeight
	end

	return y
end


local function CreateAvatarPanel(steamid)
    if not steamid or steamid == "" then return nil end
    
    if traitor_panel.assistant_avatars[steamid] and IsValid(traitor_panel.assistant_avatars[steamid]) then
        return traitor_panel.assistant_avatars[steamid]
    end
    

    local avatar = vgui.Create("AvatarImage")
    avatar:SetSize(traitor_panel.avatar_size, traitor_panel.avatar_size)
    avatar:SetVisible(false) 
    
    local ply = player.GetBySteamID(steamid)
    if IsValid(ply) then
        avatar:SetPlayer(ply, traitor_panel.avatar_size)
    end
    
    traitor_panel.assistant_avatars[steamid] = avatar
    return avatar
end


hook.Add("PlayerButtonDown", "TraitorPanelToggle", function(ply, btn)
    if ply ~= LocalPlayer() or btn ~= KEY_F4 then return end
	local localPly = LocalPlayer()
	local bangSubject = GetBangPanelSubject(localPly)
	if not localPly.isTraitor and not IsValid(bangSubject) then return end
    

    local current_time = CurTime()
    if current_time - traitor_panel.last_toggle_time < traitor_panel.toggle_cooldown then
        return
    end
    
    traitor_panel.last_toggle_time = current_time
    traitor_panel.visible = not traitor_panel.visible
    
    if traitor_panel.visible then
        surface.PlaySound("buttons/button14.wav")
    end
end)




net.Receive("HMCD_UpdateTraitorAssistants", function()
    local count = net.ReadUInt(8)
    MODE.TraitorsLocal = {}
    
    for i = 1, count do
        local color = net.ReadColor()
        local name = net.ReadString()
        local steamID = net.ReadString()
        
        table.insert(MODE.TraitorsLocal, {color, name, steamID})
    end
end)


net.Receive("HMCD_TraitorDeathState", function()
    local traitor_name = net.ReadString()
    local is_alive = net.ReadBool()
    
    if traitor_name and traitor_name ~= "" then
        traitor_panel.assistant_status_cache[traitor_name] = is_alive
    end
end)

hook.Add("HUDPaint", "DrawTraitorPanel", function()
    local ply = LocalPlayer()
	local bangSubject, bangRoleData, bangCharacterID, isBangSpectatorPanel = GetBangPanelSubject(ply)
	local isBangPanel = IsValid(bangSubject)
	if (not ply.isTraitor and not isBangPanel) or (not ply:Alive() and not isBangPanel) then
        traitor_panel.visible = false 
		traitor_panel.was_bang_panel = false
		traitor_panel.was_bang_spectator = false
		HideTraitorPanelAvatars()
        
        return 
    end

	local isAlive = ply:Alive()
	local enteredBangPanel = isBangPanel and not isBangSpectatorPanel and not traitor_panel.was_bang_panel
	local spawnedIntoBangRound = isBangPanel and not isBangSpectatorPanel and isAlive and not traitor_panel.was_bang_alive
	local enteredBangSpectatorPanel = isBangSpectatorPanel and not traitor_panel.was_bang_spectator
	if enteredBangPanel or spawnedIntoBangRound then
		traitor_panel.visible = true
		traitor_panel.smooth_toggle = 0
	elseif enteredBangSpectatorPanel then
		-- Spectator information is opt-in: it only opens when F4 is pressed.
		traitor_panel.visible = false
		traitor_panel.smooth_toggle = traitor_panel.width + 40
	end
	traitor_panel.was_bang_panel = isBangPanel
	traitor_panel.was_bang_alive = isBangPanel and not isBangSpectatorPanel and isAlive
	traitor_panel.was_bang_spectator = isBangSpectatorPanel


    local target = traitor_panel.visible and 0 or traitor_panel.width + 40
    traitor_panel.smooth_toggle = Lerp(FrameTime() * 10, traitor_panel.smooth_toggle, target)
    
	local is_main = not isBangPanel and ply.MainTraitor
	local height = isBangPanel and traitor_panel.bang_height or (is_main and traitor_panel.height or traitor_panel.assist_height)
    local x = ScrW() - traitor_panel.width - 20 + traitor_panel.smooth_toggle
    local y = ScrH() / 2 - (height / 2)
    

    if traitor_panel.smooth_toggle > traitor_panel.width + 30 then 
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
        return 
    end
    

	local panelBg = traitor_panel.colors.bg
	local panelBorder = traitor_panel.colors.border
	local panelBorderInner = traitor_panel.colors.border_inner
	local panelAccent = traitor_panel.colors.words
	if bangRoleData then
		local roleColor = bangRoleData.color1 or color_white
		panelBg = Color(math.floor(roleColor.r * 0.16), math.floor(roleColor.g * 0.16), math.floor(roleColor.b * 0.16), 230)
		panelBorder = Color(roleColor.r, roleColor.g, roleColor.b, 255)
		panelBorderInner = Color(roleColor.r, roleColor.g, roleColor.b, 120)
		panelAccent = panelBorder
	elseif isBangSpectatorPanel then
		panelBg = Color(35, 28, 8, 230)
		panelBorder = Color(225, 175, 45, 255)
		panelBorderInner = Color(225, 175, 45, 120)
		panelAccent = panelBorder
	end

	draw.RoundedBox(6, x, y, traitor_panel.width, height, panelBg)
	surface.SetDrawColor(panelBorderInner)
    surface.DrawOutlinedRect(x + 3, y + 3, traitor_panel.width - 6, height - 6, 1)
	surface.SetDrawColor(panelBorder)
    surface.DrawOutlinedRect(x, y, traitor_panel.width, height, 2)
    

	local title
	if isBangSpectatorPanel then
		title = T("bang_spectating_prefix", "관전: ") .. bangSubject:Nick()
	elseif isBangPanel then
		title = T("common_your_role", "역할: ") .. T(bangRoleData.nameKey, bangRoleData.name)
	else
		title = is_main and T("homicide_main_traitor", "Main Traitor") or T("homicide_traitor_assistant", "Traitor Assistant")
	end
    draw.SimpleText(title, "TraitorPanelTitle", x + traitor_panel.width/2, y + 15, 
                    traitor_panel.colors.title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    

	surface.SetDrawColor(panelBorder)
    surface.DrawLine(x + 15, y + 30, x + traitor_panel.width - 15, y + 30)
    

    draw.SimpleText(T("homicide_traitor_panel_hint", "Press F4 to open/close panel"), "TraitorPanelText", x + traitor_panel.width/2, y + 42,
                    Color(180, 180, 180, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if isBangPanel then
		HideTraitorPanelAvatars()

		local textX = x + traitor_panel.width / 2
		local textWidth = traitor_panel.width - 30
		local contentY = y + 63
		if bangRoleData then
			draw.SimpleText(T("bang_panel_objective", "목표"), "TraitorPanelText", textX, contentY, panelAccent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			contentY = DrawPanelWrappedText(T(bangRoleData.objectiveKey, bangRoleData.objective), "TraitorPanelText", textX, contentY + 22,
				Color(225, 225, 225), textWidth, 19) + 9
		end

		local character = MODE.BangCharacterInfo and MODE.BangCharacterInfo[bangCharacterID]
		if character then
			draw.SimpleText(T("bang_character_prefix", "캐릭터: ") .. T(character.nameKey, character.name), "TraitorPanelTitle", textX, contentY,
				panelAccent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			contentY = contentY + 29
			draw.SimpleText(T("bang_panel_ability", "능력"), "TraitorPanelText", textX, contentY, panelAccent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			local abilityDescription = MODE.GetBangAbilityDescription and MODE:GetBangAbilityDescription(bangSubject, bangCharacterID)
				or T(character.descriptionKey, character.description)
			DrawPanelWrappedText(abilityDescription, "TraitorPanelText", textX, contentY + 22,
				Color(225, 225, 225), textWidth, 19)
		end

		return
	end
    
    local word_y = y + 65
    draw.SimpleText(T("homicide_secret_words_label", "Secret words:"), "TraitorPanelText", x + traitor_panel.width/2, word_y,
                    Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    word_y = word_y + 25
    local word1 = MODE.TraitorWord or "???"
    
    draw.SimpleText(word1, "TraitorPanelWords", x + traitor_panel.width/2, word_y, 
                    traitor_panel.colors.words, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    word_y = word_y + 30
    local word2 = MODE.TraitorWordSecond or "???"
    
    draw.SimpleText(word2, "TraitorPanelWords", x + traitor_panel.width/2, word_y, 
                    traitor_panel.colors.words, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    if is_main then
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
        
        local assist_y = y + 150     
        local has_assistants = false
        MODE.TraitorsLocal = MODE.TraitorsLocal or {}
        
        if #MODE.TraitorsLocal > (ply.MainTraitor and 1 or 0) then
            has_assistants = true
        end
        
        if has_assistants then
            draw.SimpleText(T("homicide_your_assistants", "Your assistants:"), "TraitorPanelText", x + traitor_panel.width/2, assist_y,
                            Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            assist_y = assist_y + 25   
            
            for _, traitor_info in ipairs(MODE.TraitorsLocal) do
                if not traitor_info or #traitor_info < 2 then continue end
                
                if ply.MainTraitor and ply.CurAppearance and traitor_info[2] == ply.CurAppearance.AName then
                    continue
                end
                
                local color = traitor_info[1]
                local name = traitor_info[2]
                local steamID = traitor_info[3] or ""
                
                local player_found = nil
                for _, v in player.Iterator() do
                    if v.isTraitor and v.CurAppearance and v.CurAppearance.AName == name then
                        player_found = v
                        break
                    end
                end
                
                local is_alive = true
                if traitor_panel.assistant_status_cache[name] == false then
                    is_alive = false
                end
                
                if player_found then
                    is_alive = player_found:Alive() and (not player_found.organism or not player_found.organism.incapacitated)
                    traitor_panel.assistant_status_cache[name] = is_alive
                end
                
                if not is_alive then
                    traitor_panel.dead_anim[name] = traitor_panel.dead_anim[name] or 255
                    traitor_panel.dead_anim[name] = math.max(traitor_panel.dead_anim[name] - FrameTime() * 100 * traitor_panel.fade_speed, 0)
                    
                    if traitor_panel.dead_anim[name] <= 0 then continue end
                else
                    traitor_panel.dead_anim[name] = nil
                end
                
                local alpha = traitor_panel.dead_anim[name] or 255
                local display_color = is_alive and color or Color(150, 150, 150)
                display_color = Color(display_color.r, display_color.g, display_color.b, alpha)
                
                local status = is_alive and "" or T("homicide_dead_status", " [Dead]")


                local display_name = name
                if #name > 20 then
                    display_name = string.sub(name, 1, 18) .. ".."
                end
                

                if steamID and steamID ~= "" then
                    local avatar_player = player.GetBySteamID(steamID)
                    
                    if IsValid(avatar_player) then
                        local avatar = CreateAvatarPanel(steamID)
                        
                        if avatar then
                            avatar:SetPos(x + 15, assist_y - traitor_panel.avatar_size/2)
                            avatar:SetSize(traitor_panel.avatar_size, traitor_panel.avatar_size)
                            avatar:SetAlpha(alpha)
                            avatar:SetVisible(true)
                            
                            surface.SetDrawColor(50, 50, 50, alpha)
                            surface.DrawOutlinedRect(x + 15, assist_y - traitor_panel.avatar_size/2, 
                                                     traitor_panel.avatar_size, traitor_panel.avatar_size, 1)
                        end
                    end
                end
                
                draw.SimpleText(display_name..status, "TraitorPanelText", x + traitor_panel.left_padding, assist_y, 
                                display_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                assist_y = assist_y + 25   
                

                if assist_y > y + height - 30 then
                    break
                end
            end
        else

            draw.SimpleText(T("homicide_no_assistants", "No available assistants"), "TraitorPanelText", x + traitor_panel.width/2, assist_y,
                            Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    else

        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
    end
end)


hook.Add("PostPlayerDeath", "ClearTraitorPanel", function(ply)
    if ply == LocalPlayer() then
        traitor_panel.dead_anim = {}
        traitor_panel.smooth_toggle = 0
        traitor_panel.visible = false
        
        for steamid, avatar in pairs(traitor_panel.assistant_avatars) do
            if IsValid(avatar) then
                avatar:SetVisible(false)
            end
        end
    end
end)


hook.Add("Think", "UpdateTraitorAssistants", function()
	if not LocalPlayer().isTraitor or not LocalPlayer().MainTraitor then return end

	if not traitor_panel.next_assistant_check or traitor_panel.next_assistant_check < CurTime() then
		traitor_panel.next_assistant_check = CurTime() + 0.5
		
		for name, alpha in pairs(traitor_panel.dead_anim) do
			local is_alive = false
			for _, v in player.Iterator() do
				if v.isTraitor and v.CurAppearance and v.CurAppearance.AName == name then
					is_alive = v:Alive() and (not v.organism or not v.organism.incapacitated)
					break
				end
			end
			
			if is_alive then
				traitor_panel.dead_anim[name] = nil
			end
		end
	end
end)


hook.Add("Think", "RequestTraitorStatus", function()
	if not LocalPlayer().isTraitor or not LocalPlayer().MainTraitor then return end
	
	if not traitor_panel.next_status_request or traitor_panel.next_status_request < CurTime() then
		traitor_panel.next_status_request = CurTime() + 2
		
		net.Start("HMCD_RequestTraitorStatuses")
		net.SendToServer()
	end
end)
