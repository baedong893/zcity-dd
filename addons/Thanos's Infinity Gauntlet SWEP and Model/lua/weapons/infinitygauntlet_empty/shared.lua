SWEP.PrintName = "Empty Infinity Gauntlet"

SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.Weight = 999
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Convert()
	local owner = self.Owner
	if IsValid(owner) and owner:IsPlayer() then
		local wep = owner:Give("infinitygauntlet")
		if wep:IsValid() then
			wep.noStonesCreated = true
			for i=1,6 do
				wep:SetHasStone(i,false)
			end
		end
		owner:SelectWeapon("infinitygauntlet")
	end
	self:Remove()
end

function SWEP:Initialize()
	if !SERVER then return end
	timer.Simple(0,function()
		if self:IsValid() then
			self:Convert()
		end
	end)
end

function SWEP:Deploy()
	self:Convert()
end
