hg.settings = hg.settings or {}
hg.settings.tbl = hg.settings.tbl or {}

function hg.settings:AddOpt( strCategory, strConVar, strTitle, bDecimals, bString, category )
    self.tbl[strCategory] = self.tbl[strCategory] or {}
    self.tbl[strCategory][strConVar] = { strCategory, strConVar, strTitle, bDecimals or false, bString or false, category }
end
local hg_firstperson_death = CreateClientConVar("hg_firstperson_death", "0", true, false, "Toggle first-person death camera view", 0, 1)
local hg_font = CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local hg_attachment_draw_distance = CreateClientConVar("hg_attachment_draw_distance", 0, true, nil, "distance to draw attachments", 0, 4096)
local zc_language = GetConVar("zc_language") or CreateClientConVar("zc_language", "auto", true, false, "Z-City display language: auto, en, ko, zh, ru")

local function L(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

local function GetOptionTitle(convarName, fallback)
	if not ZCLang or not ZCLang.Phrases or not ZCLang.GetLanguage then
		return fallback
	end

	local phrase = ZCLang.Phrases["settings_option_" .. convarName]
	if not phrase then
		return fallback
	end

	return phrase[ZCLang.GetLanguage()] or fallback
end

local function GetOptionHelp(convarName, fallback)
	if not ZCLang or not ZCLang.Phrases or not ZCLang.GetLanguage then
		return fallback
	end

	local phrase = ZCLang.Phrases["settings_help_" .. convarName]
	if not phrase then
		return fallback
	end

	return phrase[ZCLang.GetLanguage()] or fallback
end

xbars = 17
ybars = 30

gradient_l = Material("vgui/gradient-l")

local blur = Material("pp/blurscreen")
local blur2 = Material("effects/shaders/zb_blur" )
local sw, sh = ScrW(), ScrH()

local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Bahnschrift"
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

surface.CreateFont("ZCity_setiings_tiny", {
	font = font(),
	size = ScreenScale(7),
	weight = 100
})

surface.CreateFont("ZCity_setiings_fine", {
	font = font(),
	size = ScreenScale(10),
	weight = 100
})

surface.CreateFont("ZCity_setiings_category", {
	font = font(),
	size = ScreenScale(15),
	weight = 100
})


hg.settings:AddOpt("Gameplay","hg_old_notificate", "이전 알림 방식")
hg.settings:AddOpt("Gameplay","hg_cheats", "치트 활성화")
hg.settings:AddOpt("Gameplay","hg_showthoughts", "생각 표시")
hg.settings:AddOpt("Gameplay","hg_hints", "힌트 표시")
hg.settings:AddOpt("Gameplay","hg_gary", "HG 게리")
hg.settings:AddOpt("Gameplay","hg_deathfadeout", "사망 시 페이드 아웃")

if not game.IsDedicated() then
    hg.settings:AddOpt("Serverside gameplay","hg_toughnpcs", "강력한 NPC")
    hg.settings:AddOpt("Serverside gameplay","hg_thirdperson", "3인칭 (개발 중)")
    hg.settings:AddOpt("Serverside gameplay","hg_legacycam", "레거시 카메라")
    hg.settings:AddOpt("Serverside gameplay","hg_ragdollcombat", "래그돌 전투 모드")
    hg.settings:AddOpt("Serverside gameplay","hg_movement_stamina_debuff", "이동 스테미나 디버프")
    hg.settings:AddOpt("Serverside gameplay","hg_furcity", "퍼시티")
    hg.settings:AddOpt("Serverside gameplay","hg_appearance_access_for_all", "모든 사용자 외형 전체 접근 허용", nil, nil, "bool")
    hg.settings:AddOpt("Serverside gameplay","hg_healanims", "치료 및 음식 애니메이션")
    hg.settings:AddOpt("Serverside gameplay","hg_aimtoshoot", "DarkRP 스타일 사격 시스템 (조준 시 사격 가능)")
    hg.settings:AddOpt("Serverside gameplay","hg_slings", "슬링 시스템")
end
--hg_appearance_access_for_all
--hg_furcity
--hg_legacycam
--hg_toughnpcs

hg.settings:AddOpt("Debug","hg_show_hitposmuzzle", "무기 명중 지점 표시")
hg.settings:AddOpt("Debug","hg_setzoompos", "무기 줌 위치 수정, 결과는 콘솔 확인")
hg.settings:AddOpt("Debug","hg_show_hitbox", "히트박스 표시")

hg.settings:AddOpt("Optimization","hg_potatopc", "저사양 PC 모드")
hg.settings:AddOpt("Optimization","hg_anims_draw_distance", "애니메이션 표시 거리", true, nil, "int")
hg.settings:AddOpt("Optimization","hg_anim_fps", "애니메이션 FPS", nil, nil, "int")
hg.settings:AddOpt("Optimization","hg_attachment_draw_distance", "부착물 표시 거리", true, nil, "int")
hg.settings:AddOpt("Optimization","hg_maxsmoketrails", "최대 연기 궤적 수", nil, nil, "int")
hg.settings:AddOpt("Optimization","hg_tpik_distance", "TPIK 렌더링 거리", true, nil, "int")

hg.settings:AddOpt("Blood","hg_blood_draw_distance", "혈흔 표시 거리")
hg.settings:AddOpt("Blood","hg_blood_fps", "혈흔 FPS")
hg.settings:AddOpt("Blood","hg_blood_sprites", "혈흔 스프라이트 (모든 사용자 비활성화)")
hg.settings:AddOpt("Blood","hg_old_blood", "이전 혈흔 효과")

hg.settings:AddOpt("UI","hg_font", "사용자 정의 글꼴 변경", false, true)
hg.settings:AddOpt("UI","zc_language", "Language", false, true, "language")

hg.settings:AddOpt("Weapons","hg_weaponshotblur_enable", "사격 블러 효과")
hg.settings:AddOpt("Weapons","hg_dynamic_mags", "동적 탄약 확인")
hg.settings:AddOpt("Weapons","hg_zoomsensitivity", "조준경 감도")
hg.settings:AddOpt("Weapons","hg_highpitchgunfire", "건물 내부 고주파 사격음 활성화")

hg.settings:AddOpt("View","hg_firstperson_death", "1인칭 사망 시점")
hg.settings:AddOpt("View","hg_fov", "시야각 (FOV)")
hg.settings:AddOpt("View","hg_newspectate", "부드러운 관전 카메라")
hg.settings:AddOpt("View","hg_cshs_fake", "C'sHS 래그돌 카메라")
hg.settings:AddOpt("View","hg_gun_cam", "총기 카메라 (관리자 전용)")
hg.settings:AddOpt("View","hg_nofovzoom", "시야각(FOV) 확대 활성화/비활성화")
hg.settings:AddOpt("View","hg_realismcam", "리얼리즘 카메라 (조잡함)")
hg.settings:AddOpt("View","hg_gopro", "고프로 카메라")
hg.settings:AddOpt("View","hg_newfakecam", "새로운 가짜 카메라")
hg.settings:AddOpt("View","hg_leancam_mul", "기울기 카메라 배율", true, nil, "int")
hg.settings:AddOpt("View","hg_gun_cam", "총기 카메라 (개발 중, 관리자 전용)")

hg.settings:AddOpt("Sound","hg_dmusic", "동적 음악")
hg.settings:AddOpt("Sound","hg_quietshots", "저소음 사격음 활성화/비활성화")

function hg.CreateCategory(ctgName, ParentPanel, yPos)
    local pppanel = vgui.Create('DPanel', ParentPanel)
    pppanel:SetSize(ParentPanel:GetWide() / 1.05, ParentPanel:GetTall() * 0.07)
    pppanel:SetPos(ParentPanel:GetWide() / 2 -pppanel:GetWide() / 2, yPos)
    --pppanel:SetText(ctgName)
    pppanel.Paint = function(self,w,h)
        surface.SetDrawColor(60,60,60,145)
        surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(42, 42, 42, 184)
		surface.DrawRect(0, h-5, w, 5)
    
        local categoryText = L("settings_category_" .. string.lower(string.Replace(ctgName, " ", "_")), ctgName)
        draw.SimpleText(categoryText, 'ZCity_setiings_category', w / 2, h / 2, color3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    return pppanel
end

function hg.GetConVarType(convar)
    local stringv = convar:GetString()
    local floatVal = convar:GetFloat()
    local intVal = convar:GetInt()
    local boolVal = convar:GetBool()

    if (stringv == '0' and not boolVal) or (stringv == '1' and boolVal) then
        return 'bool'
    end

    if tonumber(stringv) and math.floor(stringv) == floatVal then
        if intVal == floatVal then
            return "int"
        end
    end

    return "string"
end

local function SetConVarValue(convar, value)
    if not convar then
        return
    end

    local name = convar.GetName and convar:GetName()
    if not name or name == "" then
        return
    end

    if isbool(value) then
        RunConsoleCommand(name, value and "1" or "0")
        return
    end

    RunConsoleCommand(name, tostring(value))
end

local clr_1 = Color(255,255,255,104)
local clr_2 = Color(122,122,122,104)
local clr_3 = Color(28,28,28)
local clr_4 = Color(0, 0, 0, 30)
local clr_5 = Color(30, 29, 29, 30)
local clr_6 = Color(255, 255, 255, 100)
local clr_7 = Color(255, 255, 255, 200)
local clr_8 = Color(70, 130, 180)
function hg.CreateButton(buttonData, convarName, ParentPanel, yPos)
    local convar = GetConVar(convarName)

    if not convar then 
        return 
    end
    local pppanel = vgui.Create('DPanel', ParentPanel)
    pppanel:SetSize(ParentPanel:GetWide()/1.05, ParentPanel:GetTall()/15)
    pppanel:SetPos(ParentPanel:GetWide()/2-pppanel:GetWide()/2, yPos)
    
    surface.SetFont('ZCity_setiings_fine')
    local width2, height2 = surface.GetTextSize(buttonData[3])
    
    convarType = buttonData[6] or hg.GetConVarType(convar)
    pppanel.Paint = function(self,w,h)
        surface.SetDrawColor(43, 43, 43,145)
        surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(47, 47, 47,145)
		surface.DrawRect(0, h-3, w, 3)
        
        local titleText = convarName == "zc_language" and L("settings_language", buttonData[3]) or GetOptionTitle(convarName, buttonData[3])
        local helpText = convarName == "zc_language" and L("settings_language_help", convar:GetHelpText()) or GetOptionHelp(convarName, convar:GetHelpText())
        draw.SimpleText(titleText, 'ZCity_setiings_fine', 30, h / 2 -height2/2.5, clr_1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(helpText, 'ZCity_setiings_tiny', 30, h / 2+height2/2, clr_2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if convarType == 'language' then
        local combo = vgui.Create("DComboBox", pppanel)
        combo:SetSize(pppanel:GetWide() / 5, pppanel:GetTall() / 2)
        combo:SetPos(pppanel:GetWide() - combo:GetWide() - 20, pppanel:GetTall() / 2 - combo:GetTall() / 2)

        local languageCodes = {"auto", "en", "ko", "zh", "ru"}
        local languageFallbacks = {auto = "Auto", en = "English", ko = "Korean", zh = "Chinese", ru = "Russian"}

        local function PopulateLanguageChoices()
            if not IsValid(combo) then return end
            combo:Clear()

            local current = convar:GetString()
            local selectedLabel = languageFallbacks[current] or current
            for _, code in ipairs(languageCodes) do
                local label = ZCLang and ZCLang.LanguageName and ZCLang.LanguageName(code) or languageFallbacks[code]
                combo:AddChoice(label, code)
                if code == current then selectedLabel = label end
            end
            combo:SetValue(selectedLabel)
        end

        PopulateLanguageChoices()

        combo.OnSelect = function(_, _, _, data)
            if ZCLang and ZCLang.SetLanguage then
                ZCLang.SetLanguage(data)
            else
                RunConsoleCommand("zc_language", data or "auto")
            end
        end

        -- VGUI panels are not entities and therefore do not have EntIndex().
        -- Keep a clientside serial so every settings panel gets its own hook.
        hg.ZCLangSettingsComboSerial = (hg.ZCLangSettingsComboSerial or 0) + 1
        local languageHook = "ZCLangSettingsCombo_" .. hg.ZCLangSettingsComboSerial
        hook.Add("ZCLangChanged", languageHook, function()
            if not IsValid(combo) then
                hook.Remove("ZCLangChanged", languageHook)
                return
            end

            timer.Simple(0, PopulateLanguageChoices)
        end)

        local oldOnRemove = combo.OnRemove
        combo.OnRemove = function(self)
            hook.Remove("ZCLangChanged", languageHook)
            if oldOnRemove then oldOnRemove(self) end
        end
    elseif convarType == 'bool' then
        local toggle = vgui.Create('DButton', pppanel)
        toggle:SetSize(pppanel:GetWide() / 18, pppanel:GetTall() / 2)

        
        toggle:SetPos(pppanel:GetWide() - toggle:GetWide()*1.4 - pppanel:GetWide() / 20, pppanel:GetTall() / 2 - toggle:GetTall() / 2)
        toggle:SetText('')
        
        local animProgress = convar:GetBool() and 1 or 0
        local targetProgress = animProgress
        
        function toggle:Paint(w, h)
            if animProgress ~= targetProgress then
                animProgress = Lerp(FrameTime() * 8, animProgress, targetProgress)
            end
            
            local bgColor = Color(
                Lerp(animProgress, 180, 80),  
                Lerp(animProgress, 30, 120),  
                Lerp(animProgress, 30, 50)   
            )
            
            local shadowColor = Color(0, 0, 0, Lerp(animProgress, 150, 40))
            surface.SetDrawColor(clr_3)
            draw.RoundedBox(0, 0, 0, w, h, clr_3)
            
            surface.SetDrawColor(clr_5)
            draw.RoundedBox(0, 2, 2, w - 4, h - 4, clr_4)
            
            local slsize = h - 12
            local slPos = Lerp(animProgress, 6, w - slsize - 6)
            surface.SetDrawColor(bgColor)
            draw.RoundedBox(0, slPos, 6, slsize, slsize, bgColor)
            surface.SetDrawColor(shadowColor)
            surface.DrawRect(slPos, slsize+4, slsize, 3)
    
            surface.SetDrawColor(clr_6)
        end
        
        function toggle:DoClick()
            if convar then
                local newValue = not convar:GetBool()
                SetConVarValue(convar, newValue)

                surface.PlaySound('glide/headlights_on.wav')
                targetProgress = newValue and 1 or 0
            end
        end
        
    elseif convarType == 'int' then
        local slider = vgui.Create('DNumSlider', pppanel)
        slider:SetSize(280, 30)
        slider:SetPos(pppanel:GetWide() - 300, pppanel:GetTall() / 2 - 15)
        slider:SetText('')
        
        local min = convar:GetMin() or 0
        local max = convar:GetMax() or 100
        local decimals = buttonData[4] and 2 or 0
        
        slider:SetMin(min)
        slider:SetMax(max)
        slider:SetDecimals(decimals)
        slider:SetValue(decimals > 0 and convar:GetFloat() or convar:GetInt())
        
        function slider:OnValueChanged(val)
            if convar then
                SetConVarValue(convar, decimals > 0 and math.Round(val, decimals) or math.Round(val))
            end
        end
        
        local valueLabel = vgui.Create('DLabel', pppanel)
        valueLabel:SetPos(pppanel:GetWide() - 350, pppanel:GetTall() / 2 - 8)
        valueLabel:SetSize(50, 20)
        valueLabel:SetText(convar:GetInt())
        valueLabel:SetTextColor(clr_7)
        valueLabel:SetFont('ZCity_setiings_tiny')
        
        slider.Think = function()
            if convar then
                valueLabel:SetText(convar:GetInt())
            end
        end
        
    elseif convarType == 'string' then
        local textEntry = vgui.Create('DTextEntry', pppanel)
        textEntry:SetSize(pppanel:GetWide()/8, pppanel:GetTall()/2)
        textEntry:SetPos(pppanel:GetWide()-pppanel:GetWide()/8-20, pppanel:GetTall()/2-textEntry:GetTall()/2)
        textEntry:SetText(convar:GetString())
        textEntry:SetUpdateOnType(true) 
        textEntry:SetFont('ZCity_Tiny')
        
    
        textEntry.Paint = function(self, w, h)
            surface.SetDrawColor(30, 30, 30, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(60, 60, 60, 255)
            surface.DrawOutlinedRect(0, 0, w, h)
            
            self:DrawTextEntryText(color_white, clr_8, color_white)
        end
        
        function textEntry:OnValueChange(val)
            if convar then
                SetConVarValue(convar, val)
            end
        end
    end
    
    return pppanel
end

function hg.DrawSettings(ParentPanel)
    ParentPanel:SetAlpha(0)
    ParentPanel.Paint = function(self,w,h)

        surface.SetDrawColor(28,28,28,255)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(107, 107, 107,20)

        for i = 1, (ybars + 1) do
            surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
        end

        for i = 1, (xbars + 1) do
            surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
        end

        local border_size = ScreenScale(2)

        surface.SetDrawColor(0, 0, 0)
        surface.SetMaterial(gradient_l)
        surface.DrawTexturedRect(0, 0, border_size, sh)
		surface.SetMaterial(blur)
        surface.SetDrawColor(28,28,28,208)
        surface.DrawRect(0, 0, w, h)
    end
    hg.DrawBlur(ParentPanel, 5)
    ParentPanel:AlphaTo(255,0.15,0)
    local pppanel3 = vgui.Create('DScrollPanel', ParentPanel)
    pppanel3:SetSize(ParentPanel:GetWide(), ParentPanel:GetTall())
    pppanel3:SetPos(0,0)
    --pppanel3:SetAlpha(0)
    pppanel3.Paint = function()end
    -- 🥴 <- лучший смайлик

    local yOffset = pppanel3:GetTall()/100

    for categoryName, categoryTable in pairs(hg.settings.tbl) do
        local category = hg.CreateCategory(categoryName, pppanel3, yOffset)
        yOffset = yOffset + category:GetTall() + 12
        for convarName, settingData in pairs(categoryTable) do
            local vbv = hg.CreateButton(settingData,convarName,pppanel3,yOffset)
            if not vbv then continue end
            yOffset = yOffset + (vbv:GetTall()) + 12
        end
    end
    local pppanel23 = vgui.Create('DPanel', pppanel3)
    pppanel23:SetSize(0, 0)
    pppanel23:SetPos(0,yOffset+12)
end
