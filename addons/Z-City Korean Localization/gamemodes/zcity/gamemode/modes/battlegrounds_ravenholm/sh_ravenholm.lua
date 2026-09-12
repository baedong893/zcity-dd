local MODE = MODE

MODE.base = "battlegrounds"
MODE.name = "ravenholm"
MODE.PrintName = "레이븐홈 / 17번 지구"
MODE.MinPlayers = 2
MODE.Description = "시작할 때 레이븐홈 또는 17번 지구가 무작위로 선택됩니다. 무기를 파밍하며 좀비 또는 전기봉을 든 시민보호 기동대를 피해 최후까지 살아남으십시오. 자기장, 보급, 레드존은 없습니다."
MODE.Chance = 0.02
MODE.MenuVisible = true
MODE.EnableRedZones = false
MODE.EnableAirdrops = false
MODE.EnableSafeZone = false
MODE.AnnounceStartInChat = false
MODE.NoWinnerMessage = "이번 생존전이 승자 없이 종료되었습니다."

-- One registry entry; the per-round variant never replaces the registered mode id.
MODE.VariantOrder = {"ravenholm", "city17"}
MODE.VariantNetworkKey = "ZC_HLS_Variant"
MODE.IntroNetworkKey = "ZC_HLS_IntroStart"
MODE.SurvivorCountNetworkKey = "ZC_HLS_SurvivorCount"
MODE.IntroLeadTime = 0.5
MODE.IntroFadeTime = 0.6
MODE.Variants = {
    ravenholm = {
        PrintName = "레이븐홈에는 가지않아..",
        IntroSubtitle = "죽은 자들의 마을",
        IntroDescription = "주변에 좀비가 출몰합니다.\n무기를 파밍하고 최후까지 살아남으십시오.",
        StartMessage = "주변에 좀비가 출몰합니다. 무기를 파밍하고 최후의 생존자가 되십시오.",
        IntroSound = "zcity/hl_survival/ravenholm_intro_full.wav",
        IntroDuration = 50.755918367347,
        IntroScreenDuration = 6,
        ZombieMinimum = 16,
        ZombieSpawnInterval = 3,
        ZombieSpawnBatch = 3,
        Hostiles = {
            {type = "npc_zombie", health = 120, aggressive = true, weight = 6},
            {type = "npc_fastzombie", health = 80, aggressive = true, weight = 2},
            {type = "npc_poisonzombie", health = 250, aggressive = true, weight = 1}
        }
    },
    city17 = {
        PrintName = "17번 지구",
        IntroSubtitle = "17번 지구에 오신 것을 환영합니다.",
        IntroDescription = "전기봉을 든 시민보호 기동대를 조심하십시오.\n무기를 파밍하고 최후까지 살아남으십시오.",
        StartMessage = "전기봉을 든 시민보호 기동대가 순찰 중입니다. 무기를 파밍하고 최후의 생존자가 되십시오.",
        IntroSound = "zcity/hl_survival/city17_welcome_v2.wav",
        IntroDuration = 3.3,
        Hostiles = {
            {type = "npc_metropolice", weapon = "weapon_stunstick", health = 100, aggressive = true, weight = 1}
        }
    }
}

MODE.HostileNPCProvider = "defense"
MODE.ZombieFirstSpawnDelay = 10
MODE.ZombieSpawnInterval = 4
MODE.ZombieSpawnBatch = 2
MODE.ZombiesPerPlayer = 4
MODE.ZombieMinimum = 8
MODE.ZombieMaximum = 32
MODE.ZombieSpawnMinRadius = 600
MODE.ZombieSpawnMaxRadius = 1400
MODE.ZombieDespawnRadius = 3000

function MODE:GetVariant()
    local id
    if SERVER then
        id = self.saved and self.saved.VariantId
    else
        id = GetGlobalString(self.VariantNetworkKey, "")
    end
    return self.Variants[id]
end

function MODE:GetRoundPrintName()
    local variant = self:GetVariant()
    return variant and variant.PrintName or self.PrintName
end

function MODE:GetStartMessage()
    local variant = self:GetVariant()
    return variant and variant.StartMessage or self.Description
end
