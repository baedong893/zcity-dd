local MODE = MODE

zb = zb or {}
zb.Points = zb.Points or {}

zb.Points.NPC_DEFENSE_SPAWN= zb.Points.NPC_DEFENSE_SPAWN or {}
zb.Points.NPC_DEFENSE_SPAWN.Color = Color(243,9,9)
zb.Points.NPC_DEFENSE_SPAWN.Name = "NPC_DEFENSE_SPAWN"

zb.Points.PLY_DEFENSE_SPAWN = zb.Points.PLY_DEFENSE_SPAWN or {}
zb.Points.PLY_DEFENSE_SPAWN.Color = Color(51,243,9)
zb.Points.PLY_DEFENSE_SPAWN.Name = "PLY_DEFENSE_SPAWN"

zb.Points.DEFENSE_POINT = zb.Points.DEFENSE_POINT or {}
zb.Points.DEFENSE_POINT.Color = Color(13,9,243)
zb.Points.DEFENSE_POINT.Name = "DEFENSE_POINT"


MODE.SUBMODES = {
    STANDARD = {
        name = "표준",
        description = "클래식한 6개 웨이브의 콤바인 공격",
        waves = 6,
        enemy_type = "combine"
    },
    EXTENDED = {
        name = "확장",
        description = "확장 모드: 보스와 특수 적들이 등장하는 12개 웨이브",
        waves = 12,
        enemy_type = "combine"
    },
    ZOMBIE = {
        name = "좀비",
        description = "6개 웨이브의 좀비 아포칼립스",
        waves = 6,
        enemy_type = "zombie"
    }
}