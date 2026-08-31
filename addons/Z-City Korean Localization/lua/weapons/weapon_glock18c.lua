SWEP.Base = "weapon_glock17"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Glock 18C"
SWEP.Author = "Glock GmbH"
SWEP.Instructions = "글록(Glock)은 오스트리아의 글록(Glock Ges.m.b.H.)사가 설계 및 생산하는 폴리머 프레임, 쇼트 리코일 방식, 스트라이커 격발식, 폐쇄 노리쇠 반자동 권총 브랜드입니다. 현재 모델은 9x19mm 탄환을 사용하는 글록 18(Glock 18) 버전으로, 전용 자동 사격 모드를 지원합니다."
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10

SWEP.FakeBodyGroups = "00030"
SWEP.FakeBodyGroupsPresets = {
	"00030",
	"10030",
	"00030",
	"10030",
	"00030",
	"10030",
	"00030",
	"10030",
	"00030",
	"10030",
	"00030",
	"10030",
}

function SWEP:InitializePost()
	local Skin = math.random(0,2)
	if math.random(0,100) > 99 then
		Skin = 3
	end
	self:SetGlockSkin(Skin)
	self:SetRandomBodygroups(self.FakeBodyGroupsPresets[math.random(#self.FakeBodyGroupsPresets)] or "00030")
end

SWEP.WepSelectIcon2 = Material("vgui/hud/tfa_ins2_glock_p80.png")
SWEP.IconOverride = "entities/weapon_pwb_glock17.png"

SWEP.Primary.Automatic = true
SWEP.Primary.Wait = 0.05
SWEP.AnimShootHandMul = 0.01

SWEP.punchmul = 0.5
SWEP.punchspeed = 3

SWEP.podkid = 0.5