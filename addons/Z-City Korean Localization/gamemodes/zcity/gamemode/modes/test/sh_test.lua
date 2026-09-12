local MODE = MODE

MODE.name = "test"
MODE.PrintName = "테스트 모드"
MODE.Description = "수동 선택 전용. 1명부터 시작하며 잠수로 관전 전환되거나 추방되지 않습니다. 사망 후 좌클릭으로 부활합니다. 관리자가 라운드를 넘길 때까지 계속됩니다."
MODE.MenuVisible = true
MODE.ManualOnly = true
MODE.Chance = 0
MODE.AllowSoloActivePlayer = true
MODE.DisableAutoBot = true
MODE.DisableAFK = true
MODE.DisableAutoRTV = true
MODE.TrackRoundWins = false
MODE.GuiltDisabled = true
MODE.LootSpawn = false
MODE.ForBigMaps = false
MODE.randomSpawns = true
MODE.start_time = 0
MODE.ROUND_TIME = 0

-- Explicit false also disables the shared round timer's timeout fallback.
function MODE:ShouldRoundEnd()
    return false
end
