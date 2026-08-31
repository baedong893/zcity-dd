if CLIENT then
    local isMenuOpen = nil
    zb.availableModes = zb.availableModes or {}
    local availableModes = zb.availableModes
    
    zb.RoundList = zb.RoundList or {}
    zb.nextround = zb.nextround or nil
    local queuePanelInstance = nil 
    local modeListRefresh = nil
    local selectedModes = {}

    local function IsAdminUser(ply)
        if not IsValid(ply) then return false end
        if ply:IsAdmin() or ply:IsSuperAdmin() then return true end
        local group = ply.GetUserGroup and string.lower(ply:GetUserGroup() or "") or ""
        return group == "admin" or group == "superadmin" or group == "owner"
    end

    local function IsSuperAdminUser(ply)
        if not IsValid(ply) then return false end
        if ply:IsSuperAdmin() then return true end
        local group = ply.GetUserGroup and string.lower(ply:GetUserGroup() or "") or ""
        return group == "superadmin" or group == "owner"
    end

    local function T(key, fallback)
        return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback
    end

    local function ModeName(modeOrKey, fallback)
        local key = istable(modeOrKey) and modeOrKey.key or modeOrKey
        local name = istable(modeOrKey) and modeOrKey.name or fallback
        return ZCLang and ZCLang.ModeName and ZCLang.ModeName(key, name) or (name or key)
    end

    net.Receive("ZB_SendModesInfo", function()
        zb.availableModes = net.ReadTable()

        if modeListRefresh then
            modeListRefresh()
        end
    end)
    
    net.Receive("ZB_SendRoundList", function()
        zb.RoundList = net.ReadTable()
        zb.nextround = net.ReadString()
        table.insert(zb.RoundList, 1, zb.nextround)
        zb.nextround = nil
        if IsValid(queuePanelInstance) then
            queuePanelInstance:QueueUpdate()
        end
    end)
    
    net.Receive("ZB_NotifyRoundListChange", function()
        local playerName = net.ReadString()
        
        chat.AddText(Color(180, 180, 255), playerName, Color(255, 255, 255), " 님이 게임 모드 대기열을 수정했습니다.")
        
        net.Start("ZB_RequestRoundList")
        net.SendToServer()
    end)

    local function StyleElement(element, bgColor)
        bgColor = bgColor or Color(40, 40, 40, 200)
        
        element.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            
            if self:IsHovered() and self.Selectable then
                draw.RoundedBox(6, 1, 1, w-2, h-2, Color(60, 60, 60, 100))
                surface.SetDrawColor(255, 165, 0, 150)
                surface.DrawOutlinedRect(1, 1, w-2, h-2, 1)
            end
            
            if self.Selected then
                surface.SetDrawColor(0, 255, 0, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
        end
    end
    
    local function CreateModeItem(parent, mode, queue, index)
        local modePanel = vgui.Create("DPanel", parent)
        modePanel:SetTall(40)
        modePanel:Dock(TOP)
        modePanel:DockMargin(5, 2, 5, 2)
        modePanel.Mode = mode
        modePanel.Index = index 
        modePanel.Selectable = true
        modePanel.Selected = selectedModes[mode.key] or false
        
        StyleElement(modePanel, Color(50, 50, 50, 200))
        
        local title = vgui.Create("DLabel", modePanel)
        title:SetFont("DermaDefaultBold")
        title:SetText(ModeName(mode))
        title:SetTextColor(Color(255, 255, 255))
        title:Dock(LEFT)
        title:DockMargin(10, 0, 0, 0)
        title:SizeToContents()
        
        if queue then
            local posLabel = vgui.Create("DLabel", modePanel)
            posLabel:SetFont("DermaDefault")
            posLabel:SetText("#" .. index)
            posLabel:SetTextColor(Color(180, 180, 180))
            posLabel:Dock(LEFT)
            posLabel:DockMargin(5, 0, 0, 0)
            posLabel:SizeToContents()
            
            local upBtn = vgui.Create("DButton", modePanel)
            upBtn:SetSize(24, 24)
            upBtn:Dock(RIGHT)
            upBtn:DockMargin(2, 8, 5, 8)
            upBtn:SetText("↑")
            upBtn.DoClick = function()
                if index > 1 then
                    local item = table.remove(zb.RoundList, index)
                    table.insert(zb.RoundList, index - 1, item)
                    queue:QueueUpdate()
                    
                    /*net.Start("ZB_UpdateRoundList")
                        net.WriteTable(zb.RoundList)
                        net.WriteBool(false) 
                    net.SendToServer()*/
                end
            end
            
            local downBtn = vgui.Create("DButton", modePanel)
            downBtn:SetSize(24, 24)
            downBtn:Dock(RIGHT)
            downBtn:DockMargin(2, 8, 2, 8)
            downBtn:SetText("↓")
            downBtn.DoClick = function()
                if index < #zb.RoundList then
                    local item = table.remove(zb.RoundList, index)
                    table.insert(zb.RoundList, index + 1, item)
                    queue:QueueUpdate()
                    
                    /*net.Start("ZB_UpdateRoundList")
                        net.WriteTable(zb.RoundList)
                        net.WriteBool(false)
                    net.SendToServer()*/
                end
            end
            
            local removeBtn = vgui.Create("DButton", modePanel)
            removeBtn:SetSize(24, 24)
            removeBtn:Dock(RIGHT)
            removeBtn:DockMargin(2, 8, 2, 8)
            removeBtn:SetText("X")
            removeBtn.DoClick = function()
                table.remove(zb.RoundList, index)
                queue:QueueUpdate()

                /*net.Start("ZB_UpdateRoundList")
                    net.WriteTable(zb.RoundList)
                    net.WriteBool(false)
                net.SendToServer()*/
            end
        else

            modePanel.OnMousePressed = function()
                modePanel.Selected = not modePanel.Selected
                selectedModes[mode.key] = modePanel.Selected
                
                if modePanel.Selected then
                    surface.PlaySound("buttons/button9.wav")
                else
                    surface.PlaySound("buttons/button17.wav")
                end
            end
        end
        
        return modePanel
    end
    
    local function CreateQueuePanel(frame)
        local queuePanel = vgui.Create("DPanel", frame)
        queuePanel:SetSize(frame:GetWide() / 2 - 10, frame:GetTall())
        queuePanel:Dock(RIGHT)
        queuePanel:DockMargin(5, 5, 5, 5)
        StyleElement(queuePanel, Color(30, 30, 30, 200))
        
        queuePanelInstance = queuePanel
        
        local titleLabel = vgui.Create("DLabel", queuePanel)
        titleLabel:SetText(T("mode_menu_queue", "게임 모드 대기열"))
        titleLabel:SetFont("DermaLarge")
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(0, 5, 0, 5)
        titleLabel:SetContentAlignment(5) 
        
        local queueScroll = vgui.Create("DScrollPanel", queuePanel)
        queueScroll:Dock(FILL)
        queueScroll:DockMargin(5, 5, 5, 5)
        
        local saveBtn = vgui.Create("DButton", queuePanel)
        saveBtn:SetText(T("mode_menu_apply_queue", "대기열 적용하기"))
        saveBtn:Dock(BOTTOM)
        saveBtn:DockMargin(5, 5, 5, 5)
        saveBtn:SetTall(30)
        saveBtn.DoClick = function()
            //if #zb.RoundList > 0 then
                local tbl = table.Copy(zb.RoundList)
                //table.insert(tbl, 1, zb.nextround)
                net.Start("ZB_UpdateRoundList")
                    net.WriteTable(tbl)
                    net.WriteBool(true)
                net.SendToServer()
                
                chat.AddText(Color(0, 255, 0), "게임 모드 대기열을 적용했습니다.")
            //else
                //chat.AddText(Color(255, 0, 0), "게임 모드 대기열이 비어 있습니다!")
            //end
        end
        
        local clearBtn = vgui.Create("DButton", queuePanel)
        clearBtn:SetText(T("mode_menu_clear_queue", "대기열 초기화"))
        clearBtn:Dock(BOTTOM)
        clearBtn:DockMargin(5, 5, 5, 5)
        clearBtn:SetTall(30)
        clearBtn.DoClick = function()
            zb.RoundList = {}
            queuePanel:QueueUpdate()
            
            /*net.Start("ZB_UpdateRoundList")
                net.WriteTable({})
                net.WriteBool(false)
            net.SendToServer()*/
            
            chat.AddText(Color(255, 165, 0), "게임 모드 대기열을 초기화했습니다.")
        end
        
        function queuePanel:QueueUpdate()
            queueScroll:Clear()
            
            if zb.nextround and zb.nextround ~= "" then
                local nextRoundLabel = vgui.Create("DLabel", queueScroll)
                nextRoundLabel:SetText(T("mode_menu_next_prefix", "다음 모드: ") .. ModeName(zb.nextround, zb.nextround))
                nextRoundLabel:SetFont("DermaDefaultBold")
                nextRoundLabel:Dock(TOP)
                nextRoundLabel:DockMargin(5, 0, 0, 10)
                nextRoundLabel:SizeToContents()
            end
            
            for idx, modeKey in ipairs(zb.RoundList) do
                local mode = nil
                
                for _, availableMode in ipairs(zb.availableModes) do
                    if availableMode.key == modeKey then
                        mode = availableMode
                        break
                    end
                end
                
                if not mode then
                    mode = {key = modeKey, name = modeKey}
                end
                
                CreateModeItem(queueScroll, mode, queuePanel, idx)
            end
        end
        
        queuePanel:QueueUpdate()
        return queuePanel
    end

    local function OpenModeSelection(command)
        local frame = vgui.Create("ZFrame")
        frame:SetSize(700, 500)
        frame:Center()
        frame:SetTitle(T("mode_menu_admin", "게임 모드 관리자"))
        frame:MakePopup()
        
        selectedModes = {}
        
        local queuePanel = CreateQueuePanel(frame)
        
        local leftPanel = vgui.Create("DPanel", frame)
        leftPanel:SetSize(frame:GetWide() / 2 - 10, frame:GetTall())
        leftPanel:Dock(LEFT)
        leftPanel:DockMargin(5, 5, 5, 5)
        StyleElement(leftPanel, Color(30, 30, 30, 200))
        
        local titleLabel = vgui.Create("DLabel", leftPanel)
        titleLabel:SetText(T("mode_menu_available", "선택 가능한 게임 모드"))
        titleLabel:SetFont("DermaLarge")
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(0, 5, 0, 5)
        titleLabel:SetContentAlignment(5) 
        
        local searchBar = vgui.Create("DTextEntry", leftPanel)
        searchBar:SetPlaceholderText(T("mode_menu_search", "게임 모드 검색..."))
        searchBar:Dock(TOP)
        searchBar:DockMargin(5, 5, 5, 5)
        searchBar:SetTall(25)
        
        local dscroll = vgui.Create("DScrollPanel", leftPanel)
        dscroll:Dock(FILL)
        dscroll:DockMargin(5, 5, 5, 5)
        
        local modeItems = {}
        
        local function UpdateSearch(filter)
            filter = filter:lower()
            
            for _, item in ipairs(modeItems) do
                local visible = filter == "" or string.find(tostring(item.Mode.name or ""):lower(), filter, 1, true) or string.find(string.lower(ModeName(item.Mode)), filter, 1, true)
                item:SetVisible(visible)
            end
            
            dscroll:InvalidateLayout()
        end
        
        searchBar.OnChange = function(self)
            UpdateSearch(self:GetValue())
        end
        
        local allowedModes = {
            ["tdm"] = true,
            ["cstrike"] = true,
            ["cszombie"] = true,
            ["infinitystone"] = true,
            ["harrypotter"] = true,
            ["medusa"] = true,
			["homelander"] = true,
			["quarantinefailure"] = true,
            ["hmcd"] = true,
            ["gravtdm"] = true,
            ["hl2dm"] = true,
            ["riot"] = true,
            ["gwars"] = true,
            ["criresp"] = true,
        }
        
        local function PopulateModeItems()
            dscroll:Clear()
            modeItems = {}

			for i, mode in SortedPairsByMemberValue(zb.availableModes,"canlaunch",true) do
				if !IsSuperAdminUser(LocalPlayer()) and !mode.menuVisible and !allowedModes[mode.key] then continue end
                
                local modeBtn = CreateModeItem(dscroll, mode)
                table.insert(modeItems, modeBtn)
                
                modeBtn:SetCursor("hand")
                modeBtn:SetTooltip("Click to select/unselect mode")
                
                local inQueue = false
                for _, queuedModeKey in ipairs(zb.RoundList) do
                    if queuedModeKey == mode.key then
                        inQueue = true
                        break
                    end
                end

                local indicator = vgui.Create("DPanel", modeBtn)
                indicator:SetSize(16, 7)
                indicator:SetPos(8, 4)
                indicator.IndiColor = Color(0, 0, 0, 0)
                indicator.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, indicator.IndiColor)
                end

                if mode.canlaunch == 1 then
                    indicator.IndiColor = Color(0,255,34)
                    indicator:SetTooltip("이 모드를 실행할 수 있습니다")
                end

                if inQueue then
                    indicator.IndiColor = Color(255, 155, 0, 255)
                    indicator:SetTooltip("이 모드가 이미 대기열에 있습니다")
                end
         
                if mode.canlaunch == 0 then
                    indicator.IndiColor = Color(255,0,0,255)
                    indicator:SetTooltip("이 모드를 실행할 수 없습니다")
                end
                
                if command == "setmode" or command == "setforcemode" then
                    local selectBtn = vgui.Create("DButton", modeBtn)
                    selectBtn:SetSize(80, 26)
                    selectBtn:Dock(RIGHT)
                    selectBtn:DockMargin(5, 7, 5, 7)
                    selectBtn:SetText(T("mode_menu_select", "Select"))
                    selectBtn.DoClick = function()
                        net.Start("AdminSetGameMode")
                        net.WriteString(command)
                        net.WriteString(mode.key)
                        net.WriteBool(false) 
                        net.SendToServer()
                        frame:Close()
                    end
                end
            end

            UpdateSearch(searchBar:GetValue())
        end

        modeListRefresh = function()
            if not IsValid(frame) then
                modeListRefresh = nil
                return
            end

            PopulateModeItems()
        end

        PopulateModeItems()
        

        local batchPanel = vgui.Create("DPanel", leftPanel)
        batchPanel:Dock(BOTTOM)
        batchPanel:DockMargin(5, 5, 5, 5)
        batchPanel:SetTall(80)
        StyleElement(batchPanel, Color(40, 40, 40, 200))
        
        local batchTitle = vgui.Create("DLabel", batchPanel)
        batchTitle:SetText(T("mode_menu_batch", "일괄 작업"))
        batchTitle:SetFont("DermaDefaultBold")
        batchTitle:SetTextColor(Color(255, 255, 255))
        batchTitle:Dock(TOP)
        batchTitle:DockMargin(0, 5, 0, 5)
        batchTitle:SetContentAlignment(5)
        
        local addToQueueBtn = vgui.Create("DButton", batchPanel)
        addToQueueBtn:SetText(T("mode_menu_add_front", "선택 항목을 대기열 맨 앞에 추가"))
        addToQueueBtn:Dock(TOP)
        addToQueueBtn:DockMargin(5, 0, 5, 5)
        addToQueueBtn:SetTall(26)
        addToQueueBtn.DoClick = function()
            local selectedCount = 0
            
            local selectedKeys = {}
            for key, selected in pairs(selectedModes) do
                if selected then
                    table.insert(selectedKeys, 1, key) 
                    selectedCount = selectedCount + 1
                end
            end
            
            for i = 1, #selectedKeys do
                table.insert(zb.RoundList, 1, selectedKeys[i])
            end
            
            if selectedCount > 0 then
                queuePanel:QueueUpdate()
                
                /*net.Start("ZB_UpdateRoundList")
                    net.WriteTable(zb.RoundList)
                    net.WriteBool(false)
                net.SendToServer()*/
                
                chat.AddText(Color(0, 255, 0), "대기열 맨 앞에 " .. selectedCount .. "개의 모드를 추가했습니다!")
                
                selectedModes = {}
                for _, item in ipairs(modeItems) do
                    item.Selected = false
                end
            else
                chat.AddText(Color(255, 0, 0), "선택한 모드가 없습니다!")
            end
        end
        
        local addToEndBtn = vgui.Create("DButton", batchPanel)
        addToEndBtn:SetText(T("mode_menu_add_back", "선택 항목을 대기열 맨 뒤에 추가"))
        addToEndBtn:Dock(TOP)
        addToEndBtn:DockMargin(5, 0, 5, 0)
        addToEndBtn:SetTall(26)
        addToEndBtn.DoClick = function()
            local selectedCount = 0
            
            for key, selected in pairs(selectedModes) do
                if selected then
                    table.insert(zb.RoundList, key)
                    selectedCount = selectedCount + 1
                end
            end
            
            if selectedCount > 0 then
                queuePanel:QueueUpdate()
                
                /*net.Start("ZB_UpdateRoundList")
                    net.WriteTable(zb.RoundList)
                    net.WriteBool(false)
                net.SendToServer()*/
                
                chat.AddText(Color(0, 255, 0), "대기열 맨 뒤에 " .. selectedCount .. "개의 모드를 추가했습니다!")
                

                selectedModes = {}
                for _, item in ipairs(modeItems) do
                    item.Selected = false
                end
            else
                chat.AddText(Color(255, 0, 0), "선택한 모드가 없습니다!")
            end
        end
        
        local refreshBtn = vgui.Create("DButton", leftPanel)
        refreshBtn:SetText(T("mode_menu_refresh", "데이터 새로고침"))
        refreshBtn:Dock(BOTTOM)
        refreshBtn:DockMargin(5, 5, 5, 5)
        refreshBtn:SetTall(30)
        refreshBtn.DoClick = function()
            net.Start("ZB_RequestRoundList")
            net.SendToServer()
        end
        
        timer.Create("QueueAutoRefresh", 5, 0, function()
            if IsValid(frame) then
                //net.Start("ZB_RequestRoundList")
                //net.SendToServer()
            else
                timer.Remove("QueueAutoRefresh")
            end
        end)
        
        frame.OnClose = function()
            timer.Remove("QueueAutoRefresh")
            queuePanelInstance = nil
            modeListRefresh = nil
        end
        
        net.Start("ZB_RequestRoundList")
        net.SendToServer()
    end

    local f7SpawnMenuOpen = false
    local nextF7SpawnMenuToggle = 0

    local function IsQSpawnMenuVisible()
        return IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible()
    end

    local function CloseQSpawnMenu()
        RunConsoleCommand("-menu")

        if spawnmenu and spawnmenu.Close then
            spawnmenu.Close()
        elseif IsValid(g_SpawnMenu) then
            g_SpawnMenu:Close()
        end

        f7SpawnMenuOpen = false
    end

    local function OpenQSpawnMenu()
        if f7SpawnMenuOpen or IsQSpawnMenuVisible() then
            CloseQSpawnMenu()
            return
        end

        f7SpawnMenuOpen = true
        RunConsoleCommand("+menu")

        timer.Simple(0, function()
            if not f7SpawnMenuOpen then return end
            if spawnmenu and spawnmenu.Open then
                spawnmenu.Open()
            end
        end)
    end

    concommand.Add("zc_toggle_spawnmenu", function()
        if not IsSuperAdminUser(LocalPlayer()) then return end
        if CurTime() < nextF7SpawnMenuToggle then return end

        nextF7SpawnMenuToggle = CurTime() + 0.3
        OpenQSpawnMenu()
    end)

    local function OpenAdminMenu()
        if IsValid(isMenuOpen) then return end

        isMenuOpen = vgui.Create("ZFrame")
        local frame = isMenuOpen
        frame:SetSize(300, 210)
        frame:Center()
        frame:SetTitle(T("mode_menu_admin", "관리자 메뉴"))
        frame:MakePopup()

        local setModeBtn = vgui.Create("DButton", frame)
        setModeBtn:SetText(T("mode_menu_set_next", "다음 모드 설정"))
        setModeBtn:Dock(TOP)
        setModeBtn:DockMargin(5, 10, 5, 2)
        setModeBtn:SetSize(300, 40)
        StyleElement(setModeBtn)
        setModeBtn.DoClick = function()
            OpenModeSelection("setmode") 
        end

        local setForceModeBtn = vgui.Create("DButton", frame)
        setForceModeBtn:SetText(T("mode_menu_force_next", "다음 모드 강제 설정"))
        setForceModeBtn:Dock(TOP)
        setForceModeBtn:DockMargin(5, 2, 5, 2)
        setForceModeBtn:SetSize(300, 40)
        StyleElement(setForceModeBtn)
        setForceModeBtn.DoClick = function()
            OpenModeSelection("setforcemode")
        end
        
        local queueModeBtn = vgui.Create("DButton", frame)
        queueModeBtn:SetText(T("mode_menu_manage_queue", "게임 모드 대기열 관리"))
        queueModeBtn:Dock(TOP)
        queueModeBtn:DockMargin(5, 2, 5, 2)
        queueModeBtn:SetSize(300, 40)
        StyleElement(queueModeBtn)
        queueModeBtn.DoClick = function()
            OpenModeSelection("queue")
        end

        local endRoundBtn = vgui.Create("DButton", frame)
        endRoundBtn:SetText(T("mode_menu_end_round", "라운드 종료"))
        endRoundBtn:Dock(TOP)
        endRoundBtn:DockMargin(5, 2, 5, 2)
        endRoundBtn:SetSize(300, 40)
        StyleElement(endRoundBtn)
        endRoundBtn.DoClick = function()
			net.Start("AdminEndRound")
			net.SendToServer()
			frame:Close()
        end

        frame.OnClose = function()
            isMenuOpen = false
        end
        frame:InvalidateLayout(true)
        frame:SizeToChildren(false, true)
    end
    

    hook.Add("InitPostEntity", "RequestModeData", function()
        if IsAdminUser(LocalPlayer()) then
            timer.Simple(2, function()
                net.Start("ZB_RequestRoundList")
                net.SendToServer()
            end)
        end
    end)

    local f6Key = KEY_F6
    local f7Key = KEY_F7
    local f8Key = KEY_F8

    hook.Add("PlayerButtonDown", "OpenAdminMenuF6", function(ply, key)
        if key == f6Key and IsAdminUser(LocalPlayer()) and not IsValid(isMenuOpen) then
            OpenAdminMenu()
        end
    end)

    hook.Add("PlayerButtonDown", "OpenSpawnMenuF7", function(ply, key)
        if CurTime() < nextF7SpawnMenuToggle then return end
        if key == f7Key and IsSuperAdminUser(LocalPlayer()) then
            nextF7SpawnMenuToggle = CurTime() + 0.3
            OpenQSpawnMenu()
        end
    end)

    hook.Add("PlayerButtonDown", "OpenSpawnMenuF8", function(ply, key)
        if CurTime() < nextF7SpawnMenuToggle then return end
        if key == f8Key and IsSuperAdminUser(LocalPlayer()) then
            nextF7SpawnMenuToggle = CurTime() + 0.3
            RunConsoleCommand("zc_toggle_spawnpoint_editor")
        end
    end)

    hook.Add("SpawnMenuClose", "TrackSpawnMenuF7Close", function()
        f7SpawnMenuOpen = false
    end)
end
