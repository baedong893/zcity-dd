local weapon_class = "weapon_thaumaturgic_arm"
local SWEP = {}
SWEP.Primary = {}
SWEP.Secondary = {}

if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "기적의 팔 (Thaumaturgic Arm)"
SWEP.Instructions = [[
기적의 팔은 나중에 수행할 의식에 사용하기 위해 사용자에게서 혈액을 직접 추출할 수 있게 해줍니다.

R + 마우스 왼쪽 버튼을 눌러 본인에게서 100의 혈액을 추출하십시오.

연속적인 사용을 방해하는 무언가가 느껴집니다. 손에 피로가 쌓이기 시작합니다.

일반 공격 시, 대상이 인간일 경우 혈액 100을 흡수합니다. 
대상이 쓰러진(Ragdoll) 상태라면 300을 흡수합니다. 
흡수한 양의 2배(추출량 / 100 * 200)만큼 사용자의 변종 혈액(Abnormal Blood)이 보충됩니다.

이 무기는 벽을 타격하거나 보조 공격을 사용할 때를 제외하고는 아무런 소리를 내지 않습니다.

별도의 시각 효과는 발생하지 않습니다.

일반 공격에는 타격 피해가 없습니다.

보조 공격으로만 직접적인 피해를 입힐 수 있습니다.

이 무기로 인한 출혈은 매우 치명적입니다.
]]
SWEP.ThaumaturgicArm = true
--Each secondary strike will collapse the victim.

SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"
SWEP.WorldModelReal = "models/weapons/gleb/c_knife_t.mdl"
SWEP.WorldModelExchange = "models/weapons/w_models/w_jyringe_proj.mdl"
SWEP.DontChangeDropped = true
SWEP.modelscale = 0.85
SWEP.modelscale2 = 1

SWEP.BleedMultiplier = 3

SWEP.weaponPos = Vector(-3.0,0.1,-0.2)
SWEP.weaponAng = Angle(0,180,90)
SWEP.attack_ang = Angle(-55,-3,0)
SWEP.HoldPos = Vector(2,2,0)
SWEP.HoldAng = Angle(0,0,0)
SWEP.AttackPos = Vector(0,0,-10)
SWEP.AnimTime1 = 0.8
SWEP.AttackTime = 0.3
SWEP.Attack2Time = 0.3
SWEP.WaitTime1 = 0.6
SWEP.WaitTime2 = 0.5
SWEP.AnimTime2 = 1
SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 0
SWEP.DamageSecondary = 8
SWEP.basebone = 76

SWEP.AttackLen1 = 60
SWEP.AttackLen2 = 50


SWEP.AttackSwing = ""
SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = ""
SWEP.Attack2HitFlesh = "snd_jack_hmcd_slash.wav"
SWEP.DeploySnd = ""

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "stab_miss",
    ["attack2"] = "midslash1",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_traumatic_arm.png")
	SWEP.IconOverride = "vgui/icons/ico_traumatic_arm.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.BreakBoneMul = 0.1
SWEP.ImmobilizationMul = 2
SWEP.StaminaMul = 0.5
function SWEP:Initialize()
    self.attackanim = 0
    self.sprintanim = 0
    self.animtime = 0
    self.animspeed = 1
    self.reverseanim = false
    self.Initialzed = true
    self:PlayAnim("idle",10,true)

    self:SetAttackLength(self.AttackLen1)
    self:SetAttackWait(0)

    self:SetHold(self.HoldType)

    self:InitAdd()
end

function SWEP:HurtOwner()
	local ent = self:GetOwner()
	local max_blood_take = 100
	local blood_take = 100
	local old_blood = ent.organism.blood
	local new_blood = math.max(ent.organism.blood - blood_take, 0)
	local lost_blood = old_blood - new_blood
	ent.Abnormalties_Blood = (ent.Abnormalties_Blood or 0) + (lost_blood / max_blood_take) * 200
	ent.organism.blood = new_blood
	
	if(hg.Abnormalties)then
		hg.Abnormalties.ShowMessage(ent, tostring(math.Round(ent.Abnormalties_Blood)))
	end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
	addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -1 or 0)
	addPosLerp.x = addPosLerp.x + (self:GetBlocking() and -4 or 0)
	addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -11 or 0)
	addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 120 or 0)
    return true
end

-- function SWEP:StartHurtingSelf()
	-- self.HurtSelf = self:GetOwner()
	
	-- self:SetOwner(game.GetWorld())
-- end

-- function SWEP:StopHurtingSelf()
	-- if(IsValid(self.HurtSelf))then
		-- self:SetOwner(self.HurtSelf)
	-- end

	-- self.HurtSelf = nil
-- end

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_SLASH
	
	self:SetAttackLength(self.AttackLen2)
    return true
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_CLUB
	
	if(self:GetOwner():KeyDown(IN_RELOAD) and self:GetOwner():KeyPressed(IN_ATTACK))then
		if(SERVER)then
			self:HurtOwner()
		end
		
		return false
	else
		self:SetAttackLength(self.AttackLen1)
	end
	
    return true
end

hook.Add("EntityTakeDamage", "Abnormalties_Weapon", function(ent, dmg)
	local attacker = dmg:GetAttacker()
	
	if(IsValid(attacker) and attacker:IsPlayer())then
		local wep = attacker:GetActiveWeapon()
		
		if(IsValid(wep) and wep:GetClass() == weapon_class and dmg:GetDamage() <= 3)then
			if((ent:IsPlayer() or ent:GetClass() == "prop_ragdoll") and ent.organism)then
				local max_blood_take = 100
				local blood_take = 300
				
				if(ent:IsPlayer())then
					blood_take = 100
				end
				
				local old_blood = ent.organism.blood
				local new_blood = math.max(ent.organism.blood - blood_take, 0)
				local lost_blood = old_blood - new_blood
				attacker.Abnormalties_Blood = (attacker.Abnormalties_Blood or 0) + (lost_blood / max_blood_take) * 200
				ent.organism.blood = new_blood
				
				if(hg.Abnormalties)then
					hg.Abnormalties.ShowMessage(attacker, tostring(math.Round(attacker.Abnormalties_Blood)))
				end
			end
		end
	end
end)

weapons.Register(SWEP, weapon_class)