ENT.Type 			= "anim"
ENT.Base 			= "base_anim"


function ENT:Cure(plyr)
	if (plyr != nil && plyr != NULL && plyr != null) then
	
		if (plyr:IsPlayer()) then
			if (timer.Exists("InfectionTimer"..plyr:GetName().."")) then
				timer.Destroy("InfectionTimer"..plyr:GetName().."")
				plyr:PrintMessage( HUD_PRINTTALK, "YOU HAVE BEEN CURED!" )
			end
			
			if (timer.Exists("ShakeTimer"..plyr:GetName().."")) then
				timer.Destroy("ShakeTimer"..plyr:GetName().."")
			end
			
			if (InfectConfig.PZ && plyr:GetActiveWeapon():IsValid() && plyr:GetActiveWeapon():GetClass() == "weapon_zombie") then
				local pos = plyr:GetPos()
				plyr:Spawn()
				plyr:StripWeapons()
				plyr:Give("weapon_crowbar")
				--plyr:EmitSound("npc/zombie/zo_attack"..math.random(1,2)..".wav")
				--plyr:SetModel("models/player/zombie_classic.mdl")
				plyr:SetPos(pos)
				plyr:SelectWeapon("weapon_crowbar")
				plyr:SetHealth(100)
				plyr:PrintMessage( HUD_PRINTTALK, "YOU ARE NOW A HUMAN!")
			end
		end
		
	end
end




