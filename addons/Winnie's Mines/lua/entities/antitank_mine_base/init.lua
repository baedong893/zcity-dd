AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
DEFINE_BASECLASS("_mine_entity")

if (SERVER) then
    util.AddNetworkString("MineExplosionBlur_net")
end
 

function ENT:Initialize() BaseClass.Initialize(self) end

function ENT:Touch(ent)
    if (ent:GetClass():lower() == self:GetClass() or (ent:GetClass():find("trigger")) or ent:IsPlayer() or self.desactived) then 
        return 
    end
  
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(2000)
    dmginfo:SetAttacker(self:GetCreator())
    dmginfo:SetDamageType(DMG_DIRECT)
    dmginfo:SetInflictor(self)
    dmginfo:SetDamagePosition(self:GetPos())

    if (ent:GetClass() == "gmod_sent_vehicle_fphysics_wheel") then ent:GetBaseEnt():TakeDamageInfo(dmginfo)
    else ent:TakeDamageInfo(dmginfo) end

    self:Detonate()
end

function ENT:Use(ply) BaseClass.Use(self, ply) end

function ENT:Think() BaseClass.Think(self) end

function ENT:Detonate()  
    local plyTbl = player.GetAll()
    local plyToApply = {}
    for _, ply in pairs(plyTbl) do
        if ply:Alive() and self:GetPos():Distance(ply:GetPos()) <= 600 then
            table.insert(plyToApply, ply)
        end
    end

    net.Start("MineExplosionBlur_net")
    net.Send(plyToApply)

    BaseClass.Detonate(self)
end