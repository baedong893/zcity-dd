local currentRTVMenu = nil
-- Values
local maps = {}
local time = 0
local votes = {}
local winmap = ""
local rtvStarted = false
local rtvEnded = false
local currentRTVMenu = nil

local VoteCD = 0

-- RTV CL Functions
local BlurBackground = hg.BlurBackground
local fallbackMapIcon = Material("icon64/tool.png")

local function GetMapIconMaterial(path)
    local mat = Material(path)
    if not mat or mat:IsError() then
        return fallbackMapIcon
    end

    return mat
end

local function PrettyMapName(mapName)
    if not isstring(mapName) or mapName == "" then return "알 수 없는 맵" end

    local parts = string.Explode("_", mapName)
    if #parts > 1 and string.len(parts[1]) <= 4 then
        table.remove(parts, 1)
    end

    if #parts <= 0 or not parts[1] or parts[1] == "" then
        return mapName
    end

    parts[1] = string.upper(string.Left(parts[1], 1)) .. string.sub(parts[1], 2)
    return table.concat(parts, " ")
end

function zb.RTVMenu()
    system.FlashWindow()

    if IsValid(currentRTVMenu) then
        currentRTVMenu:Remove()
    end

    local RTVMenu = vgui.Create("ZB_RTVMenu")
    currentRTVMenu = RTVMenu
    RTVMenu:SetSize(ScrW() / 2.0, ScrH() / 1.05)
    RTVMenu:Center()
    RTVMenu:SetTitle("")
    RTVMenu:SetBackgroundBlur(true)
    RTVMenu:ShowCloseButton(false)
    RTVMenu:SetDraggable(false)
    RTVMenu:MakePopup()
    RTVMenu:SetKeyboardInputEnabled(false)

    local MAPSPanel = vgui.Create("DPanel", RTVMenu)
    MAPSPanel:Dock(FILL)
    MAPSPanel:DockMargin(5, ScrH() * 0.04, 5, ScrH() * 0.01)
    function MAPSPanel.Paint() end

    for k, v in ipairs(maps) do
        if not isstring(v) or v == "" then continue end

        local MapButton = vgui.Create("ZB_RTVButton", MAPSPanel)
        MapButton:Dock(TOP)
        MapButton:DockMargin(0, 5, 0, 0)
        MapButton:SetSize(0, ScrH() * 0.06)
        
        if v == "random" then
            MapButton:SetText("랜덤 맵")
            MapButton.Map = "random"
            MapButton.MapIcon = GetMapIconMaterial("icon64/random.png")
        else
            if v == game.GetMap() then
                MapButton:SetText("기존맵을 더하자")
            else
                MapButton:SetText(PrettyMapName(v))
            end
            MapButton.Map = v
            MapButton.MapIcon = GetMapIconMaterial("maps/thumb/" .. MapButton.Map .. ".png")
        end

        function MapButton:Think()
            self.Votes = votes[self.Map] or 0
            if self.Map ~= "random" and self.Map == winmap then 
                self.Win = true 
            else 
                self.Win = false 
            end
        end

        function MapButton:DoClick()
            if VoteCD > CurTime() then return end
            net.Start("ZB_RockTheVote_vote")
                net.WriteString(self.Map)
            net.SendToServer()
            VoteCD = CurTime() + 1

            if IsValid(RTVMenu.ExitButton) then
                RTVMenu.ExitButton:SetVisible(true)
                RTVMenu.ExitButton:SetEnabled(true)
            end
        end
    end

    local button = vgui.Create("DButton", RTVMenu)
    RTVMenu.ExitButton = button
    button:SetPos(ScrW() / 2.0 - ScreenScale(25), ScreenScale(5))
    button:SetSize(ScreenScale(20), ScreenScale(10))
    button:SetText("")
    button:SetVisible(false)
    button:SetEnabled(false)

    function button:Paint(w, h)
        BlurBackground(self)

        surface.SetDrawColor(255, 0, 0, 128)
        surface.DrawOutlinedRect(0, 0, w, h, 2.5)

        local x, y = w / 2, h / 2
        local txt = "Exit"
        surface.SetFont("HomigradFont")
        surface.SetTextColor(255, 255, 255, 255)
        local tw, th = surface.GetTextSize(txt)
        surface.SetTextPos(x - tw / 2, y - th / 2)
        surface.DrawText(txt)
    end

    function button:DoClick()
        if IsValid(RTVMenu) then
            RTVMenu:Remove()
        end
    end
end

function zb.StartRTV()
    maps = net.ReadTable()
    time = net.ReadFloat()
    zb.RTVMenu()
    rtvStarted = true
end

net.Receive("RTVMenu", function()
    zb.RTVMenu()
end)

function zb.RTVregVote()
    votes = net.ReadTable()
end

function zb.EndRTV()
    winmap = net.ReadString()
    rtvEnded = true
    rtvStarted = false

    votes = {}

    if IsValid(currentRTVMenu) then
        currentRTVMenu:Remove()
        currentRTVMenu = nil
    end
end

-- NETWORKING

net.Receive("ZB_RockTheVote_start", zb.StartRTV)
net.Receive("ZB_RockTheVote_voteCLreg", zb.RTVregVote)
net.Receive("ZB_RockTheVote_end", zb.EndRTV)
