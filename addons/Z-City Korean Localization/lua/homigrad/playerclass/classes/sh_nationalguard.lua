local CLASS = player.RegClass("nationalguard")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {}
for i = 1, 9 do
    table.insert(models,"models/dejtriyev/enhancednatguard/male_0"..i..".mdl")
end

local ranks = {
    {name = "이병", chance = 25},      -- PVT (Private)
    {name = "일병", chance = 20},      -- PV2 (Private Second Class)
    {name = "상병", chance = 18},      -- PFC (Private First Class)
    {name = "상병(기술병)", chance = 12}, -- SPC (Specialist)
    {name = "병장", chance = 8},       -- CPL (Corporal)
    {name = "하사", chance = 7},       -- SGT (Sergeant)
    {name = "중사", chance = 4},       -- SSG (Staff Sergeant)
    {name = "상사", chance = 2.5},     -- SFC (Sergeant First Class)
    {name = "원사", chance = 1.2},     -- MSG (Master Sergeant)
    {name = "일등상사", chance = 0.8}, -- 1SG (First Sergeant)
    {name = "주임원사", chance = 0.5}, -- SGM (Sergeant Major)
    {name = "명령주임원사", chance = 0.3}, -- CSM (Command Sergeant Major)
    {name = "육군주임원사", chance = 0.1}, -- SMA (Sergeant Major of the Army)
    {name = "소위", chance = 0.3},     -- 2LT (Second Lieutenant)
    {name = "중위", chance = 0.2},     -- 1LT (First Lieutenant)
    {name = "대위", chance = 0.08},    -- CPT (Captain)
    {name = "소령", chance = 0.02},    -- MAJ (Major)
}

local clr = Color(5, 65, 0):ToVector()
function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""

    local randomValue = math.random() * 100
    local cumulativeChance = 0
    local rank = "PVT"

    for _, rankInfo in ipairs(ranks) do
        cumulativeChance = cumulativeChance + rankInfo.chance
        if randomValue <= cumulativeChance then
            rank = rankInfo.name
            break
        end
    end

    self:SetNWString("PlayerName", rank .. " " .. Appearance.AName)
    self:SetPlayerColor(clr)
    self:SetModel(models[math.random(#models)])
    self:SetBodygroup(0,14)
    self:SetSubMaterial()
    self.CurAppearance = Appearance
end

local function IsLookingAt(ply, targetVec)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local diff = targetVec - ply:GetShootPos()
    return ply:GetAimVector():Dot(diff) / diff:Length() >= 0.8 
end

function CLASS.Guilt(self, Victim)
    if CLIENT then return end

    if Victim:GetPlayerClass() == self:GetPlayerClass() then
        --self:ChatPrint("You killed your teammate!")
        return 1
    end

    if CurrentRound().name == "hmcd" then
        return zb.ForcesAttackedInnocent(self, Victim)
    end

    return 1
end

hook.Add("HG_PlayerFootstep", "nationalguard_footsteps", function(ply, pos, foot, sound, volume, rf)
	local chr = hg.GetCurrentCharacter(ply)
	if ply:Alive() and ply.PlayerClassName == "nationalguard" then
		local ent = hg.GetCurrentCharacter(ply)

		if not (ply:IsWalking() or ply:Crouching()) and ent == ply then
			local snd = "zcitysnd/" .. string.Replace(sound, "player/footsteps", "player/footsteps_military/")
			if SoundDuration(snd) <= 0 then
				snd = sound -- missing footsteps fix
			end
			EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95,105)) )

			return true
		end
	end
end)