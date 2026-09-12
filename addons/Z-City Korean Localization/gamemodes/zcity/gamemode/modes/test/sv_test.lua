local MODE = MODE

local function GiveTestEquipment(ply)
    local hands = ply:Give("weapon_hands_sh")
    if IsValid(hands) then ply:SelectWeapon("weapon_hands_sh") end
end

local function ResetIdlePlayers()
    for _, ply in player.Iterator() do
        zb.ResetAFK(ply)
    end
end

function MODE:Intermission()
    game.CleanUpMap()
    ResetIdlePlayers()

    -- The round system already respawns participants before Intermission.
    for _, ply in player.Iterator() do
        if IsValid(ply) and ply:Team() ~= TEAM_SPECTATOR then
            ApplyAppearance(ply, nil, nil, nil, true)
            ply:SetupTeam(0)
            ply:Freeze(false)
        end
    end
end

function MODE:GiveEquipment()
    for _, ply in player.Iterator() do
        if IsValid(ply) and ply:Team() ~= TEAM_SPECTATOR and ply:Alive() then
            GiveTestEquipment(ply)
        end
    end
end

function MODE:RoundStart()
    ResetIdlePlayers()
end

function MODE:PlayerDeathThink(ply)
    if zb.ROUND_STATE ~= 1 then return end
    if not IsValid(ply) or not ply:IsPlayer() or ply:Alive() or ply:IsBot() then return end
    if ply:Team() == TEAM_SPECTATOR or not ply:KeyPressed(IN_ATTACK) then return end

    -- Use normal spawning to reset the body and leave spectator mode.
    -- KeyPressed requires a fresh click, so holding fire through death cannot respawn.
    ply:Spawn()
    if not ply:Alive() then return end
    ply:SetPlayerClass()
    ply:SetupTeam(0)
    ply:Freeze(false)
    zb.ResetAFK(ply)
    GiveTestEquipment(ply)
    -- Do not run the spectator/death handlers again after a successful respawn.
    return true
end

function MODE:EndRound()
    -- Leave the next mode a fresh AFK grace period.
    ResetIdlePlayers()
end
