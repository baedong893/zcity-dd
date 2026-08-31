ZCLang = ZCLang or {}

local LANG_AUTO = "auto"
local langCvar

if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("ZCLang_SetLanguage")
	local allowedLanguages = {en = true, ko = true, zh = true, ru = true}

	net.Receive("ZCLang_SetLanguage", function(_, ply)
		if not IsValid(ply) then return end
		local lang = net.ReadString()
		if not allowedLanguages[lang] then return end
		if (ply.ZCLangNextSync or 0) > CurTime() then return end
		ply.ZCLangNextSync = CurTime() + 0.25
		ply:SetNWString("zc_language", lang)
	end)
else
	langCvar = GetConVar("zc_language") or CreateClientConVar("zc_language", LANG_AUTO, true, false, "Z-City display language: auto, en, ko, zh, ru")
end

ZCLang.Languages = {
	auto = "Auto",
	en = "English",
	ko = "Korean",
	zh = "Chinese",
	ru = "Russian",
}

ZCLang.Phrases = {
	main_disconnect = {
		en = "Disconnect",
		ko = "연결 끊기",
		zh = "断开连接",
		ru = "Отключиться",
	},
	main_game_menu = {
		en = "Main Menu",
		ko = "메인 메뉴",
		zh = "主菜单",
		ru = "Главное меню",
	},
	main_discord = {
		en = "Discord",
		ko = "디스코드",
		zh = "Discord",
		ru = "Discord",
	},
	main_traitor_role = {
		en = "Traitor Role",
		ko = "배신자 역할",
		zh = "叛徒角色",
		ru = "Роль предателя",
	},
	main_achievements = {
		en = "Achievements",
		ko = "업적",
		zh = "成就",
		ru = "Достижения",
	},
	main_settings = {
		en = "Settings",
		ko = "설정",
		zh = "设置",
		ru = "Настройки",
	},
	main_appearance = {
		en = "Appearance",
		ko = "외형",
		zh = "外观",
		ru = "Внешность",
	},
	main_back = {
		en = "Back",
		ko = "뒤로가기",
		zh = "返回",
		ru = "Назад",
	},
	settings_language = {
		en = "Language",
		ko = "언어",
		zh = "语言",
		ru = "Язык",
	},
		settings_language_help = {
		en = "Changes Z-City menu language.",
		ko = "Z-City 메뉴 언어를 변경합니다.",
		zh = "更改 Z-City 菜单语言。",
		ru = "Изменяет язык меню Z-City.",
	},
	common_role_english = {
		en = "Role: ",
		ko = "역할: ",
		zh = "角色：",
		ru = "Роль: ",
	},
	common_you_are_prefix = {
		en = "You are ",
		ko = "당신은 ",
		zh = "你是 ",
		ru = "Вы ",
	},
	common_you_are_suffix = {
		en = ".",
		ko = "입니다.",
		zh = "。",
		ru = ".",
	},
	spectator_target_player = {
		en = "Spectating player: ",
		ko = "관전중인 플레이어: ",
		zh = "正在观看的玩家: ",
		ru = "Наблюдаемый игрок: ",
	},
	spectator_character_name = {
		en = "In-game name: ",
		ko = "게임 내 이름: ",
		zh = "游戏内名称: ",
		ru = "Имя в игре: ",
	},
	settings_category_ui = {
		en = "UI",
		ko = "UI",
		zh = "界面",
		ru = "Интерфейс",
	},
	settings_category_gameplay = {
		en = "Gameplay",
		ko = "Gameplay",
		zh = "游戏玩法",
		ru = "Игровой процесс",
	},
	settings_category_view = {
		en = "View",
		ko = "시야",
		zh = "视角",
		ru = "Вид",
	},
	settings_category_sound = {
		en = "Sound",
		ko = "사운드",
		zh = "声音",
		ru = "Звук",
	},
	settings_category_weapons = {
		en = "Weapons",
		ko = "무기",
		zh = "武器",
		ru = "Оружие",
	},
	settings_category_optimization = {
		en = "Optimization",
		ko = "최적화",
		zh = "优化",
		ru = "Оптимизация",
	},
	settings_category_blood = {
		en = "Blood",
		ko = "혈흔",
		zh = "血迹",
		ru = "Кровь",
	},
	settings_category_debug = {
		en = "Debug",
		ko = "Debug",
		zh = "调试",
		ru = "Отладка",
	},
	settings_category_serverside_gameplay = {
		en = "Serverside Gameplay",
		zh = "Serverside Gameplay",
		ru = "Serverside Gameplay",
	},
	settings_option_hg_old_notificate = {
		en = "Old notification style",
		zh = "旧版通知样式",
		ru = "Старый стиль уведомлений",
	},
	settings_help_hg_old_notificate = {
		en = "Toggle old notifications (chatprints)",
		zh = "切换旧版通知（聊天输出）",
		ru = "Переключить старые уведомления (чат)",
	},
	settings_option_hg_cheats = {
		en = "Enable cheats",
		zh = "启用作弊",
		ru = "Включить читы",
	},
	settings_help_hg_cheats = {
		en = "Toggle uzelezz cheats",
		zh = "切换无用作弊功能",
		ru = "Переключить бесполезные читы",
	},
	settings_option_hg_showthoughts = {
		en = "Show thoughts",
		zh = "显示想法",
		ru = "Показывать мысли",
	},
	settings_help_hg_showthoughts = {
		en = "Toggle thoughts of your character",
		zh = "切换角色想法显示",
		ru = "Показывать мысли вашего персонажа",
	},
	settings_option_hg_hints = {
		en = "Show hints",
		zh = "显示提示",
		ru = "Показывать подсказки",
	},
	settings_help_hg_hints = {
		en = "Toggle UI hints",
		zh = "切换界面提示",
		ru = "Переключить подсказки интерфейса",
	},
	settings_option_hg_gary = {
		en = "HG Gary",
		zh = "HG Gary",
		ru = "HG Gary",
	},
	settings_help_hg_gary = {
		en = "center weapon in fake",
		zh = "在假镜头中居中武器",
		ru = "Центрировать оружие в фальшивой камере",
	},
	settings_option_hg_deathfadeout = {
		en = "Fade out on death",
		zh = "死亡时淡出",
		ru = "Затемнение при смерти",
	},
	settings_help_hg_deathfadeout = {
		en = "Toggle screen fade and sound mute on death",
		zh = "切换死亡时画面淡出和声音静音",
		ru = "Затемнение экрана и приглушение звука при смерти",
	},
	settings_option_hg_toughnpcs = {
		en = "Tough NPCs",
		zh = "Tough NPCs",
		ru = "Tough NPCs",
	},
	settings_option_hg_thirdperson = {
		en = "Third person (in development)",
		zh = "Third person (in development)",
		ru = "Third person (in development)",
	},
	settings_option_hg_legacycam = {
		en = "Legacy camera",
		zh = "Legacy camera",
		ru = "Legacy camera",
	},
	settings_option_hg_ragdollcombat = {
		en = "Ragdoll combat mode",
		zh = "Ragdoll combat mode",
		ru = "Ragdoll combat mode",
	},
	settings_option_hg_movement_stamina_debuff = {
		en = "Movement stamina debuff",
		zh = "Movement stamina debuff",
		ru = "Movement stamina debuff",
	},
	settings_option_hg_furcity = {
		en = "Furcity",
		zh = "Furcity",
		ru = "Furcity",
	},
	settings_option_hg_appearance_access_for_all = {
		en = "Allow full appearance access for all users",
		zh = "Allow full appearance access for all users",
		ru = "Allow full appearance access for all users",
	},
	settings_option_hg_healanims = {
		en = "Healing and eating animations",
		zh = "Healing and eating animations",
		ru = "Healing and eating animations",
	},
	settings_option_hg_aimtoshoot = {
		en = "DarkRP-style aim-to-shoot system",
		zh = "DarkRP-style aim-to-shoot system",
		ru = "DarkRP-style aim-to-shoot system",
	},
	settings_option_hg_slings = {
		en = "Sling system",
		zh = "Sling system",
		ru = "Sling system",
	},
	settings_option_hg_show_hitposmuzzle = {
		en = "Show weapon hit position",
		zh = "显示武器命中位置",
		ru = "Показывать точку попадания оружия",
	},
	settings_help_hg_show_hitposmuzzle = {
		en = "shows weapons crosshair, work only admin rank or sv_cheats 1",
		zh = "显示武器准星，仅管理员或 sv_cheats 1 可用",
		ru = "Показывает прицел оружия, работает только для админов или при sv_cheats 1",
	},
	settings_option_hg_setzoompos = {
		en = "Adjust weapon zoom position",
		zh = "调整武器缩放位置",
		ru = "Настроить позицию приближения оружия",
	},
	settings_help_hg_setzoompos = {
		en = "settingzoom",
		zh = "设置缩放位置",
		ru = "Настройка позиции приближения",
	},
	settings_option_hg_show_hitbox = {
		en = "Show hitboxes",
		zh = "显示碰撞箱",
		ru = "Показывать хитбоксы",
	},
	settings_help_hg_show_hitbox = {
		en = "shows custom player hitboxes, work only for admins or with sv_cheats 1 enabled",
		zh = "显示自定义玩家碰撞箱，仅管理员或启用 sv_cheats 1 时可用",
		ru = "Показывает пользовательские хитбоксы игроков, только для админов или при sv_cheats 1",
	},
	settings_option_hg_potatopc = {
		en = "Potato PC mode",
		zh = "低配电脑模式",
		ru = "Режим слабого ПК",
	},
	settings_help_hg_potatopc = {
		en = "Toggle potato (low-end pc) mode",
		zh = "切换低配置电脑模式",
		ru = "Переключить режим слабого ПК",
	},
	settings_option_hg_anims_draw_distance = {
		en = "Animation draw distance",
		zh = "动画绘制距离",
		ru = "Дальность отрисовки анимаций",
	},
	settings_help_hg_anims_draw_distance = {
		en = "Modify draw anims distance in hammer units (0 = infinite)",
		zh = "修改动画绘制距离（Hammer 单位，0 = 无限）",
		ru = "Изменить дальность отрисовки анимаций в hammer-единицах (0 = бесконечно)",
	},
	settings_option_hg_anim_fps = {
		en = "Animation FPS",
		zh = "动画 FPS",
		ru = "FPS анимаций",
	},
	settings_help_hg_anim_fps = {
		en = "Modify bone manipulate frames amount (not tpik) (0 = maximum fps available)",
		zh = "修改骨骼操作帧数（非 TPIK，0 = 最大可用 FPS）",
		ru = "Изменить частоту кадров манипуляции костями (не TPIK), 0 = максимум",
	},
	settings_option_hg_attachment_draw_distance = {
		en = "Attachment draw distance",
		zh = "附件绘制距离",
		ru = "Дальность отрисовки аксессуаров",
	},
	settings_help_hg_attachment_draw_distance = {
		en = "distance to draw attachments",
		zh = "附件显示距离",
		ru = "Дальность отображения аксессуаров",
	},
	settings_option_hg_maxsmoketrails = {
		en = "Max smoke trails",
		zh = "最大烟雾轨迹数",
		ru = "Максимум дымовых следов",
	},
	settings_help_hg_maxsmoketrails = {
		en = "Max amount of smoke trail effects (lags starts after 10)",
		zh = "最大烟雾轨迹效果数量（超过 10 后可能卡顿）",
		ru = "Максимальное число дымовых следов (лаги начинаются после 10)",
	},
	settings_option_hg_tpik_distance = {
		en = "TPIK render distance",
		zh = "TPIK 渲染距离",
		ru = "Дальность рендера TPIK",
	},
	settings_help_hg_tpik_distance = {
		en = "The distance (in hammer units) at which the third person inverse kinematics enables, 0 = inf",
		zh = "第三人称逆向运动学启用距离（Hammer 单位，0 = 无限）",
		ru = "Дистанция включения IK от третьего лица в hammer-единицах, 0 = беск.",
	},
	settings_option_hg_blood_draw_distance = {
		en = "Blood draw distance",
		zh = "血迹绘制距离",
		ru = "Дальность отрисовки крови",
	},
	settings_option_hg_blood_fps = {
		en = "Blood FPS",
		zh = "血迹 FPS",
		ru = "FPS крови",
	},
	settings_help_hg_blood_fps = {
		en = "fps to draw blood",
		zh = "绘制血迹的 FPS",
		ru = "FPS отрисовки крови",
	},
	settings_option_hg_blood_sprites = {
		en = "Blood sprites (disable for all users)",
		zh = "血迹精灵/轨迹",
		ru = "Спрайты или следы крови",
	},
	settings_option_hg_old_blood = {
		en = "Old blood effects",
		zh = "旧版血迹效果",
		ru = "Старые эффекты крови",
	},
	settings_help_hg_old_blood = {
		en = "new decals, or old",
		zh = "使用新版贴花或旧版效果",
		ru = "Новые декали или старые эффекты",
	},
	settings_option_hg_font = {
		en = "Change custom font",
		zh = "更改自定义字体",
		ru = "Изменить пользовательский шрифт",
	},
	settings_help_hg_font = {
		en = "Change UI text font",
		zh = "更改界面文字字体",
		ru = "Изменить шрифт текста интерфейса",
	},
	settings_option_hg_weaponshotblur_enable = {
		en = "Weapon shot blur",
		zh = "开火模糊效果",
		ru = "Размытие при выстреле",
	},
	settings_help_hg_weaponshotblur_enable = {
		en = "Enable shotblur",
		zh = "启用开火模糊",
		ru = "Включить размытие при выстреле",
	},
	settings_option_hg_dynamic_mags = {
		en = "Dynamic ammo check",
		zh = "动态弹药检查",
		ru = "Динамическая проверка боезапаса",
	},
	settings_help_hg_dynamic_mags = {
		en = "Enables dynamic ammo show when shooting",
		zh = "射击时动态显示弹药",
		ru = "Включает динамическое отображение боезапаса при стрельбе",
	},
	settings_option_hg_zoomsensitivity = {
		en = "Scope sensitivity",
		zh = "瞄准镜灵敏度",
		ru = "Чувствительность прицела",
	},
	settings_help_hg_zoomsensitivity = {
		en = "Multiply aiming zoom sensitivity",
		zh = "调整瞄准缩放灵敏度倍率",
		ru = "Множитель чувствительности при приближении",
	},
	settings_option_hg_highpitchgunfire = {
		en = "Enable high-pitched indoor gunfire",
		zh = "启用室内高频枪声",
		ru = "Высокий тон выстрелов в помещении",
	},
	settings_help_hg_highpitchgunfire = {
		en = "Toggle high pitched gunfire sounds inside buildings",
		zh = "切换建筑内高音调枪声",
		ru = "Переключить высокий тон выстрелов внутри зданий",
	},
	settings_option_hg_firstperson_death = {
		en = "First-person death camera",
		zh = "第一人称死亡镜头",
		ru = "Камера смерти от первого лица",
	},
	settings_help_hg_firstperson_death = {
		en = "Toggle first-person death camera view",
		zh = "切换第一人称死亡视角",
		ru = "Переключить камеру смерти от первого лица",
	},
	settings_option_hg_fov = {
		en = "Field of view (FOV)",
		zh = "视野范围 (FOV)",
		ru = "Поле зрения (FOV)",
	},
	settings_help_hg_fov = {
		en = "Change first-person field of view",
		zh = "更改第一人称视野范围",
		ru = "Изменить поле зрения от первого лица",
	},
	settings_option_hg_newspectate = {
		en = "Smooth spectator camera",
		zh = "平滑观战镜头",
		ru = "Плавная камера наблюдателя",
	},
	settings_help_hg_newspectate = {
		en = "Smooth spectator camera movement",
		zh = "平滑观战镜头移动",
		ru = "Плавное движение камеры наблюдателя",
	},
	settings_option_hg_cshs_fake = {
		en = "C'sHS ragdoll camera",
		zh = "C'sHS 布娃娃镜头",
		ru = "Камера рэгдолла C'sHS",
	},
	settings_help_hg_cshs_fake = {
		en = "Toggle C'sHS-like ragdoll camera view",
		zh = "切换类似 C'sHS 的布娃娃镜头",
		ru = "Переключить камеру рэгдолла в стиле C'sHS",
	},
	settings_option_hg_gun_cam = {
		en = "Gun camera (admin only)",
		zh = "枪械镜头（仅管理员）",
		ru = "Оружейная камера (только админ)",
	},
	settings_option_hg_nofovzoom = {
		en = "Enable/disable FOV zoom",
		zh = "启用/禁用 FOV 缩放",
		ru = "Включить/выключить приближение FOV",
	},
	settings_help_hg_nofovzoom = {
		en = "Enable FOV zooming when aiming",
		zh = "瞄准时启用 FOV 缩放",
		ru = "Включить приближение FOV при прицеливании",
	},
	settings_option_hg_realismcam = {
		en = "Realism camera (clumsy)",
		zh = "真实感镜头（笨拙）",
		ru = "Реалистичная камера (неуклюжая)",
	},
	settings_help_hg_realismcam = {
		en = "Toggle realism first-person camera view",
		zh = "切换真实感第一人称镜头",
		ru = "Переключить реалистичную камеру от первого лица",
	},
	settings_option_hg_gopro = {
		en = "GoPro camera",
		zh = "GoPro 镜头",
		ru = "Камера GoPro",
	},
	settings_option_hg_newfakecam = {
		en = "New fake camera",
		zh = "新版假镜头",
		ru = "Новая фальшивая камера",
	},
	settings_help_hg_newfakecam = {
		en = "New camera rotate",
		zh = "新版镜头旋转",
		ru = "Новое вращение камеры",
	},
	settings_option_hg_leancam_mul = {
		en = "Lean camera multiplier",
		zh = "倾斜镜头倍率",
		ru = "Множитель наклона камеры",
	},
	settings_help_hg_leancam_mul = {
		en = "Multiply first-person camera view leaning angle",
		zh = "调整第一人称镜头倾斜角倍率",
		ru = "Множитель угла наклона камеры от первого лица",
	},
	settings_option_hg_dmusic = {
		en = "Dynamic music",
		zh = "动态音乐",
		ru = "Динамическая музыка",
	},
	settings_option_hg_quietshots = {
		en = "Toggle quieter gun sounds",
		zh = "切换较安静的枪声",
		ru = "Тихие звуки выстрелов",
	},
	common_your_role = {
		en = "Your role: ",
		ko = "당신의 역할: ",
		zh = "你的角色：",
		ru = "Ваша роль: ",
	},
	common_your_role_spaced = {
		en = "Your role: ",
		ko = "당신의 역할: ",
		zh = "你的角色：",
		ru = "Ваша роль: ",
	},
	common_profession_prefix = {
		en = "Profession: ",
		ko = "Profession: ",
		zh = "Profession: ",
		ru = "Profession: ",
	},
	homicide_traitor_list = {
		en = "Traitor list:",
		ko = "배신자 명단:",
		zh = "叛徒名单：",
		ru = "Список предателей:",
	},
	homicide_accomplice = {
		en = "Accomplice",
		ko = "조력자",
		zh = "同伙",
		ru = "Сообщник",
	},
	homicide_traitor_secret_words = {
		en = "Traitor secret words:",
		ko = "배신자 비밀 암호:",
		zh = "叛徒秘密暗号：",
		ru = "Секретные слова предателей:",
	},
	homicide_traitor_alone = {
		en = "You are alone on this mission.",
		ko = "이번 임무는 당신 혼자입니다.",
		zh = "这次任务只有你一人。",
		ru = "В этой миссии вы один.",
	},
	homicide_traitor_one_accomplice = {
		en = "You have one accomplice.",
		ko = "당신에게는 1명의 공범이 있습니다.",
		zh = "你有一名同伙。",
		ru = "У вас есть один сообщник.",
	},
	homicide_traitor_many_accomplices = {
		en = "There are %s other traitors besides you.",
		ko = "당신 외에 %s명의 배신자가 더 있습니다.",
		zh = "除你之外还有 %s 名叛徒。",
		ru = "Кроме вас есть еще %s предателей.",
	},
	homicide_traitor_secret_words_chat = {
		en = "The traitor secret words are \"%s\" and \"%s\".",
		ko = "배신자 비밀 암호는 \"%s\"와 \"%s\"입니다.",
		zh = "叛徒秘密暗号是 \"%s\" 和 \"%s\"。",
		ru = "Секретные слова предателей: \"%s\" и \"%s\".",
	},
	homicide_traitor_list_main_only = {
		en = "Traitor list (only the main traitor can see this):",
		ko = "배신자 명단 (메인 배신자인 당신만 볼 수 있습니다):",
		zh = "叛徒名单（只有主叛徒可见）：",
		ru = "Список предателей (виден только главному предателю):",
	},
	homicide_main_traitor = {
		en = "Main Traitor",
		ko = "메인 배신자",
		zh = "主叛徒",
		ru = "Главный предатель",
	},
	homicide_traitor_assistant = {
		en = "Traitor Assistant",
		ko = "배신자 조력자",
		zh = "叛徒助手",
		ru = "Помощник предателя",
	},
	homicide_traitor_panel_hint = {
		en = "Press F4 to open/close panel",
		ko = "F4를 눌러 패널 열기/닫기",
		zh = "按 F4 打开/关闭面板",
		ru = "Нажмите F4, чтобы открыть/закрыть панель",
	},
	homicide_secret_words_label = {
		en = "Secret words:",
		ko = "비밀 암호:",
		zh = "秘密暗号：",
		ru = "Секретные слова:",
	},
	homicide_your_assistants = {
		en = "Your assistants:",
		ko = "당신의 조력자들:",
		zh = "你的助手：",
		ru = "Ваши помощники:",
	},
	homicide_dead_status = {
		en = " [Dead]",
		ko = " [죽음]",
		zh = " [死亡]",
		ru = " [мертв]",
	},
	homicide_no_assistants = {
		en = "No available assistants",
		ko = "가용 조력자 없음",
		zh = "没有可用助手",
		ru = "Нет доступных помощников",
	},
	homicide_traitor_prefix = {
		en = "Traitor ",
		ko = "Traitor ",
		zh = "Traitor ",
		ru = "Traitor ",
	},
	homicide_traitor_was = {
		en = "%s was the traitor (%s)",
		ko = "%s was the traitor (%s)",
		zh = "%s was the traitor (%s)",
		ru = "%s was the traitor (%s)",
	},
	homicide_traitor_is_suffix = {
		en = " was the traitor.",
		ko = " was the traitor.",
		zh = " was the traitor.",
		ru = " was the traitor.",
	},
	homicide_traitor_killed_suffix = {
		en = " was killed.",
		ko = " was killed.",
		zh = " was killed.",
		ru = " was killed.",
	},
	homicide_player_died_suffix = {
		en = " died.",
		ko = " died.",
		zh = " died.",
		ru = " died.",
	},
	homicide_killed_by = {
		en = "%s was killed by %s.",
		ko = "%s was killed by %s.",
		zh = "%s was killed by %s.",
		ru = "%s was killed by %s.",
	},
	homicide_killer_won = {
		en = "The killer won.",
		ko = "The killer won.",
		zh = "The killer won.",
		ru = "The killer won.",
	},
	homicide_killer_killed_everyone = {
		en = "The killer killed everyone.",
		ko = "The killer killed everyone.",
		zh = "The killer killed everyone.",
		ru = "The killer killed everyone.",
	},
	homicide_traitor_killed_everyone = {
		en = "The traitor killed everyone.",
		ko = "The traitor killed everyone.",
		zh = "The traitor killed everyone.",
		ru = "The traitor killed everyone.",
	},
	homicide_all_died = {
		en = "Everyone died.",
		ko = "Everyone died.",
		zh = "Everyone died.",
		ru = "Everyone died.",
	},
	homicide_all_civilians_killed = {
		en = "All civilians were killed.",
		ko = "All civilians were killed.",
		zh = "All civilians were killed.",
		ru = "All civilians were killed.",
	},
	role_gangster = {
		en = "Gangster",
		ko = "갱스터",
		zh = "帮派成员",
		ru = "Гангстер",
	},
	role_citizen = {
		en = "Citizen",
		ko = "시민",
		zh = "市民",
		ru = "Гражданин",
	},
	role_traitor = {
		en = "Traitor",
		ko = "배신자",
		zh = "叛徒",
		ru = "Предатель",
	},
	role_witness = {
		en = "Witness",
		ko = "목격자",
		zh = "目击者",
		ru = "Свидетель",
	},
	role_sheriff = {
		en = "Sheriff",
		ko = "보안관",
		zh = "治安官",
		ru = "Шериф",
	},
	role_bang_deputy = {
		en = "Deputy",
		ko = "부관",
		zh = "副警长",
		ru = "Помощник шерифа",
	},
	role_bang_outlaw = {
		en = "Outlaw",
		ko = "무법자",
		zh = "歹徒",
		ru = "Бандит",
	},
	role_bang_renegade = {
		en = "Renegade",
		ko = "배신자",
		zh = "叛徒",
		ru = "Ренегат",
	},
	bang_character_prefix = {
		en = "Character: ", ko = "캐릭터: ", zh = "角色：", ru = "Персонаж: ",
	},
	bang_panel_objective = {
		en = "Objective", ko = "목표", zh = "目标", ru = "Цель",
	},
	bang_panel_ability = {
		en = "Ability", ko = "능력", zh = "能力", ru = "Способность",
	},
	bang_character_vulture_sam = {
		en = "Vulture Sam", ko = "벌처 샘", zh = "秃鹫山姆", ru = "Стервятник Сэм",
	},
	bang_character_sid_ketchum = {
		en = "Sid Ketchum", ko = "시드 케첨", zh = "席德·凯彻姆", ru = "Сид Кетчум",
	},
	bang_character_bart_cassidy = {
		en = "Bart Cassidy", ko = "바트 캐시디", zh = "巴特·卡西迪", ru = "Барт Кэссиди",
	},
	bang_character_jourdonnais = {
		en = "Jourdonnais", ko = "주르도네", zh = "朱尔多内", ru = "Журдоннэ",
	},
	bang_character_slab_killer = {
		en = "Slab the Killer", ko = "슬랩 더 킬러", zh = "杀手斯拉布", ru = "Слэб-Убийца",
	},
	bang_character_el_gringo = {
		en = "El Gringo", ko = "엘 그링고", zh = "埃尔·格林戈", ru = "Эль Гринго",
	},
	bang_character_tequila_joe = {
		en = "Tequila Joe", ko = "테킬라 죠", zh = "龙舌兰乔", ru = "Текила Джо",
	},
	bang_character_greg_digger = {
		en = "Greg Digger", ko = "그레그 디거", zh = "掘墓人格雷格", ru = "Грег Диггер",
	},
	bang_character_vera_custer = {
		en = "Vera Custer", ko = "베라 쿠스터", zh = "维拉·卡斯特", ru = "Вера Кастер",
	},
	bang_character_big_spencer = {
		en = "Big Spencer", ko = "빅 스펜서", zh = "大斯宾塞", ru = "Большой Спенсер",
	},
	bang_character_mick_defender = {
		en = "Mick Defender", ko = "믹 디펜더", zh = "米克·防御者", ru = "Мик Защитник",
	},
	bang_character_suzy_lafayette = {
		en = "Suzy Lafayette", ko = "수지 라파예트", zh = "苏西·拉法叶", ru = "Сьюзи Лафайет",
	},
	bang_character_paul_regret = {
		en = "Paul Regret", ko = "폴 리그레트", zh = "保罗·雷格雷特", ru = "Пол Регрет",
	},
	bang_character_sean_mallory = {
		en = "Sean Mallory", ko = "숀 말로리", zh = "肖恩·马洛里", ru = "Шон Мэллори",
	},
	bang_character_vulture_sam_desc = {
		en = "Search corpses twice as fast and detect newly equipped corpses for 15 seconds.",
		ko = "시체를 두 배 빠르게 수색하고 새로 사망한 장비 보유 시체를 15초간 감지합니다.",
		zh = "搜查尸体的速度提高一倍，并在15秒内感知新死亡且携带装备的尸体。",
		ru = "Обыскивает тела вдвое быстрее и видит новые тела со снаряжением 15 секунд.",
	},
	bang_character_sid_ketchum_desc = {
		en = "Press G to discard two non-firearm items and reduce bleeding and pain. 45-second cooldown.",
		ko = "G를 눌러 비무기 소지품 2개를 버리고 출혈과 통증을 완화합니다. 재사용 45초.",
		zh = "按G丢弃两件非枪械物品并减轻出血和疼痛。冷却45秒。",
		ru = "Нажмите G, чтобы сбросить два предмета, уменьшив кровотечение и боль. Перезарядка 45 сек.",
	},
	bang_character_bart_cassidy_desc = {
		en = "After taking 35 damage, gain a bandage or ammunition. 30-second cooldown.",
		ko = "누적 피해 35를 받으면 붕대나 탄약을 얻습니다. 재사용 30초.",
		zh = "累计受到35点伤害后获得绷带或弹药。冷却30秒。",
		ru = "После 35 урона получает бинт или боеприпасы. Перезарядка 30 сек.",
	},
	bang_character_jourdonnais_desc = {
		en = "Has a 20% chance to block a non-headshot bullet. 25-second cooldown after activation.",
		ko = "머리를 제외한 총탄을 20% 확률로 막습니다. 발동 후 재사용 25초.",
		zh = "有20%概率挡住非爆头子弹。触发后冷却25秒。",
		ru = "С шансом 20% блокирует пулю, кроме попадания в голову. Перезарядка 25 сек.",
	},
	bang_character_slab_killer_desc = {
		en = "Every 20 seconds, the next shot gains 40% penetration and causes 25% more bleeding.",
		ko = "20초마다 다음 탄환의 관통력이 40%, 출혈량이 25% 증가합니다.",
		zh = "每20秒，下一发子弹的穿透力提高40%，出血提高25%。",
		ru = "Раз в 20 сек. следующий выстрел получает +40% пробития и +25% кровотечения.",
	},
	bang_character_el_gringo_desc = {
		en = "Attackers have a 35% chance to drop a non-firearm item. 20-second cooldown per attacker.",
		ko = "공격자가 35% 확률로 비무기 소지품 하나를 떨어뜨립니다. 공격자별 재사용 20초.",
		zh = "攻击者有35%概率掉落一件非枪械物品。每名攻击者冷却20秒。",
		ru = "Атакующий с шансом 35% роняет один предмет. Перезарядка 20 сек. на атакующего.",
	},
	bang_character_tequila_joe_desc = {
		en = "Medicine you use has twice its normal effect.",
		ko = "사용하는 의약품의 효과가 2배가 됩니다.",
		zh = "你使用的药品效果变为两倍。",
		ru = "Используемые вами лекарства действуют вдвое сильнее.",
	},
	bang_character_greg_digger_desc = {
		en = "When another participant is eliminated, recover 5 health and 150 blood. 30-second cooldown.",
		ko = "다른 참가자가 제거되면 체력 5와 혈액 150을 회복합니다. 재사용 30초.",
		zh = "其他参与者被淘汰时，恢复5点生命和150点血量。冷却30秒。",
		ru = "Когда выбывает другой участник, восстанавливает 5 здоровья и 150 крови. Перезарядка 30 сек.",
	},
	bang_character_vera_custer_desc = {
		en = "Copies one other living participant's ability for the entire round.",
		ko = "다른 생존자 한 명의 능력을 이번 라운드 동안 복사합니다.",
		zh = "在整个回合中复制另一名存活参与者的能力。",
		ru = "Копирует способность другого живого участника на весь раунд.",
	},
	bang_vera_copied_ability = {
		en = "Copied ability: %s - %s",
		ko = "복사 능력: %s - %s",
		zh = "复制能力：%s - %s",
		ru = "Скопированная способность: %s — %s",
	},
	bang_character_big_spencer_desc = {
		en = "Starts with two reserve magazines, but takes 20% more damage from every source.",
		ko = "예비탄 2탄창을 가지고 시작하지만 모든 피해를 20% 더 받습니다.",
		zh = "开局携带两个备用弹匣，但受到的所有伤害增加20%。",
		ru = "Начинает с двумя запасными магазинами, но получает на 20% больше любого урона.",
	},
	bang_character_mick_defender_desc = {
		en = "Has a 20% chance to make bullets aimed at the head or torso miss. 15-second cooldown after activation.",
		ko = "머리와 몸통에 맞은 총탄을 20% 확률로 빗나가게 합니다. 발동 후 재사용 15초.",
		zh = "有20%概率使击中头部或躯干的子弹落空。触发后冷却15秒。",
		ru = "С шансом 20% заставляет пули, попавшие в голову или корпус, промахнуться. После срабатывания перезарядка 15 сек.",
	},
	bang_character_suzy_lafayette_desc = {
		en = "When all loaded and reserve ammunition is gone, immediately gain one magazine for an owned firearm. 45-second cooldown.",
		ko = "장전탄과 예비탄이 모두 소진되면 보유 총기에 맞는 탄약 한 탄창을 즉시 가져옵니다. 재사용 45초.",
		zh = "当所有装填和备用弹药耗尽时，立即为持有的枪械获得一个弹匣的弹药。冷却45秒。",
		ru = "Когда заканчиваются все патроны в оружии и запасе, немедленно получает один магазин для имеющегося оружия. Перезарядка 45 сек.",
	},
	bang_suzy_refilled = {
		en = "All ammunition was exhausted. You gained one magazine.",
		ko = "탄약이 모두 소진되어 한 탄창을 가져왔습니다.",
		zh = "弹药已全部耗尽，你获得了一个弹匣。",
		ru = "Все боеприпасы закончились. Вы получили один магазин.",
	},
	bang_character_paul_regret_desc = {
		en = "The farther away the attacker is, the higher the chance to negate their bullet, up to 40% beyond about 30 meters. 20-second cooldown after activation.",
		ko = "공격자가 멀수록 총탄 무효화 확률이 증가하며 약 30m 이상에서 최대 40%가 됩니다. 발동 후 재사용 20초.",
		zh = "攻击者距离越远，子弹无效的概率越高；约30米以上时最高为40%。触发后冷却20秒。",
		ru = "Чем дальше атакующий, тем выше шанс отменить его пулю — до 40% на дистанции около 30 метров. После срабатывания перезарядка 20 сек.",
	},
	bang_character_sean_mallory_desc = {
		en = "Starts with one unrestricted Type 59 grenade.",
		ko = "별도 제한 없이 Type 59 수류탄 1개를 가지고 시작합니다.",
		zh = "开局携带一枚无额外限制的59式手榴弹。",
		ru = "Начинает раунд с одной гранатой Type 59 без дополнительных ограничений.",
	},
	bang_greg_healed = {
		en = "Another participant was eliminated. You recovered health and blood.",
		ko = "다른 참가자가 제거되어 체력과 혈액을 회복했습니다.",
		zh = "另一名参与者被淘汰，你恢复了生命和血量。",
		ru = "Другой участник выбыл. Вы восстановили здоровье и кровь.",
	},
	bang_skill_cooldown = {
		en = "Your ability is still on cooldown.", ko = "능력을 아직 다시 사용할 수 없습니다.", zh = "能力仍在冷却中。", ru = "Способность ещё восстанавливается.",
	},
	bang_sid_needs_items = {
		en = "You need two non-firearm items to use this ability.", ko = "사용하려면 비무기 소지품이 2개 필요합니다.", zh = "使用此能力需要两件非枪械物品。", ru = "Для способности нужны два предмета, не являющихся оружием.",
	},
	bang_sid_used = {
		en = "You discarded two items and reduced your bleeding and pain.", ko = "소지품 2개를 버려 출혈과 통증을 완화했습니다.", zh = "你丢弃了两件物品并减轻了出血和疼痛。", ru = "Вы сбросили два предмета и уменьшили кровотечение и боль.",
	},
	bang_jourdonnais_block = {
		en = "Your barrel stopped the bullet.", ko = "술통이 총탄을 막아냈습니다.", zh = "酒桶挡住了子弹。", ru = "Бочка остановила пулю.",
	},
	bang_slab_fired = {
		en = "Your empowered round was fired.", ko = "강화탄이 발사되었습니다.", zh = "强化弹已发射。", ru = "Усиленный патрон выпущен.",
	},
	bang_bart_reward = {
		en = "You endured the damage and gained a bandage or ammunition.", ko = "피해를 버텨내고 붕대나 탄약을 얻었습니다.", zh = "你承受了伤害并获得了绷带或弹药。", ru = "Вы выдержали урон и получили бинт или боеприпасы.",
	},
	bang_el_gringo_triggered = {
		en = "Your attacker dropped an item.", ko = "공격자가 소지품 하나를 떨어뜨렸습니다.", zh = "攻击者掉落了一件物品。", ru = "Атакующий выронил предмет.",
	},
	bang_el_gringo_attacker = {
		en = "Attacking El Gringo made you drop an item.", ko = "엘 그링고를 공격하여 소지품 하나를 떨어뜨렸습니다.", zh = "攻击埃尔·格林戈使你掉落了一件物品。", ru = "Атака на Эль Гринго заставила вас выронить предмет.",
	},
	bang_deputy_sheriff_karma = {
		en = "You lost karma for shooting the sheriff.",
		ko = "보안관을 공격하여 카르마가 감소했습니다.",
		zh = "你因射击警长而失去了业力。",
		ru = "Вы потеряли карму за выстрел в шерифа.",
	},
	role_fellow_cowboy = {
		en = "Fellow Cowboy",
		ko = "동료 카우보이",
		zh = "牛仔同伴",
		ru = "Ковбой-союзник",
	},
	role_shahid = {
		en = "Shahid",
		ko = "샤히드",
		zh = "殉道者",
		ru = "Шахид",
	},
	role_traitor_mario = {
		en = "Traitor Mario",
		ko = "배신자 마리오",
		zh = "叛徒马里奥",
		ru = "Марио-предатель",
	},
	role_hero_mario = {
		en = "Hero Mario",
		ko = "영웅 마리오",
		zh = "英雄马里奥",
		ru = "Герой Марио",
	},
	role_civilian_mario = {
		en = "Civilian Mario",
		ko = "시민 마리오",
		zh = "市民马里奥",
		ru = "Мирный Марио",
	},
	role_infiltrator = {
		en = "Infiltrator",
		ko = "Infiltrator",
		zh = "Infiltrator",
		ru = "Infiltrator",
	},
	role_assassin = {
		en = "Assassin",
		ko = "Assassin",
		zh = "Assassin",
		ru = "Assassin",
	},
	role_chemist = {
		en = "Chemist",
		ko = "Chemist",
		zh = "Chemist",
		ru = "Chemist",
	},
	role_bystander = {
		en = "Bystander",
		ko = "Bystander",
		zh = "Bystander",
		ru = "Bystander",
	},
	role_innocent = {
		en = "Innocent",
		ko = "Innocent",
		zh = "Innocent",
		ru = "Innocent",
	},
	role_doctor = {
		en = "Doctor",
		ko = "Doctor",
		zh = "Doctor",
		ru = "Doctor",
	},
	role_engineer = {
		en = "Engineer",
		ko = "Engineer",
		zh = "Engineer",
		ru = "Engineer",
	},
	role_builder = {
		en = "Builder",
		ko = "Builder",
		zh = "Builder",
		ru = "Builder",
	},
	objective_homicide_traitor = {
		en = "You are armed with items, poison, explosives, and weapons in your pockets. Kill everyone here.",
		ko = "당신은 주머니 속에 아이템, 독극물, 폭발물, 그리고 무기들로 무장했습니다. 이곳의 모두를 살해하십시오.",
		zh = "你携带了道具、毒药、爆炸物和武器。杀死这里的所有人。",
		ru = "Вы вооружены предметами, ядами, взрывчаткой и оружием. Убейте всех здесь.",
	},
	objective_homicide_gunner = {
		en = "You are a civilian with a hunting weapon. Find and stop the traitor before it is too late.",
		ko = "당신은 사냥용 무기를 가진 시민입니다. 너무 늦기 전에 배신자를 찾아 제압하십시오.",
		zh = "你是持有猎枪的市民。趁还来得及，找到并制止叛徒。",
		ru = "Вы гражданин с охотничьим оружием. Найдите и остановите предателя, пока не поздно.",
	},
	objective_homicide_innocent = {
		en = "You are a civilian. Trust only yourself, but stay with the crowd so the traitor has a harder time acting.",
		ko = "당신은 시민입니다. 오직 자신만을 믿으되, 배신자가 활동하기 어렵도록 군중 속에 머무르십시오.",
		zh = "你是市民。只相信自己，但尽量待在人群中，让叛徒更难行动。",
		ru = "Вы гражданин. Доверяйте только себе, но держитесь толпы, чтобы предателю было сложнее действовать.",
	},
	objective_homicide_witness_gun = {
		en = "You are a witness with a hidden firearm. Help the police find the killer faster.",
		ko = "당신은 총기를 숨겨둔 목격자입니다. 경찰이 범인을 더 빨리 찾을 수 있도록 돕기로 결심했습니다.",
		zh = "你是藏有枪械的目击者。协助警方更快找到杀手。",
		ru = "Вы свидетель со спрятанным оружием. Помогите полиции быстрее найти убийцу.",
	},
	objective_homicide_witness = {
		en = "You are a witness at a murder scene. It did not happen to you, but you should still be careful.",
		ko = "당신은 살인 사건 현장의 목격자입니다. 비록 당신에게 일어난 일은 아니지만, 주의하는 것이 좋습니다.",
		zh = "你是谋杀现场的目击者。虽然事情不是发生在你身上，但你仍要小心。",
		ru = "Вы свидетель на месте убийства. Это случилось не с вами, но вам все равно стоит быть осторожным.",
	},
	objective_homicide_wildwest_traitor = {
		en = "This town is not big enough for all of us.",
		ko = "이 마을은 우리 모두가 살기엔 너무 좁군.",
		zh = "这个镇子容不下我们所有人。",
		ru = "Этот город слишком мал для всех нас.",
	},
	objective_homicide_sheriff = {
		en = "You are the sheriff of this town. Find that outlaw bastard and put him down.",
		ko = "당신은 이 마을의 보안관입니다. 저 무법자 자식을 찾아내 처단해야 합니다.",
		zh = "你是这个镇子的治安官。找到那个亡命徒并解决他。",
		ru = "Вы шериф этого города. Найдите этого преступника и прикончите его.",
	},
	objective_bang_sheriff = {
		en = "Your identity is public. Eliminate every Outlaw and the Renegade.",
		ko = "당신의 신분은 공개되어 있습니다. 무법자와 배신자를 모두 제거하십시오.",
		zh = "你的身份是公开的。消灭所有歹徒和叛徒。",
		ru = "Ваша роль раскрыта. Уничтожьте всех бандитов и ренегата.",
	},
	objective_bang_deputy = {
		en = "Keep your identity hidden, protect the Sheriff, and eliminate the Outlaws and Renegade.",
		ko = "정체를 숨긴 채 보안관을 보호하고 무법자와 배신자를 제거하십시오.",
		zh = "隐藏身份，保护治安官，并消灭歹徒和叛徒。",
		ru = "Скрывайте свою роль, защищайте шерифа и уничтожьте бандитов и ренегата.",
	},
	objective_bang_outlaw = {
		en = "Keep your identity hidden and kill the Sheriff. The Outlaws win when the Sheriff dies.",
		ko = "정체를 숨기고 보안관을 처치하십시오. 보안관이 죽으면 무법자들이 승리합니다.",
		zh = "隐藏身份并杀死治安官。治安官死亡时歹徒获胜。",
		ru = "Скрывайте свою роль и убейте шерифа. Бандиты победят после его смерти.",
	},
	objective_bang_renegade = {
		en = "Deceive everyone and become the last survivor. The Sheriff must die last.",
		ko = "모두를 속여 마지막 생존자가 되십시오. 보안관은 반드시 마지막으로 죽어야 합니다.",
		zh = "欺骗所有人并成为最后的幸存者。治安官必须最后死亡。",
		ru = "Обманите всех и останьтесь последним в живых. Шериф должен погибнуть последним.",
	},
	bang_unknown_player = {
		en = "Unknown player",
		ko = "알 수 없는 플레이어",
		zh = "未知玩家",
		ru = "Неизвестный игрок",
	},
	bang_role_revealed = {
		en = "%s was the %s.",
		ko = "%s의 역할은 %s였습니다.",
		zh = "%s的角色是%s。",
		ru = "%s был ролью: %s.",
	},
	bang_win_law = {
		en = "The Sheriff and Deputies win.",
		ko = "보안관과 부관이 승리했습니다.",
		zh = "治安官和副警长获胜。",
		ru = "Шериф и помощники победили.",
	},
	bang_win_outlaws = {
		en = "The Outlaws win.",
		ko = "무법자들이 승리했습니다.",
		zh = "歹徒获胜。",
		ru = "Бандиты победили.",
	},
	bang_win_renegade = {
		en = "The Renegade survives alone and wins.",
		ko = "배신자가 홀로 살아남아 승리했습니다.",
		zh = "叛徒独自存活并获胜。",
		ru = "Ренегат остался один и победил.",
	},
	bang_win_draw = {
		en = "The duel ends without a winner.",
		ko = "승자 없이 결투가 끝났습니다.",
		zh = "决斗在无人获胜的情况下结束。",
		ru = "Дуэль закончилась без победителя.",
	},
	bang_penalty_deputy = {
		en = "You killed a Deputy and lost all weapons and ammunition as punishment.",
		ko = "부관을 죽인 벌로 모든 무기와 탄약을 잃었습니다.",
		zh = "你杀死了副警长，因此失去了所有武器和弹药。",
		ru = "За убийство помощника вы потеряли всё оружие и боеприпасы.",
	},
	bang_reward_outlaw = {
		en = "You eliminated an Outlaw and received ammunition and a bandage.",
		ko = "무법자를 처치하여 탄약과 붕대를 얻었습니다.",
		zh = "你消灭了歹徒并获得了弹药和绷带。",
		ru = "Вы устранили бандита и получили боеприпасы и бинт.",
	},
	objective_homicide_cowboy = {
		en = "Justice must be served. There is an outlaw going around killing people.",
		ko = "정의를 구현해야 합니다. 사람들을 죽이고 다니는 무법자 놈이 돌아다니고 있어요.",
		zh = "正义必须得到伸张。有个亡命徒正在四处杀人。",
		ru = "Правосудие должно свершиться. Преступник ходит вокруг и убивает людей.",
	},
	objective_homicide_shahid = {
		en = "Brother, by God's will (Insha'Allah). Do not disappoint Him.",
		ko = "형제여, 신의 뜻대로(Insha'Allah). 그분을 실망시키지 마십시오.",
		zh = "兄弟，遵从神的意志（Insha'Allah）。不要让祂失望。",
		ru = "Брат, по воле Бога (Иншааллах). Не разочаруй Его.",
	},
	objective_homicide_lunatic_survive = {
		en = "A madman is on the loose. Now you need to survive.",
		ko = "미친놈이 날뛰고 있습니다. 이제 살아남아야 합니다.",
		zh = "疯子正在横行。现在你必须活下去。",
		ru = "Безумец на свободе. Теперь вам нужно выжить.",
	},
	objective_homicide_mario_traitor = {
		en = "You are evil Mario! Jump around and knock everyone down.",
		ko = "당신은 사악한 마리오입니다! 사방을 점프하며 모두를 쓰러뜨리십시오.",
		zh = "你是邪恶马里奥！到处跳跃并击倒所有人。",
		ru = "Вы злой Марио! Прыгайте вокруг и сбейте всех с ног.",
	},
	objective_homicide_mario_hero = {
		en = "You are hero Mario! Use your jumping ability to stop the traitor.",
		ko = "당신은 영웅 마리오입니다! 점프 능력을 사용해 배신자를 저지하십시오.",
		zh = "你是英雄马里奥！用跳跃能力阻止叛徒。",
		ru = "Вы герой Марио! Используйте прыжки, чтобы остановить предателя.",
	},
	objective_homicide_mario_civilian = {
		en = "You are spectator Mario. Survive and avoid the traitor's traps!",
		ko = "당신은 구경꾼 마리오입니다. 살아남아서 배신자의 함정을 피하십시오!",
		zh = "你是旁观者马里奥。活下来并避开叛徒的陷阱！",
		ru = "Вы Марио-наблюдатель. Выживите и избегайте ловушек предателя!",
	},
	objective_homicide_accomplice = {
		en = "You have no assigned equipment. Help the other traitors win.",
		ko = "지급된 장비가 없습니다. 다른 배신자들의 승리를 도우십시오.",
		zh = "你没有分配到装备。帮助其他叛徒获胜。",
		ru = "У вас нет выданного снаряжения. Помогите другим предателям победить.",
	},
	common_round_starting = {
		en = "Round starting...",
		ko = "라운드 시작 중...",
		zh = "回合开始中...",
		ru = "Раунд начинается...",
	},
	hmcd_type_standard = {
		en = "Standard",
		ko = "일반",
		zh = "标准",
		ru = "Стандарт",
	},
	hmcd_type_soe = {
		en = "State of Emergency",
		ko = "비상사태",
		zh = "紧急状态",
		ru = "Чрезвычайное положение",
	},
	hmcd_type_gunfreezone = {
		en = "Gun Free Zone",
		ko = "총기 금지 구역",
		zh = "禁枪区",
		ru = "Зона без оружия",
	},
	hmcd_type_suicidelunatic = {
		en = "Suicide Lunatic",
		ko = "자폭광",
		zh = "自爆疯子",
		ru = "Смертник-безумец",
	},
	hmcd_type_wildwest = {
		en = "Wild West",
		ko = "서부극",
		zh = "狂野西部",
		ru = "Дикий Запад",
	},
	hmcd_type_bang = {
		en = "BANG!",
		ko = "뱅!",
		zh = "砰！",
		ru = "БЭНГ!",
	},
	hmcd_type_supermario = {
		en = "Super Mario",
		ko = "슈퍼 마리오",
		zh = "超级马里奥",
		ru = "Супер Марио",
	},
	objective_homicide_gangster_cops = {
		en = "Those damn cops have no idea who they are dealing with.",
		ko = "Those damn cops have no idea who they are dealing with.",
		zh = "Those damn cops have no idea who they are dealing with.",
		ru = "Those damn cops have no idea who they are dealing with.",
	},
	common_players = {
		en = "Players:",
		ko = "플레이어:",
		zh = "玩家:",
		ru = "Игроки:",
	},
	defense_vote_title = {
		en = "Game Mode Vote",
		ko = "게임 모드 선택",
		zh = "游戏模式投票",
		ru = "Голосование за режим",
	},
	defense_vote_subtitle = {
		en = "Vote for the mode to play this round",
		ko = "이번 라운드에 진행할 모드에 투표하세요",
		zh = "投票选择本回合要进行的模式",
		ru = "Голосуйте за режим этого раунда",
	},
	defense_time_left = {
		en = "Time left:",
		ko = "남은 시간:",
		zh = "剩余时间：",
		ru = "Осталось времени:",
	},
	defense_vote_stats = {
		en = "Vote stats:",
		ko = "투표 통계:",
		zh = "投票统计：",
		ru = "Статистика голосования:",
	},
	defense_total_votes = {
		en = "Total votes: ",
		ko = "총 투표수: ",
		zh = "总票数：",
		ru = "Всего голосов: ",
	},
	defense_standard = {
		en = "Standard: ",
		ko = "표준: ",
		zh = "标准：",
		ru = "Стандарт: ",
	},
	defense_extended = {
		en = "Extended: ",
		ko = "확장: ",
		zh = "扩展：",
		ru = "Расширенный: ",
	},
	defense_zombie = {
		en = "Zombie: ",
		ko = "좀비: ",
		zh = "僵尸：",
		ru = "Зомби: ",
	},
	defense_votes_suffix = {
		en = " votes)",
		ko = "표)",
		zh = "票)",
		ru = " голосов)",
	},
	defense_in_development = {
		en = "IN DEVELOPMENT",
		ko = "개발 중",
		zh = "开发中",
		ru = "В РАЗРАБОТКЕ",
	},
	defense_selected = {
		en = "SELECTED",
		ko = "선택됨",
		zh = "已选择",
		ru = "ВЫБРАНО",
	},
	defense_mode_development_notice = {
		en = "This mode is currently in development and will be available soon!",
		ko = "이 모드는 현재 개발 중이며 곧 이용 가능합니다!",
		zh = "该模式正在开发中，很快就会开放！",
		ru = "Этот режим сейчас в разработке и скоро будет доступен!",
	},
	defense_boss_appeared = {
		en = "Boss Appeared",
		ko = "보스 출현",
		zh = "Boss 出现",
		ru = "Появился босс",
	},
	defense_boss_prepare = {
		en = "A powerful enemy is coming. Prepare for battle!",
		ko = "강력한 적이 나타납니다. 전투를 준비하십시오!",
		zh = "强大的敌人即将出现。准备战斗！",
		ru = "Появляется сильный враг. Приготовьтесь к бою!",
	},
	defense_commander_supply = {
		en = "Commander Supply Request",
		ko = "지휘관 보급 청구",
		zh = "指挥官补给请求",
		ru = "Запрос снабжения командира",
	},
	defense_available_points = {
		en = "Available points: ",
		ko = "가용 포인트: ",
		zh = "可用点数：",
		ru = "Доступные очки: ",
	},
	defense_your_order = {
		en = "Your order",
		ko = "당신의 주문",
		zh = "你的订单",
		ru = "Ваш заказ",
	},
	defense_total_cost = {
		en = "Total cost: ",
		ko = "총 비용: ",
		zh = "总花费：",
		ru = "Общая стоимость: ",
	},
	defense_points_suffix = {
		en = " points",
		ko = " 포인트",
		zh = " 点",
		ru = " очков",
	},
	defense_place_order = {
		en = "Place order",
		ko = "주문하기",
		zh = "下单",
		ru = "Сделать заказ",
	},
	common_spectators = {
		en = "Spectators:",
		ko = "관전자:",
		zh = "观察者:",
		ru = "Наблюдатели:",
	},
	scoreboard_win_streak = {
		en = "Wins: ",
		ko = "연승: ",
		zh = "连胜: ",
		ru = "Победы: ",
	},
	spectator_panel_character = {
		en = "Character: ",
		ko = "게임 내 이름: ",
		zh = "游戏内名称: ",
		ru = "Имя в игре: ",
	},
	spectator_mode_as = {
		en = "as | ",
		ko = "모드 | ",
		zh = "模式 | ",
		ru = "режим | ",
	},
	spectator_mode_free_roam = {
		en = "Free roam",
		ko = "자유 관전",
		zh = "自由视角",
		ru = "Свободная камера",
	},
	common_player_list = {
		en = "Player list:",
		ko = "플레이어 목록:",
		zh = "玩家列表:",
		ru = "Список игроков:",
	},
	common_close = {
		en = "Close",
		ko = "Close",
		zh = "Close",
		ru = "Close",
	},
	common_unknown = {
		en = "Unknown",
		ko = "Unknown",
		zh = "Unknown",
		ru = "Unknown",
	},
	common_left = {
		en = "Left...",
		ko = "Left...",
		zh = "Left...",
		ru = "Left...",
	},
	common_dead_suffix = {
		en = " - Dead",
		ko = " - Dead",
		zh = " - Dead",
		ru = " - Dead",
	},
	common_waiting_players = {
		en = "Waiting for players: ",
		ko = "Waiting for players: ",
		zh = "Waiting for players: ",
		ru = "Waiting for players: ",
	},
	mode_dm_title = {
		en = "Drunk fighters",
		ko = "Drunk fighters",
		zh = "醉酒斗士",
		ru = "Пьяные бойцы",
	},
	mode_dm_objective = {
		en = "Kill everyone. Each time you hurt someone, the drugs pull you in deeper.",
		ko = "모두를 죽이십시오. 누군가에게 상처를 입힐 때마다 약물에 취합니다.",
		zh = "杀死所有人。每伤害一个人，药物就会让你陷得更深。",
		ru = "Убейте всех. Каждый раз, когда вы раните кого-то, наркотики затягивают вас сильнее.",
	},
	mode_dm_fighter = {
		en = "Vagrant",
		ko = "부랑자",
		zh = "流浪汉",
		ru = "Бродяга",
	},
	objective_defense_hold = {
		en = "Defend the base from the Combine attack.",
		ko = "콤바인의 공격으로부터 기지를 방어하십시오.",
		zh = "保护基地免受联合军攻击。",
		ru = "Защитите базу от атаки Альянса.",
	},
	mode_cszombie_buy = {
		en = "Press F3 to buy weapons",
		ko = "Press F3 to buy weapons",
		zh = "Press F3 to buy weapons",
		ru = "Press F3 to buy weapons",
	},
	mode_cszombie_results = {
		en = "Zombie Results",
		ko = "Zombie Results",
		zh = "Zombie Results",
		ru = "Zombie Results",
	},
	mode_homelander_wait_title = {
		en = "You will spawn when the countdown ends.",
		ko = "You will spawn when the countdown ends.",
		zh = "You will spawn when the countdown ends.",
		ru = "You will spawn when the countdown ends.",
	},
	mode_homelander_wait_subtitle = {
		en = "Rest while you wait.",
		ko = "Rest while you wait.",
		zh = "Rest while you wait.",
		ru = "Rest while you wait.",
	},
	mode_homelander_timer = {
		en = "Homelander arrives in: ",
		ko = "Homelander arrives in: ",
		zh = "Homelander arrives in: ",
		ru = "Homelander arrives in: ",
	},
	mode_infinity_title = {
		en = "Infinity Stone",
		ko = "Infinity Stone",
		zh = "Infinity Stone",
		ru = "Infinity Stone",
	},
	mode_scp_title = {
		en = "SCP Raid",
		ko = "SCP Raid",
		zh = "SCP Raid",
		ru = "SCP Raid",
	},
	mode_scp_release_timer = {
		en = "Containment opens in ",
		ko = "Containment opens in ",
		zh = "Containment opens in ",
		ru = "Containment opens in ",
	},
	pluvtown_somewhere = {
		en = "Somewhere in Pluv Town",
		ko = "플러브 타운 어딘가",
		zh = "普拉夫镇的某处",
		ru = "Где-то в Плув-Тауне",
	},
	pluvtown_madness = {
		en = "Pluvtown Madness",
		ko = "플러브타운 광기",
		zh = "普拉夫镇狂乱",
		ru = "Безумие Плув-Тауна",
	},
	defense_next_wave = {
		en = "Next wave in: ",
		ko = "다음 웨이브까지: ",
		zh = "下一波倒计时：",
		ru = "Следующая волна через: ",
	},
	role_terrorist = {
		en = "Terrorist",
		ko = "테러리스트",
		zh = "恐怖分子",
		ru = "Террорист",
	},
	role_alpha_mtf = {
		en = "Alpha MTF",
		ko = "Alpha MTF",
		zh = "Alpha MTF",
		ru = "Alpha MTF",
	},
	role_omega_mtf = {
		en = "Omega MTF",
		ko = "Omega MTF",
		zh = "Omega MTF",
		ru = "Omega MTF",
	},
	role_swat = {
		en = "SWAT Officer",
		ko = "SWAT Officer",
		zh = "SWAT Officer",
		ru = "SWAT Officer",
	},
	role_suspect = {
		en = "Suspect",
		ko = "Suspect",
		zh = "Suspect",
		ru = "Suspect",
	},
	role_civilian = {
		en = "Civilian",
		ko = "Civilian",
		zh = "Civilian",
		ru = "Civilian",
	},
	role_killer = {
		en = "Killer",
		ko = "살인마",
		zh = "杀手",
		ru = "Убийца",
	},
	role_cook = {
		en = "Cook",
		ko = "Cook",
		zh = "Cook",
		ru = "Cook",
	},
	role_hunter = {
		en = "Hunter",
		ko = "Hunter",
		zh = "Hunter",
		ru = "Hunter",
	},
	scp_obj_scp = {
		en = "Eliminate all MTF support.",
		ko = "Eliminate all MTF support.",
		zh = "Eliminate all MTF support.",
		ru = "Eliminate all MTF support.",
	},
	scp_obj_alpha = {
		en = "Contain SCP-106. If wiped out, reinforcements will deploy.",
		ko = "Contain SCP-106. If wiped out, reinforcements will deploy.",
		zh = "Contain SCP-106. If wiped out, reinforcements will deploy.",
		ru = "Contain SCP-106. If wiped out, reinforcements will deploy.",
	},
	scp_obj_omega = {
		en = "This is the final support. Contain SCP-106 at all costs.",
		ko = "This is the final support. Contain SCP-106 at all costs.",
		zh = "This is the final support. Contain SCP-106 at all costs.",
		ru = "This is the final support. Contain SCP-106 at all costs.",
	},
	fear_line_where = {
		en = "Where did everyone go?",
		ko = "Where did everyone go?",
		zh = "Where did everyone go?",
		ru = "Where did everyone go?",
	},
	fear_line_anyone = {
		en = "Is anyone here?",
		ko = "Is anyone here?",
		zh = "Is anyone here?",
		ru = "Is anyone here?",
	},
	fear_line_quiet = {
		en = "It is strangely quiet.",
		ko = "It is strangely quiet.",
		zh = "It is strangely quiet.",
		ru = "It is strangely quiet.",
	},
	fear_line_no = {
		en = "No.",
		ko = "No.",
		zh = "No.",
		ru = "No.",
	},
	sv_homelander_buy = {
		en = "Buy weapons before Homelander arrives.",
		ko = "Buy weapons before Homelander arrives.",
		zh = "Buy weapons before Homelander arrives.",
		ru = "Buy weapons before Homelander arrives.",
	},
	sv_homelander_wait = {
		en = "You are Homelander. You will enter the battlefield in 40 seconds.",
		ko = "You are Homelander. You will enter the battlefield in 40 seconds.",
		zh = "You are Homelander. You will enter the battlefield in 40 seconds.",
		ru = "You are Homelander. You will enter the battlefield in 40 seconds.",
	},
	sv_homelander_hunt = {
		en = "You are Homelander. Hunt for 3 minutes.",
		ko = "You are Homelander. Hunt for 3 minutes.",
		zh = "You are Homelander. Hunt for 3 minutes.",
		ru = "You are Homelander. Hunt for 3 minutes.",
	},
	sv_homelander_kill_after_laser = {
		en = "Kill Homelander after his laser disappears.",
		ko = "Kill Homelander after his laser disappears.",
		zh = "Kill Homelander after his laser disappears.",
		ru = "Kill Homelander after his laser disappears.",
	},
	sv_homelander_arrived = {
		en = "Homelander has arrived.",
		ko = "Homelander has arrived.",
		zh = "Homelander has arrived.",
		ru = "Homelander has arrived.",
	},
	sv_homelander_compound_death = {
		en = "Died from Compound V side effects.",
		ko = "Died from Compound V side effects.",
		zh = "Died from Compound V side effects.",
		ru = "Died from Compound V side effects.",
	},
	sv_homelander_laser_gone = {
		en = "Homelander's laser is gone. Kill him now.",
		ko = "Homelander's laser is gone. Kill him now.",
		zh = "Homelander's laser is gone. Kill him now.",
		ru = "Homelander's laser is gone. Kill him now.",
	},
	sv_homelander_wins = {
		en = "Homelander survived.",
		ko = "Homelander survived.",
		zh = "Homelander survived.",
		ru = "Homelander survived.",
	},
	sv_homelander_hunters_win = {
		en = "The hunters killed Homelander.",
		ko = "The hunters killed Homelander.",
		zh = "The hunters killed Homelander.",
		ru = "The hunters killed Homelander.",
	},
	sv_scp_escaped = {
		en = "SCP-106 has escaped containment!",
		ko = "SCP-106 has escaped containment!",
		zh = "SCP-106 has escaped containment!",
		ru = "SCP-106 has escaped containment!",
	},
	sv_scp_support = {
		en = "MTF reinforcements have arrived!",
		ko = "MTF reinforcements have arrived!",
		zh = "MTF reinforcements have arrived!",
		ru = "MTF reinforcements have arrived!",
	},
	sv_scp_omega = {
		en = "Final support, Omega MTF has been deployed!",
		ko = "Final support, Omega MTF has been deployed!",
		zh = "Final support, Omega MTF has been deployed!",
		ru = "Final support, Omega MTF has been deployed!",
	},
	sv_scp_started = {
		en = "SCP-106 containment operation has begun.",
		ko = "SCP-106 containment operation has begun.",
		zh = "SCP-106 containment operation has begun.",
		ru = "SCP-106 containment operation has begun.",
	},
	sv_scp_need_support = {
		en = "SCP-106 containment failed. Requesting reinforcements!",
		ko = "SCP-106 containment failed. Requesting reinforcements!",
		zh = "SCP-106 containment failed. Requesting reinforcements!",
		ru = "SCP-106 containment failed. Requesting reinforcements!",
	},
	sv_scp_alpha_dead = {
		en = "Alpha squad has been wiped out. Requesting final support!",
		ko = "Alpha squad has been wiped out. Requesting final support!",
		zh = "Alpha squad has been wiped out. Requesting final support!",
		ru = "Alpha squad has been wiped out. Requesting final support!",
	},
	sv_scp_mtf_win = {
		en = "SCP-106 was successfully contained!",
		ko = "SCP-106 was successfully contained!",
		zh = "SCP-106 was successfully contained!",
		ru = "SCP-106 was successfully contained!",
	},
	sv_scp_scp_win = {
		en = "SCP-106 containment failed. Request reinforcements immediately!",
		ko = "SCP-106 containment failed. Request reinforcements immediately!",
		zh = "SCP-106 containment failed. Request reinforcements immediately!",
		ru = "SCP-106 containment failed. Request reinforcements immediately!",
	},
	sv_fear_defeat = {
		en = "All survivors died. Fear consumed you. Defeat.",
		ko = "All survivors died. Fear consumed you. Defeat.",
		zh = "All survivors died. Fear consumed you. Defeat.",
		ru = "All survivors died. Fear consumed you. Defeat.",
	},
	mode_infinity_quote = {
		en = "Fine. I'll do it myself.",
		ko = "Fine. I'll do it myself.",
		zh = "Fine. I'll do it myself.",
		ru = "Fine. I'll do it myself.",
	},
	objective_wizard_survive = {
		en = "Survive with magic until the end.",
		ko = "마법으로 마지막까지 살아남으십시오.",
		zh = "用魔法存活到最后。",
		ru = "Выживите до конца с помощью магии.",
	},
	objective_medusa_survive = {
		en = "Petrify everyone and survive until the end.",
		ko = "모두 석화시키고 마지막까지 살아남으십시오.",
		zh = "石化所有人并存活到最后。",
		ru = "Обратите всех в камень и выживите до конца.",
	},
	objective_cszombie_human = {
		en = "Buy weapons and survive the infection.",
		ko = "무기를 구매하고 감염에서 살아남으십시오.",
		zh = "购买武器并在感染中活下来。",
		ru = "Покупайте оружие и переживите заражение.",
	},
	objective_cszombie_zombie = {
		en = "Infect every human.",
		ko = "모든 인간을 감염시키십시오.",
		zh = "感染所有人类。",
		ru = "Заразите всех людей.",
	},
	mode_tdm_shop_hint = {
		en = "Press F3 to open the shop",
		ko = "F3을 눌러 상점을 여십시오",
		zh = "按 F3 打开商店",
		ru = "Нажмите F3, чтобы открыть магазин",
	},
	objective_infinity_stone = {
		en = "Fine. I'll do it myself.",
		ko = "Fine. I'll do it myself.",
		zh = "好吧。我自己来。",
		ru = "Ладно. Я сделаю это сам.",
	},
	common_somewhere_pluvtown = {
		en = "SOMEWHERE IN PLUVTOWN",
		ko = "플러브 타운 어딘가",
		zh = "PLUVTOWN 的某处",
		ru = "ГДЕ-ТО В ПЛАВТАУНЕ",
	},
	replay_browser_title = {
		en = "Z-City Event Bodycam Replay Browser",
		ko = "Z-City Event Bodycam Replay Browser",
		zh = "Z-City Event Bodycam Replay Browser",
		ru = "Z-City Event Bodycam Replay Browser",
	},
	replay_play = {
		en = "Play",
		ko = "Play",
		zh = "Play",
		ru = "Play",
	},
	replay_stop = {
		en = "Stop",
		ko = "Stop",
		zh = "Stop",
		ru = "Stop",
	},
	replay_load_selected = {
		en = "Load Selected",
		ko = "Load Selected",
		zh = "Load Selected",
		ru = "Load Selected",
	},
	replay_refresh = {
		en = "Refresh",
		ko = "Refresh",
		zh = "Refresh",
		ru = "Refresh",
	},
	replay_reset_all = {
		en = "Reset All",
		ko = "Reset All",
		zh = "Reset All",
		ru = "Reset All",
	},
	replay_restore_latest = {
		en = "Restore Latest",
		ko = "Restore Latest",
		zh = "Restore Latest",
		ru = "Restore Latest",
	},
	replay_delete = {
		en = "Delete",
		ko = "Delete",
		zh = "Delete",
		ru = "Delete",
	},
	replay_reset = {
		en = "Reset",
		ko = "Reset",
		zh = "Reset",
		ru = "Reset",
	},
	replay_cancel = {
		en = "Cancel",
		ko = "Cancel",
		zh = "Cancel",
		ru = "Cancel",
	},
	replay_selected_none = {
		en = "Selected: none",
		ko = "Selected: none",
		zh = "Selected: none",
		ru = "Selected: none",
	},
	replay_selected_prefix = {
		en = "Selected: ",
		ko = "Selected: ",
		zh = "Selected: ",
		ru = "Selected: ",
	},
	replay_none = {
		en = "none",
		ko = "none",
		zh = "none",
		ru = "none",
	},
	replay_confirm_reset_all = {
		en = "Move all saved event replays to trash?",
		ko = "Move all saved event replays to trash?",
		zh = "Move all saved event replays to trash?",
		ru = "Move all saved event replays to trash?",
	},
	replay_no_file_selected = {
		en = "Select a saved event replay file first.",
		ko = "Select a saved event replay file first.",
		zh = "Select a saved event replay file first.",
		ru = "Select a saved event replay file first.",
	},
	replay_not_loaded = {
		en = "Replay is not loaded.",
		ko = "Replay is not loaded.",
		zh = "Replay is not loaded.",
		ru = "Replay is not loaded.",
	},
	replay_stopped = {
		en = "Replay stopped.",
		ko = "Replay stopped.",
		zh = "Replay stopped.",
		ru = "Replay stopped.",
	},
	replay_too_few_events = {
		en = "Not enough events to play.",
		ko = "Not enough events to play.",
		zh = "Not enough events to play.",
		ru = "Not enough events to play.",
	},
	replay_loading_saved = {
		en = "Loading saved event replay...",
		ko = "Loading saved event replay...",
		zh = "Loading saved event replay...",
		ru = "Loading saved event replay...",
	},
	replay_load_failed = {
		en = "Event replay failed to load or did not respond.",
		ko = "Event replay failed to load or did not respond.",
		zh = "Event replay failed to load or did not respond.",
		ru = "Event replay failed to load or did not respond.",
	},
	replay_tracers_hide = {
		en = "Hide shot lines",
		ko = "Hide shot lines",
		zh = "Hide shot lines",
		ru = "Hide shot lines",
	},
	replay_tracers_show = {
		en = "Show shot lines",
		ko = "Show shot lines",
		zh = "Show shot lines",
		ru = "Show shot lines",
	},
	replay_hitpos_hide = {
		en = "Hide HitPos",
		ko = "Hide HitPos",
		zh = "Hide HitPos",
		ru = "Hide HitPos",
	},
	replay_hitpos_show = {
		en = "Show HitPos",
		ko = "Show HitPos",
		zh = "Show HitPos",
		ru = "Show HitPos",
	},
	replay_victim_hide = {
		en = "Hide victim markers",
		ko = "Hide victim markers",
		zh = "Hide victim markers",
		ru = "Hide victim markers",
	},
	replay_victim_show = {
		en = "Show victim markers",
		ko = "Show victim markers",
		zh = "Show victim markers",
		ru = "Show victim markers",
	},
	replay_freecam_off = {
		en = "Freecam off",
		ko = "Freecam off",
		zh = "Freecam off",
		ru = "Freecam off",
	},
	replay_freecam_on = {
		en = "Freecam on",
		ko = "Freecam on",
		zh = "Freecam on",
		ru = "Freecam on",
	},
	spawn_editor_title = {
		en = "Spawnpoint Editor",
		ko = "Spawnpoint Editor",
		zh = "Spawnpoint Editor",
		ru = "Spawnpoint Editor",
	},
	spawn_editor_create = {
		en = "Create",
		ko = "Create",
		zh = "Create",
		ru = "Create",
	},
	spawn_editor_delete = {
		en = "Delete",
		ko = "Delete",
		zh = "Delete",
		ru = "Delete",
	},
	spawn_editor_saved_slots = {
		en = "saved slots",
		ko = "saved slots",
		zh = "saved slots",
		ru = "saved slots",
	},
	spawn_editor_save = {
		en = "Save spawnpoints",
		ko = "Save spawnpoints",
		zh = "Save spawnpoints",
		ru = "Save spawnpoints",
	},
	spawn_editor_load = {
		en = "Load",
		ko = "Load",
		zh = "Load",
		ru = "Load",
	},
	spawn_editor_delete_slot = {
		en = "Delete slot",
		ko = "Delete slot",
		zh = "Delete slot",
		ru = "Delete slot",
	},
	spawn_editor_reset = {
		en = "Reset to map spawns",
		ko = "Reset to map spawns",
		zh = "Reset to map spawns",
		ru = "Reset to map spawns",
	},
	spawn_editor_menu_toggle = {
		en = "Show spawnpoint editor",
		ko = "Show spawnpoint editor",
		zh = "Show spawnpoint editor",
		ru = "Show spawnpoint editor",
	},
	spawn_editor_menu_help = {
		en = "Blue circles are saved ZCity spawn points. Yellow circles are original map spawn entities. Use right click in Create/Delete mode. Reset restores the original yellow map spawns.",
		ko = "Blue circles are saved ZCity spawn points. Yellow circles are original map spawn entities. Use right click in Create/Delete mode. Reset restores the original yellow map spawns.",
		zh = "Blue circles are saved ZCity spawn points. Yellow circles are original map spawn entities. Use right click in Create/Delete mode. Reset restores the original yellow map spawns.",
		ru = "Blue circles are saved ZCity spawn points. Yellow circles are original map spawn entities. Use right click in Create/Delete mode. Reset restores the original yellow map spawns.",
	},
	spawn_editor_refresh = {
		en = "Refresh spawn points",
		ko = "Refresh spawn points",
		zh = "Refresh spawn points",
		ru = "Refresh spawn points",
	},
	spawn_msg_look_flat = {
		en = "Look at a flat floor to add a spawn point.",
		ko = "Look at a flat floor to add a spawn point.",
		zh = "Look at a flat floor to add a spawn point.",
		ru = "Look at a flat floor to add a spawn point.",
	},
	spawn_msg_added = {
		en = "Spawn point added.",
		ko = "Spawn point added.",
		zh = "Spawn point added.",
		ru = "Spawn point added.",
	},
	spawn_msg_removed = {
		en = "Spawn point removed from editor set.",
		ko = "Spawn point removed from editor set.",
		zh = "Spawn point removed from editor set.",
		ru = "Spawn point removed from editor set.",
	},
	spawn_msg_reset = {
		en = "Spawn points reset to original map spawns.",
		ko = "Spawn points reset to original map spawns.",
		zh = "Spawn points reset to original map spawns.",
		ru = "Spawn points reset to original map spawns.",
	},
	spawn_msg_saved_prefix = {
		en = "Spawn preset saved: ",
		ko = "Spawn preset saved: ",
		zh = "Spawn preset saved: ",
		ru = "Spawn preset saved: ",
	},
	spawn_msg_loaded_prefix = {
		en = "Spawn preset loaded: ",
		ko = "Spawn preset loaded: ",
		zh = "Spawn preset loaded: ",
		ru = "Spawn preset loaded: ",
	},
	spawn_msg_not_found = {
		en = "Spawn preset not found.",
		ko = "Spawn preset not found.",
		zh = "Spawn preset not found.",
		ru = "Spawn preset not found.",
	},
	mode_name_tdm = {
		en = "Team Deathmatch",
		ko = "팀 데스매치",
		zh = "团队死亡竞赛",
		ru = "Командный бой насмерть",
	},
	mode_name_cstrike = {
		en = "Counter-Strike",
		ko = "Counter-Strike",
		zh = "Counter-Strike",
		ru = "Counter-Strike",
	},
	mode_name_cszombie = {
		en = "CS Zombie",
		ko = "CS 좀비",
		zh = "CS 僵尸",
		ru = "CS Зомби",
	},
	mode_name_infinitystone = {
		en = "Infinity Stone",
		ko = "인피니티 스톤",
		zh = "无限宝石",
		ru = "Камень бесконечности",
	},
	mode_name_harrypotter = {
		en = "Harry Potter",
		ko = "해리 포터",
		zh = "哈利波特",
		ru = "Гарри Поттер",
	},
	mode_name_medusa = {
		en = "Medusa",
		ko = "메두사",
		zh = "美杜莎",
		ru = "Медуза",
	},
	mode_name_homelander = {
		en = "Homelander Tag",
		ko = "홈랜더 술래잡기",
		zh = "祖国人追逐战",
		ru = "Догонялки с Хоумлендером",
	},
	mode_name_quarantinefailure = {
		en = "Containment Failure",
		ko = "격리 실패",
		zh = "隔离失败",
		ru = "Срыв карантина",
	},
	qf_role_carrier = {
		en = "Patient Zero",
		ko = "최초 감염원",
		zh = "零号感染者",
		ru = "Нулевой пациент",
	},
	qf_role_doctor = {
		en = "Doctor",
		ko = "의사",
		zh = "医生",
		ru = "Врач",
	},
	qf_role_soldier = {
		en = "Containment Soldier",
		ko = "격리군",
		zh = "隔离部队",
		ru = "Солдат карантина",
	},
	qf_role_citizen = {
		en = "Citizen",
		ko = "시민",
		zh = "市民",
		ru = "Гражданский",
	},
	qf_role_infected = {
		en = "Infected",
		ko = "감염자",
		zh = "感染者",
		ru = "Заражённый",
	},
	qf_objective_carrier = {
		en = "Eat or throw the biohazard ball and infect every survivor.",
		ko = "바이오볼을 먹거나 던져 모든 생존자를 감염시키세요.",
		zh = "吃下或投掷生化球，感染所有幸存者。",
		ru = "Съешьте или бросьте биошар и заразите всех выживших.",
	},
	qf_objective_doctor = {
		en = "Save one infected person with your only cure.",
		ko = "단 하나의 치료제로 감염자를 구하세요.",
		zh = "用唯一的解药救下一名感染者。",
		ru = "Спасите одного заражённого единственным лекарством.",
	},
	qf_objective_soldier = {
		en = "Follow citizen reports and stop the infected.",
		ko = "시민의 신고를 확인하고 감염자를 저지하세요.",
		zh = "查看市民举报并阻止感染者。",
		ru = "Проверяйте сообщения граждан и остановите заражённых.",
	},
	qf_objective_citizen = {
		en = "Report suspicious people with your phone and survive.",
		ko = "휴대폰으로 수상한 사람을 신고하고 살아남으세요.",
		zh = "用手机举报可疑人员并生存下来。",
		ru = "Сообщайте о подозрительных людях по телефону и выживите.",
	},
	qf_objective_infected = {
		en = "Attack survivors and spread the infection.",
		ko = "생존자를 공격해 감염을 퍼뜨리세요.",
		zh = "攻击幸存者并传播感染。",
		ru = "Атакуйте выживших и распространяйте инфекцию.",
	},
	qf_infection_countdown = {
		en = "Transformation in: ",
		ko = "변이까지: ",
		zh = "变异倒计时：",
		ru = "До превращения: ",
	},
	mode_name_blood_money = {
		en = "Blood Money",
		ko = "블러드 머니",
		zh = "血钱",
		ru = "Кровавые деньги",
	},
	mode_name_tdm_melee = {
		en = "TDM Melee",
		ko = "근접전 팀 데스매치",
		zh = "近战团队死斗",
		ru = "Командный бой врукопашную",
	},
	mode_name_lbs = {
		en = "Last Bystander Standing",
		ko = "최후의 생존자",
		zh = "最后的旁观者",
		ru = "Последний выживший",
	},
	mode_name_juggernaut = {
		en = "Juggernaut",
		ko = "저거너트",
		zh = "重装战士",
		ru = "Джаггернаут",
	},
	mode_name_smo = {
		en = "Special Military Operation",
		ko = "특수 군사 작전",
		zh = "特别军事行动",
		ru = "Специальная военная операция",
	},
	mode_name_hmcd = {
		en = "Homicide",
		ko = "호미사이드",
		zh = "凶案",
		ru = "Убийство",
	},
	mode_name_gravtdm = {
		en = "Gravity Gun Team Deathmatch",
		ko = "그래비티 건 팀 데스매치",
		zh = "重力枪团队死亡竞赛",
		ru = "Командный бой с грави-пушками",
	},
	mode_name_hl2dm = {
		en = "Half-Life 2 Deathmatch",
		ko = "하프라이프 2 데스매치",
		zh = "半条命 2 死亡竞赛",
		ru = "Half-Life 2 Deathmatch",
	},
	mode_title_hl2dm = {
		en = "ZBattle | Half-Life 2 Deathmatch",
		ko = "ZBattle | 하프라이프 2 데스매치",
		zh = "ZBattle | 半条命 2 死亡竞赛",
		ru = "ZBattle | Half-Life 2 Deathmatch",
	},
	objective_hl2dm_rebel = {
		en = "Kill all Combine forces and survive.",
		ko = "모든 콤바인을 사살하고 생존하십시오.",
		zh = "消灭所有联合军并生存。",
		ru = "Убейте всех солдат Альянса и выживите.",
	},
	objective_hl2dm_combine = {
		en = "Eliminate all rebel forces.",
		ko = "모든 반군 세력을 섬멸하십시오.",
		zh = "消灭所有反抗军。",
		ru = "Уничтожьте все силы повстанцев.",
	},
	mode_team_prefix = {
		en = "Your team: ",
		ko = "당신의 팀: ",
		zh = "你的队伍：",
		ru = "Ваша команда: ",
	},
	mode_vietnam_vc_obj = {
		en = "Eliminate the US Army.",
		ko = "미군을 전멸시키십시오.",
		zh = "消灭美军。",
		ru = "Уничтожьте армию США.",
	},
	mode_vietnam_us_obj = {
		en = "Eliminate the Viet Cong.",
		ko = "베트콩을 전멸시키십시오.",
		zh = "消灭越共。",
		ru = "Уничтожьте Вьетконг.",
	},
	role_viet_cong = {
		en = "Viet Cong",
		ko = "베트콩",
		zh = "越共",
		ru = "Вьетконг",
	},
	role_vc_machine_gunner = {
		en = "VC Machine Gunner",
		ko = "베트콩 기관총 사수",
		zh = "越共机枪手",
		ru = "Пулеметчик Вьетконга",
	},
	role_us_army = {
		en = "US Army",
		ko = "미군",
		zh = "美军",
		ru = "Армия США",
	},
	role_us_machine_gunner = {
		en = "US Machine Gunner",
		ko = "미군 기관총 사수",
		zh = "美军机枪手",
		ru = "Пулеметчик армии США",
	},
	mode_sfd_objective = {
		en = "Kill everyone.",
		ko = "모두를 처치하십시오.",
		zh = "杀死所有人。",
		ru = "Убейте всех.",
	},
	role_superfighter = {
		en = "Superfighter",
		ko = "슈퍼파이터",
		zh = "超级战士",
		ru = "Супербоец",
	},
	role_slugcat = {
		en = "Slugcat",
		ko = "슬러그캣",
		zh = "蛞蝓猫",
		ru = "Слизнекот",
	},
	mode_slug_arena_objective = {
		en = "Survive and eliminate the others.",
		ko = "생존하고 다른 이들을 제거하십시오.",
		zh = "活下来并消灭其他人。",
		ru = "Выживите и устраните остальных.",
	},
	mode_gwars_bloodz_obj = {
		en = "Take out all Groove members.",
		ko = "그루브 조직원을 모두 제거하십시오.",
		zh = "消灭所有 Groove 成员。",
		ru = "Устраните всех участников Groove.",
	},
	mode_gwars_groove_obj = {
		en = "Take out all Bloodz members.",
		ko = "블러즈 조직원을 모두 제거하십시오.",
		zh = "消灭所有 Bloodz 成员。",
		ru = "Устраните всех участников Bloodz.",
	},
	mode_gwars_swat_timer_suffix = {
		en = " until SWAT arrival!",
		ko = " SWAT 대원 도착까지 남은 시간!",
		zh = " 距离 SWAT 到达！",
		ru = " до прибытия SWAT!",
	},
	mode_gwars_pluvtown_somewhere = {
		en = "Somewhere in Pluv Town",
		ko = "플러브 타운 어딘가",
		zh = "普拉夫镇的某处",
		ru = "Где-то в Плув-Тауне",
	},
	mode_tarkov_bear_obj = {
		en = "Eliminate USEC before SCAVs arrive.",
		ko = "SCAV이 도착하기 전에 USEC을 전멸시키십시오.",
		zh = "Eliminate USEC before SCAVs arrive.",
		ru = "Eliminate USEC before SCAVs arrive.",
	},
	mode_tarkov_usec_obj = {
		en = "Eliminate BEAR before SCAVs arrive.",
		ko = "SCAV이 도착하기 전에 BEAR를 전멸시키십시오.",
		zh = "Eliminate BEAR before SCAVs arrive.",
		ru = "Eliminate BEAR before SCAVs arrive.",
	},
	mode_tarkov_scav_obj = {
		en = "Enter the area and eliminate the surviving PMCs.",
		ko = "교전 지역에 진입해 살아남은 PMC를 제거하십시오.",
		zh = "Enter the area and eliminate the surviving PMCs.",
		ru = "Enter the area and eliminate the surviving PMCs.",
	},
	mode_tarkov_boss_obj = {
		en = "Lead the SCAV team with your PKM.",
		ko = "PKM과 중장비로 SCAV 팀을 지휘하십시오.",
		zh = "Lead the SCAV team with your PKM.",
		ru = "Lead the SCAV team with your PKM.",
	},
	mode_tarkov_scav_timer = {
		en = "SCAV arrival: ",
		ko = "SCAV 도착까지: ",
		zh = "SCAV arrival: ",
		ru = "SCAV arrival: ",
	},
	mode_tarkov_scav_active = {
		en = "SCAVs are in the area: ",
		ko = "SCAV 교전 잔여 시간: ",
		zh = "SCAVs are in the area: ",
		ru = "SCAVs are in the area: ",
	},
	mode_tarkov_scav_arrived = {
		en = "SCAVs have entered the area.",
		ko = "SCAV 팀이 교전 지역에 진입했습니다.",
		zh = "SCAVs have entered the area.",
		ru = "SCAVs have entered the area.",
	},
	mode_tarkov_boss_arrived = {
		en = "A heavily armed SCAV boss is leading them.",
		ko = "PKM과 중장비로 무장한 SCAV 보스가 이들을 지휘합니다.",
		zh = "A heavily armed SCAV boss is leading them.",
		ru = "A heavily armed SCAV boss is leading them.",
	},
	mode_tarkov_no_scavs = {
		en = "No SCAV reinforcements were available.",
		ko = "투입 가능한 SCAV 지원 인원이 없습니다.",
		zh = "No SCAV reinforcements were available.",
		ru = "No SCAV reinforcements were available.",
	},
	mode_criresp_swat_obj = {
		en = "Negotiations failed. Eliminate the threat. 10-4.",
		ko = "협상이 결렬되었습니다. 위협을 제거하십시오. 10-4.",
		zh = "谈判失败。消除威胁。10-4。",
		ru = "Переговоры провалились. Устраните угрозу. 10-4.",
	},
	mode_criresp_suspect_obj = {
		en = "This is my house. I do what I want.",
		ko = "여긴 내 집입니다. 나는 내 마음대로 할 겁니다.",
		zh = "这是我的房子。我想做什么就做什么。",
		ru = "Это мой дом. Я буду делать что хочу.",
	},
	mode_criresp_swat_timer = {
		en = "SWAT arrival in: ",
		ko = "SWAT 도착까지: ",
		zh = "SWAT 到达倒计时：",
		ru = "SWAT прибудет через: ",
	},
	common_you_are_role = {
		en = "You are %s.",
		ko = "당신은 %s입니다.",
		zh = "你是%s。",
		ru = "Вы: %s.",
	},
	mode_name_riot = {
		en = "Riot",
		ko = "폭동",
		zh = "暴动",
		ru = "Бунт",
	},
	mode_name_gwars = {
		en = "Gang Wars",
		ko = "갱 전쟁",
		zh = "帮派战争",
		ru = "Война банд",
	},
	mode_name_tarkov = {
		en = "Tarkov Raid",
		ko = "타르코프 습격",
		zh = "Tarkov Raid",
		ru = "Tarkov Raid",
	},
	mode_name_criresp = {
		en = "Crisis Response",
		ko = "위기 대응",
		zh = "危机响应",
		ru = "Кризисное реагирование",
	},
	mode_name_coop = {
		en = "CO-OP",
		ko = "CO-OP",
		zh = "CO-OP",
		ru = "CO-OP",
	},
	mode_name_dm = {
		en = "Deathmatch",
		ko = "데스매치",
		zh = "死亡竞赛",
		ru = "Бой насмерть",
	},
	mode_name_defense = {
		en = "NPC Defense",
		ko = "NPC 방어",
		zh = "NPC 防御",
		ru = "Оборона от NPC",
	},
	mode_name_scp106raid = {
		en = "SCP Raid",
		ko = "SCP 습격",
		zh = "SCP 突袭",
		ru = "Рейд SCP",
	},
	mode_name_pathowogen = {
		en = "Pathowogen",
		ko = "Pathowogen",
		zh = "Pathowogen",
		ru = "Pathowogen",
	},
	pathowogen_extraction_point = {
		en = "[Extraction Point]",
		ko = "[탈출 지점]",
		zh = "[撤离点]",
		ru = "[Точка эвакуации]",
	},
	pathowogen_extraction_countdown = {
		en = "Extraction in: ",
		ko = "탈출까지: ",
		zh = "撤离倒计时：",
		ru = "Эвакуация через: ",
	},
	mode_name_vietnam = {
		en = "Vietnam War",
		ko = "베트남 전쟁",
		zh = "越南战争",
		ru = "Вьетнамская война",
	},
	mode_name_superfighters = {
		en = "Superfighters 3D",
		ko = "슈퍼파이터 3D",
		zh = "超级战士 3D",
		ru = "Superfighters 3D",
	},
	mode_name_event = {
		en = "Event",
		ko = "이벤트",
		zh = "事件",
		ru = "Событие",
	},
	mode_name_slug_arena = {
		en = "Slug Arena",
		ko = "슬러그 아레나",
		zh = "蛞蝓竞技场",
		ru = "Арена слизнекотов",
	},
	mode_name_fear = {
		en = "Homicide Fear",
		ko = "호미사이드 공포",
		zh = "凶案恐惧",
		ru = "Страх убийства",
	},
	mode_menu_admin = {
		en = "Game Mode Admin",
		ko = "Game Mode Admin",
		zh = "Game Mode Admin",
		ru = "Game Mode Admin",
	},
	mode_menu_queue = {
		en = "Game Mode Queue",
		ko = "Game Mode Queue",
		zh = "Game Mode Queue",
		ru = "Game Mode Queue",
	},
	mode_menu_available = {
		en = "Available Game Modes",
		ko = "Available Game Modes",
		zh = "Available Game Modes",
		ru = "Available Game Modes",
	},
	mode_menu_apply_queue = {
		en = "Apply queue",
		ko = "Apply queue",
		zh = "Apply queue",
		ru = "Apply queue",
	},
	mode_menu_clear_queue = {
		en = "Clear queue",
		ko = "Clear queue",
		zh = "Clear queue",
		ru = "Clear queue",
	},
	mode_menu_next_prefix = {
		en = "Next mode: ",
		ko = "Next mode: ",
		zh = "Next mode: ",
		ru = "Next mode: ",
	},
	mode_menu_search = {
		en = "Search game modes...",
		ko = "Search game modes...",
		zh = "Search game modes...",
		ru = "Search game modes...",
	},
	mode_menu_select = {
		en = "Select",
		ko = "Select",
		zh = "Select",
		ru = "Select",
	},
	mode_menu_batch = {
		en = "Batch actions",
		ko = "Batch actions",
		zh = "Batch actions",
		ru = "Batch actions",
	},
	mode_menu_add_front = {
		en = "Add selected to front of queue",
		ko = "Add selected to front of queue",
		zh = "Add selected to front of queue",
		ru = "Add selected to front of queue",
	},
	mode_menu_add_back = {
		en = "Add selected to back of queue",
		ko = "Add selected to back of queue",
		zh = "Add selected to back of queue",
		ru = "Add selected to back of queue",
	},
	mode_menu_refresh = {
		en = "Refresh data",
		ko = "Refresh data",
		zh = "Refresh data",
		ru = "Refresh data",
	},
	mode_menu_set_next = {
		en = "Set next mode",
		ko = "Set next mode",
		zh = "Set next mode",
		ru = "Set next mode",
	},
	mode_menu_force_next = {
		en = "Force next mode",
		ko = "Force next mode",
		zh = "Force next mode",
		ru = "Force next mode",
	},
	mode_menu_manage_queue = {
		en = "Manage game mode queue",
		ko = "Manage game mode queue",
		zh = "Manage game mode queue",
		ru = "Manage game mode queue",
	},
	mode_menu_end_round = {
		en = "End round",
		ko = "End round",
		zh = "End round",
		ru = "End round",
	},
	mode_title_coop = {
		en = "Homicide | CO-OP",
		ko = "Homicide | CO-OP",
		zh = "Homicide | CO-OP",
		ru = "Homicide | CO-OP",
	},
	mode_title_criresp = {
		en = "Crisis Response",
		ko = "Crisis Response",
		zh = "Crisis Response",
		ru = "Crisis Response",
	},
	mode_title_riot = {
		en = "Homicide | Riot",
		ko = "Homicide | Riot",
		zh = "Homicide | Riot",
		ru = "Homicide | Riot",
	},
	role_fighter = {
		en = "Fighter",
		ko = "전투원",
		zh = "战斗员",
		ru = "Боец",
	},
	role_human = {
		en = "Human",
		ko = "인간",
		zh = "人类",
		ru = "Человек",
	},
	role_zombie = {
		en = "Zombie",
		ko = "좀비",
		zh = "僵尸",
		ru = "Зомби",
	},
	role_survivor = {
		en = "Survivor",
		ko = "생존자",
		zh = "幸存者",
		ru = "Выживший",
	},
	role_freeman = {
		en = "Freeman",
		ko = "프리맨",
		zh = "弗里曼",
		ru = "Фримен",
	},
	role_rebel = {
		en = "Rebel",
		ko = "반군",
		zh = "反抗军",
		ru = "Повстанец",
	},
	role_refugee = {
		en = "Refugee",
		ko = "난민",
		zh = "难民",
		ru = "Беженец",
	},
	role_medic = {
		en = "Medic",
		ko = "의무병",
		zh = "医疗兵",
		ru = "Медик",
	},
	role_grenadier = {
		en = "Grenadier",
		ko = "척탄병",
		zh = "掷弹兵",
		ru = "Гренадер",
	},
	role_combine = {
		en = "Combine",
		ko = "콤바인",
		zh = "联合军",
		ru = "Альянс",
	},
	role_combine_soldier = {
		en = "Combine Soldier",
		ko = "콤바인 솔저",
		zh = "联合军士兵",
		ru = "Солдат Альянса",
	},
	role_elite_combine_soldier = {
		en = "Elite Combine Soldier",
		ko = "엘리트 콤바인 솔저",
		zh = "精英联合军士兵",
		ru = "Элитный солдат Альянса",
	},
	role_combine_shotgunner = {
		en = "Combine Shotgunner",
		ko = "콤바인 샷건병",
		zh = "联合军霰弹兵",
		ru = "Дробовик Альянса",
	},
	role_metrocop = {
		en = "Metrocop",
		ko = "메트로캅",
		zh = "都市警察",
		ru = "Метрокоп",
	},
	role_rioter = {
		en = "Rioter",
		ko = "폭도",
		zh = "暴徒",
		ru = "Бунтовщик",
	},
	role_law_enforcement = {
		en = "Law Enforcement",
		ko = "법 집행관",
		zh = "执法人员",
		ru = "Правоохранитель",
	},
	role_gauntlet = {
		en = "Gauntlet",
		ko = "건틀렛",
		zh = "手套持有者",
		ru = "Перчатка",
	},
	role_homelander = {
		en = "Homelander",
		ko = "홈랜더",
		zh = "祖国人",
		ru = "Хоумлендер",
	},
	role_wizard = {
		en = "Wizard",
		ko = "마법사",
		zh = "巫师",
		ru = "Волшебник",
	},
	role_medusa = {
		en = "Medusa",
		ko = "메두사",
		zh = "美杜莎",
		ru = "Медуза",
	},
	role_counter_terrorist = {
		en = "Counter Terrorist",
		ko = "대테러부대",
		zh = "反恐部队",
		ru = "Контртеррорист",
	},
	role_eventer = {
		en = "Eventer",
		ko = "이벤트 진행자",
		zh = "事件主持者",
		ru = "Организатор события",
	},
	role_player = {
		en = "Player",
		ko = "플레이어",
		zh = "玩家",
		ru = "Игрок",
	},
	role_bloodz = {
		en = "Bloodz",
		ko = "Bloodz",
		zh = "Bloodz",
		ru = "Bloodz",
	},
	role_groove = {
		en = "Groove",
		ko = "Groove",
		zh = "Groove",
		ru = "Groove",
	},
	role_bear = {
		en = "BEAR",
		ko = "BEAR",
		zh = "BEAR",
		ru = "BEAR",
	},
	role_usec = {
		en = "USEC",
		ko = "USEC",
		zh = "USEC",
		ru = "USEC",
	},
	role_scav = {
		en = "SCAV",
		ko = "SCAV",
		zh = "SCAV",
		ru = "SCAV",
	},
	role_scav_boss = {
		en = "SCAV Boss",
		ko = "SCAV 보스",
		zh = "SCAV Boss",
		ru = "SCAV Boss",
	},
	role_police_response = {
		en = "Police Response",
		ko = "경찰 대응팀",
		zh = "警方响应队",
		ru = "Полицейская группа реагирования",
	},
	objective_follow_freeman = {
		en = "Follow Freeman!",
		ko = "Follow Freeman!",
		zh = "Follow Freeman!",
		ru = "Follow Freeman!",
	},
	objective_lead_rebels = {
		en = "Lead the rebels to victory!",
		ko = "Lead the rebels to victory!",
		zh = "Lead the rebels to victory!",
		ru = "Lead the rebels to victory!",
	},
	objective_no_equipment = {
		en = "You have no equipment. Help the other traitors win.",
		ko = "You have no equipment. Help the other traitors win.",
		zh = "You have no equipment. Help the other traitors win.",
		ru = "You have no equipment. Help the other traitors win.",
	},
	objective_round_starting = {
		en = "Round starting...",
		ko = "Round starting...",
		zh = "Round starting...",
		ru = "Round starting...",
	},
	objective_survive_avoid_killer = {
		en = "Survive and avoid the killer. Help the others survive.",
		ko = "Survive and avoid the killer. Help the others survive.",
		zh = "Survive and avoid the killer. Help the others survive.",
		ru = "Survive and avoid the killer. Help the others survive.",
	},
	chat_player_joined = {
		en = "%s joined as a player.",
		ko = "%s joined as a player.",
		zh = "%s joined as a player.",
		ru = "%s joined as a player.",
	},
	chat_current_karma = {
		en = "Current karma: ",
		ko = "Current karma: ",
		zh = "Current karma: ",
		ru = "Текущая карма: ",
	}
}

