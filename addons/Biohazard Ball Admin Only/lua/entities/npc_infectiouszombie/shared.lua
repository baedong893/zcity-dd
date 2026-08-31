
ENT.PrintName		= "Infectious Zombie"
ENT.Author			= "jmoak3"
ENT.Information		= "Zombie that makes more zombies"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false
ENT.Base				= "base_nextbot"

function ENT:OnRemove()
end

function ENT:PhysicsCollide( data, physobj )
end

function ENT:PhysicsUpdate( physobj )
end

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:Infect(plyr)
	if (plyr != nil && plyr != NULL && plyr != null && SERVER) then
	
		if (plyr:IsPlayer() && plyr:IsValid() && !(plyr:GetActiveWeapon():IsValid() && plyr:GetActiveWeapon():GetClass() == "weapon_zombie")) then
				if (!timer.Exists("InfectionTimer"..plyr:GetName().."")) then
					timer.Create("InfectionTimer"..plyr:GetName().."", math.random(InfectConfig.InfectTimeMin, InfectConfig.InfectTimeMax), 1, 
					function()
						if (plyr:Alive() && plyr:GetActiveWeapon():IsValid() && plyr:GetActiveWeapon():GetClass() != "weapon_zombie") then
							if (InfectConfig.PZ) then
								local pos = plyr:GetPos()
								plyr:Spawn()
								plyr:EmitSound("npc/zombie/zo_attack"..math.random(1,2)..".wav")
								plyr:SetModel("models/player/zombie_classic.mdl")
								plyr:SetPos(pos)
								timer.Create("GiveWepTimer"..math.random(1,999), 0, 1, 
									function() 
										if (plyr:IsValid()) then 
											plyr:StripWeapons()
											plyr:Give("weapon_zombie")
											plyr:SelectWeapon("weapon_zombie")
										end
									end)
								plyr:SetHealth(InfectConfig.Health)
								plyr:PrintMessage( HUD_PRINTTALK, "YOU ARE NOW A ZOMBIE!")
							else
								local ent = ents.Create("npc_infectiouszombie")
								ent:SetPos(plyr:GetPos())
								ent:Spawn()
								ent:Activate()
								plyr:SetPos(plyr:GetPos()+ Vector(0,0,15))
								plyr:Kill()
							end
						end
						--player:takeDamage(
					end)
					
				if (InfectConfig.InfectMessage) then plyr:PrintMessage( HUD_PRINTTALK, "YOU HAVE BEEN INFECTED!")  end
			end
			if (InfectConfig.ScreenTick) then
				if (!timer.Exists("ShakeTimer"..plyr:GetName().."")) then
					timer.Create("ShakeTimer"..plyr:GetName().."", InfectConfig.ScreenTickFreq, 0,
					function()
						plyr:ViewPunch(Angle(math.random(-1,1),math.random(-1,1),math.random(-1,1)))
					end)
				end
			end
		end
		if (plyr:IsNPC()) then
			plyr:SetColor(Color(142, 252, 0))
			timer.Create("InfectionTimer"..math.random(1,999).."", math.random(5, 60), 1, 
			function()
				if(plyr:IsValid()) then
					local ent = ents.Create("npc_infectiouszombie")
					ent:SetPos(plyr:GetPos())
					ent:Spawn()
					ent:Activate()
					plyr:Remove()
				end
			end)
		end
	end
end



function StopTimers(player)
	if (timer.Exists("InfectionTimer"..player:GetName().."")) then
		timer.Destroy("InfectionTimer"..player:GetName().."")
	end
	
	if (timer.Exists("ShakeTimer"..player:GetName().."")) then
		timer.Destroy("ShakeTimer"..player:GetName().."")
	end
end
hook.Add("PlayerSpawn", "Stop Timers", StopTimers)


function CheckHeadshot(npc, hitgroup, dmg)
	if (npc:GetClass()=="npc_infectiouszombie") then
		if (hitgroup == HITGROUP_HEAD) then
			dmg = 1.5*dmg
		end
	end
end
hook.Add("ScaleNPCDamage", "CheckForZombieHeadshot", CheckHeadshot)