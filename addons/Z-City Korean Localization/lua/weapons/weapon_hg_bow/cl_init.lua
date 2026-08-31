include("shared.lua")
SWEP.Category = "Weapons - Other"
SWEP.PrintName = "\"디어 헌터\" 컴파운드 보우"
SWEP.Instructions = "이 활은 290뉴턴의 당김 하중을 가진 현대식 알루미늄-파이버글래스 컴파운드 보우입니다. 주로 브로드헤드 화살촉과 함께 북미의 중형 게임(사냥감)을 포획하는 데 사용됩니다. \n\n마우스 오른쪽 버튼: 조준 \n조준 중 마우스 왼쪽 버튼: 발사 \n비조준 시 마우스 왼쪽 버튼: 타격"
SWEP.WorldModelReal = "models/z_city/nmrih/weapons/bow/v_bow_deerhunter.mdl"
SWEP.WorldModelExchange = false
SWEP.setlh = true
SWEP.setrh = true
SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.WepSelectIcon = Material("entities/zcity/deerhunterbow.png")
SWEP.IconOverride = "entities/zcity/deerhunterbow.png"
SWEP.BounceWeaponIcon = false

SWEP.HoldPos = Vector(0,0,0)
SWEP.HoldAng = Angle(0,0,0)

--SWEP.LerpHoldPos = Vector(0,0,0)
--SWEP.LerpHoldAng = Angle(0,0,0)

function SWEP:PostSetHandPos()
    self.LerpHoldPos = self.LerpHoldPos or Vector(0,0,0)
    self.LerpHoldAng = self.LerpHoldAng or Angle(0,0,0)

    self.HoldPos = LerpVectorFT(0.03,self.HoldPos,self.LerpHoldPos)
    self.HoldAng = LerpAngleFT(0.02,self.HoldAng,self.LerpHoldAng)


    if self.AnimArHoldtypes[self.seq] then
        self.LerpHoldPos.x = self:IsLocal() and 13 or 15.5
        self.LerpHoldPos.y = self:IsLocal() and 0.65 or 0
        self.LerpHoldAng[3] = 2
        self.HoldType = "ar2"
    else
        self.HoldType = "slam"
        self.LerpHoldPos.x = 0
        self.LerpHoldAng[3] = 0
    end
end