ZCLang.LanguageNames = {
	en = {auto = "Auto", en = "English", ko = "Korean", zh = "Chinese", ru = "Russian"},
	ko = {auto = "자동", en = "영어", ko = "한국어", zh = "중국어", ru = "러시아어"},
	zh = {auto = "自动", en = "英语", ko = "韩语", zh = "中文", ru = "俄语"},
	ru = {auto = "Авто", en = "Английский", ko = "Корейский", zh = "Китайский", ru = "Русский"}
}

-- Korean completion layer. The original table contains a number of entries
-- whose Korean value is missing or still duplicates the English placeholder.
-- Keeping the corrections together makes missing connections easy to audit.
local koreanOverrides = {
	settings_category_ui = "UI",
	settings_category_gameplay = "게임플레이",
	settings_category_debug = "디버그",
	settings_category_serverside_gameplay = "서버 게임플레이",

	settings_option_hg_old_notificate = "이전 알림 방식",
	settings_help_hg_old_notificate = "이전 채팅 알림 방식을 사용합니다.",
	settings_option_hg_cheats = "치트 활성화",
	settings_help_hg_cheats = "Z-City 치트 기능을 활성화합니다.",
	settings_option_hg_showthoughts = "생각 표시",
	settings_help_hg_showthoughts = "캐릭터의 생각을 표시합니다.",
	settings_option_hg_hints = "힌트 표시",
	settings_help_hg_hints = "화면 힌트를 표시합니다.",
	settings_option_hg_gary = "HG 게리",
	settings_help_hg_gary = "래그돌 상태에서 무기를 중앙에 배치합니다.",
	settings_option_hg_deathfadeout = "사망 시 페이드 아웃",
	settings_help_hg_deathfadeout = "사망 시 화면을 어둡게 하고 소리를 줄입니다.",
	settings_option_hg_toughnpcs = "강력한 NPC",
	settings_option_hg_thirdperson = "3인칭 (개발 중)",
	settings_option_hg_legacycam = "레거시 카메라",
	settings_option_hg_ragdollcombat = "래그돌 전투 모드",
	settings_option_hg_movement_stamina_debuff = "이동 스태미나 디버프",
	settings_option_hg_furcity = "퍼시티",
	settings_option_hg_appearance_access_for_all = "모든 사용자 외형 전체 접근 허용",
	settings_option_hg_healanims = "치료 및 음식 애니메이션",
	settings_option_hg_aimtoshoot = "DarkRP 방식 조준 사격",
	settings_option_hg_slings = "슬링 시스템",
	settings_option_hg_show_hitposmuzzle = "무기 명중 지점 표시",
	settings_help_hg_show_hitposmuzzle = "관리자 또는 sv_cheats 1에서 무기 조준점과 명중 지점을 표시합니다.",
	settings_option_hg_setzoompos = "무기 줌 위치 조정",
	settings_help_hg_setzoompos = "무기의 조준 위치를 조정합니다.",
	settings_option_hg_show_hitbox = "히트박스 표시",
	settings_help_hg_show_hitbox = "관리자 또는 sv_cheats 1에서 사용자 정의 히트박스를 표시합니다.",
	settings_option_hg_potatopc = "저사양 PC 모드",
	settings_help_hg_potatopc = "저사양 PC용 최적화 모드를 사용합니다.",
	settings_option_hg_anims_draw_distance = "애니메이션 표시 거리",
	settings_help_hg_anims_draw_distance = "애니메이션 표시 거리를 Hammer 단위로 설정합니다. 0은 무제한입니다.",
	settings_option_hg_anim_fps = "애니메이션 FPS",
	settings_help_hg_anim_fps = "TPIK를 제외한 뼈대 애니메이션 갱신률입니다. 0은 최대입니다.",
	settings_option_hg_attachment_draw_distance = "부착물 표시 거리",
	settings_help_hg_attachment_draw_distance = "무기 부착물이 표시되는 거리를 설정합니다.",
	settings_option_hg_maxsmoketrails = "최대 연기 궤적",
	settings_help_hg_maxsmoketrails = "동시에 표시할 연기 궤적 효과의 최대 개수입니다.",
	settings_option_hg_tpik_distance = "TPIK 렌더링 거리",
	settings_help_hg_tpik_distance = "3인칭 역운동학이 활성화되는 거리입니다. 0은 무제한입니다.",
	settings_option_hg_blood_draw_distance = "혈흔 표시 거리",
	settings_option_hg_blood_fps = "혈흔 FPS",
	settings_help_hg_blood_fps = "혈흔 효과의 갱신률을 설정합니다.",
	settings_option_hg_blood_sprites = "혈흔 스프라이트 (모든 사용자 비활성화)",
	settings_option_hg_old_blood = "이전 혈흔 효과",
	settings_help_hg_old_blood = "새 혈흔 데칼 대신 이전 효과를 사용합니다.",
	settings_option_hg_font = "사용자 정의 글꼴",
	settings_help_hg_font = "UI에 사용할 글꼴을 변경합니다.",
	settings_option_hg_weaponshotblur_enable = "사격 블러 효과",
	settings_help_hg_weaponshotblur_enable = "사격 시 화면 흐림 효과를 사용합니다.",
	settings_option_hg_dynamic_mags = "동적 탄약 확인",
	settings_help_hg_dynamic_mags = "사격 중 동적으로 탄약 수를 표시합니다.",
	settings_option_hg_zoomsensitivity = "조준경 감도",
	settings_help_hg_zoomsensitivity = "조준 중 마우스 감도 배율을 설정합니다.",
	settings_option_hg_highpitchgunfire = "실내 고주파 총성",
	settings_help_hg_highpitchgunfire = "건물 내부에서 고주파 총성 효과를 사용합니다.",
	settings_option_hg_firstperson_death = "1인칭 사망 카메라",
	settings_help_hg_firstperson_death = "사망 시 1인칭 카메라를 사용합니다.",
	settings_option_hg_fov = "시야각 (FOV)",
	settings_help_hg_fov = "1인칭 시야각을 변경합니다.",
	settings_option_hg_newspectate = "부드러운 관전 카메라",
	settings_help_hg_newspectate = "관전 카메라를 부드럽게 이동합니다.",
	settings_option_hg_cshs_fake = "C'sHS 래그돌 카메라",
	settings_help_hg_cshs_fake = "C'sHS 방식의 래그돌 카메라를 사용합니다.",
	settings_option_hg_gun_cam = "총기 카메라 (관리자 전용)",
	settings_option_hg_nofovzoom = "FOV 줌 활성화",
	settings_help_hg_nofovzoom = "조준 시 FOV 확대를 사용합니다.",
	settings_option_hg_realismcam = "리얼리즘 카메라",
	settings_help_hg_realismcam = "사실적인 1인칭 카메라를 사용합니다.",
	settings_option_hg_gopro = "고프로 카메라",
	settings_option_hg_newfakecam = "새 래그돌 카메라",
	settings_help_hg_newfakecam = "새 래그돌 카메라 회전 방식을 사용합니다.",
	settings_option_hg_leancam_mul = "기울기 카메라 배율",
	settings_help_hg_leancam_mul = "1인칭 카메라 기울기 각도의 배율입니다.",
	settings_option_hg_dmusic = "동적 음악",
	settings_option_hg_quietshots = "조용한 총성",

	common_profession_prefix = "직업: ",
	common_close = "닫기",
	common_unknown = "알 수 없음",
	common_left = "남음...",
	common_dead_suffix = " - 사망",
	common_waiting_players = "플레이어 대기 중: ",
	homicide_traitor_prefix = "배신자 ",
	homicide_traitor_was = "%s님은 배신자였습니다 (%s)",
	homicide_traitor_is_suffix = "님은 배신자였습니다.",
	homicide_traitor_killed_suffix = "님이 사망했습니다.",
	homicide_player_died_suffix = "님이 사망했습니다.",
	homicide_killed_by = "%s님이 %s님에게 살해당했습니다.",
	homicide_killer_won = "살인마가 승리했습니다.",
	homicide_killer_killed_everyone = "살인마가 모두를 살해했습니다.",
	homicide_traitor_killed_everyone = "배신자가 모두를 살해했습니다.",
	homicide_all_died = "모두 사망했습니다.",
	homicide_all_civilians_killed = "모든 시민이 살해당했습니다.",
	role_infiltrator = "잠입자",
	role_assassin = "암살자",
	role_chemist = "화학자",
	role_bystander = "방관자",
	role_innocent = "무고한 시민",
	role_doctor = "의사",
	role_engineer = "기술자",
	role_builder = "건설자",
	objective_homicide_gangster_cops = "저 경찰들은 누구를 상대하는지 전혀 모릅니다.",

	mode_dm_title = "취객 난투",
	mode_cszombie_buy = "F3을 눌러 무기를 구매하세요",
	mode_cszombie_results = "좀비 결과",
	mode_homelander_wait_title = "카운트다운이 끝나면 출전합니다.",
	mode_homelander_wait_subtitle = "기다리는 동안 휴식하십시오.",
	mode_homelander_timer = "홈랜더 도착까지: ",
	mode_infinity_title = "인피니티 스톤",
	mode_scp_title = "SCP 습격",
	mode_scp_release_timer = "격리실 개방까지 ",
	role_alpha_mtf = "알파 기동특무부대",
	role_omega_mtf = "오메가 기동특무부대",
	role_swat = "SWAT 대원",
	role_suspect = "용의자",
	role_civilian = "시민",
	role_cook = "요리사",
	role_hunter = "사냥꾼",
	scp_obj_scp = "모든 기동특무부대 지원군을 제거하십시오.",
	scp_obj_alpha = "SCP-106을 격리하십시오. 전멸하면 지원군이 투입됩니다.",
	scp_obj_omega = "마지막 지원입니다. 어떤 대가를 치르더라도 SCP-106을 격리하십시오.",
	fear_line_where = "모두 어디로 간 거지?",
	fear_line_anyone = "누구 없어요?",
	fear_line_quiet = "이상할 정도로 조용합니다.",
	fear_line_no = "안 돼.",
	sv_homelander_buy = "홈랜더가 도착하기 전에 무기를 구매하십시오.",
	sv_homelander_wait = "당신은 홈랜더입니다. 40초 후 전장에 투입됩니다.",
	sv_homelander_hunt = "당신은 홈랜더입니다. 3분 동안 사냥하십시오.",
	sv_homelander_kill_after_laser = "레이저가 사라진 뒤 홈랜더를 처치하십시오.",
	sv_homelander_arrived = "홈랜더가 도착했습니다.",
	sv_homelander_compound_death = "컴파운드 V 부작용으로 사망했습니다.",
	sv_homelander_laser_gone = "홈랜더의 레이저가 사라졌습니다. 지금 처치하십시오.",
	sv_homelander_wins = "홈랜더가 살아남았습니다.",
	sv_homelander_hunters_win = "사냥꾼들이 홈랜더를 처치했습니다.",
	sv_scp_escaped = "SCP-106이 격리실을 벗어났습니다!",
	sv_scp_support = "기동특무부대 지원군이 도착했습니다!",
	sv_scp_omega = "마지막 지원인 오메가 기동특무부대가 투입되었습니다!",
	sv_scp_started = "SCP-106 격리 작전이 시작되었습니다.",
	sv_scp_need_support = "SCP-106 격리에 실패했습니다. 지원군을 요청합니다!",
	sv_scp_alpha_dead = "알파 부대가 전멸했습니다. 마지막 지원을 요청합니다!",
	sv_scp_mtf_win = "SCP-106을 성공적으로 격리했습니다!",
	sv_scp_scp_win = "SCP-106 격리에 실패했습니다. 즉시 지원을 요청하십시오!",
	sv_fear_defeat = "모든 생존자가 사망했습니다. 공포에 잠식되어 패배했습니다.",
	mode_infinity_quote = "좋아. 내가 직접 하지.",
	objective_infinity_stone = "좋아. 내가 직접 하지.",

	replay_browser_title = "Z-City 사건 바디캠 리플레이 목록",
	replay_play = "재생",
	replay_stop = "정지",
	replay_load_selected = "선택 항목 불러오기",
	replay_refresh = "새로고침",
	replay_reset_all = "전체 초기화",
	replay_restore_latest = "최근 항목 복원",
	replay_delete = "삭제",
	replay_reset = "초기화",
	replay_cancel = "취소",
	replay_selected_none = "선택: 없음",
	replay_selected_prefix = "선택: ",
	replay_none = "없음",
	replay_confirm_reset_all = "저장된 사건 리플레이를 모두 휴지통으로 이동할까요?",
	replay_no_file_selected = "먼저 저장된 사건 리플레이를 선택하십시오.",
	replay_not_loaded = "리플레이를 불러오지 않았습니다.",
	replay_stopped = "리플레이가 정지되었습니다.",
	replay_too_few_events = "재생할 이벤트가 부족합니다.",
	replay_loading_saved = "저장된 사건 리플레이를 불러오는 중...",
	replay_load_failed = "사건 리플레이를 불러오지 못했거나 응답이 없습니다.",
	replay_tracers_hide = "사격선 숨기기",
	replay_tracers_show = "사격선 표시",
	replay_hitpos_hide = "명중 지점 숨기기",
	replay_hitpos_show = "명중 지점 표시",
	replay_victim_hide = "피격자 표시 숨기기",
	replay_victim_show = "피격자 표시",
	replay_freecam_off = "자유 시점 끄기",
	replay_freecam_on = "자유 시점 켜기",
	spawn_editor_title = "스폰 지점 편집기",
	spawn_editor_create = "생성",
	spawn_editor_delete = "삭제",
	spawn_editor_saved_slots = "저장 슬롯",
	spawn_editor_save = "스폰 지점 저장",
	spawn_editor_load = "불러오기",
	spawn_editor_delete_slot = "슬롯 삭제",
	spawn_editor_reset = "맵 기본 스폰으로 초기화",
	spawn_editor_menu_toggle = "스폰 지점 편집기 표시",
	spawn_editor_menu_help = "파란 원은 저장된 Z-City 스폰 지점, 노란 원은 맵 기본 스폰입니다. 생성/삭제 모드에서 우클릭하십시오.",
	spawn_editor_refresh = "스폰 지점 새로고침",
	spawn_msg_look_flat = "평평한 바닥을 바라보고 스폰 지점을 추가하십시오.",
	spawn_msg_added = "스폰 지점을 추가했습니다.",
	spawn_msg_removed = "편집 목록에서 스폰 지점을 제거했습니다.",
	spawn_msg_reset = "맵 기본 스폰 지점으로 초기화했습니다.",
	spawn_msg_saved_prefix = "스폰 프리셋 저장: ",
	spawn_msg_loaded_prefix = "스폰 프리셋 불러옴: ",
	spawn_msg_not_found = "스폰 프리셋을 찾지 못했습니다.",

	mode_menu_admin = "게임 모드 관리",
	mode_menu_queue = "게임 모드 대기열",
	mode_menu_available = "사용 가능한 게임 모드",
	mode_menu_apply_queue = "대기열 적용",
	mode_menu_clear_queue = "대기열 비우기",
	mode_menu_next_prefix = "다음 모드: ",
	mode_menu_search = "게임 모드 검색...",
	mode_menu_select = "선택",
	mode_menu_batch = "일괄 작업",
	mode_menu_add_front = "선택 항목을 대기열 앞으로",
	mode_menu_add_back = "선택 항목을 대기열 뒤로",
	mode_menu_refresh = "데이터 새로고침",
	mode_menu_set_next = "다음 모드 설정",
	mode_menu_force_next = "다음 모드 강제 지정",
	mode_menu_manage_queue = "게임 모드 대기열 관리",
	mode_menu_end_round = "라운드 종료",
	mode_title_criresp = "위기 대응",
	mode_title_riot = "호미사이드 | 폭동",
	role_bloodz = "블러즈",
	role_groove = "그루브",
	objective_follow_freeman = "프리맨을 따라가십시오!",
	objective_lead_rebels = "반군을 승리로 이끄십시오!",
	objective_no_equipment = "장비가 없습니다. 다른 배신자들의 승리를 도우십시오.",
	objective_round_starting = "라운드 시작 중...",
	objective_survive_avoid_killer = "살인마를 피해 생존하고 다른 사람들의 생존을 도우십시오.",
	chat_player_joined = "%s님이 플레이어로 참가했습니다.",
	chat_current_karma = "현재 카르마: "
}

