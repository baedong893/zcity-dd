COMMANDS.sendtospawn = {
	function(ply, args)
		if not ply:IsAdmin() then return end
		local plya = #args > 0 and args[1] or ply:Name()
		for i, ply2 in pairs(player.GetListByName(plya)) do
			if ply2:Alive() then
				ply2:Spawn()
				ply:ChatPrint( ply2:Name() .. " | 무작위 스폰 지점으로 이동시켰습니다..." )
			end
		end
	end,
	0
}

COMMANDS.give = {
	function(ply, args)
		if not ply:IsAdmin() then return end
		local plya = #args > 1 and args[1] or ply:Name()
		local wep = #args > 1 and args[2] or args[1]
		for i, ply2 in pairs(player.GetListByName(plya)) do
			if ply2:Alive() then
				local ent = ply2:Give( wep )
                if not IsValid(ent) then return end

                ent:Use(ply2)
				ply:ChatPrint( ply2:Name() .. " | 무기를 지급했습니다" )
			end
		end
	end,
	0
}

COMMANDS.respawn = {
	function(ply, args)
		if not ply:IsAdmin() then return end
		local plya = #args > 0 and args[1] or ply:Name()
		for i, ply2 in pairs(player.GetListByName(plya)) do
			ply2:Spawn()
            ApplyAppearance( ply2 )
			local hands = ply2:Give("weapon_hands_sh")
			ply2:SelectWeapon(hands)

			ply:ChatPrint( ply2:Name() .. " | 리스폰되었습니다" )
		end
	end,
	0
}