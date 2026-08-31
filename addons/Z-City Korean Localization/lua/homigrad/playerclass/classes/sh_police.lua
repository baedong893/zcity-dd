local CLASS = player.RegClass("police")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    -- Male
    ["male 01"] = "models/monolithservers/mpd/male_01.mdl",
    ["male 03"] = "models/monolithservers/mpd/male_03.mdl",
    ["male 04"] = "models/monolithservers/mpd/male_04_2.mdl",
    ["male 05"] = "models/monolithservers/mpd/male_05.mdl",
    ["male 07"] = "models/monolithservers/mpd/male_07_2.mdl",
    ["male 08"] = "models/monolithservers/mpd/male_08.mdl",
    ["male 09"] = "models/monolithservers/mpd/male_09_2.mdl",
    -- FEMKI
}

local ranks = {
    {name = "총경", chance = 5},     -- Chief
    {name = "경정", chance = 5},     -- Cmdr. (Commander)
    {name = "경감", chance = 15},    -- Cpt. (Captain)
    {name = "경위", chance = 35},    -- Lt. (Lieutenant)
    {name = "경사", chance = 45},    -- Sgt. (Sergeant)
    {name = "순경", chance = 80}     -- Officer
}

local clr = Color(10, 10, 100):ToVector()
function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance
    Appearance.AAttachments = ""
    Appearance.AColthes = ""

    local randomValue = math.random(100)
    local cumulativeChance = 0
    local rank = "순경" -- 기본값

    for _, rankInfo in ipairs(ranks) do
        cumulativeChance = cumulativeChance + rankInfo.chance
        if randomValue <= cumulativeChance then
            rank = rankInfo.name
            break
        end
    end

    self:SetNWString("PlayerName", rank .. " " .. Appearance.AName)
    self:SetPlayerColor(clr)
    self:SetModel(models[string.lower(Appearance.AModel)] or table.Random(models))
    self:SetBodyGroups("000000000000000000")
    self:SetSubMaterial()
    self:SetNetVar("Accessories", Appearance.AAttachmets or "none")
    self.CurAppearance = Appearance
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

