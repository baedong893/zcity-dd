
local MODE = MODE

MODE.MapSize = 7500
MODE.ZoneTimeToShrink = 120

function MODE.GetZoneRadius()
	if !zonedistance or !isnumber(zonedistance) then return 0xFFFFFFFF /*UUUUUUUUUUUUUUUUUCK*/ end
	local dist = zonedistance + 2048
	
	return (dist * math.max(((zb.ROUND_START + MODE.ZoneTimeToShrink) - CurTime()) / MODE.ZoneTimeToShrink, 0.025))
end

function MODE:HG_MovementCalc_2( mul, ply, cmd, mv )
    if (zb.ROUND_START or 0) + 20 > CurTime() and cmd then 
        cmd:RemoveKey(IN_ATTACK)
        cmd:RemoveKey(IN_ATTACK2)
        if mv then
            mv:RemoveKey(IN_ATTACK)
            mv:RemoveKey(IN_ATTACK2)
        end

        -- 시작 유예시간에는 공격만 막는다. 무기를 손으로 강제 전환하면
        -- DM을 상속한 모드에서도 선택한 총/도구를 들 수 없다.
    end
end

function MODE:PlayerCanLegAttack( ply )
	if (zb.ROUND_START or 0) + 20 > CurTime() then
		return false
	end
end
