local MODE = MODE

function MODE:CanLaunch()
	return false
end

function MODE:GiveEquipment()
	timer.Simple(0.1, function()
		for _, ply in player.Iterator() do
			if not ply:Alive() then continue end

			ply:SetSuppressPickupNotices(true)
			ply.noSound = true

			if ply:Team() == 1 then
				ply:SetPlayerClass("swat")
				zb.GiveRole(ply, "Counter Terrorist", Color(0, 0, 190))
				ply:SetNetVar("CurPluv", "pluvberet")
			else
				ply:SetPlayerClass("terrorist")
				zb.GiveRole(ply, "Terrorist", Color(190, 0, 0))
				ply:SetNetVar("CurPluv", "pluvboss")
			end

			ply:Give("weapon_physcannon")
			ply:Give("weapon_hands_sh")
			ply:Give("weapon_bandage_sh")
			ply:Give("weapon_tourniquet")
			ply:SelectWeapon("weapon_physcannon")

			if ply.organism then
				ply.organism.allowholster = true
			end

			timer.Simple(0.1, function()
				if not IsValid(ply) then return end
				ply.noSound = false
				ply:SetSuppressPickupNotices(false)
			end)
		end
	end)
end
