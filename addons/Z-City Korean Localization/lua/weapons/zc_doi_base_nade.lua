if SERVER then AddCSLuaFile() end

SWEP.Base = "zc_doi_base"

local function GetFallbackNadeViewModel(self)
	if self.HoldType == "slam" then return "models/weapons/c_slam.mdl" end
	return "models/weapons/c_grenade.mdl"
end

function SWEP:Initialize()
	self:SetupDoiPrimary()
	self.DOIModel = self.DOIModel or self.ViewModel
	self.ViewModel = self.BasicViewModel or GetFallbackNadeViewModel(self)
	self.ViewModelFOV = self.ViewModelFOV or self.ViewModelFOVBase or 60
	self.UseHands = true
	self.Primary.ClipSize = self.ClipSize or 1
	self.Primary.DefaultClip = self.Primary.DefaultClip or 1
	self.Primary.Automatic = false
	self.Primary.Ammo = self.Ammo or "grenade"
	self:SetHoldType(self.HoldType or "grenade")

	if SERVER and self:Clip1() <= 0 then
		self:SetClip1(self.Primary.ClipSize)
	end
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	self:SetNextPrimaryFire(CurTime() + 1)
	self:TakePrimaryAmmo(1)
	owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	if SERVER and self.ShootEnt then
		local ent = ents.Create(self.ShootEnt)
		if IsValid(ent) then
			ent:SetPos(owner:GetShootPos() + owner:GetAimVector() * 24)
			ent:SetAngles(owner:EyeAngles())
			ent:SetOwner(owner)
			ent.Owner = owner
			ent:Spawn()
			ent:Activate()

			local phys = ent:GetPhysicsObject()
			local force = self.ThrowForceMax or self.ShootEntForce or 900
			if IsValid(phys) then
				phys:SetVelocity(owner:GetAimVector() * force + owner:GetVelocity())
				phys:AddAngleVelocity(VectorRand() * 360)
			else
				ent:SetVelocity(owner:GetAimVector() * force + owner:GetVelocity())
			end
		end
	end

	timer.Simple(0.25, function()
		if not IsValid(self) or not IsValid(owner) then return end
		if self:Clip1() <= 0 and owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
			owner:StripWeapon(self:GetClass())
		end
	end)
end
