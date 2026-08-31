SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.PrintName = "SLUGCAT"
SWEP.Author = "john rainworld"
SWEP.Instructions = [[FIVE PEBBLES 탄환을 사용하는 권총입니다.

레인 월드(RAIN WORLD)에서 가장 조용한 고양이 중 하나입니다.

...내 말이 들리나?

내 방 바닥에 앉아 있는 작은 짐승아. 네가 무엇을 찾고 있는지 알 것 같구나.

너는 반복되는 굴레, 되풀이되는 패턴 속에 갇혀 있지. 여기서 벗어날 길을 원하고 있어.

하지만 그 갈망이 널 특별하게 만들어 주지는 않는다는 걸 알아두렴. 연산 계층의 미생물부터, 실례지만 그들에 비하면 신이나 다름없는 나에 이르기까지 모든 생명체가 그 똑같은 좌절감을 공유하고 있으니까.

먼저 좋은 소식부터 말해주지. 어떤 의미에서 내가 바로 네가 찾던 존재다. 나와 내 동족들은 너와 수많은 이들의 가슴 속에 요동치는 그 폐쇄공포증을 해결하는 것을 목적으로 존재하거든. 기묘한 자선이지. 너는 모르는 수혜자요, 나는 내키지 않는 선물이라니. 그 고결한 후원자들? 다 떠나고 없단다.

나쁜 소식은 명확한 해결책이 발견되지 않았다는 거야. 그리고 매 순간 장치들은 부식되어 새로운 붕괴 상태로 접어들고 있지. 나는 너희 집단을 도울 수도, 너 개인을 도울 수도 없다. 심지어 나 자신조차 도울 수 없지.

하지만 너에게는 다른 길이 있다. 오래된 길이지. 농장 배열지(Farm Arrays)를 지나 서쪽으로 가거라. 그리고 땅이 갈라진 곳을 통해 지면 아래로, 네가 닿을 수 있는 가장 깊은 곳까지 내려가렴. 고대인들이 사원을 짓고 그들의 우스꽝스러운 의식을 치르며 춤추던 곳 말이다. 내가 준 표식이 널 통과시켜 줄 것이다.

그게 누군가의 문제를 해결해 주지는 못하겠지만, 네 문제는 해결해 주겠지.]]
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/salat_port/slugcat_figure.mdl"
//SWEP.WorldModelFake = "models/salat_port/slugcat_figure.mdl"

SWEP.FakePos = Vector(1, 1.005, -1.21)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-1.6,-0.1,0)
SWEP.AttachmentAng = Angle(0,0,0)


SWEP.DOZVUK = true

SWEP.FakeReloadSounds = {
	[0.4] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",

	[0.70] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",

}

SWEP.FakeEmptyReloadSounds = {
	[0.4] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",

	[0.70] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
	[1.05] = "zcitysnd/sound/weapons/m9/handling/m9_boltrelease.wav",
}
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m45_8.mdl"
local vector_full = Vector(1,1,1)

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(0,-1,0)
SWEP.lmagang2 = Angle(0,0,0)

SWEP.FakeReloadEvents = {
	[0.2] = function( self, timeMul ) 
		if CLIENT and self:Clip1() < 1 then
			self:GetWM():SetBodygroup(1,1)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1.5 * timeMul)
		end 
	end,
	[0.43] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			hg.CreateMag( self, Vector(0,55,-55) )
			self:GetWM():ManipulateBoneScale(92, vector_origin)
		end 
	end,
	[0.55] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			self:GetWM():SetBodygroup(1,0)
			self:GetWM():ManipulateBoneScale(92, vector_full)
		end 
	end,
}

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reloadempty",
}

SWEP.WepSelectIcon2 = Material("vgui/wep_jack_hmcd_suppressed.png")
SWEP.IconOverride = "vgui/wep_jack_hmcd_suppressed.png"

SWEP.weaponInvCategory = 4

