AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.PrintName = "SCP-106 섬광 조사기"
SWEP.Category = "Z 시티 SCP 모드"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Instructions = "좌클릭: 범위 섬광 / 빛이 닿는 SCP-106의 시야를 2초간 차단 / 5초간 이동속도 25% 감소 및 능력·무기 차단"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.UseHands = true
SWEP.ViewModel = "models/glide/weapons/c_homing_launcher.mdl"
SWEP.WorldModel = "models/glide/weapons/w_homing_launcher.mdl"
SWEP.ViewModelFOV = 50
SWEP.HoldType = "rpg"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false

SWEP.FlashDistance = 256
SWEP.FlashRadius = 512
SWEP.FlashDuration = 5
SWEP.FlashBlindDuration = 2
SWEP.FlashCooldown = 8

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	self:SetHoldType(self.HoldType)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), CurTime() + 0.3))
	return true
end

function SWEP:GetFlashOrigin(owner)
	local origin = owner:GetShootPos()
	local tr = util.TraceLine({
		start = origin,
		endpos = origin + owner:GetAimVector() * self.FlashDistance,
		filter = {owner, self},
		mask = MASK_SHOT
	})
	if tr.StartSolid or tr.AllSolid then return end
	-- Keep the light outside a struck wall/floor so visibility traces do not start in it.
	return tr.Hit and (tr.HitPos + tr.HitNormal * 2) or tr.HitPos
end

-- Exposure uses the same light origin/radius as the visual, including visible phasing players.
-- It does not use human organism damage/flashbang hooks: SCP-106 ignores those effects.
function SWEP:CanExpose(target, owner, flashOrigin)
	if not IsValid(target) or target == owner or not target:IsPlayer() or not target:Alive() then return false end
	if target:Team() == TEAM_SPECTATOR then return false end
	local weapon = target:GetWeapon("swep_106_pd")
	if not IsValid(weapon) or not weapon.ApplyFlashDisable then return false end
	if target:GetNoDraw() then return false end
	local ownerDream = owner.IsDreaming and owner:IsDreaming()
	local targetDream = target.IsDreaming and target:IsDreaming()
	if ownerDream or targetDream then return false end

	-- A lit part of the body counts even when the crosshair misses its center.
	local samples = {target:NearestPoint(flashOrigin), target:WorldSpaceCenter(), target:EyePos()}
	for _, point in ipairs(samples) do
		if flashOrigin:DistToSqr(point) <= self.FlashRadius * self.FlashRadius then
			local tr = util.TraceLine({
				start = flashOrigin,
				endpos = point,
				filter = {owner, self},
				mask = MASK_SHOT
			})
			if not tr.StartSolid and not tr.AllSolid and (not tr.Hit or tr.Entity == target) then
				return true
			end
		end
	end
	return false
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryFire() > CurTime() then return end
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
	if owner:GetActiveWeapon() ~= self or owner:IsFrozen() then return end
	if zb and zb.ROUND_STATE ~= 1 then return end
	if owner.organism and owner.organism.otrub then return end
	local scpWeapon = owner:GetWeapon("swep_106_pd")
	if IsValid(scpWeapon) and scpWeapon:IsFlashDisabled() then return end

	self:SetNextPrimaryFire(CurTime() + self.FlashCooldown)
	-- Predict the camera shutter for the shooter; the server also plays it for observers.
	if IsFirstTimePredicted() then
		self:EmitSound("NPC_CScanner.TakePhoto")
	end
	if CLIENT then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	owner:SetAnimation(PLAYER_ATTACK1)

	local flashOrigin = self:GetFlashOrigin(owner)
	if not flashOrigin then return end
	-- Send the gameplay radius with the light so the visible and effective areas agree.
	local effect = EffectData()
	effect:SetOrigin(flashOrigin)
	effect:SetRadius(self.FlashRadius)
	effect:SetEntity(self)
	util.Effect("scp106_flash", effect, true, true)

	for _, target in ipairs(player.GetAll()) do
		if self:CanExpose(target, owner, flashOrigin) then
			target:GetWeapon("swep_106_pd"):ApplyFlashDisable(self.FlashDuration, self.FlashBlindDuration)
		end
	end
end

function SWEP:SecondaryAttack() end
function SWEP:Reload() end

if CLIENT then
	-- Register with the weapon so connected clients also receive the effect on Lua refresh.
	-- A newly added effects file is not guaranteed to load in an existing session.
	local flashEffect = {}
	function flashEffect:Init(data)
		local radius = data:GetRadius()
		if radius <= 0 then return end
		local source = data:GetEntity()
		local light = DynamicLight(IsValid(source) and source:EntIndex() or self:EntIndex())
		if not light then return end
		light.Pos = data:GetOrigin()
		light.r = 255
		light.g = 255
		light.b = 255
		light.Brightness = 10
		light.Size = radius
		light.DieTime = CurTime() + 0.02
		light.Decay = radius
	end
	function flashEffect:Think() return false end
	function flashEffect:Render() end
	effects.Register(flashEffect, "scp106_flash")

	SWEP.WepSelectIcon = surface.GetTextureID("glide/vgui/glide_homing_launcher_icon")
	SWEP.IconOverride = "glide/vgui/glide_homing_launcher.png"
	function SWEP:DrawHUD()
		local remaining = math.max(self:GetNextPrimaryFire() - CurTime(), 0)
		local text = remaining > 0 and string.format("섬광 충전: %.1f초", remaining) or "좌클릭: 범위 섬광"
		draw.SimpleText(text, "DermaDefaultBold", ScrW() * 0.5, ScrH() * 0.7, color_white, TEXT_ALIGN_CENTER)
	end
end
