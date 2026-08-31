--
local PANEL = {}

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = hg.DrawBlur

function PANEL:Paint( w, h )

    local text = "맵 변경 투표를 시작할 시간입니다"

	BlurBackground(self)

	surface.SetFont( "ZB_InterfaceMediumLarge" )
	surface.SetTextColor( color_white )
	local lengthX, lengthY = surface.GetTextSize( text )
	surface.SetTextPos( w / 2 - lengthX/2,20 )
	surface.DrawText( text )

	surface.SetDrawColor( 255, 0, 0, 128)
    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )

end

vgui.Register( "ZB_RTVMenu", PANEL, "ZFrame")