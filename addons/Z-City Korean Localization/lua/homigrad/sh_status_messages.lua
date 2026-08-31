
local allowedchars = {
    "아",
    "아악",
    "윽",
    "끄윽",
    "아아악",
}

local audible_pain = {
    "아아아악.. 씨발.. 너무 아파.",
    "더 이상은 못 참겠어!",
    "멈추게 해줘, 제발 멈추게 해달라고, 멈춰!",
    "왜 안 멈추는 거야, 왜!",
    "차라리 기절시켜줘. 제발!",
    "내가 왜 이런 고통을 느끼려고 태어난 거야, 왜...",
    "이걸 멈출 수만 있다면 뭐든지 하겠어... 뭐든지.",
    "이건 사는 게 아니야, 고문당하는 거라고!",
    "이제 아무래도 상관없으니까 이 고통 좀 끝내줘!",
    "이걸 멈추는 거 말고는 아무것도 중요하지 않아...",
    "매 순간순간이 영겁의 불길 속에 있는 것 같아.",
    "차라리 죽는 게 자비로운 수준이야...",
    "단 한 순간만이라도 고통 없이 있고 싶어..",
    "지금 당장 진통제라도 좀 있으면 좋겠는데. 씨발.",
}

local sharp_pain = {
    "아아악",
    "아악",
    "아아아악",
    "아아아악",
    "아아아아아악",
    "아아아악",
    "아아아아악",
    "아아아아아악",
    "아아아아아아악",
    "아아아악",
    "아아아악",
    "아아아아아아아아악",
    "아아아아악",
    "아아아아악",
    "아아아아악",
    "아아아",
    "아아아악",
    "아아아악",
    "아아아아아아아아아악",
    "아아아아아아아아아아아아악",
    "아아아아아아아아아아아아아아아악",
    "아아아아아아아아아악",
    "아아아아아아아아아악",
    "아아아아아아아아아아아아아아아아아아악",
    "아아아아아아아아아악",
    "아아아아아아아아아아악",
    "아아아아아아아아아아아악",
    "아아아아아아아아아아아아아아아악",
    "아아아아아아아아아아아아아아아악",
    "아아아아아아아아아아아아아아아아아아아아아아아아악",
    "아아아아아아아아아아아아아아아아아아아아아아악",
}

hg.sharp_pain = sharp_pain

local random_phrase = {
    "여기 좀 으스스하네...",
    "모든 게 너무 조용해...",
    "지금 숨 쉬는 게 묘하게 기분 좋네.",
    "이 정적이 영원히 계속되면 어쩌지?",
    "왜 아무 일도 안 일어나는 거야?",
}

local fear_hurt_ironic = {
    "살아남는다면... 여기서 배울 점이 있겠지.",
    "미래의 내 전기 작가도 이 부분은 안 믿을 거야.",
    "참나, 죽는 방법 치고는 진짜 멍청하네.",
    "적어도 내 인생이 지루하진 않았어.",
    "나 자신에게 쓰는 메모: 다시는 이런 짓 하지 말 것.",
    "죽기에 그리 나쁜 날은 아니군.",
}

local fear_phrases = {
    "생각보다 그렇게 나쁘진 않아... 그치?",
    "이런 식으로 죽고 싶지는 않아.",
    "정말로 이렇게 끝나는 거야?",
    "이건 좋지 않아.",
    "진짜 이렇게 끝인 건가?",
    "이렇게 죽고 싶진 않다고.",
    "나갈 방법이 있으면 좋겠는데.",
    "후회되는 일이 너무 많아.",
    "이게 끝일 리가 없어.",
    "나한테 이런 일이 일어나다니 믿기지 않아.",
    "좀 더 진지하게 임했어야 했어.",
    "만약 내가 못 버티면 어쩌지..?",
    "생각했던 것보다 훨씬 심각해.",
    "이건 너무 불공평해.",
    "아직 포기할 순 없어.",
    "이런 식일 줄은 꿈에도 몰랐는데.",
    "내 직감을 믿었어야 했어.",
    "숨 쉬자. 그냥 숨 쉬는 거야.",
    "손이 차가워지네. 진정해, 떨지 마.",
}

