local MODE = MODE

function MODE:RoundStart()
    zb.RemoveFade()
end

function MODE:HUDPaint()
    if zb.ROUND_STATE ~= 1 then return end

    draw.SimpleText("테스트 모드 · 시간 제한 없음", "ZB_InterfaceMedium", ScrW() * 0.5, ScreenScale(12), color_white, TEXT_ALIGN_CENTER)
    draw.SimpleText("잠수 처리 꺼짐 · 관리자 라운드 종료로 진행", "ZB_InterfaceSmall", ScrW() * 0.5, ScreenScale(26), color_white, TEXT_ALIGN_CENTER)

    local ply = LocalPlayer()
    if IsValid(ply) and not ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
        draw.SimpleText("좌클릭으로 부활", "ZB_InterfaceMedium", ScrW() * 0.5, ScreenScale(42), color_white, TEXT_ALIGN_CENTER)
    end
end
