AddCSLuaFile()

SWEP.PrintName = "Zombie Claws"
SWEP.Author = "Z-City"
SWEP.Purpose = "Infect humans"
SWEP.Instructions = "Left click to infect humans."
SWEP.Category = "Z-City"

SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.AllowDrop = false

SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""
SWEP.UseHands = false
SWEP.HoldType = "knife"
SWEP.ViewModelFOV = 70
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.6

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Range = 90
SWEP.HitDelay = 0.1
SWEP.PropDamage = 25

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	local owner = self:GetOwner()
	if IsValid(owner) then
		local vm = owner:GetViewModel()
		if IsValid(vm) then
			local seq = vm:LookupSequence("fists_draw")
			if seq and seq >= 0 then
				vm:ResetSequence(seq)
			end
		end
	end

	return true
end

function SWEP:Reload()
end

function SWEP:SecondaryAttack()
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	owner:SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("npc/zombie/zombie_voice_idle" .. math.random(1, 2) .. ".wav")

	local vm = owner:GetViewModel()
	if IsValid(vm) then
		local seq = vm:LookupSequence(math.random(2) == 1 and "fists_right" or "fists_left")
		if seq and seq >= 0 then
			vm:ResetSequence(seq)
		end
	end

	if SERVER then
		timer.Simple(self.HitDelay, function()
			if IsValid(self) then
				self:DoClawHit()
			end
		end)
	end
end

function SWEP:DoClawHit()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local tr = util.TraceHull({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * self.Range,
		mins = Vector(-10, -10, -10),
		maxs = Vector(10, 10, 10),
		filter = owner
	})

	local ent = tr.Entity
	if not IsValid(ent) then
		self:EmitSound("npc/zombie/claw_miss" .. math.random(1, 2) .. ".wav")
		return
	end

	self:EmitSound("npc/zombie/claw_strike" .. math.random(1, 3) .. ".wav")

	local target = ent
	if SERVER and hg and hg.RagdollOwner then
		target = hg.RagdollOwner(ent) or target
	end

	if IsValid(target) and target:IsPlayer() then
		local round = CurrentRound()
		if round and round.name == "cszombie" and round.InfectHuman then
			round:InfectHuman(owner, target)
		end

		return
	end

	if SERVER then
		ent:TakeDamage(self.PropDamage, owner, self)
	end
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
