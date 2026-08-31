--local Organism = hg.organism
local function isCrush(dmgInfo)
	return (not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_BLAST)) or dmgInfo:GetInflictor().RubberBullets
end

local halfValue2 = util.halfValue2
local function damageBone(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet, nodmgchange)
	local crush = isCrush(dmgInfo)
	
	if dmgInfo:IsDamageType(DMG_SLASH) and dmg > 1.5 then
		//crush = false
	end
	
	dmg = dmg * (dmgInfo:GetInflictor().BreakBoneMul or 1)
	
	if crush then
		crush = halfValue2(1 - org[key], 1, 0.5)
		dmg = dmg / math.max(10 * crush * (bone or 1), 1)
		if dmgInfo:GetInflictor().RubberBullets then dmg = dmg * dmgInfo:GetInflictor().Penetration end
	end

	local val = org[key]
	org[key] = math.min(org[key] + dmg, 1)
	local scale = 1 - (org[key] - val)
	
	if !nodmgchange then dmgInfo:ScaleDamage(1 - (crush and 1 * crush * math.max((1 - org[key]) ^ 0.1, 0.5) or (1 - org[key]) * (bone))) end

	return (crush and 1 * crush * math.max((1 - org[key]) ^ 0.1, 0.5) or (1 - org[key]) * (bone)), VectorRand(-0.2,0.2) / math.Clamp(dmg,0.4,0.8)
end

local huyasd = {
    ["spine1"] = "골반 아래로 아무것도 느껴지지 않아.",
    ["spine2"] = "몸통 아래로 감각도 없고 움직여지지도 않아.",
    ["spine3"] = "전혀 움직일 수가 없어. 숨쉬기조차 힘들어.",
    ["skull"] = "머리가 너무 울려.",
}

local broke_arm = {
    "아아악! 세상에, 부러졌어! 내 팔! 내 팔이 부러졌다고!",
    "씨발, 내 팔이 부러졌어! 아, 씨발!",
    "안 돼, 안 돼, 안 돼! 내 팔이 완전히 꺾여버렸잖아!",
    "내... 내 팔이... 부러졌어- 뚝 소리 나는 걸 들었단 말이야!",
    "내 팔이 이렇게 반으로 꺾일 리가 없는데!",
}

local dislocated_arm = {
    "내 팔이- 세상에, 소켓에서 빠져나왔어!",
    "씨발- 어깨가 그냥- 덜렁거리고 있잖아!",
    "내 팔..! 탈구됐어! 뼈 튀어나온 게 눈으로 다 보인다고!",
    "팔이 그냥- 죽은 고기처럼- 제대로 붙어 있지도 않아!",
    "빌어먹을! 뼈가 어긋난 게 그대로 느껴져!",
}

local broke_leg = {
    "내 다리- 씨발, 부러졌어- 뚝 부러지는 소리를 들었다고!",
    "제길! 정강이가 완전히 박살 났잖아!",
    "무릎이 이상해- 다리 전체가 완전히 뒤틀렸어!",
    "내 다리..! 그냥- 근육이랑 가죽만 대롱대롱 매달려 있네!",
    "통증이 골반까지 치밀어 올라와- 씨발, 장난 아니야!",
    "발을 못 움직이겠어- 발목까지 부러진 것 같아!",
}

local dislocated_leg = {
    "내 다리- 씨발, 무릎이 빠졌어!",
    "무릎뼈가 엉뚱한 곳에 박혀 있는 게 보여!",
    "아악- 고관절이 빠졌어- 밖으로 완전히 꺾여버렸다고!",
    "뒤로 꺾였잖아- 무릎이 이 방향으로 꺾일 리가 없는데!",
    "제길! 고관절이 탈구됐어!",
    "발목도 비틀렸는데- 무릎이 진짜 문제야!",
}