SWEP.weight = 1
SWEP.punchmul = 0
SWEP.punchspeed = 1
SWEP.CustomShell = "9x19"
SWEP.norecoil = true
SWEP.NoWINCHESTERFIRE = true


SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(5.767,0.001,2.28)
SWEP.LocalMuzzleAng = Angle(0.7,-0.1,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 352525
SWEP.Primary.DefaultClip = 352525
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "14.5x114mm B32"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 555555
SWEP.Primary.Sound = {"zcity/voice/slugcat_1/waw_1.mp3", 0, 100, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 555555
SWEP.Primary.Wait = 0.01
SWEP.ReloadTime = 0
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		--[3] = {"supressor3", Vector(0,0.2,0), {}},
		["mount"] = Vector(-0.1,0.4,0.03),
	},
	underbarrel = {
		["mount"] = Vector(13, -1.4, -1),
		["mountAngle"] = Angle(0, -0.75, 90),
		["mountType"] = "picatinny_small"
	},
}

SWEP.ReloadTime = 4
SWEP.ReloadSoundes = {
	"none",
	"none",
	"zcity/voice/slugcat_1/waw_2.mp3",
	"zcity/voice/slugcat_1/waw_1.mp3",
	"none",
	"zcity/voice/slugcat_1/waw_1.mp3",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_tpistol" -- shared in sh_effects.lua

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-3, -0.0136, 2.9594)
SWEP.RHandPos = Vector(-2, 0, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.00, -0.01, 0), Angle(-0.01, 0.01, 0)}
SWEP.Ergonomics = 1
SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 0.1
SWEP.addSprayMul = 0.25
SWEP.Penetration = 6.5
SWEP.WorldPos = Vector(4,-1.5,-2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-0.1,-0.9,0)
SWEP.lengthSub = 25
SWEP.DistSound = "zcity/voice/slugcat_1/waw_1.mp3"

SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.ShockMultiplier = 0.8
SWEP.HurtMultiplier = 1
SWEP.PainMultiplier = 1

--local to head
SWEP.RHPos = Vector(12,-4.5,3.5)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

local finger1 = Angle(-65,50,-70)
local finger2 = Angle(-10,-10,-0)
local finger3 = Angle(31,1,-25)
local finger4 = Angle(-10,-5,-5)
local finger5 = Angle(0,-65,-15)
local finger6 = Angle(15,-5,-15)

function SWEP:AnimHoldPost()
	--self:BoneSet("r_finger0", vector_zero, finger6)
	--self:BoneSet("l_finger0", vector_zero, finger1)
    --self:BoneSet("l_finger02", vector_zero, finger2)
	--self:BoneSet("l_finger1", vector_zero, finger3)
	--self:BoneSet("r_finger1", vector_zero, finger4)
	--self:BoneSet("r_finger11", vector_zero, finger5)
	
end

SWEP.podkid = 1

SWEP.ShootAnimMul = 5
SWEP.SightSlideOffset = 1.2

function SWEP:DrawPost()
	
end

function SWEP:ModelCreated(model)
	local wep = self:GetWeaponEntity()
	if IsValid(wep) then
		wep:SetBodygroup(0, math.Round(util.SharedRandom("asdslug"..self:EntIndex(), 0, 6)))
	end
end

--RELOAD ANIMS PISTOL

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,0),
	"fastreload",
	Vector(0,0,0),
	"reloadend",
	"reloadend",
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,40),
	Angle(0,0,40),
	Angle(0,0,90),
	Angle(0,0,40),
	Angle(0,0,90),
	Angle(0,0,40),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(-2,0,2),
	Vector(0,0,0),
	Vector(0,0,0)
}
SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(15,2,20),
	Angle(15,2,20),
	Angle(0,0,0)
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
}


-- Inspect Assault

SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(4,4,15),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(-6,-15,-15),
	Angle(1,15,-45),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(0,0,0),
	Angle(0,0,0)
}