for key, value in pairs(koreanOverrides) do
	if ZCLang.Phrases[key] then
		ZCLang.Phrases[key].ko = value
	end
end

local function NormalizeLang(value)
	value = string.lower(tostring(value or ""))
	if value:StartWith("ko") or value == "kr" then return "ko" end
	if value:StartWith("zh") or value == "cn" or value == "tw" or value == "hk" or string.find(value, "chinese", 1, true) then return "zh" end
	if value:StartWith("ru") then return "ru" end
	if value:StartWith("en") then return "en" end
	return nil
end

function ZCLang.DetectLanguage()
	local gmodLang = GetConVar("gmod_language")
	local detected = NormalizeLang(gmodLang and gmodLang:GetString())
	if detected then return detected end

	if system and system.GetCountry then
		detected = NormalizeLang(system.GetCountry())
		if detected then return detected end
	end

	return "en"
end

function ZCLang.GetLanguage()
	if SERVER then return "en" end
	local selected = NormalizeLang(langCvar:GetString())
	if selected then return selected end
	return ZCLang.DetectLanguage()
end

function ZCLang.GetPlayerLanguage(ply)
	if not IsValid(ply) then return "en" end
	local lang = NormalizeLang(ply:GetNWString("zc_language", ""))
	return lang or "en"
