AddCSLuaFile()

if SERVER then
   resource.AddFile("materials/vgui/ttt/icon_cure.vmt")
end

SWEP.Author 				= "jmoak3"
SWEP.Contact 				= "mrjmoak3@gmail.com or @jmoak3"
SWEP.Purpose 				= "A cure for the Biohazard Ball's infection"
SWEP.Instructions 			= "Left-Click to throw the Cure"
	
SWEP.Spawnable 				= true
SWEP.AdminOnly		 		= false
SWEP.UseHands 				= false

SWEP.ViewModel 				= "models/weapons/v_bugbait.mdl"
SWEP.WorldModel				= "models/weapons/w_bugbait.mdl"

SWEP.HoldType = "grenade"
SWEP.Primary.NumberofShots 	= 1
SWEP.Primary.ClipSize 		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.DrawAmmo			= true

SWEP.AllowDrop = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV  = 72
SWEP.Category 				= "jmoak3"

SWEP.DrawCrosshair = false
SWEP.Primary.Ammo 			= ""

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.PrintName 				= "Cure"
SWEP.Slot					= 6

SWEP.Icon = "vgui/ttt/icon_cure"

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
	
	local ent = ents.Create("sent_cure")
	
	if (self.Weapon==nil || !IsValid(ent)) then return end
	
	local fireTimer = "CureFireTimer_" .. self:EntIndex()
	timer.Create(fireTimer, 1, 1, function()
		if !IsValid(self) then return end
		self.CanFire = true
		if IsValid(self.Weapon) then self.Weapon:SendWeaponAnim(ACT_VM_DRAW) end
		self:Remove()
	end) 
	
	ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector()* 16))
	ent:SetAngles(self.Owner:EyeAngles())
	ent:SetColor(Color(0, 0, 255))
	ent:SetOwner(self.Owner)
	ent.ZC_CureOwner = self.Owner
	ent:Spawn()
	hook.Run("ZC_CureThrown", self, ent, self.Owner)
	
	local phys = ent:GetPhysicsObject()
	
	if !(phys && IsValid(phys)) then ent:Remove() return end
	
	phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * 1300)
	
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.5)
	if SERVER then
		local handled, allowed = hook.Run("ZC_CureCanThrow", self.Owner, self)
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
		local handled, consume = hook.Run("ZC_CureSelfUse", plyr, self)
		if handled then
			if consume ~= false && IsValid(self) then self:Remove() end
			return
		end
	end

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