local is_aimed_at_phrases = {
    "세상에. 끝이구나.",
    "움직이지... 마.",
    "정말 이렇게 죽는 건가?",
    "도망쳤어야 했어. 왜 안 그랬지?",
    "제발 방아쇠를 당기지 마. 제발.",
    "방아쇠에 걸린 손가락이 보여.",
    "죽고 싶지 않아. 이런 식은 아니야.",
    "빌면 상황이 더 나빠질까?",
    "이건 꿈일 거야. 현실일 리 없어.",
    "누가 나 좀 도와줘. 제발. 아무나.",
    "이런 곳에서 죽고 싶지 않아.",
    "내 마지막 기억이 공포가 아니었으면 좋겠는데.",
    "죽고 싶지 않아.",
}

local near_death_poetic = {
    "일어서려고 해도... 도저히 안 돼...",
    "숨을 들이켜도 허공만 마시는 기분이야...",
    "눈을 뜨고 있는 건지 감고 있는 건지도 모르겠어...",
    "내 마지막 미각은 피와 구리 맛이겠군.",
    "초점이 자꾸만 어긋나.",
    "어떻게 서는 건지 기억이 안 나.",
    "머릿속에서 모든 게 메아리쳐.",
    "눈을 한 번 깜빡이면 다시 뜨는 데 한참이 걸려.",
    "손에 아무것도 잡히지 않아.",
    "폐가 공기를 거부하고 있어.",
    "이제 와서 후회해 봐야 소용없지.",
}

local near_death_positive = {
    "죽고 싶지 않아.",
    "살아남아야 해.",
    "아직 기회는 있어.",
    "공포에 굴복할 순 없지.",
    "딱 한 번만 더 해보자.",
    "이런 데서 죽을 생각은 추호도 없어.",
    "좋아... 차분하게 생각하는 거야.",
    "가만히 있어. 움직이면 상태만 더 나빠질 뿐이야.",
    "천천히 숨 쉬자. 당황해봤자 도움 안 돼.",
    "끝날 때까지 끝난 게 아니야.",
    "통증은 그냥 신호일 뿐이야. 무시해.",
    "만약 이게 정말 끝이라 해도... 최소한 순식간일 거야.",
    "이보다 더한 상황에서도 살아남았었잖아. 아마도.",
    "내가 그리던 마지막 모습은 이게 아니었는데.",
}

local broken_limb = {
    "씨발. 씨발. 이거 확실히 부러졌어!",
    "뼛조각들이 움직이는 게 느껴져!",
    "존나 부러진 것 같아. 내 생각엔..",
    "생각만 해도 너무 아파. 분명히 부러졌어.",
    "여기가 이렇게 휘어지면 안 되는 건데.",
    "아, 씨발. 뚝 하고 부러졌잖아.",
    "개방 골절은 아닌 것 같은데, 확실히 어디가 부러진 기분이야.",
}

local dislocated_limb = {
    "그래, 저게 저런 식으로 꺾이면 안 되지.",
    "이 뼈를 다시 끼워 넣어야 해.",
    "안 돼... 제자리로 다시 돌려놓아야 한다고.",
    "저기가 너무 아파. 검사를 좀 받아봐야 할 것 같아.",
    "팔다리가 탈구됐어.",
}

local hungry_a_bit = {
    "음, 배고프다...",
    "먹을 게 좀 있으면 좋겠는데...",
    "배고파...",
    "뭐 좀 먹어야겠어.",
}

local very_hungry = {
    "내 배가... 윽...",
    "뭐라도 안 먹으면 상태가 더 나빠질 거야...",
    "속이... 제길... 메스꺼워.",
}

local after_unconscious = {
    "무슨 일이 있었던 거지? 아파...",
    "여기가 어디야? 왜 이렇게 아픈 건데...",
    "나-나 진짜 죽는 줄 알았어...",
    "내 머리... 무슨 일이 일어난 거야?",
    "방금 나 죽을 뻔한 건가?",
    "방금 죽었던 것 같은 기분이야.",
    "저승에서 날 안 받아준 건가?",
    "아-씨발... 머리가 너무 울려...",
    "아, 지금 당장 일어나기 힘들 것 같아... 하지만 일어나야 해...",
    "여기 전혀 모르는 곳인데... 아니, 와본 적이 있나?",
    "이런 경험은 다시는 하고 싶지 않아!",
}