end

function ZCLang.SetLanguage(lang)
	lang = lang == LANG_AUTO and LANG_AUTO or NormalizeLang(lang)
	RunConsoleCommand("zc_language", lang or LANG_AUTO)

	if CLIENT then
		timer.Simple(0, function()
			if ZCLang and ZCLang.SyncLanguage then
				ZCLang.SyncLanguage(lang)
			end
		end)
	end
end

function ZCLang.T(key, fallback, langOverride)
	local phrase = ZCLang.Phrases[key]
	local lang = NormalizeLang(langOverride) or ZCLang.GetLanguage()
	if phrase then
		return phrase[lang] or fallback or phrase.en or phrase.ko or key
	end

	return fallback or key
end

function ZCLang.PlayerT(ply, key, fallback)
	local phrase = ZCLang.Phrases[key]
	local lang = SERVER and ZCLang.GetPlayerLanguage(ply) or ZCLang.GetLanguage()
	if phrase then
		return phrase[lang] or fallback or phrase.en or phrase.ko or key
	end

	return fallback or key
end

function ZCLang.LanguageName(lang)
	local displayLanguage = CLIENT and ZCLang.GetLanguage() or "en"
	local names = ZCLang.LanguageNames[displayLanguage] or ZCLang.LanguageNames.en
	return names[lang or ""] or ZCLang.Languages[lang or ""] or tostring(lang or "")
