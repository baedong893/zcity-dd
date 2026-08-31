AddCSLuaFile()

if SERVER then
	--resource.AddFile("models/weapons/c_arms_citizen.mdl")
	--resource.AddFile("models/weapons/c_arms_citizen/c_arms_citizen_hands.vmt")
	--resource.AddFile("materials/models/weapons/zombiehand/hand.vmt")
end

SWEP.Author 				= "jmoak3"
SWEP.Contact 				= "mrjmoak3@gmail.com or @jmoak3"
SWEP.Purpose 				= "BRAINS"
SWEP.Instructions 			= "BRAINS"
	
SWEP.Spawnable 				= false
SWEP.UseHands 				= false
SWEP.ViewModel				= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel				= ""
--SWEP.Base					= "weapon_tttbase"
--SWEP.Kind = WEAPON_EQUIP

SWEP.HoldType = "knife"
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.DrawAmmo = true
SWEP.ViewModelFOV  = 70
SWEP.ViewModelFlip = true
SWEP.Primary.Automatic = false
SWEP.Damage = InfectConfig.ZombieDamage
SWEP.Category 				= "jmoak3"

SWEP.DrawCrosshair = false
SWEP.Primary.Ammo 			= ""


SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.AllowDrop = false
SWEP.ViewModelFlip = false
SWEP.PrintName 				= "Zombie Hands"
SWEP.Slot					= 6
SWEP.AutoSpawnable = false
--SWEP.LimitedStock = true
SWEP.HitTime = 0.1
SWEP.CoolDown = 0.4
SWEP.IdleWait = 0.4
SWEP.CoolEffect = false

local testing = false

function SWEP:Initialize()
	self:InstallDataTable()
	self:SetWeaponHoldType(self.HoldType)
	--if (SERVER) then self.Owner:SetMaxSpeed(50) end
	self.CanFire = true
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "CoolMeleeAttack")
	self:NetworkVar("Float", 2, "IdleTime")
	self:SetNextMeleeAttack(-1)
	self:SetCoolMeleeAttack(-1)
	self:SetIdleTime(-1)	
	local dxlevel = GetConVarNumber("mat_dxlevel")
	if (dxlevel > 89) then self.CoolEffect = true end
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "fists_draw" ) )
	return true
end

function SWEP:Reload()

end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:HandleRelations(i)
	i:AddEntityRelationship(self.Owner, 1, 99)
	
	if (i:GetClass() == "npc_citizen") then
		i:AddEntityRelationship(self.Owner, 2, 99)
	end
end

function SWEP:Think()
	-- NPC relationship updates do not need to scan nearby entities every server frame.
	-- Throttling this prevents the cost from multiplying with every infected player.
	if (SERVER && (self.NextRelationScan or 0) <= CurTime()) then
		self.NextRelationScan = CurTime() + 0.5
		local _ents = ents.FindInSphere( self:GetPos(), 1000 )
		local ignore = GetConVarNumber("ai_ignoreplayers")
		self.IgnorePlayer = ignore
		for k, i in pairs( _ents ) do
			if (i:IsValid() && i:GetClass()!="npc_infectiouszombie" && (i:IsNPC() || ((ignore == 0 && i:IsPlayer() && i:Alive() && i:GetActiveWeapon():IsValid() && i:GetActiveWeapon():GetClass() != "weapon_zombie")))) then
				if (i:GetClass()!="npc_infectiouszombie" && !i:IsPlayer()) then
					self:HandleRelations(i)
				end
			end
		end
	end
	if (SERVER && InfectConfig.FixZombieModels) then
		self.Owner:SetModel("models/player/zombie_classic.mdl")
	end
	
	if (InfectConfig.TouchInfect) then
		local attackableEnts = ents.FindInSphere(self.Owner:GetPos(), InfectConfig.TouchInfectRadius)
		if (attackableEnts != nil) then
			for _,i in pairs(attackableEnts) do
				if (((i:IsPlayer() && i:Alive()) || i:IsNPC()) && i != self.Owner && SERVER) then
					self:Infect(i)
				end
			end
		end
	end
	
	if (table.Count(self.Owner:GetWeapons()) > 1 && SERVER) then
		self.Owner:StripWeapons()
		self.Owner:Give("weapon_zombie")
		self.Owner:SelectWeapon("weapon_zombie")
		self.Owner:PrintMessage( HUD_PRINTTALK, "NOM")
	end
	
	local nextMelee = self:GetNextMeleeAttack()
	local nextCool = self:GetCoolMeleeAttack()
	local nextIdle = self:GetIdleTime()
	
	if (nextMelee > 0 && CurTime() >= nextMelee && !(nextCool > 0)) then
		self:CutEmUp()
		self:SetCoolMeleeAttack(CurTime() + self.CoolDown)
	end
	
	if (nextCool > 0 && CurTime() >= nextCool && !(nextIdle > 0)) then
		self:Idle()
		self:SetIdleTime(CurTime() + self.IdleWait)
	end
	
	if (nextIdle > 0 && CurTime() >= nextIdle) then
		self:SetNextMeleeAttack(0)
		self:SetCoolMeleeAttack(0)
		self:SetIdleTime(0)
	end
end