local slight_braindamage_phraselist = {
    "이해가 안 돼...",
    "말이 안 되잖아...",
    "여기가 어디지?",
    "어? 이게 뭐야..?",
    "무슨 일이 일어나고 있는지 모르겠어...",
    "저기요?",
    "으으으으... 아아... 허어...",
    "무슨... 일이 벌어지는 거야?",
}

local braindamage_phraselist = {
    "버버베.. 여이가 어디지이?!",
    "브으으... 메엑...",
    "음--흐으으. 응?",
    "그흐음으 흐으으...",
    "아그윽...으으?",
    "흐으윽... 제-제기일.",
    "으으음프, 음-프!",
    "사알-살려어줘어...",
    "으으윽... 그음?",
    "그으으... 브그윽..",
    "느으으오오오(뇌).",
}

local cold_phraselist = {
    "점점 추워지네..",
    "너무 추워.",
    "몸이 떨려, 씨발 진짜.",
    "여기 너무 으스스하게 춥다..",
    "몸을 녹일 게 좀 필요해...",
    "꽤 춥네...",
    "추위 때문에 몸살 날 것 같아, 젠장."
}

local freezing_phraselist = {
    "모.. 몸에.. 가-감각이 어-없어..",
    "다.. 다리에.. 가-감각이 안 느껴져...",
    "어.. 어어어엄청 추-추워.. 죽을 거 가-같아..",
    "어-얼굴이.. 마-마비된 것 가-같아..",
    "추-추워..",
    "아.. 아무것도.. 안-안 느껴져..",
}

local numb_phraselist = {
    "이제.. 안 춥네..",
    "왜... 따뜻하게 느껴지지..?",
    "괜찮아진 것 같아... 내 생각엔...",
    "드디어 좀 따뜻해졌네...",
    "다시 따뜻해졌어... 어째서인지 몰라도...",
    "방금까진 얼어 죽을 것 같았는데... 이 열기는 어디서 오는 거지..?",
}

local hot_phraselist = {
    "땀이 너무 나네..",
    "더워 죽겠어..",
    "옷이 땀으로 다 젖었네, 씨발.",
    "땀 냄새 존나 나네. 진짜 열 좀 식혀야겠어...",
    "너무 더워, 씨발 진짜.",
    "몸에 열이 너무 올라오는데...",
    "여기 왜 이렇게 더운 거야?"
}

local heatstroke_phraselist = {
    "물이 필요해!!",
    "제발... 물 좀...",
    "어지러워... 씨바알-",
    "내 머리!- 너무 아파..",
    "머리가 욱신거려..",
}

local heatvomit_phraselist = {
    "이 열기 때문에..- 토할 것 같아-",
    "으으윽... 곧 나올 것 같아-",
    "씨발.. 우욱.. 기분이 영-"
}

local hg_showthoughts = ConVarExists("hg_showthoughts") and GetConVar("hg_showthoughts") or CreateClientConVar("hg_showthoughts", "1", true, true, "Toggle thoughts of your character", 0, 1)