end

ZCLang.ModeNameKeys = {
	tdm = "mode_name_tdm",
	tdmmelee = "mode_name_tdm_melee",
	cstrike = "mode_name_cstrike",
	cszombie = "mode_name_cszombie",
	infinitystone = "mode_name_infinitystone",
	harrypotter = "mode_name_harrypotter",
	medusa = "mode_name_medusa",
	homelander = "mode_name_homelander",
	quarantinefailure = "mode_name_quarantinefailure",
	bloodmoney = "mode_name_blood_money",
	blood_money = "mode_name_blood_money",
	["Blood Money"] = "mode_name_blood_money",
	lbs = "mode_name_lbs",
	juggernaut = "mode_name_juggernaut",
	Juggernaut = "mode_name_juggernaut",
	smo = "mode_name_smo",
	hmcd = "mode_name_hmcd",
	homicide = "mode_name_hmcd",
	gravtdm = "mode_name_gravtdm",
	hl2dm = "mode_name_hl2dm",
	riot = "mode_name_riot",
	gwars = "mode_name_gwars",
	tarkov = "mode_name_tarkov",
	criresp = "mode_name_criresp",
	coop = "mode_name_coop",
	dm = "mode_name_dm",
	defense = "mode_name_defense",
	scp106raid = "mode_name_scp106raid",
	pathowogen = "mode_name_pathowogen",
	vietnam = "mode_name_vietnam",
	superfighters = "mode_name_superfighters",
	event = "mode_name_event",
	scugarena = "mode_name_slug_arena",
	fear = "mode_name_fear"
}

