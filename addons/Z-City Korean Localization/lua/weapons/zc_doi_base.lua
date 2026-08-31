if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_base"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Primary = SWEP.Primary or {}
SWEP.Secondary = SWEP.Secondary or {}

local function PickSound(soundData)
	if istable(soundData) then return soundData[math.random(#soundData)] end
	return soundData
end

local function FirstFiremode(self)
	if not istable(self.Firemodes) then return nil end
	return self.Firemodes[1]
end

local function GetFallbackViewModel(self)
	if self.ShootEnt then return "models/weapons/c_rpg.mdl" end
	if self.Class == "Pistol" then return "models/weapons/c_pistol.mdl" end
	if self.Class == "Grenade" then return "models/weapons/c_grenade.mdl" end
	if self.HoldType == "smg" then return "models/weapons/c_smg1.mdl" end
	if self.HoldType == "pistol" or self.HoldType == "revolver" then return "models/weapons/c_pistol.mdl" end
	return "models/weapons/c_irifle.mdl"
end

function SWEP:SetupDoiPrimary()
	self.Primary = self.Primary or {}
	self.Primary.ClipSize = self.ClipSize or self.Primary.ClipSize or 30
	self.Primary.DefaultClip = self.Primary.DefaultClip or self.Primary.ClipSize * 3
	self.Primary.Automatic = self.Primary.Automatic ~= nil and self.Primary.Automatic or ((FirstFiremode(self) or {}).Mode == -1)
	self.Primary.Ammo = self.Ammo or self.Primary.Ammo or "SMG1"

	self.Secondary = self.Secondary or {}
	self.Secondary.ClipSize = -1
	self.Secondary.DefaultClip = -1
	self.Secondary.Automatic = false
	self.Secondary.Ammo = "none"
end

function SWEP:Initialize()
	self:SetupDoiPrimary()
	self.DOIModel = self.DOIModel or self.ViewModel
	self.ViewModel = self.BasicViewModel or GetFallbackViewModel(self)
	self.ViewModelFOV = self.ViewModelFOV or self.ViewModelFOVBase or 60
	self.UseHands = true
	self:SetHoldType(self.HoldType or "ar2")

	if SERVER and self:Clip1() <= 0 then
		self:SetClip1(self.Primary.ClipSize)
	end
end

function SWEP:Deploy()
	self.DOIModel = self.DOIModel or self.ViewModel
	self.ViewModel = self.BasicViewModel or GetFallbackViewModel(self)
	self.ViewModelFOV = self.ViewModelFOV or self.ViewModelFOVBase or 60
	self.UseHands = true
	self:SetHoldType(self.HoldType or "ar2")

	local snd = PickSound((self.Class == "Pistol" and ARC9DOI and ARC9DOI.PistolDraw) or (ARC9DOI and ARC9DOI.Draw))
	if snd then self:EmitSound(snd, 65, 100, 0.55) end

	return true
end

function SWEP:GetFireDelay()
	return 60 / math.max(self.RPM or 450, 1)
end

function SWEP:CanPrimaryAttack()
	if self:Clip1() > 0 then return true end

	local snd = PickSound(self.DryFireSound)
	if snd then self:EmitSound(snd, 60, 100, 0.7) end
	self:SetNextPrimaryFire(CurTime() + (self.DryFireDelay or 0.25))
	return false
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
	self:TakePrimaryAmmo(1)

	local shootSound = PickSound(self.ShootSound or self.FirstShootSound)
	if shootSound then self:EmitSound(shootSound, self.ShootVolume or 110, self.ShootPitch or 100, self.ShootVolumeActual or 1) end

	owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	if self.ShootEnt then
		if SERVER then
			local ent = ents.Create(self.ShootEnt)
			if IsValid(ent) then
				ent:SetPos(owner:GetShootPos() + owner:GetAimVector() * 32)
				ent:SetAngles(owner:EyeAngles())
				ent:SetOwner(owner)
				ent.Owner = owner
				ent:Spawn()
				ent:Activate()

				local phys = ent:GetPhysicsObject()
				local force = self.ShootEntForce or 7000
				if IsValid(phys) then
					phys:SetVelocity(owner:GetAimVector() * force + owner:GetVelocity())
				else
					ent:SetVelocity(owner:GetAimVector() * force + owner:GetVelocity())
				end
			end
		end

		owner:ViewPunch(Angle(-(self.RecoilUp or self.Recoil or 1), 0, 0))
		return
	end

	local bullet = {}
	bullet.Num = self.Num or self.NumShots or 1
	bullet.Src = owner:GetShootPos()
	bullet.Dir = owner:GetAimVector()
	bullet.Spread = Vector(self.Spread or 0.018, self.Spread or 0.018, 0)
	bullet.Tracer = 1
	bullet.Force = self.ImpactForce or 4
	bullet.Damage = self.DamageMax or self.Damage or 25
	bullet.AmmoType = self.Primary.Ammo

	owner:FireBullets(bullet)
	owner:ViewPunch(Angle(-(self.RecoilUp or self.Recoil or 1), math.Rand(-(self.RecoilSide or 0.5), self.RecoilSide or 0.5), 0))
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Reload()
	if self:Clip1() >= (self.Primary.ClipSize or 0) then return end
	if self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then return end

	self:DefaultReload(ACT_VM_RELOAD)
	self:SetNextPrimaryFire(CurTime() + 2.2)
end

if CLIENT then
	local fallbackOffset = {
		Pos = Vector(-8, 4, -5),
		Ang = Angle(-5, 0, 180),
		Scale = 1
	}

	local function GetWorldModelPath(self)
		if self.DOIModel and util.IsValidModel(self.DOIModel) then return self.DOIModel end
		if self.WorldModel and util.IsValidModel(self.WorldModel) then return self.WorldModel end
	end

	local function ApplyModelTransform(model, pos, ang, offset)
		offset = offset or fallbackOffset

		local localPos = offset.TPIKPos or offset.Pos or fallbackOffset.Pos
		local localAng = offset.Ang or fallbackOffset.Ang
		local scale = offset.Scale or fallbackOffset.Scale
		local drawPos, drawAng = LocalToWorld(localPos, localAng, pos, ang)

		model:SetPos(drawPos)
		model:SetAngles(drawAng)
		model:SetModelScale(scale, 0)
	end

	function SWEP:DrawWorldModel()
		local modelPath = GetWorldModelPath(self)
		if not modelPath then return end

		if not IsValid(self.DOIWorldModel) or self.DOIWorldModel:GetModel() ~= modelPath then
			if IsValid(self.DOIWorldModel) then self.DOIWorldModel:Remove() end
			self.DOIWorldModel = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
			if not IsValid(self.DOIWorldModel) then return end
			self.DOIWorldModel:SetNoDraw(true)
		end

		local mdl = self.DOIWorldModel
		local owner = self:GetOwner()

		if IsValid(owner) then
			local bone = owner:LookupBone("ValveBiped.Bip01_R_Hand") or owner:LookupBone("ValveBiped.Bip01_R_Forearm")
			if not bone then return end

			local matrix = owner:GetBoneMatrix(bone)
			if not matrix then return end

			ApplyModelTransform(mdl, matrix:GetTranslation(), matrix:GetAngles(), self.WorldModelOffset)
		else
			mdl:SetPos(self:GetPos())
			mdl:SetAngles(self:GetAngles())
			mdl:SetModelScale((self.WorldModelOffset and self.WorldModelOffset.Scale) or 1, 0)
		end

		mdl:SetupBones()
		mdl:DrawModel()
	end

	function SWEP:OnRemove()
		if IsValid(self.DOIWorldModel) then
			self.DOIWorldModel:Remove()
			self.DOIWorldModel = nil
		end
	end
end
