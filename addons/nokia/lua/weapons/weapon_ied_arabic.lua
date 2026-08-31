if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName = "Report Phone"
SWEP.Category = "Z City"
SWEP.Author = "Chev / M9K, modified for Z City"
SWEP.Purpose = "Phone used to report suspicious people. Bomb functions removed."
SWEP.Instructions = "Primary: Aim at a player and report them. Secondary: Disabled."

SWEP.Slot = 4
SWEP.SlotPos = 26

SWEP.DrawAmmo = false
SWEP.DrawWeaponInfoBox = true
SWEP.BounceWeaponIcon = false
SWEP.DrawCrosshair = false
SWEP.Weight = 2
SWEP.HoldType = "pistol"
SWEP.ViewModelFOV = 75
SWEP.WorkWithFake = true
SWEP.weaponInvCategory = false

SWEP.ViewModel = "models/weapons/weapon_ied_arabic.mdl"
SWEP.WorldModel = "models/weapons/weapon_ied_arabic.mdl"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.FiresUnderwater = true

SWEP.Primary.Sound = Sound("buttons/button14.wav")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local REPORT_RANGE = 1200
local REPORT_COOLDOWN = 5

local function GetRoundMode()
	if CurrentRound then
		return CurrentRound()
	end
end

local function FindPlayerInCamera(reporter)
	local startPos = reporter:EyePos()
	local endPos = startPos + reporter:EyeAngles():Forward() * REPORT_RANGE

	local tr = util.TraceHull({
		start = startPos,
		endpos = endPos,
		mins = Vector(-8, -8, -8),
		maxs = Vector(8, 8, 8),
		filter = reporter,
		mask = MASK_SHOT
	})

	local ent = tr.Entity
	if IsValid(ent) and ent:IsPlayer() then
		return ent
	end
end

function SWEP:FindReportTarget(reporter)
	return FindPlayerInCamera(reporter)
end

local function CanReport(round, reporter, target)
	if not IsValid(reporter) or not reporter:IsPlayer() or not reporter:Alive() then return false end
	if not IsValid(target) or not target:IsPlayer() or not target:Alive() then return false end
	if reporter == target then return false end

	if round and round.CanPhoneReport then
		local allowed, reason = round:CanPhoneReport(reporter, target)
		if not allowed and reason then reporter:ChatPrint(reason) end
		return allowed and true or false
	end

	reporter:ChatPrint("현재 라운드에서는 신고 기능을 사용할 수 없습니다.")
	return false
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType or "fist")
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + REPORT_COOLDOWN)

	if CLIENT then return end

	local reporter = self:GetOwner()
	if not IsValid(reporter) then return end

	local target = FindPlayerInCamera(reporter)
	if not IsValid(target) then
		reporter:ChatPrint("신고할 대상을 화면 중앙에 두고 찍으세요.")
		return
	end

	local round = GetRoundMode()
	if not CanReport(round, reporter, target) then return end

	self:EmitSound(self.Primary.Sound)

	if round and round.StartReport then
		round:StartReport(reporter, target)
		return
	end

	reporter:ChatPrint("현재 라운드에서 신고 기능을 사용할 수 없습니다.")
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.5)
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:GetViewModelPosition(pos, ang)
	pos = pos + ang:Right() * 6
	pos = pos + ang:Up() * -3.5
	pos = pos + ang:Forward() * 7
	ang:RotateAroundAxis(ang:Forward(), -10)
	return pos, ang
end
