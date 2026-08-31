AddCSLuaFile()

if SERVER then
   	resource.AddFile("materials/vgui/ttt/icon_biohazardball.vmt")
end

SWEP.Author 				= "jmoak3"
SWEP.Contact 				= "mrjmoak3@gmail.com or @jmoak3"
SWEP.Purpose 				= "A seemingly harmless ball of zombie meat"
SWEP.Instructions 			= "Throw the Biohazard Ball and infect a player! Right click to eat!"

SWEP.Spawnable 				= true
SWEP.AdminOnly		 		= false
SWEP.UseHands 				= false

SWEP.ViewModel 				= "models/weapons/v_bugbait.mdl"
SWEP.WorldModel				= "models/weapons/w_bugbait.mdl"

SWEP.HoldType = "grenade"
SWEP.Primary.ClipSize 		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.DrawAmmo = true
SWEP.ViewModelFOV  = 72
SWEP.ViewModelFlip = true

SWEP.Category 				= "jmoak3"

SWEP.DrawCrosshair = false
SWEP.Primary.Ammo 			= ""


SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.AllowDrop = true
SWEP.ViewModelFlip = false

SWEP.PrintName 				= "Biohazard Ball"
SWEP.Slot					= 1
SWEP.AutoSpawnable = false
SWEP.Icon = "vgui/ttt/icon_biohazardball"

local testing = false

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self.CanFire = true
end


function SWEP:Reload()
end

function SWEP:Think()
	
end

function SWEP:Throw()
	if (!SERVER) then return end
	
	self:ShootEffects()
	self.BaseClass.ShootEffects(self)
	
	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	self.CanFire = false
	
	local ent = ents.Create("sent_biohazardball")
	
	if (self.Weapon==nil || !IsValid(ent)) then return end
	
	local fireTimer = "BBFireTimer_" .. self:EntIndex()
	timer.Create(fireTimer, 1, 1, function()
		if !IsValid(self) then return end
		self.CanFire = true
		if IsValid(self.Weapon) then self.Weapon:SendWeaponAnim(ACT_VM_DRAW) end
		self:Remove()
	end) 
	
	ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector()* 16))
	ent:SetAngles(self.Owner:EyeAngles())
	ent:SetOwner(self.Owner)
	ent.ZC_BiohazardOwner = self.Owner
	ent:Spawn()
	hook.Run("ZC_BiohazardBallThrown", self, ent, self.Owner)
	
	local phys = ent:GetPhysicsObject()
	
	if !(phys && IsValid(phys)) then ent:Remove() return end
	
	phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * 1300)

end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.5)
	if SERVER then
		local handled, allowed = hook.Run("ZC_BiohazardBallCanThrow", self.Owner, self)
		if handled and not allowed then return end
	end

	if (self.CanFire) then
		self:Throw()
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.5)
	local plyr = self.Owner
	if SERVER then
		local handled, consume = hook.Run("ZC_BiohazardBallSelfUse", plyr, self)
		if handled then
			if consume ~= false && IsValid(self) then self:Remove() end
			return
		end
	end

	if (plyr != nil && plyr != NULL && plyr != null && SERVER) then
		if (plyr:IsPlayer() && plyr:IsValid()) then
			if (!timer.Exists("InfectionTimer"..plyr:GetName().."")) then
				timer.Create("InfectionTimer"..plyr:GetName().."", math.random(InfectConfig.InfectTimeMin, InfectConfig.InfectTimeMax), 1, 
				function()
					if (plyr:Alive()) then
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
	if (SERVER) then self:Remove() end
end

