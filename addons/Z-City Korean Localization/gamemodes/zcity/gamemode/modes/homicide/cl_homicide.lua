local MODE = MODE
MODE.name = "hmcd"

--\\Local Functions
local function T(key, fallback)
	return ZCLang and ZCLang.T and ZCLang.T(key, fallback) or fallback or key
end

local function screen_scale_2(num)
	return ScreenScale(num) / (ScrW() / ScrH())
end
--//

MODE.TypeSounds = {
	["standard"] = {"snd_jack_hmcd_psycho.mp3","snd_jack_hmcd_shining.mp3"},
	["soe"] = "snd_jack_hmcd_disaster.mp3",
	["gunfreezone"] = "snd_jack_hmcd_panic.mp3" ,
	["suicidelunatic"] = "zbattle/jihadmode.mp3",
	["wildwest"] = "snd_jack_hmcd_wildwest.mp3",
	["bang"] = "snd_jack_hmcd_wildwest.mp3",
	["supermario"] = "snd_jack_hmcd_psycho.mp3"
}
local fade = 0
net.Receive("HMCD_RoundStart",function()
	for i, ply in player.Iterator() do
		ply.isTraitor = false
		ply.isGunner = false
	end

	--\\
	lply.isTraitor = net.ReadBool()
	lply.isGunner = net.ReadBool()
	MODE.Type = net.ReadString()
	local screen_time_is_default = net.ReadBool()
	lply.SubRole = net.ReadString()
	lply.MainTraitor = net.ReadBool()
	MODE.TraitorWord = net.ReadString()
	MODE.TraitorWordSecond = net.ReadString()
	MODE.TraitorExpectedAmt = net.ReadUInt(MODE.TraitorExpectedAmtBits)
	StartTime = CurTime()
	MODE.TraitorsLocal = {}

	if(lply.isTraitor and MODE.Type ~= "bang" and screen_time_is_default)then
        if(MODE.TraitorExpectedAmt == 1)then
            chat.AddText(T("homicide_traitor_alone", "You are alone on this mission."))
        else
            if(MODE.TraitorExpectedAmt == 2)then
                chat.AddText(T("homicide_traitor_one_accomplice", "You have one accomplice."))
            else
                chat.AddText(string.format(T("homicide_traitor_many_accomplices", "There are %s other traitors besides you."), MODE.TraitorExpectedAmt - 1))
            end

            chat.AddText(string.format(T("homicide_traitor_secret_words_chat", "The traitor secret words are \"%s\" and \"%s\"."), MODE.TraitorWord, MODE.TraitorWordSecond))
        end

        if(lply.MainTraitor)then
            if(MODE.TraitorExpectedAmt > 1)then
                chat.AddText(T("homicide_traitor_list_main_only", "Traitor list (only the main traitor can see this):"))
			end

			for key = 1, MODE.TraitorExpectedAmt do
				local traitor_info = {net.ReadColor(false), net.ReadString()}

				if(MODE.TraitorExpectedAmt > 1)then
					MODE.TraitorsLocal[#MODE.TraitorsLocal + 1] = traitor_info

					chat.AddText(traitor_info[1], "\t" .. traitor_info[2])
				end
			end
		end
	end

	lply.Profession = net.ReadString()
	if MODE.Type == "bang" then
		lply.BangRole = net.ReadString()
		lply.BangCharacter = net.ReadString()
	else
		lply.BangRole = nil
		lply.BangCharacter = nil
	end
	--//

	if(MODE.RoleChooseRoundTypes[MODE.Type] and !screen_time_is_default)then
		MODE.DynamicFadeScreenEndTime = CurTime() + MODE.RoleChooseRoundStartTime
	else
		MODE.DynamicFadeScreenEndTime = CurTime() + MODE.DefaultRoundStartTime
	end

	MODE.RoleEndedChosingState = screen_time_is_default

	if(screen_time_is_default)then
		if istable(MODE.TypeSounds[MODE.Type]) then
			surface.PlaySound(table.Random(MODE.TypeSounds[MODE.Type]))
		else
			surface.PlaySound(MODE.TypeSounds[MODE.Type])
		end
	end

	fade = 0
end)

local bangRoleLanguageKeys = {
	sheriff = "role_sheriff",
	deputy = "role_bang_deputy",
	outlaw = "role_bang_outlaw",
	renegade = "role_bang_renegade",
}

local bangRoleFallbacks = {
	sheriff = "보안관",
	deputy = "부관",
	outlaw = "무법자",
	renegade = "배신자",
}

local function BangRoleName(role)
	return T(bangRoleLanguageKeys[role] or "", bangRoleFallbacks[role] or role)
end

MODE.BangCharacterInfo = {
	vulture_sam = {nameKey = "bang_character_vulture_sam", name = "벌처 샘", descriptionKey = "bang_character_vulture_sam_desc", description = "시체를 빠르게 수색하고 장비가 든 시체를 감지합니다."},
	sid_ketchum = {nameKey = "bang_character_sid_ketchum", name = "시드 케첨", descriptionKey = "bang_character_sid_ketchum_desc", description = "G: 소지품 2개를 버려 출혈과 통증을 완화합니다."},
	bart_cassidy = {nameKey = "bang_character_bart_cassidy", name = "바트 캐시디", descriptionKey = "bang_character_bart_cassidy_desc", description = "피해를 버티면 붕대나 탄약을 얻습니다."},
	jourdonnais = {nameKey = "bang_character_jourdonnais", name = "주르도네", descriptionKey = "bang_character_jourdonnais_desc", description = "일정 확률로 머리를 제외한 총탄을 막습니다."},
	slab_killer = {nameKey = "bang_character_slab_killer", name = "슬랩 더 킬러", descriptionKey = "bang_character_slab_killer_desc", description = "20초마다 다음 탄환의 관통력과 출혈이 증가합니다."},
	el_gringo = {nameKey = "bang_character_el_gringo", name = "엘 그링고", descriptionKey = "bang_character_el_gringo_desc", description = "공격자가 일정 확률로 비무기 소지품을 떨어뜨립니다."},
	tequila_joe = {nameKey = "bang_character_tequila_joe", name = "테킬라 죠", descriptionKey = "bang_character_tequila_joe_desc", description = "사용하는 의약품의 효과가 2배가 됩니다."},
	greg_digger = {nameKey = "bang_character_greg_digger", name = "그레그 디거", descriptionKey = "bang_character_greg_digger_desc", description = "다른 참가자가 제거되면 체력 5와 혈액 150을 회복합니다. 재사용 30초."},
	vera_custer = {nameKey = "bang_character_vera_custer", name = "베라 쿠스터", descriptionKey = "bang_character_vera_custer_desc", description = "다른 생존자 한 명의 능력을 이번 라운드 동안 복사합니다."},
	big_spencer = {nameKey = "bang_character_big_spencer", name = "빅 스펜서", descriptionKey = "bang_character_big_spencer_desc", description = "예비탄 2탄창을 가지고 시작하지만 받는 피해가 20% 증가합니다."},
	mick_defender = {nameKey = "bang_character_mick_defender", name = "믹 디펜더", descriptionKey = "bang_character_mick_defender_desc", description = "머리와 몸통에 맞은 총탄을 20% 확률로 빗나가게 합니다. 발동 후 재사용 15초."},
	suzy_lafayette = {nameKey = "bang_character_suzy_lafayette", name = "수지 라파예트", descriptionKey = "bang_character_suzy_lafayette_desc", description = "모든 총알이 소진되면 즉시 한 탄창을 가져옵니다. 재사용 45초."},
	paul_regret = {nameKey = "bang_character_paul_regret", name = "폴 리그레트", descriptionKey = "bang_character_paul_regret_desc", description = "공격자와 멀수록 총탄을 무효화할 확률이 증가합니다. 발동 후 재사용 20초."},
	sean_mallory = {nameKey = "bang_character_sean_mallory", name = "숀 말로리", descriptionKey = "bang_character_sean_mallory_desc", description = "Type 59 수류탄 1개를 가지고 시작합니다."},
}

function MODE:GetBangAbilityDescription(ply, characterID)
	local character = self.BangCharacterInfo and self.BangCharacterInfo[characterID]
	if not character then return "" end
	if characterID ~= "vera_custer" or not IsValid(ply) then
		return T(character.descriptionKey, character.description)
	end

	local copiedID = ply:GetNWString("HMCD_BangAbilityCharacter", "")
	local copied = self.BangCharacterInfo[copiedID]
	if not copied or copiedID == "vera_custer" then
		return T(character.descriptionKey, character.description)
	end

	return string.format(T("bang_vera_copied_ability", "복사 능력: %s - %s"),
		T(copied.nameKey, copied.name), T(copied.descriptionKey, copied.description))
end

local bangVultureMarks = {}
net.Receive("HMCD_BangVultureCorpse", function()
	local victim = net.ReadEntity()
	if IsValid(victim) then bangVultureMarks[victim] = CurTime() + 15 end
end)

hook.Add("PreDrawHalos", "HMCD_BangVultureHalos", function()
	if MODE.Type ~= "bang" or lply:GetNWString("HMCD_BangAbilityCharacter", lply.BangCharacter or "") ~= "vulture_sam" then return end
	local marked = {}
	for victim, expires in pairs(bangVultureMarks) do
		if expires <= CurTime() or not IsValid(victim) then
			bangVultureMarks[victim] = nil
		else
			local ragdoll = victim:GetNWEntity("RagdollDeath")
			if IsValid(ragdoll) then marked[#marked + 1] = ragdoll end
		end
	end
	if #marked > 0 then halo.Add(marked, Color(235, 190, 70), 2, 2, 1, true, true) end
end)

net.Receive("HMCD_BangRoleReveal", function()
	local victim = net.ReadEntity()
	local role = net.ReadString()
	local name = IsValid(victim) and victim:Nick() or T("bang_unknown_player", "알 수 없는 플레이어")
	chat.AddText(Color(235, 190, 70), "[BANG!] ", color_white,
		string.format(T("bang_role_revealed", "%s의 역할은 %s였습니다."), name, BangRoleName(role)))
end)

net.Receive("HMCD_BangRoundEnd", function()
	local winner = net.ReadString()
	local winnerText = {
		law = T("bang_win_law", "보안관과 부관이 승리했습니다."),
		outlaws = T("bang_win_outlaws", "무법자들이 승리했습니다."),
		renegade = T("bang_win_renegade", "배신자가 홀로 살아남아 승리했습니다."),
		draw = T("bang_win_draw", "승자 없이 결투가 끝났습니다."),
	}

	chat.AddText(Color(235, 190, 70), "[BANG!] ", color_white, winnerText[winner] or winnerText.draw)

	for _ = 1, net.ReadUInt(8) do
		local ply = net.ReadEntity()
		local role = net.ReadString()
		local name = IsValid(ply) and ply:Nick() or T("bang_unknown_player", "알 수 없는 플레이어")
		chat.AddText(Color(180, 180, 180), name .. " - ", color_white, BangRoleName(role))
	end

	LocalPlayer().BangRole = nil
	LocalPlayer().BangCharacter = nil
	table.Empty(bangVultureMarks)
end)

hook.Add("HUDPaint", "HMCD_BangSheriffMarker", function()
	if not zb or zb.ROUND_STATE ~= 1 or MODE.Type ~= "bang" then return end
	if zb.CROUND and zb.CROUND ~= "hmcd" and zb.CROUND ~= "bang" then return end

	local localPlayer = LocalPlayer()
	if not IsValid(localPlayer) then return end

	for _, sheriff in player.Iterator() do
		if not sheriff:GetNWBool("HMCD_BangSheriff", false) then continue end
		if not sheriff:Alive() or sheriff == localPlayer then continue end
		if localPlayer:GetPos():DistToSqr(sheriff:GetPos()) > 2250000 then continue end
		if not hg.isVisible(localPlayer:EyePos(), sheriff:EyePos(), {localPlayer, sheriff}, MASK_VISIBLE) then continue end

		local screen = (sheriff:EyePos() + Vector(0, 0, 18)):ToScreen()
		if not screen.visible then continue end
		draw.SimpleText("★ " .. T("role_sheriff", "보안관"), "ZB_HomicideMedium", screen.x, screen.y,
			Color(235, 190, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end
end)

MODE.TypeNames = {
	["standard"] = "Standard",
	["soe"] = "State of Emergency",
	["gunfreezone"] = "Gun Free Zone",
	["suicidelunatic"] = "Suicide Lunatic",
	["wildwest"] = "Wild west",
	["bang"] = "BANG!",
	["supermario"] = "Super Mario"
}

MODE.TypeNameKeys = {
	["standard"] = "hmcd_type_standard",
	["soe"] = "hmcd_type_soe",
	["gunfreezone"] = "hmcd_type_gunfreezone",
	["suicidelunatic"] = "hmcd_type_suicidelunatic",
	["wildwest"] = "hmcd_type_wildwest",
	["bang"] = "hmcd_type_bang",
	["supermario"] = "hmcd_type_supermario"
}

--local hg_coolvetica = ConVarExists("hg_coolvetica") and GetConVar("hg_coolvetica") or CreateClientConVar("hg_coolvetica", "0", true, false, "changes every text to coolvetica because its good", 0, 1)
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Bahnschrift", true, false, "Change UI text font")
local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Bahnschrift"
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

surface.CreateFont("ZB_HomicideSmall", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMedium", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMediumLarge", {
	font = font(),
	size = ScreenScale(25),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideLarge", {
	font = font(),
	size = ScreenScale(30),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideHumongous", {
	font = font(),
	size = 255,
	weight = 400,
	antialias = true
})

MODE.TypeObjectives = {}
MODE.TypeObjectives.soe = {
    traitor = {
        objective = "당신은 주머니 속에 아이템, 독극물, 폭발물, 그리고 무기들로 무장했습니다. 이곳의 모두를 살해하십시오.",
        objectiveKey = "objective_homicide_traitor",
        name = "배신자",
        nameKey = "role_traitor",
        color1 = Color(190,0,0),
        color2 = Color(190,0,0)
    },

    gunner = {
        objective = "당신은 사냥용 무기를 가진 시민입니다. 너무 늦기 전에 배신자를 찾아 제압하십시오.",
        objectiveKey = "objective_homicide_gunner",
        name = "시민",
        nameKey = "role_citizen",
        color1 = Color(0,120,190),
        color2 = Color(158,0,190)
    },

    innocent = {
        objective = "당신은 시민입니다. 오직 자신만을 믿으되, 배신자가 활동하기 어렵도록 군중 속에 머무르십시오.",
        objectiveKey = "objective_homicide_innocent",
        name = "시민",
        nameKey = "role_citizen",
        color1 = Color(0,120,190)
    },
}

MODE.TypeObjectives.standard = {
    traitor = {
        objective = "당신은 주머니 속에 아이템, 독극물, 폭발물, 그리고 무기들로 무장했습니다. 이곳의 모두를 살해하십시오.",
        objectiveKey = "objective_homicide_traitor",
        name = "살인마",
        nameKey = "role_killer",
        color1 = Color(190,0,0),
        color2 = Color(190,0,0)
    },

    gunner = {
        objective = "당신은 총기를 숨겨둔 목격자입니다. 경찰이 범인을 더 빨리 찾을 수 있도록 돕기로 결심했습니다.",
        objectiveKey = "objective_homicide_witness_gun",
        name = "목격자",
        nameKey = "role_witness",
        color1 = Color(0,120,190),
        color2 = Color(158,0,190)
    },

    innocent = {
        objective = "당신은 살인 사건 현장의 목격자입니다. 비록 당신에게 일어난 일은 아니지만, 주의하는 것이 좋습니다.",
        objectiveKey = "objective_homicide_witness",
        name = "목격자",
        nameKey = "role_witness",
        color1 = Color(0,120,190)
    },
}

MODE.TypeObjectives.wildwest = {
    traitor = {
        objective = "이 마을은 우리 모두가 살기엔 너무 좁군.",
        objectiveKey = "objective_homicide_wildwest_traitor",
        name = "살인마",
        nameKey = "role_killer",
        color1 = Color(190,0,0),
        color2 = Color(190,0,0)
    },

    gunner = {
        objective = "당신은 이 마을의 보안관입니다. 저 무법자 자식을 찾아내 처단해야 합니다.",
        objectiveKey = "objective_homicide_sheriff",
        name = "보안관",
        nameKey = "role_sheriff",
        color1 = Color(0,120,190),
        color2 = Color(158,0,190)
    },

    innocent = {
        objective = "정의를 구현해야 합니다. 사람들을 죽이고 다니는 무법자 놈이 돌아다니고 있어요.",
        objectiveKey = "objective_homicide_cowboy",
        name = "동료 카우보이",
        nameKey = "role_fellow_cowboy",
        color1 = Color(0,120,190),
        color2 = Color(158,0,190)
    },
}

MODE.BangRoleObjectives = {
	sheriff = {
		objective = "당신의 신분은 공개되어 있습니다. 무법자와 배신자를 모두 제거하십시오.",
		objectiveKey = "objective_bang_sheriff",
		name = "보안관",
		nameKey = "role_sheriff",
		color1 = Color(220, 165, 35),
		color2 = Color(220, 165, 35),
	},
	deputy = {
		objective = "정체를 숨긴 채 보안관을 보호하고 무법자와 배신자를 제거하십시오.",
		objectiveKey = "objective_bang_deputy",
		name = "부관",
		nameKey = "role_bang_deputy",
		color1 = Color(45, 125, 220),
		color2 = Color(45, 125, 220),
	},
	outlaw = {
		objective = "정체를 숨기고 보안관을 처치하십시오. 보안관이 죽으면 무법자들이 승리합니다.",
		objectiveKey = "objective_bang_outlaw",
		name = "무법자",
		nameKey = "role_bang_outlaw",
		color1 = Color(195, 45, 25),
		color2 = Color(195, 45, 25),
	},
	renegade = {
		objective = "모두를 속여 마지막 생존자가 되십시오. 보안관은 반드시 마지막으로 죽어야 합니다.",
		objectiveKey = "objective_bang_renegade",
		name = "배신자",
		nameKey = "role_bang_renegade",
		color1 = Color(145, 70, 175),
		color2 = Color(145, 70, 175),
	},
}

-- The common HUD requires a three-role table before selecting the private role.
MODE.TypeObjectives.bang = {
	traitor = MODE.BangRoleObjectives.outlaw,
	gunner = MODE.BangRoleObjectives.sheriff,
	innocent = MODE.BangRoleObjectives.deputy,
}

MODE.TypeObjectives.gunfreezone = {
    traitor = {
        objective = "당신은 주머니 속에 아이템, 독극물, 폭발물, 그리고 무기들로 무장했습니다. 이곳의 모두를 살해하십시오.",
        objectiveKey = "objective_homicide_traitor",
        name = "살인마",
        nameKey = "role_killer",
        color1 = Color(190,0,0),
        color2 = Color(190,0,0)
    },

    gunner = {
        objective = "당신은 살인 사건 현장의 목격자입니다. 비록 당신에게 일어난 일은 아니지만, 주의하는 것이 좋습니다.",
        objectiveKey = "objective_homicide_witness",
        name = "목격자",
        nameKey = "role_witness",
        color1 = Color(0,120,190)
    },

    innocent = {
        objective = "당신은 살인 사건 현장의 목격자입니다. 비록 당신에게 일어난 일은 아니지만, 주의하는 것이 좋습니다.",
        objectiveKey = "objective_homicide_witness",
        name = "목격자",
        nameKey = "role_witness",
        color1 = Color(0,120,190)
    },
}

MODE.TypeObjectives.suicidelunatic = {
    traitor = {
        objective = "형제여, 신의 뜻대로(Insha'Allah). 그분을 실망시키지 마십시오.",
        objectiveKey = "objective_homicide_shahid",
        name = "샤히드",
        nameKey = "role_shahid",
        color1 = Color(190,0,0),
        color2 = Color(190,0,0)
    },

    gunner = {
        objective = "미친놈이 날뛰고 있습니다. 이제 살아남아야 합니다.",
        objectiveKey = "objective_homicide_lunatic_survive",
        name = "시민",
        nameKey = "role_citizen",
        color1 = Color(0,120,190)
    },

    innocent = {
        objective = "미친놈이 날뛰고 있습니다. 이제 살아남아야 합니다.",
        objectiveKey = "objective_homicide_lunatic_survive",
        name = "시민",
        nameKey = "role_citizen",
        color1 = Color(0,120,190)
    },
}


MODE.TypeObjectives.supermario = {
    traitor = {
        objective = "당신은 사악한 마리오입니다! 사방을 점프하며 모두를 쓰러뜨리십시오.",
        objectiveKey = "objective_homicide_mario_traitor",
        name = "배신자 마리오",
        nameKey = "role_traitor_mario",
        color1 = Color(190,0,0),
        color2 = Color(190,0,0)
    },

    gunner = {
        objective = "당신은 영웅 마리오입니다! 점프 능력을 사용해 배신자를 저지하십시오.",
        objectiveKey = "objective_homicide_mario_hero",
        name = "영웅 마리오",
        nameKey = "role_hero_mario",
        color1 = Color(158,0,190),
        color2 = Color(158,0,190)
    },

    innocent = {
        objective = "당신은 구경꾼 마리오입니다. 살아남아서 배신자의 함정을 피하십시오!",
        objectiveKey = "objective_homicide_mario_civilian",
        name = "시민 마리오",
        nameKey = "role_civilian_mario",
        color1 = Color(0,120,190)
    },
}

function MODE:RenderScreenspaceEffects()
	-- MODE.DynamicFadeScreenEndTime = MODE.DynamicFadeScreenEndTime or 0
	fade_end_time = MODE.DynamicFadeScreenEndTime or 0
	local time_diff = fade_end_time - CurTime()

	if(time_diff > 0)then
		zb.RemoveFade()

		local fade = math.min(time_diff / MODE.FadeScreenTime, 1)

		surface.SetDrawColor(0, 0, 0, 255 * fade)
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1 )
	end
end

local handicap = {
    [1] = "핸디캡 적용: 오른쪽 다리가 골절되었습니다.",
    [2] = "핸디캡 적용: 심각한 비만 상태입니다.",
    [3] = "핸디캡 적용: 혈우병을 앓고 있습니다.",
    [4] = "핸디캡 적용: 신체 기능이 마비되었습니다."
}

function MODE:HUDPaint()
	if not MODE.Type or not MODE.TypeObjectives[MODE.Type] then return end
	if lply:Team() == TEAM_SPECTATOR then return end
	if StartTime + 12 < CurTime() then return end
	
	fade = Lerp(FrameTime()*1, fade, math.Clamp(StartTime + 5 - CurTime(),-2,2))

	draw.SimpleText(T("mode_name_hmcd", "Homicide") .. " | " .. T(MODE.TypeNameKeys[MODE.Type], MODE.TypeNames[MODE.Type] or "Unknown"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local roleData
	if MODE.Type == "bang" then
		roleData = MODE.BangRoleObjectives[lply.BangRole]
	else
		roleData = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner ) or MODE.TypeObjectives[MODE.Type].innocent
	end
	if not roleData then return end
	local Rolename = T(roleData.nameKey, roleData.name)
	local ColorRole = roleData.color1
	ColorRole.a = 255 * fade

	local color_role_innocent = MODE.TypeObjectives[MODE.Type].innocent.color1
	color_role_innocent.a = 255 * fade

	local color_white_faded = Color(255, 255, 255, 255 * fade)
	color_white_faded.a = 255 * fade

    draw.SimpleText((ZCLang and ZCLang.T and ZCLang.T("common_your_role", "Your role: ") or "Your role: ") .. Rolename, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)



	local cur_y = sh * 0.5
	if MODE.Type == "bang" then
		local character = MODE.BangCharacterInfo[lply.BangCharacter]
		if character then
			cur_y = cur_y + ScreenScale(20)
			draw.SimpleText(T("bang_character_prefix", "Character: ") .. T(character.nameKey, character.name), "ZB_HomicideMedium", sw * 0.5, cur_y, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(MODE:GetBangAbilityDescription(lply, lply.BangCharacter), "ZB_HomicideSmall", sw * 0.5, sh * 0.84, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	-- local ColorRole = ( lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.color1 ) or ( lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.color1 ) or MODE.TypeObjectives[MODE.Type].innocent.color1
	-- ColorRole.a = 255 * fade
	if(lply.SubRole and lply.SubRole != "")then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText("" .. ((MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Name or lply.SubRole) or lply.SubRole), "ZB_HomicideMediumLarge", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if(MODE.Type ~= "bang" and !lply.MainTraitor and lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)

        draw.SimpleText(T("homicide_accomplice", "Accomplice"), "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end


	if(MODE.Type ~= "bang" and lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)

		if(lply.MainTraitor)then
			MODE.TraitorsLocal = MODE.TraitorsLocal or {}

			if(#MODE.TraitorsLocal > 1)then
				draw.SimpleText(T("homicide_traitor_list", "Traitor list:"), "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				for _, traitor_info in ipairs(MODE.TraitorsLocal) do
					local traitor_color = Color(traitor_info[1].r, traitor_info[1].g, traitor_info[1].b, 255 * fade)
					cur_y = cur_y + ScreenScale(15)

					draw.SimpleText(traitor_info[2], "ZB_HomicideMedium", sw * 0.5, cur_y, traitor_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		else
			draw.SimpleText(T("homicide_traitor_secret_words", "Traitor secret words:"), "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			cur_y = cur_y + ScreenScale(15)

			draw.SimpleText("\"" .. MODE.TraitorWord .. "\"", "ZB_HomicideMedium", sw * 0.5, cur_y, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			cur_y = cur_y + ScreenScale(15)

			draw.SimpleText("\"" .. MODE.TraitorWordSecond .. "\"", "ZB_HomicideMedium", sw * 0.5, cur_y, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	if(lply.Profession and lply.Profession != "")then
		cur_y = cur_y + ScreenScale(20)

        draw.SimpleText((ZCLang and ZCLang.T and ZCLang.T("common_profession_prefix", "Profession: ") or "Profession: ") .. ((MODE.Professions[lply.Profession] and MODE.Professions[lply.Profession].Name or lply.Profession) or lply.Profession), "ZB_HomicideMedium", sw * 0.5, cur_y, color_role_innocent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
	
	if(handicap[lply:GetLocalVar("karma_sickness", 0)])then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText(handicap[lply:GetLocalVar("karma_sickness", 0)], "ZB_HomicideMedium", sw * 0.5, cur_y, color_role_innocent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local Objective = T(roleData.objectiveKey, roleData.objective)

	if(lply.SubRole and lply.SubRole != "")then
		if(MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Objective)then
			Objective = MODE.SubRoles[lply.SubRole].Objective
		end
	end

	if(MODE.Type ~= "bang" and !lply.MainTraitor and lply.isTraitor)then
        Objective = T("objective_homicide_accomplice", "You have no assigned equipment. Help the other traitors win.")
    end

    --; WARNING Traitor's objective is not lined up with SubRole's
    if(!MODE.RoleEndedChosingState)then
        Objective = T("common_round_starting", "Round starting...")
    end

	local ColorObj = roleData.color2 or roleData.color1 or Color(255,255,255)
	ColorObj.a = 255 * fade
	draw.SimpleText( Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if hg.PluvTown.Active then
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText(T("pluvtown_somewhere", "Somewhere in Pluv Town"), "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local CreateEndMenu

net.Receive("hmcd_roundend", function()
	local traitors, gunners = {}, {}

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local traitor = net.ReadEntity()
		traitors[key] = traitor
		traitor.isTraitor = true
	end

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local gunner = net.ReadEntity()
		gunners[key] = gunner
		gunner.isGunner = true
	end

	timer.Simple(2.5, function()


		lply.isPolice = false
		lply.isTraitor = false
		lply.isGunner = false
		lply.MainTraitor = false
		lply.SubRole = nil
		lply.Profession = nil
	end)

	traitor = traitors[1] or Entity(0)

	CreateEndMenu(traitor)
end)

net.Receive("hmcd_announce_traitor_lose", function()
	local traitor = net.ReadEntity()
	local traitor_alive = net.ReadBool()

	if(IsValid(traitor))then
		chat.AddText(color_white, (traitor_alive and "" or "배신자 "), traitor:GetPlayerColor():ToColor(), traitor:GetPlayerName() .. ", " .. traitor:Nick(), color_white, (traitor_alive and "님은 배신자입니다." or "님이 살해당했습니다."))
	end
end)

local colGray = Color(85,85,85)
local colRed = Color(130,10,10)
local colRedUp = Color(160,30,30)

local colBlue = Color(10,10,160)
local colBlueUp = Color(40,40,160)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(255,255,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = BlurBackground or hg.DrawBlur

if IsValid(hmcdEndMenu) then
	hmcdEndMenu:Remove()
	hmcdEndMenu = nil
end

CreateEndMenu = function(traitor)
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end

	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

	if !IsValid(hmcdEndMenu) then return end

	local players = {}

	local traitorName = IsValid(traitor) and traitor:GetPlayerName() or "unknown"
	local traitorNick = IsValid(traitor) and traitor:Nick() or "unknown"

	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if !IsValid(ply) then return end
		
		players[#players + 1] = {
			nick = ply:Nick(),
			name = ply:GetPlayerName(),
			isTraitor = ply.isTraitor,
			isGunner = ply.isGunner,
			incapacitated = ply.organism and ply.organism.otrub,
			alive = ply:Alive(),
			col = ply:GetPlayerColor():ToColor(),
			frags = ply:Frags(),
			steamid = ply:IsBot() and "BOT" or ply:SteamID64(),
		}
	end

	surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5, ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2, ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX, posY)
	hmcdEndMenu:SetSize(sizeX, sizeY)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton", hmcdEndMenu)
	closebutton:SetPos(5, 5)
	closebutton:SetSize(ScrW() / 20, ScrH() / 30)
	closebutton:SetText("")

	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor(122, 122, 122, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		surface.SetFont("ZB_InterfaceMedium")
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		local lengthX, lengthY = surface.GetTextSize("Close")
		surface.SetTextPos(lengthX - lengthX / 1.1, 4)
		surface.DrawText("Close")
	end

	hmcdEndMenu.PaintOver = function(self,w,h)
		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
        local lengthX, lengthY = surface.GetTextSize(traitorName .. "님은 배신자였습니다 ("..traitorNick..")")
        surface.SetTextPos(w / 2 - lengthX / 2, 20)
        surface.DrawText(traitorName .. "님은 배신자였습니다 ("..traitorNick..")")
	end

	-- PLAYERS
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for i, info in ipairs(players) do
		local but = vgui.Create("DButton",DScrollPanel)

		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")

		but.Paint = function(self,w,h)
			local col1 = (info.isTraitor and colRed) or (info.alive and colBlue) or colGray
			local col2 = info.isTraitor and (info.alive and colRedUp or colSpect1) or ((info.alive and !info.incapacitated) and colBlueUp) or colSpect1
			local name = info.nick
			surface.SetDrawColor(col1.r, col1.g, col1.b, col1.a)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(col2.r, col2.g, col2.b, col2.a)
			surface.DrawRect(0, h / 2, w, h / 2)

			local col = info.col
			surface.SetFont("ZB_InterfaceMediumLarge")
			local lengthX, lengthY = surface.GetTextSize(name)

			surface.SetTextColor(0, 0, 0, 255)
			surface.SetTextPos(w / 2 + 1, h / 2 - lengthY / 2 + 1)
			surface.DrawText(name)

			surface.SetTextColor(col.r, col.g, col.b, col.a)
			surface.SetTextPos(w / 2, h / 2 - lengthY / 2)
			surface.DrawText(name)


			local col = colSpect2
			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize(info.name)
			surface.SetTextPos(15, h / 2 - lengthY / 2)
			surface.DrawText(info.name .. ((!info.alive and " - died") or (info.incapacitated and " - incapacitated") or ""))

			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r, col.g, col.b, col.a)
			local lengthX, lengthY = surface.GetTextSize(info.frags)
			surface.SetTextPos(w - lengthX -15,h/2 - lengthY/2)
			surface.DrawText(info.frags)
		end

		function but:DoClick()
			if info.steamid == "BOT" then chat.AddText(Color(255, 0, 0), "That's a bot.") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..info.steamid)
		end

		DScrollPanel:AddItem(but)
	end

	return true
end

function MODE:RoundStart()
	-- if IsValid(hmcdEndMenu) then
	-- 	hmcdEndMenu:Remove()
	-- 	hmcdEndMenu = nil
	-- end
end

--\\
net.Receive("HMCD(StartPlayersRoleSelection)", function()
	local role = net.ReadString()

	hg.SelectPlayerRole(role)
end)

function hg.SelectPlayerRole(role, mode)
	role = role or "Traitor"
	mode = mode or "soe"

	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end

	if(MODE.RoleChooseRoundTypes[mode])then
		//VGUI_HMCD_RolePanelList = vgui.Create("ZB_TraitorSelectionMenu")
		//VGUI_HMCD_RolePanelList:Center()
		VGUI_HMCD_RolePanelList = vgui.Create("HMCD_RolePanelList")
		VGUI_HMCD_RolePanelList.RolesIDsList = MODE.RoleChooseRoundTypes[mode][role]	--; WARNING TCP Reroute
		VGUI_HMCD_RolePanelList.Mode = mode
		-- VGUI_HMCD_RolePanelList:SetSize(ScreenScale(600), ScreenScale(300))
		VGUI_HMCD_RolePanelList:SetSize(screen_scale_2(700), screen_scale_2(300))
		VGUI_HMCD_RolePanelList:Center()
		VGUI_HMCD_RolePanelList:InvalidateParent(false)
		VGUI_HMCD_RolePanelList:Construct()
		VGUI_HMCD_RolePanelList:MakePopup()
	end
end

net.Receive("HMCD(EndPlayersRoleSelection)", function()
	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end
end)

net.Receive("HMCD(SetSubRole)", function(len, ply)
	lply.SubRole = net.ReadString()
end)
--//

--CreateEndMenu()
