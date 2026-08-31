--

local modes = {}
modes.slider = function(optiondata, panel)
    -- optiondata = {convar = "convarname",desc = "descreption", min = 123, max = 123}
    local DermaNumSlider = vgui.Create( "DNumSlider", panel )
    DermaNumSlider:Dock( TOP )
    DermaNumSlider:DockMargin(10,5,5,2.5)	
    DermaNumSlider:SetSize(50,45)	
    DermaNumSlider:SetText( optiondata.convar .. "\n" .. optiondata.desc )	
    DermaNumSlider:SetMin( optiondata.min )				 	
    DermaNumSlider:SetMax( optiondata.max )				
    DermaNumSlider:SetDecimals( optiondata.decimals or 0 )				
    DermaNumSlider:SetConVar( optiondata.convar )	
    DermaNumSlider:SizeToContents()
end
modes.switcher = function(optiondata, panel)
    -- optiondata = {convar = "convarname",desc = "descreption"}
    local DermaCheckbox = panel:Add( "DCheckBoxLabel" )
	DermaCheckbox:Dock( TOP )
    DermaCheckbox:DockMargin(10,5,10,2.5)
	DermaCheckbox:SetText( optiondata.convar .. "\n" .. optiondata.desc )
	DermaCheckbox:SetConVar( optiondata.convar )
	DermaCheckbox:SetValue( GetConVar(optiondata.convar):GetBool() )
	DermaCheckbox:SizeToContents()		
end
modes.binder = function(optiondata, panel)
    -- optiondata = {convar = "convarname",desc = "descreption"}
end

local options = {}

-- optiondata = {desc = "descreption", and mode vars}
function hg.AddOptionPanel( convarname, mode, optiondata, category )
    optiondata = optiondata or {}
    category = category or "other"
    optiondata.convar = convarname

    options[category] = options[category] or {}

    options[category][convarname] = {mode, optiondata}
end

hg.AddOptionPanel( "hg_potatopc", "switcher", {desc = "저사양 모드를 활성화합니다. 성능이 낮은 PC에서 사용하세요."}, "optimization" )
hg.AddOptionPanel( "hg_dynamic_mags", "switcher", {desc = "가변형 잔탄수 HUD(Floating Ammo HUD) 기능을 활성화합니다."}, "other" )
hg.AddOptionPanel( "hg_anims_draw_distance", "slider", {desc = "애니메이션 렌더링 거리를 변경합니다.\nFPS 향상에 도움이 됩니다. | 0 - 무제한",min = 0,max = 4096}, "optimization" )
hg.AddOptionPanel( "hg_attachment_draw_distance", "slider", {desc = "부착물 렌더링 거리를 변경합니다.\nFPS 향상에 도움이 됩니다. | 0 - 무제한",min = 0,max = 4096}, "optimization" )
hg.AddOptionPanel( "hg_old_notificate", "switcher", {desc = "이전 방식의 데미지 알림(채팅창 출력)을 활성화합니다.",min = 0,max = 4096}, "other" )
hg.AddOptionPanel( "hg_weaponshotblur_enable", "switcher", {desc = "사격 시 화면 흐림(Blur) 효과를 활성화합니다.",min = 0,max = 4096}, "other" )
hg.AddOptionPanel( "hg_weaponshotblur_mul", "slider", {desc = "사격 시 발생하는 화면 흐림 효과의 강도를 조절합니다.",min = 0,max = 1,decimals = 3}, "other" )
hg.AddOptionPanel( "hg_maxsmoketrails", "slider", {desc = "연기 잔상 효과의 최대 개수를 설정합니다. (10개 이상 시 렉 발생 가능)",min = 0,max = 30,decimals = 0}, "optimization" )
hg.AddOptionPanel( "hg_optimise_scopes", "slider", {desc = "조준 시 프레임 드랍이 심할 경우 사용하세요. (1 - 주변 프롭 품질 저하, 2 - 메인 렌더링 비활성화)",min = 0,max = 2,decimals = 0}, "optimization" )

local red = Color(75,25,25)
local redselected = Color(150,0,0)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0
BlurBackground = BlurBackground or hg.DrawBlur

local function CreateOptionsMenu()
    local sizeX,sizeY = ScrW() / 3.2 ,ScrH() / 2.2
	local posX,posY = ScrW() / 2 - sizeX / 2,ScrH() / 2 - sizeY / 2

    local MainFrame = vgui.Create("ZFrame") -- The name of the panel we don't have to parent it.
    MainFrame:SetPos( posX, posY ) -- Set the position to 100x by 100y. 
    MainFrame:SetSize( sizeX, sizeY ) -- Set the size to 300x by 200y.
    MainFrame:SetTitle( "ZCity 옵션" ) -- Set the title in the top left to "Derma Frame".
    MainFrame:MakePopup() -- Makes your mouse be able to move around.
    //function MainFrame:Paint( w, h )
    //    draw.RoundedBox( 0, 2.5, 2.5, w-5, h-5, Color( 0, 0, 0, 140) )
    //    BlurBackground(MainFrame)
    //    surface.SetDrawColor( 255, 0, 0, 128)
    //    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
    //end

    local DScrollPanel = vgui.Create("DScrollPanel", MainFrame)
	DScrollPanel:SetPos(10, 50)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 60)
	--function DScrollPanel:Paint( w, h )
	--	BlurBackground(self)
--
	--	surface.SetDrawColor( 255, 0, 0, 128)
    --    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	--end

    local DLabel = vgui.Create( "DLabel", DScrollPanel )
    DLabel:Dock(TOP)
    DLabel:DockMargin(20,5,5,2.5)
    DLabel:SetText( "Optimization" )

    for k,v in pairs(options["optimization"]) do
       
        modes[v[1]](v[2],DScrollPanel)
    end
    
    local DLabel = vgui.Create( "DLabel", DScrollPanel )
    DLabel:Dock(TOP)
    DLabel:DockMargin(20,15,5,2.5)
    DLabel:SetText( "Other" )

    for k,v in pairs(options["other"]) do
       
        modes[v[1]](v[2],DScrollPanel)
    end
end

if concommand.GetTable()["hg_options"] then return end
options_old = {}

concommand.Add("hg_options",function()
    CreateOptionsMenu()
end)