function SWEP:CutEmUp()
	local trace = util.TraceLine( 
	{
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector()*75,
		filter = self.Owner
	})
	local i = trace.Entity
	if (trace.HitNonWorld) then
		if ((((i:IsPlayer() && i:Alive()) || i:IsNPC()) && i:EntIndex() != self.Owner:EntIndex()) ||
					(i:GetClass() == "prop_physics" || i:GetClass() == "prop_physics_multiplayer" || i:GetClass() == "prop_dynamic")) then
			self:EmitSound("npc/zombie/claw_strike"..math.random(1,3)..".wav")
			
			if (SERVER) then 
				--if player deal damage normally
				if (i:IsPlayer() || i:IsNPC()) then
					i:TakeDamage(self.Damage, self.Owner, self)
				end
				--if prop...
				if (i:GetClass() == "prop_physics" || i:GetClass() == "prop_physics_multiplayer" || i:GetClass() == "prop_dynamic") then
					timer.Create("DamageTimer"..math.random(1,999), 0, 1, 
					function() 
						if (i:IsValid()) then 
							i:TakeDamage(self.Damage, self.Owner, self)
						end
					end)
				end
				
				if (math.random(1, InfectConfig.InfectScratchChance ) == 1 && 
					((i:IsPlayer() && !(i:GetActiveWeapon():IsValid() && i:GetActiveWeapon():GetClass() == "weapon_zombie")) || i:IsNPC())) then 
						self:Infect(i) 
				end
				if (i:IsPlayer()) then
					i:ViewPunch(Angle(math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage))
				end
				if (i:GetClass() == "prop_physics" || i:GetClass() == "prop_physics_multiplayer" || i:GetClass() == "prop_dynamic") then
					local phys = i:GetPhysicsObject()
					if (phys != nil && phys != NULL && phys:IsValid()) then
						print("hit a prop")
						phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * 20000)
					end
				end
			end
		end
	end
end

function SWEP:PrimaryAttack()
	local nextMelee = self:GetNextMeleeAttack()
	if (IsFirstTimePredicted() && !(nextMelee > 0)) then
		--self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		local vm = self.Owner:GetViewModel()
		vm:ResetSequence( vm:LookupSequence( "fists_right" ) )

		--self.Owner:DoAnimationEvent(PLAYER_ATTACK1)
		
		self:EmitSound("npc/zombie/zombie_voice_idle"..math.random(1,2)..".wav")
		self:SetNextMeleeAttack(CurTime()+self.HitTime)	
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Precache()
	util.PrecacheSound("npc/zombie/zombie_voice_idle1.wav")
	util.PrecacheSound("npc/zombie/zombie_voice_idle2.wav")
    util.PrecacheSound("npc/zombie/claw_strike1.wav")
    util.PrecacheSound("npc/zombie/claw_strike2.wav")
    util.PrecacheSound("npc/zombie/claw_strike3.wav")
    util.PrecacheSound("npc/zombie/claw_miss1.wav")
    util.PrecacheSound("npc/zombie/claw_miss2.wav")
end

function SWEP:OnRemove()
end

function SWEP:DrawHUD()
	if (self.CoolEffect) then DrawMaterialOverlay( "models/shadertest/shader4", 0.05) end
end

function SWEP:Infect(plyr)
	if SERVER and hook.Run("ZC_BiohazardZombieInfect", self.Owner, plyr, self) then return end

	if (plyr != nil && plyr != NULL && plyr != null && SERVER) then
		if (plyr:IsPlayer() && (plyr != self.Owner) && plyr:IsValid() &&
			plyr:GetActiveWeapon():IsValid() && plyr:Alive() && 
			plyr:GetActiveWeapon():GetClass() != "weapon_zombie") then
				if (!timer.Exists("InfectionTimer"..plyr:GetName().."")) then
					timer.Create("InfectionTimer"..plyr:GetName().."", math.random(InfectConfig.InfectTimeMin, InfectConfig.InfectTimeMax), 1, 
					function()
						if (plyr:GetActiveWeapon():IsValid() && plyr:Alive() &&
								plyr:GetActiveWeapon():GetClass() != "weapon_zombie") then
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
					self.Owner:PrintMessage( HUD_PRINTTALK, "THEY TASTE GOOD")
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

function SWEP:Idle()
	local vm = self.Owner:GetViewModel()
	vm:ResetSequence( vm:LookupSequence( "fists_idle_01") )
end

function StopTimers(plyr)
	if (timer.Exists("InfectionTimer"..plyr:GetName().."")) then
		timer.Destroy("InfectionTimer"..plyr:GetName().."")
	end
	
	if (timer.Exists("ShakeTimer"..plyr:GetName().."")) then
		timer.Destroy("ShakeTimer"..plyr:GetName().."")
	end
end
hook.Add("PlayerSpawn", "Stop Timers", StopTimers)

function CheckHeadshot(plyr, hitgroup, dmg)
	if (plyr:IsPlayer() && InfectConfig.HeadshotOnly && plyr:GetActiveWeapon():IsValid() &&
			plyr:GetActiveWeapon():GetClass() == "weapon_zombie") then
		if (hitgroup != HITGROUP_HEAD) then
			plyr:SetHealth(InfectConfig.Health)
			dmg = 0
		end
	end
end
hook.Add("ScalePlayerDamage", "CheckForPZombieHeadshot", CheckHeadshot)

function ZombiesCantUseWeapons(plyr, wep)
	if (plyr:IsPlayer() && plyr:GetActiveWeapon():IsValid() &&
			plyr:GetActiveWeapon():GetClass() == "weapon_zombie") then
		return false
	end
end
hook.Add("PlayerCanPickupWeapon", "ZombiesCantUseWeaponsCheck", ZombiesCantUseWeapons)


--function MuteZombies(plyr, bind, pressed)
--	if (InfectConfig.MuteZombies) then
--		 if (string.find(bind, "+voicerecord") && plyr:GetActiveWeapon():IsValid() &&
--				plyr:GetActiveWeapon():GetClass() == "weapon_zombie") then
--			  return false
--		 end
--	end
--end
--hook.Add("PlayerBindPress", "MutePlayerZombies", MuteZombies)

	