function string.Random(length)
	local length = tonumber(length)

    if length < 1 then return end

    local result = {}

    for i = 1, length do
        result[i] = allowedchars[math.random(#allowedchars)]
    end

    return table.concat(result)
end

function hg.nothing_happening(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear < -0.6
end

function hg.fearful(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear > 0.5
end

function hg.likely_to_phrase(ply)
	local org = ply.organism

	local pain = org.pain
	local brain = org.brain
	local blood = org.blood
	local fear = org.fear
	local temperature = org.temperature
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone - CurTime()) < -3)

	return (broken_dislocated) and 5
		or (pain > 65) and 5
		or (temperature < 31 and 0.5)
		or (temperature > 38 and 0.5)
		or (blood < 3000 and 0.3)
		--or (fear > 0.5 and 0.7)
		or (brain > 0.1 and brain * 5)
		or (fear < -0.5 and 0.05)
		or -0.1
end

function IsAimedAt(ply)
    return ply.aimed_at or 0
end

local function get_status_message(ply)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end

	local nomessage = hook.Run("HG_CanThoughts", ply) --ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"
	if nomessage ~= nil and nomessage == false then return "" end

    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism
	
	if not org or not org.brain then return "" end

	local pain = org.pain
	local brain = org.brain
	local temperature = org.temperature
	local blood = org.blood
	local hungry = org.hungry
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone + 3 - CurTime()) < -3)

	if broken_dislocated and org.just_damaged_bone then
		org.just_damaged_bone = nil
	end
	
	local broken_notify = (org.rarm == 1) or (org.larm == 1) or (org.rleg == 1) or (org.lleg == 1)
	local dislocated_notify = (org.rarm == 0.5) or (org.larm == 0.5) or (org.rleg == 0.5) or (org.lleg == 0.5)
	local after_unconscious_notify = org.after_otrub

	if not isnumber(pain) then return "" end

	local str = ""

	local most_wanted_phraselist
	
	if temperature < 35 then
		most_wanted_phraselist = temperature > 31 and cold_phraselist or (temperature < 28 and numb_phraselist or freezing_phraselist)
	elseif temperature > 38 then
		most_wanted_phraselist = temperature < 40 and hot_phraselist or heatstroke_phraselist
	end

	if not most_wanted_phraselist and hungry and hungry > 25 and math.random(3) == 1 then
		most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
	end

	if (blood < 3100) or (pain > 75) or (broken_dislocated) or (broken_notify) or (dislocated_notify) then
		if pain > 75 and (broken_dislocated) then
			most_wanted_phraselist = math.random(2) == 1 and audible_pain or (broken_notify and broken_limb or dislocated_limb)
		elseif pain > 75 then
			most_wanted_phraselist = audible_pain
		elseif broken_dislocated then
			most_wanted_phraselist = (broken_notify and broken_limb or dislocated_limb)
		end

		if pain > 100 then
			most_wanted_phraselist = sharp_pain
		end

		if not most_wanted_phraselist then
			if (broken_dislocated_notify) and (blood < 3100) then
				most_wanted_phraselist = blood < 2900 and (near_death_poetic) or (math.random(2) == 1 and (broken_notify and broken_limb or dislocated_limb) or near_death_poetic)
			--elseif(broken_dislocated_notify)then
				--most_wanted_phraselist = (broken_notify and broken_limb or dislocated_limb)
			elseif(blood < 3100)then
				most_wanted_phraselist = near_death_poetic
			end
		end
	elseif after_unconscious_notify then
		most_wanted_phraselist = after_unconscious
	elseif hg.nothing_happening(ply) then
		most_wanted_phraselist = random_phrase

		if hungry and hungry > 25 and math.random(5) == 1 then
			most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
		end
	elseif hg.fearful(ply) then
		most_wanted_phraselist = ((IsAimedAt(ply) > 0.9) and is_aimed_at_phrases or (math.random(10) == 1 and fear_hurt_ironic or fear_phrases))
	end

	if brain > 0.1 then
		most_wanted_phraselist = brain < 0.2 and slight_braindamage_phraselist or braindamage_phraselist
	end
	
	if most_wanted_phraselist then
		str = most_wanted_phraselist[math.random(#most_wanted_phraselist)]

		return str
	else
		return ""
	end
end

local allowedlist_types = {
	heatvomit = heatvomit_phraselist,
}

function hg.get_phraselist(ply, type)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end
	
	local nomessage = ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"

	if nomessage then return "" end
    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism	
	if not org or not org.brain then return "" end

	if not isstring(type) or not allowedlist_types[type] then return "" end

	local needed_list = allowedlist_types[type]

	local str = needed_list[math.random(#needed_list)]
	return str
end

function hg.get_status_message(ply)
	local txt = get_status_message(ply)

	return txt
end
