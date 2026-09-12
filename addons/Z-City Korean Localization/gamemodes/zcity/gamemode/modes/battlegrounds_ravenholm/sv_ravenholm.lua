local MODE = MODE

for _, id in ipairs(MODE.VariantOrder) do
    resource.AddFile("sound/" .. MODE.Variants[id].IntroSound)
end

local function Parent(mode)
    return zb.modes[mode.base]
end

function MODE:IsSurvivor(ply)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() or ply:Team() == TEAM_SPECTATOR then return false end
    if ply.organism and ply.organism.incapacitated then return false end
    -- Attachment and completed transformation are separate states: conversion
    -- clears the headcrab netvar while leaving the player entity alive.
    return ply.PlayerClassName ~= "headcrabzombie" and not ply:GetNetVar("headcrab", false)
end

function MODE:CheckAlivePlayers()
    local survivors = {}
    for _, ply in player.Iterator() do
        if self:IsSurvivor(ply) then survivors[#survivors + 1] = ply end
    end
    -- The HUD receives the count used by victory/NPC targeting, including on reconnect.
    SetGlobalInt(self.SurvivorCountNetworkKey, #survivors)
    return survivors
end

local function ClosestPlayer(npc, players)
    local closest, distance
    for _, ply in ipairs(players) do
        local candidate = npc:GetPos():DistToSqr(ply:GetPos())
        if not distance or candidate < distance then closest, distance = ply, candidate end
    end
    return closest, distance
end

local function PickZombie(mode)
    local variant = mode:GetVariant()
    if not variant then return end
    local total = 0
    for _, definition in ipairs(variant.Hostiles) do total = total + definition.weight end
    local roll = math.random(total)
    for _, definition in ipairs(variant.Hostiles) do
        roll = roll - definition.weight
        if roll <= 0 then return definition end
    end
end

local function CollectHeadcrabs(mode)
    local zombies = mode.saved.Zombies
    if not zombies or #zombies == 0 then return end
    -- Source zombies give released/thrown headcrabs their zombie as owner.
    -- Keep these children in the same list so they share targeting and cleanup.
    for _, npc in ipairs(ents.FindByClass("npc_headcrab*")) do
        if table.HasValue(zombies, npc:GetOwner()) and not table.HasValue(zombies, npc) then
            zombies[#zombies + 1] = npc
        end
    end
end

function MODE:ClearZombies()
    CollectHeadcrabs(self)
    -- Clear ownership before Remove triggers entity/death hooks.
    local zombies = self.saved.Zombies or {}
    self.saved.Zombies = {}
    self.saved.NextZombieSpawn = nil
    for _, npc in ipairs(zombies) do
        if IsValid(npc) then npc:Remove() end
    end
end

function MODE:Intermission()
    self:ClearZombies()
    Parent(self).Intermission(self)
    self.saved.VariantId = self.VariantOrder[math.random(#self.VariantOrder)]
    SetGlobalString(self.VariantNetworkKey, self.saved.VariantId)
    SetGlobalFloat(self.IntroNetworkKey, CurTime() + self.IntroLeadTime)
    self:CheckAlivePlayers()
end

function MODE:RoundStart()
    -- A direct start without an intermission still chooses only once.
    if not self:GetVariant() then self:Intermission() end
    Parent(self).RoundStart(self)
    self:CheckAlivePlayers()
    self.saved.Zombies = self.saved.Zombies or {}
    self.saved.NextZombieSpawn = CurTime() + self.ZombieFirstSpawnDelay
end

function MODE:RoundThink()
    if CurrentRound() ~= self or zb.ROUND_STATE ~= 1 then return end
    CollectHeadcrabs(self)
    local players = self:CheckAlivePlayers()
    local zombies = self.saved.Zombies or {}
    self.saved.Zombies = zombies
    local farthest = self.ZombieDespawnRadius * self.ZombieDespawnRadius

    for index = #zombies, 1, -1 do
        local npc = zombies[index]
        if not IsValid(npc) then
            table.remove(zombies, index)
        else
            local target, distance = ClosestPlayer(npc, players)
            if npc:Health() <= 0 or not target or distance > farthest then
                table.remove(zombies, index)
                npc:Remove()
            else
                for _, ply in player.Iterator() do
                    npc:AddEntityRelationship(ply, ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and D_HT or D_NU, 99)
                end
                npc:SetEnemy(target)
                npc:UpdateEnemyMemory(target, target:GetPos())
            end
        end
    end

    if #players == 0 or CurTime() < (self.saved.NextZombieSpawn or 0) then return end
    self.saved.NextZombieSpawn = CurTime() + self.ZombieSpawnInterval
    local provider = zb.modes[self.HostileNPCProvider]
    if not provider or not provider.SpawnHostileNPC then return end
    local limit = math.Clamp(#players * self.ZombiesPerPlayer, self.ZombieMinimum, self.ZombieMaximum)
    for _ = 1, math.min(self.ZombieSpawnBatch, math.max(limit - #zombies, 0)) do
        local target = players[math.random(#players)]
        local center = target:GetPos()
        local pos = provider:FindNavMeshSpawnPoint(center, self.ZombieSpawnMinRadius, self.ZombieSpawnMaxRadius)
            or provider:FindValidSpawnPoint(center, self.ZombieSpawnMaxRadius)
        -- Both paths use defense's floor/hull/visibility checks; the fallback must also stay nearby.
        local distance = pos and center:DistToSqr(pos)
        if distance and distance >= self.ZombieSpawnMinRadius ^ 2 and distance <= self.ZombieSpawnMaxRadius ^ 2
            and util.IsInWorld(pos) and bit.band(util.PointContents(pos), bit.bor(CONTENTS_WATER, CONTENTS_SLIME)) == 0 then
            local definition = PickZombie(self)
            local npc = definition and provider:SpawnHostileNPC(definition, pos)
            if IsValid(npc) then
                npc:SetHealth(definition.health)
                npc:SetMaxHealth(definition.health)
                for _, ply in player.Iterator() do
                    npc:AddEntityRelationship(ply, ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and D_HT or D_NU, 99)
                end
                npc:SetEnemy(target)
                provider:AssignNPCTarget(npc)
                zombies[#zombies + 1] = npc
            end
        end
    end
end

function MODE:EntityRemoved(ent)
    -- Capture children before the engine clears their removed owner's handle.
    if self.saved.Zombies and table.HasValue(self.saved.Zombies, ent) then
        CollectHeadcrabs(self)
    end
end

function MODE:EndRound()
    self:ClearZombies()
    Parent(self).EndRound(self)
    self:ClearIntro()
end

function MODE:ClearIntro()
    self.saved.VariantId = nil
    SetGlobalString(self.VariantNetworkKey, "")
    SetGlobalFloat(self.IntroNetworkKey, 0)
    SetGlobalInt(self.SurvivorCountNetworkKey, 0)
end

function MODE:ZB_PreRoundStart()
    -- Waiting-room selection can switch modes without calling EndRound.
    self:ClearZombies()
    self:ClearIntro()
end

function MODE:BoringRoundFunction()
    -- Without a safe zone, distance to an arbitrary map center must not award a win.
    self.saved.Winner = nil
end

function MODE:PostCleanupMap()
    self:ClearZombies()
    SetGlobalFloat(self.IntroNetworkKey, 0)
end