ZCLang.ModePrintNameKeys = {
	["Team Deathmatch"] = "mode_name_tdm",
    ["팀 데스매치"] = "mode_name_tdm",
	["TDM Melee"] = "mode_name_tdm_melee",
	["Blood Money"] = "mode_name_blood_money",
	["last bystander standing"] = "mode_name_lbs",
	["Last Bystander Standing"] = "mode_name_lbs",
	["Juggernaut"] = "mode_name_juggernaut",
	["Special Military Operation"] = "mode_name_smo",
	["Counter-Strike"] = "mode_name_cstrike",
	["CS Zombie"] = "mode_name_cszombie",
	["?�피?�티 ?�톤"] = "mode_name_infinitystone",
	["Infinity Stone"] = "mode_name_infinitystone",
    ["인피니티 스톤"] = "mode_name_infinitystone",
	["Harry Potter"] = "mode_name_harrypotter",
    ["해리 포터"] = "mode_name_harrypotter",
	["Medusa"] = "mode_name_medusa",
    ["메두사"] = "mode_name_medusa",
	["Homelander Tag"] = "mode_name_homelander",
	["Containment Failure"] = "mode_name_quarantinefailure",
	["격리 실패"] = "mode_name_quarantinefailure",
	["Homicide"] = "mode_name_hmcd",
    ["호미사이드"] = "mode_name_hmcd",
	["Gravity Gun Team Deathmatch"] = "mode_name_gravtdm",
	["Half-Life 2 Deathmatch"] = "mode_name_hl2dm",
	["Riot"] = "mode_name_riot",
    ["폭동"] = "mode_name_riot",
	["Gang Wars"] = "mode_name_gwars",
    ["갱 전쟁"] = "mode_name_gwars",
	["Tarkov Raid"] = "mode_name_tarkov",
	["타르코프 습격"] = "mode_name_tarkov",
	["Crisis Response"] = "mode_name_criresp",
	["CO-OP"] = "mode_name_coop",
	["Deathmatch"] = "mode_name_dm",
    ["데스매치"] = "mode_name_dm",
	["NPC Defense"] = "mode_name_defense",
    ["HL2 기지 방어"] = "mode_name_defense",
	["SCP ?�격"] = "mode_name_scp106raid",
    ["SCP 습격"] = "mode_name_scp106raid",
	["Pathowogen :3"] = "mode_name_pathowogen",
	["Vietnam War"] = "mode_name_vietnam",
    ["베트남 전쟁"] = "mode_name_vietnam",
	["베트???�쟁"] = "mode_name_vietnam",
	["Superfighters 3D"] = "mode_name_superfighters",
	["Event"] = "mode_name_event",
	["Slug Arena"] = "mode_name_slug_arena",
	["Homicide2"] = "mode_name_fear"
}