local function legs(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	local oldDmg = org[key]
	local dmg = dmg * 4

	if dmgInfo:IsDamageType(DMG_CRUSH) and dmg > 4 and !org[key.."amputated"] then
		hg.organism.AmputateLimb(org, key)

		return 0
	end

	if org[key] == 1 then return 0 end

	local result, vecrand = damageBone(org, 0.3, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	
	local dmg = org[key]
	
	org[key] = org[key] * 0.5

	if dmg < 0.7 then return 0 end
	if dmg < 1 and !dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) then return 0 end

	if org.isPly and !org[key.."amputated"] then org.just_damaged_bone = CurTime() end
	
	if dmg >= 1 and (!dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) or math.random(3) != 1) then
		org[key] = 1

		org.painadd = org.painadd + 55
		org.owner:AddNaturalAdrenaline(1)
		org.immobilization = org.immobilization + dmg * 25
		org.fearadd = org.fearadd + 0.5

		--if org.isPly and !org[key.."amputated"] then org.owner:Notify(broke_leg[math.random(#broke_leg)], 1, "broke"..key, 1, nil, nil) end

		timer.Simple(0, function() hg.LightStunPlayer(org.owner,2) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		//broken
	else
		//org[key] = 0.5
		org[key.."dislocation"] = true

		org.painadd = org.painadd + 35
		org.owner:AddNaturalAdrenaline(0.5)
		org.immobilization = org.immobilization + dmg * 10
		org.fearadd = org.fearadd + 0.5

		--if org.isPly and !org[key.."amputated"] then org.owner:Notify(dislocated_leg[math.random(#dislocated_leg)], 1, "dislocated"..key, 1, nil, nil) end

		timer.Simple(0, function() hg.LightStunPlayer(org.owner,2) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		//dislocated
	end

	hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 2, "Legs bone damage harm")

	return result, vecrand
end

local function arms(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	local oldDmg = org[key]
	local dmg = dmg * 4
	
	if dmgInfo:IsDamageType(DMG_CRUSH) and dmg > 4 and !org[key.."amputated"] then
		hg.organism.AmputateLimb(org, key)

		return 0
	end

	if org[key] == 1 then return 0 end

	local result, vecrand = damageBone(org, 0.3, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	
	local dmg = org[key]
	
	org[key] = org[key] * 0.5

	if dmg < 0.6 then return 0 end
	if dmg < 1 and !dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) then return 0 end

	if org.isPly and !org[key.."amputated"] then org.just_damaged_bone = CurTime() end
	
	if dmg >= 1 and (!dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) or math.random(3) != 1) then
		org[key] = 1

		org.painadd = org.painadd + 55
		org.owner:AddNaturalAdrenaline(1)
		org.fearadd = org.fearadd + 0.5

		--if org.isPly and !org[key.."amputated"] then org.owner:Notify(broke_arm[math.random(#broke_arm)], 1, "broke"..key, 1, nil, nil) end

		--timer.Simple(0, function() hg.LightStunPlayer(org.owner,1) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		//broken
	else
		org[key.."dislocation"] = true
		//org[key] = 0.5

		org.painadd = org.painadd + 35
		org.owner:AddNaturalAdrenaline(0.5)
		org.fearadd = org.fearadd + 0.5

		--if org.isPly and !org[key.."amputated"] then org.owner:Notify(dislocated_arm[math.random(#dislocated_arm)], 1, "dislocated"..key, 1, nil, nil) end

		--timer.Simple(0, function() hg.LightStunPlayer(org.owner,1) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		//dislocated
	end

	hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 1.5, "Arms bone damage harm")

	if org[key] == 1 and key == "rarm" and org.isPly then
		local wep = org.owner.GetActiveWeapon and org.owner:GetActiveWeapon()
		
		/*if IsValid(wep) then
			local inv = org.owner:GetNetVar("Inventory",{})
			if not (inv["Weapons"] and inv["Weapons"]["hg_sling"] and ishgweapon(wep) and not wep:IsPistolHoldType()) then
				hg.drop(org.owner)
			else
				org.owner:SetActiveWeapon(org.owner:GetWeapon("weapon_hands_sh"))
			end
		end*/
	end

	return result, vecrand
end

local function spine(org, bone, dmg, dmgInfo, number, boneindex, dir, hit, ricochet)
	if dmgInfo:IsDamageType(DMG_BLAST) then dmg = dmg / 3 end

	local name = "spine" .. number
	local name2 = "fake_spine" .. number
	if org[name] >= hg.organism[name2] then return 0 end
	local oldDmg = org[name]

	local result, vecrand = damageBone(org, 0.1, isCrush(dmgInfo) and dmg * 2 or dmg * 2, dmgInfo, name, boneindex, dir, hit, ricochet)
	
	hg.AddHarmToAttacker(dmgInfo, (org[name] - oldDmg) * 5, "Spine bone damage harm")
	
	if (name == "spine3" || name == "spine2") then
		hg.AddHarmToAttacker(dmgInfo, (org[name] - oldDmg) * 8, "Broken spine harm")
	end

	if org[name] >= hg.organism[name2] and org.isPly then
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		if org.owner:IsPlayer() then
			org.owner:Notify(huyasd[name], true, name, 2)
		end
		org.painadd = org.painadd + 25
	end
	
	if dmg > 0.2 then
		--org.owner:Notify("Your spinal cord is damaged.",true,"spinalcord",4)
	end

	org.painadd = org.painadd + dmg * 2
	timer.Simple(0, function() hg.LightStunPlayer(org.owner) end)
	org.shock = org.shock + dmg * 5
	return result,vecrand
end

local jaw_broken_msg = {
    "턱뼈 조각들이 느껴져... 씨발, 씨발, 씨발!",
    "내 턱이 머리 속에서 그냥 덜렁거리고 있잖아!",
    "턱이... 아, 진짜 너무 아파... 뼛조각들이 움직이는 게 느껴져.",
}

local jaw_dislocated_msg = {
    "턱이 안 다물어져... 씨발, 너무 아파!",
    "내 턱... 그냥 저기에 걸려 있어-- 아, 통증이 장난 아니야.",
    "턱을 전혀 못 움직이겠어... 그리고 정말 욱신거려.",
    //"말도 제대로 안 나와. 주먹으로 쳐서라도 맞춰야 하는데... 너무 아파서 엄두가 안 나.",
}

local input_list = hg.organism.input_list
input_list.jaw = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.jaw

	local result, vecrand = damageBone(org, 0.25, dmg, dmgInfo, "jaw", boneindex, dir, hit, ricochet)

	hg.AddHarmToAttacker(dmgInfo, (org.jaw - oldDmg) * 3, "Jaw bone damage harm")

	if org.jaw == 1 and (org.jaw - oldDmg) > 0 and org.isPly then org.owner:Notify(jaw_broken_msg[math.random(#jaw_broken_msg)], true, "jaw", 2) end

	local dislocated = (org.jaw - oldDmg) > math.Rand(0.1, 0.3)

	if org.jaw == 1 then
		org.shock = org.shock + dmg * 40
		org.avgpain = org.avgpain + dmg * 30

		if oldDmg != 1 then org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO) end
	end

	org.shock = org.shock + dmg * 3

	if dislocated then
		org.shock = org.shock + dmg * 20
		org.avgpain = org.avgpain + dmg * 20
		
		if !org.jawdislocation then
			org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		end

		org.jawdislocation = true

		if org.isPly then org.owner:Notify(jaw_dislocated_msg[math.random(#jaw_dislocated_msg)], true, "jaw", 2) end
	end

	if dmg > 0.2 then
		if org.isPly then timer.Simple(0, function() hg.LightStunPlayer(org.owner,1 + dmg) end) end
	end

	return result, vecrand
end

hook.Add("CanListenOthers", "CantHaveShitInDetroit", function(output, input, isChat, teamonly, text)
	if IsValid(output) and (output.organism.jaw == 1 or output.organism.jawdislocation) and output:Alive() and (output:IsSpeaking() or isChat) then
		-- and !isChat and output:IsSpeaking()
		output.organism.painadd = output.organism.painadd + 2 * (output:IsSpeaking() and 1 or (isChat and 5 or 0))
		output:Notify("My jaw is really hurting when I speak.", 60, "painfromjawspeak", 0, nil, Color(255, 210, 210))
	end
end)

input_list.skull = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.skull
	
	local result, vecrand = damageBone(org, 0.25, dmg, dmgInfo, "skull", boneindex, dir, hit, ricochet)

	hg.AddHarmToAttacker(dmgInfo, (org.skull - oldDmg) * 4, "Skull bone damage harm")

	if org.skull == 1 then
		org.shock = org.shock + dmg * 40
		org.avgpain = org.avgpain + dmg * 30

		if oldDmg != 1 then org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO) end
	end

	org.shock = org.shock + dmg * 3

	local rnd = math.random(10) == 1 or dmgInfo:IsDamageType(DMG_CRUSH)
	org.consciousness = math.Approach(org.consciousness, 0, rnd and dmg * 2 or 0)

	org.brain = math.min(org.brain + (rnd and dmg * 0.05 or 0), 1)

	if (org.skull - oldDmg) > 0.6 then
		org.brain = math.min(org.brain + 0.1, 1)
	end

	if org.brain >= 0.01 and math.random(3) == 1 and (rnd or (org.skull - oldDmg) > 0.6) then
		--hg.applyFencingToPlayer(org.owner, org)
		org.shock = 70

		timer.Simple(0.1, function()
			local rag = hg.GetCurrentCharacter(org.owner)

			if IsValid(rag) and rag:IsRagdoll() then
				hg.applyFencingToPlayer(org.owner, org)
				--local stype = "rigor"--hg.getRandomSpasm()
				--hg.applySpasm(rag, stype)
				--if rag.organism then rag.organism.spasm, rag.organism.spasmType = true, stype end
			end
		end)
	end

	if dmg > 0.4 then
		if org.isPly then
			timer.Simple(0, function()
				hg.LightStunPlayer(org.owner,1 + dmg)
			end)
		end
	end
	
	org.shock = org.shock + (dmg > 1 and 50 or dmg * 10)

	if org.skull == 1 then
		if org.isPly then
			//org.owner:Notify(huyasd["skull"],true,"skull",4)
		end

		--[[if dir then
			net.Start("hg_bloodimpact")
			net.WriteVector(dmgInfo:GetDamagePosition())
			net.WriteVector(dir / 10)
			net.WriteFloat(3)
			net.WriteInt(1,8)
			net.Broadcast()
		end--]]
	end

	org.disorientation = org.disorientation + (isCrush(dmgInfo) and dmg * 1 or dmg * 1)

	return result,vecrand
end

local ribs = {
    "내 가슴이... 부러졌어.",
    "몸통 안에서 뭔가가 뚝 하고 끊어지는 소리가 났어.",
    "가슴 속에 날카로운 게 찌르는 것 같아...",
    "몸통 안에서 뭔가 날카로운 게 느껴져.",
}

input_list.chest = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)	
	local oldDmg = org.chest

	if dmgInfo:IsDamageType(DMG_SLASH+DMG_BULLET+DMG_BUCKSHOT) and math.random(5) == 1 then return 0, vector_origin end --random chance it passed through ribs

	local result, vecrand = damageBone(org, 0.1, dmg / 4, dmgInfo, "chest", boneindex, dir, hit, ricochet, true)
	
	hg.AddHarmToAttacker(dmgInfo, (org.chest - oldDmg) * 3, "Ribs bone damage harm")

	org.painadd = org.painadd + dmg * 1
	org.shock = org.shock + dmg * 1

	if org.isPly and (not org.brokenribs or (org.brokenribs ~= math.Round(org.chest * 3))) then
		org.brokenribs = math.Round(org.chest * 3)
		
		if org.brokenribs > 0 then
			//org.owner:Notify(ribs[math.random(#ribs)], 5, "ribs", 4)

			org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)

			return math.min(0, result)
		end
	end

	return result * 0.5, vecrand
end

input_list.pelvis = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.pelvis
	org.painadd = org.painadd + dmg * 1
	org.shock = org.shock + dmg * 1

	local result = damageBone(org, bone, dmg * 0.5, dmgInfo, "pelvis", boneindex, dir, hit, ricochet)
	
	hg.AddHarmToAttacker(dmgInfo, (org.pelvis - oldDmg) / 2, "Pelvis bone damage harm")

	if org.isPly and org.pelvis == 1 then
		//org.owner:Notify("My pelvis is agonizingly hurting.", true, "pelvis", 4)
	end

	return result
end

input_list.rarmup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone * 1.25, dmg, dmgInfo, "rarm", boneindex, dir, hit, ricochet) end
input_list.rarmdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone, dmg, dmgInfo, "rarm", boneindex, dir, hit, ricochet) end
input_list.larmup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone * 1.25, dmg, dmgInfo, "larm", boneindex, dir, hit, ricochet) end
input_list.larmdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone, dmg, dmgInfo, "larm", boneindex, dir, hit, ricochet) end
input_list.rlegup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg * 1.25, dmgInfo, "rleg", boneindex, dir, hit, ricochet) end
input_list.rlegdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg, dmgInfo, "rleg", boneindex, dir, hit, ricochet) end
input_list.llegup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg * 1.25, dmgInfo, "lleg", boneindex, dir, hit, ricochet) end
input_list.llegdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg, dmgInfo, "lleg", boneindex, dir, hit, ricochet) end
input_list.spine1 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 1, boneindex, dir, hit, ricochet) end
input_list.spine2 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 2, boneindex, dir, hit, ricochet) end
input_list.spine3 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 3, boneindex, dir, hit, ricochet) end