function ZCLang.ModeName(key, fallback)
	local phraseKey = ZCLang.ModeNameKeys[tostring(key or "")]
	if phraseKey then return ZCLang.T(phraseKey, fallback or key) end

	phraseKey = ZCLang.ModePrintNameKeys[tostring(fallback or "")]
	if phraseKey then return ZCLang.T(phraseKey, fallback) end

	return fallback or key
end

if SERVER then
	function ZCLang.ChatPrint(ply, key, fallback)
		if not IsValid(ply) then return end
		ply:ChatPrint(ZCLang.PlayerT(ply, key, fallback))
	end

	function ZCLang.Broadcast(key, fallback)
		for _, ply in player.Iterator() do
			ZCLang.ChatPrint(ply, key, fallback)
		end
	end
end

if CLIENT then
	function ZCLang.SyncLanguage(langOverride)
		local resolved = NormalizeLang(langOverride) or ZCLang.GetLanguage()
		net.Start("ZCLang_SetLanguage")
			net.WriteString(resolved)
		net.SendToServer()
		hook.Run("ZCLangChanged", resolved)
	end

	ZCLang.TextKeys = {
		["Close"] = "common_close",
		["닫기"] = "common_close",
		["Players:"] = "common_players",
		["플레이어:"] = "common_players",
		["Player list:"] = "common_player_list",
		["플레이어 목록:"] = "common_player_list",
		["Spectators:"] = "common_spectators",
		["Unknown"] = "common_unknown",
		["ZBattle | Half-Life 2 Deathmatch"] = "mode_title_hl2dm",
        ["마법으로 마지막까지 살아남으십시오."] = "objective_wizard_survive",
        ["모두 석화시키고 마지막까지 살아남으십시오."] = "objective_medusa_survive",
        ["Fine. I'll do it myself."] = "objective_infinity_stone",
        ["SOMEWHERE IN PLUVTOWN"] = "common_somewhere_pluvtown",
        ["플러브 타운 어딘가"] = "common_somewhere_pluvtown",
        ["플러브타운 어딘가에서"] = "common_somewhere_pluvtown",
		["게임 모드 선택"] = "defense_vote_title",
		["이번 라운드에 진행할 모드에 투표하세요"] = "defense_vote_subtitle",
		["남은 시간:"] = "defense_time_left",
		["투표 통계:"] = "defense_vote_stats",
		["IN DEVELOPMENT"] = "defense_in_development",
		["SELECTED"] = "defense_selected",
		["이 모드는 현재 개발 중이며 곧 이용 가능합니다!"] = "defense_mode_development_notice",
		["보스 출현"] = "defense_boss_appeared",
		["강력한 적이 나타납니다. 전투를 준비하십시오!"] = "defense_boss_prepare",
		["지휘관 보급 청구"] = "defense_commander_supply",
		["당신의 주문"] = "defense_your_order",
		["주문하기"] = "defense_place_order",
		["Free roam"] = "spectator_mode_free_roam",
		["as | Free roam"] = "spectator_mode_free_roam"
	}

	ZCLang.RoleTextKeys = {
		["Fighter"] = "role_fighter",
		["Human"] = "role_human",
		["Zombie"] = "role_zombie",
		["Survivor"] = "role_survivor",
		["Freeman"] = "role_freeman",
		["Rebel"] = "role_rebel",
		["Refugee"] = "role_refugee",
		["Medic"] = "role_medic",
		["Grenadier"] = "role_grenadier",
		["Combine"] = "role_combine",
		["Combine Soldier"] = "role_combine_soldier",
		["Elite Combine Soldier"] = "role_elite_combine_soldier",
		["Combine Shotgunner"] = "role_combine_shotgunner",
		["Metrocop"] = "role_metrocop",
		["Rioter"] = "role_rioter",
		["Law Enforcement"] = "role_law_enforcement",
		["Gauntlet"] = "role_gauntlet",
		["Homelander"] = "role_homelander",
		["Wizard"] = "role_wizard",
        ["마법사"] = "role_wizard",
		["Medusa"] = "role_medusa",
        ["메두사"] = "role_medusa",
		["Counter Terrorist"] = "role_counter_terrorist",
		["Terrorist"] = "role_terrorist",
		["SWAT"] = "role_swat",
		["Suspect"] = "role_suspect",
		["Eventer"] = "role_eventer",
		["Player"] = "role_player",
		["Bloodz"] = "role_bloodz",
		["Groove"] = "role_groove",
		["BEAR"] = "role_bear",
		["USEC"] = "role_usec",
		["SCAV"] = "role_scav",
		["SCAV Boss"] = "role_scav_boss",
		["Police Response"] = "role_police_response",
		["Gangster"] = "role_gangster",
		["Traitor"] = "role_traitor",
		["Witness"] = "role_witness",
		["Sheriff"] = "role_sheriff",
		["Fellow Cowboy"] = "role_fellow_cowboy",
		["Shahid"] = "role_shahid",
		["Infiltrator"] = "role_infiltrator",
		["Assassin"] = "role_assassin",
		["Chemist"] = "role_chemist",
		["Bystander"] = "role_bystander",
		["Innocent"] = "role_innocent",
		["Doctor"] = "role_doctor",
		["Engineer"] = "role_engineer",
		["Builder"] = "role_builder",
		["Viet Cong"] = "role_viet_cong",
		["VC Machine Gunner"] = "role_vc_machine_gunner",
		["US Army"] = "role_us_army",
		["US Machine Gunner"] = "role_us_machine_gunner",
        ["베트콩"] = "role_viet_cong",
        ["베트남군"] = "role_viet_cong",
        ["베트콩 기관총 사수"] = "role_vc_machine_gunner",
        ["미군"] = "role_us_army",
        ["미군 기관총 사수"] = "role_us_machine_gunner"
	}

	ZCLang.PrefixKeys = {
		{"Your role: ", "common_your_role"},
		{"Your role : ", "common_your_role_spaced"},
		{"Role: ", "common_role_english"},
		{"Profession: ", "common_profession_prefix"},
		{"당신의 역할: ", "common_your_role"},
		{"당신의 역할 : ", "common_your_role_spaced"},
		{"직업: ", "common_profession_prefix"},
		{"총 투표수: ", "defense_total_votes"},
		{"표준: ", "defense_standard"},
		{"확장: ", "defense_extended"},
		{"좀비: ", "defense_zombie"},
		{"가용 포인트: ", "defense_available_points"},
		{"총 비용: ", "defense_total_cost"}
	}

	function ZCLang.TranslateText(text)
		if not isstring(text) then return text end

		local key = ZCLang.TextKeys[text]
		if key then return ZCLang.T(key, text) end

		key = ZCLang.ModePrintNameKeys[text]
		if key then return ZCLang.T(key, text) end

		if string.sub(text, 1, 10) == "ZBattle | " then
			local modeName = string.sub(text, 11)
			return "ZBattle | " .. ZCLang.ModeName(nil, modeName)
		end

		if string.sub(text, 1, 11) == "Homicide | " then
			local modeName = string.sub(text, 12)
			return "Homicide | " .. ZCLang.ModeName(nil, modeName)
		end

		local pipeStart, pipeEnd = string.find(text, " | ", 1, true)
		if pipeStart then
			local left = string.sub(text, 1, pipeStart - 1)
			local right = string.sub(text, pipeEnd + 1)
			local leftKey = ZCLang.ModePrintNameKeys[left]
			local rightKey = ZCLang.ModePrintNameKeys[right]

			if leftKey or rightKey then
				return ZCLang.T(leftKey, left) .. " | " .. ZCLang.T(rightKey, right)
			end
		end

		if text == "Character:" then
			return string.TrimRight(ZCLang.T("spectator_panel_character", "Character: "))
		end

		if string.sub(text, 1, #"Character: ") == "Character: " then
			return ZCLang.T("spectator_panel_character", "Character: ") .. string.sub(text, #"Character: " + 1)
		end

		if text == "Free roam" then
			return ZCLang.T("spectator_mode_free_roam", "Free roam")
		end

		if text == "as | " then
			return ZCLang.T("spectator_mode_as", "as | ")
		end

		if text == "as | Free roam" then
			return ZCLang.T("spectator_mode_as", "as | ") .. ZCLang.T("spectator_mode_free_roam", "Free roam")
		end

		for _, data in ipairs(ZCLang.PrefixKeys) do
			local prefix, prefixKey = data[1], data[2]
			if string.sub(text, 1, #prefix) == prefix then
				local rest = string.sub(text, #prefix + 1)
				local roleKey = ZCLang.RoleTextKeys[rest]
				if roleKey then rest = ZCLang.T(roleKey, rest) end
				return ZCLang.T(prefixKey, prefix) .. rest
			end
		end

		return text
	end
	if not ZCLang.DrawWrapped then
		ZCLang.DrawWrapped = true

		local oldSimpleText = draw.SimpleText
		function draw.SimpleText(text, ...)
			return oldSimpleText(ZCLang.TranslateText(text), ...)
		end

		local oldSimpleTextOutlined = draw.SimpleTextOutlined
		function draw.SimpleTextOutlined(text, ...)
			return oldSimpleTextOutlined(ZCLang.TranslateText(text), ...)
		end

		local oldDrawText = surface.DrawText
		function surface.DrawText(text, ...)
			return oldDrawText(ZCLang.TranslateText(text), ...)
		end
	end

	local function SyncCurrentLanguage()
		if ZCLang and ZCLang.SyncLanguage then
			ZCLang.SyncLanguage()
		end
	end

	timer.Simple(1, SyncCurrentLanguage)
	hook.Add("InitPostEntity", "ZCLangInitialSync", function()
		timer.Simple(0, SyncCurrentLanguage)
	end)

	cvars.AddChangeCallback("zc_language", function(_, _, new)
		timer.Simple(0, function()
			if ZCLang and ZCLang.SyncLanguage then
				ZCLang.SyncLanguage(new)
			end
		end)
	end, "ZCLangSync")
end
