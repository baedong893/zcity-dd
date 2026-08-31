local MODE = MODE
MODE.start_time = 1
MODE.end_time = 7
 
MODE.ROUND_TIME = 600
 
MODE.randomSpawns = true

MODE.shouldfreeze = true

MODE.PoliceAllowed = false
MODE.OverrideSpawn = true

MODE.LootSpawn = true
MODE.LootOnTime = true

MODE.Chance = 0.2 -- this is mostly unused
MODE.LootDivTime = 500

function MODE:SetupChances()
	for name, tbl in pairs(MODE.Types) do
		zb.ModesChances[name] = zb.ModesChances[name] or tbl.Chance
	end
end

MODE.LootTable = {
	{40, {
		{15,"weapon_smallconsumable"},
		{12,"weapon_bigconsumable"},
		{8,"weapon_tourniquet"},
		{8,"weapon_bandage_sh"},
		{7,"weapon_ducttape"},
		{6,"weapon_painkillers"},
		{5,"weapon_bloodbag"},
		{4,"weapon_walkie_talkie"},
		{3,"hg_flashlight"},
		{3,"weapon_bigbandage_sh"},
		{2,"weapon_medkit_sh"},

		{1,"weapon_matches"},

		{0.2,"weapon_morphine"},
		{0.2,"weapon_mannitol"},
		{0.5,"weapon_naloxone"},
		{0.1,"weapon_fentanyl"},
		{0.9,"weapon_betablock"},
		{0.5,"weapon_adrenaline"},

		{0.65,"ent_armor_mask2"},
		{0.27, "ent_armor_helmet2"},
	}},
	{20,{
		{12,"weapon_hammer"},
		{6,"weapon_brick"},
		{10,"weapon_pocketknife"},

		{4,"weapon_bat"},
		{4,"weapon_leadpipe"},
		{3,"weapon_hg_extinguisher"},

		{2,"weapon_hg_crowbar"},
		{1,"weapon_hatchet"},
		{0.9,"weapon_hg_axe"},
		{0.5,"weapon_hg_machete"},
		{0.4,"weapon_hg_sledgehammer"},

		{0.2,"hg_brassknuckles"},
		{0.13,"weapon_hg_spear"},
		{0.13, "weapon_hg_spear_pro"},
	}},
	{11,{
		{10,"*sight*"},
		{7,"*barrel*"},

		{7,"ent_armor_helmet7"},
		{5,"ent_armor_vest7"},
		{8, "ent_armor_helmet2"},
	}},
	{9,{
		{6,"*sight*"},
		{5,"*barrel*"},

		{15,"weapon_mp-80"},
		{8,"weapon_makarov"},
		{7,"weapon_ruger"},
		{4,"weapon_revolver2"},
		{4,"weapon_px4beretta"},
		{3.5,"weapon_m1911"},
		{3,"weapon_m9beretta"},
		{2,"weapon_fn45"},
	}},
	{6, {
		{9,"weapon_hk_usp"},
		{9,"weapon_glock17"},
		{9,"weapon_cz75"},
		{9,"weapon_px4beretta"},

		{6,"weapon_deagle"},
		{6,"weapon_colt9mm"},

		{5,"weapon_doublebarrel_short"},
		{5,"weapon_doublebarrel"},
		{4, "weapon_flintlock"},
	}},
	{4,{
		{5,"ent_armor_vest3"},
		{5,"ent_armor_helmet1"},
		{2,"ent_armor_vest4"},
		{2, "ent_armor_helmet5"},
	}},
	{2, {
		{4,"weapon_remington870"},

		{4,"weapon_hg_molotov_tpik"},
		{4,"weapon_hg_pipebomb_tpik"},

		{3,"weapon_mini14"},
		{3,"weapon_kar98"},
		{3,"weapon_ar_pistol"},
		{3,"weapon_draco"},
		{3,"weapon_mp5"},
		{3,"weapon_m16a2"},

		{2,"weapon_mp7"},
		{2,"weapon_sks"},
		{2,"weapon_ar15"},
		{2,"weapon_ac556"},

		{1,"weapon_vpo136"},
		{1,"weapon_musket"},
		{1,"weapon_vpo136"},
		{1,"weapon_sr25"},
	}},
}

MODE.LootTableStandard = {
	{65, {
		{15,"weapon_smallconsumable"},
		{12,"weapon_bigconsumable"},
		{8,"weapon_tourniquet"},
		{8,"weapon_bandage_sh"},
		{7,"weapon_ducttape"},
		{6,"weapon_painkillers"},
		{5,"weapon_bloodbag"},
		{4,"hg_flashlight"},
		{1,"weapon_matches"},--for dumbasses
	}},
	{35, {
		{1,"weapon_hammer"},
		{1,"weapon_brick"},
		{1,"weapon_pocketknife"},
		{0.32,"weapon_bat"},
		{0.3,"weapon_leadpipe"},

		{0.15,"weapon_hg_extinguisher"},
		{0.14,"weapon_hg_crowbar"},

		{0.12,"weapon_hatchet"},
		{0.10,"weapon_hg_axe"},
		{0.09,"weapon_hg_sledgehammer"},
		{0.07,"weapon_hg_machete"},
	}},
}

-- MODE.TraitorWords = {
	-- "пистолет",
	-- "трейтор",
	-- "ганмен",
	-- "калаш (винтовка)",
	-- "бомба",
	-- "цианид",
	-- "нож",
	-- "труба",
	-- "топор",
	-- "юсп (пистолет)",
	-- "арка (винтовка)",
	-- "каряк (винтовка)",
	-- "граната",
	-- "улица",
	-- "здание",
	-- "патроны",
	-- "бинт",
	-- "аптечка",
	-- "обезболивающее",
	-- "дробовик",
-- }

MODE.TraitorWordsAdjectives = {
    "예쁨",
    "슬픔",
    "나쁨",
    "멋짐",
    "행복",
    "추함",
    "웃김",
    "빨강",
    "초록",
    "파랑",
    "노랑",
    "주황",
    "하늘색(시안)",
    "분홍",
    "매혹적",
	"",	--; да да
}

MODE.TraitorWords = {
    "상자",
    "죽음",
    "남성",
    "리볼버",
    "문",
    "권총",
    "배신자",
    "무장 시민",
    "AK 소총",
    "폭탄",
    "시안화물",
    "단검",
    "파이프",
    "도끼",
    "USP 권총",
    "AR15 소총",
    "Kar98k 소총",
    "수류탄",
    "외부",
    "건물",
    "탄약",
    "붕대",
    "구급 상자",
    "진통제",
    "샷건",
    "우울함",
    "독극물",
    "살인",
}

local function EnsureTraitorWords()
	if not isstring(MODE.TraitorWord) then
		MODE.TraitorWord = table.Random(MODE.TraitorWords) or ""
	end

	if not isstring(MODE.TraitorWordSecond) then
		MODE.TraitorWordSecond = table.Random(MODE.TraitorWords) or ""
	end

	return MODE.TraitorWord, MODE.TraitorWordSecond
end

MODE.TraitorActions = {
    "공기나 벽을 향해 주먹질하기",
    "점프하기",
    "앉기",
    "무작위로 쓰러지기(래그돌)",
    "제자리에서 회전하기",
}

SetGlobalBool("RolesPlus_Enable", true)

util.AddNetworkString("HMCDPoliceRole")
util.AddNetworkString("HMCD(StartPlayersRoleSelection)")
util.AddNetworkString("HMCD(EndPlayersRoleSelection)")
util.AddNetworkString("HMCD(SetSubRole)")
util.AddNetworkString("hmcd_announce_traitor_lose")

MODE.Type = MODE.Type or "standard"
MODE.Types = MODE.Types or {}

local function GetActiveHomicidePlayerCount()
	local count = 0

	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then
			count = count + 1
		end
	end

	return count
end

local function CanLaunchHomicideType(typeName)
	if typeName == "standard" then return true end

	local typeData = MODE.Types and MODE.Types[typeName]
	local minPlayers = (typeData and typeData.MinPlayers) or 2
	local playerCount = GetActiveHomicidePlayerCount()

	return playerCount >= minPlayers
end

local homicideFallbackOrder = {
	"standard",
	"wildwest",
	"gunfreezone",
}

local function FindLaunchableHomicideType()
	for _, typeName in ipairs(homicideFallbackOrder) do
		if MODE.Types and MODE.Types[typeName] and CanLaunchHomicideType(typeName) then
			return typeName
		end
	end
end

MODE.Types.standard = {
	Chance = 0.2,
	ChanceFunction = function() return (zb.GetWorldSize() < ZBATTLE_BIGMAP) and (zb.ModesChances["standard"] or zb.modes["hmcd"].Types.standard.Chance) or 0 end,
	LootTable = MODE.LootTableStandard,
	Messages = {
        [3] = "모두 사망했습니다.",
        [1] = "살인마가 모든 사람을 살해했습니다.",
        [0] = "살인마가",
	},
	Message = "The murderer was ",
	TraitorLoot = function(ply)
		ply:Give("weapon_buck200knife")
		ply:Give("weapon_hg_type59_tpik")
		ply:Give("weapon_adrenaline")
		ply:Give("weapon_hg_shuriken")
		ply:Give("weapon_hg_smokenade_tpik")
		ply:Give("weapon_traitor_ied")
		ply:Give("weapon_traitor_poison1")
		ply:Give("weapon_traitor_poison2")
		ply:Give("weapon_traitor_poison3")
		ply:Give("weapon_traitor_poison_consumable")
		ply:Give("weapon_traitor_suit")
		ply:Give("weapon_beartrap_homigrad")
		local wep = ply:Give("weapon_zoraki")
		timer.Simple(1,function() wep:ApplyAmmoChanges(2) end)

		ply.organism.stamina.range = 220

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
	end,
	GunManLoot = function(ply)
		ply:Give("weapon_px4beretta")
		ply.organism.recoilmul = 1
	end,
	PoliceTime = 220,
	SkillIssue = 4,
	PoliceAllowed = true,
	PoliceEquipment = function(ply)
		ply:SetPlayerClass("police")
		local glock = ply:Give("weapon_glock17")
		ply:GiveAmmo(glock:GetMaxClip1() * 3,glock:GetPrimaryAmmoType(),true)
		if math.random(0, 1) == 1 then
			hg.AddAttachmentForce(ply, glock, "holo16")
		end

		if math.random(0, 1) == 1 then
			hg.AddAttachmentForce(ply, glock, "laser3")
		end

		ply:Give("weapon_medkit_sh")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_naloxone")
		ply:Give("weapon_painkillers")
		ply:Give("weapon_handcuffs")
		ply:Give("weapon_handcuffs_key")
		ply:Give("weapon_hg_tonfa")
		
		local gun = ply:Give("weapon_taser")
		ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)

		hg.AddArmor(ply, {"vest2"})

		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon( hands )

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
		ply.organism.recoilmul = 0.8

		ply:SetNetVar("CurPluv", "pluvberet")

		zb.GiveRole(ply, "Police Officer", Color(15,15,255))
	end
}
MODE.Types.wildwest = {
	Chance = 0.05,
	ChanceFunction = function() return (zb.GetWorldSize() < ZBATTLE_BIGMAP) and (zb.ModesChances["wildwest"] or zb.modes["hmcd"].Types.wildwest.Chance) or 0 end,
	LootTable = MODE.LootTableStandard,
	Messages = {
        [3] = "적막만이 텅 빈 도시를 채웁니다...",
        [1] = "마을은 범죄의 손아귀에 떨어졌습니다.",
        [0] = "다시 한번 법의 심판이 내려졌습니다. 그 자는",
	},
	Message = "The criminal was ",
	TraitorLoot = function(ply)
		ply:Give("weapon_sogknife")
		ply:Give("weapon_hg_type59_tpik")
		ply:Give("weapon_adrenaline")
		local revolver = ply:Give(math.random(2) == 2 and "weapon_winchester" or "weapon_revolver2")
		ply:GiveAmmo(revolver:GetMaxClip1() * 1,revolver:GetPrimaryAmmoType(),true)
		ply:Give("weapon_traitor_ied")
		ply:Give("weapon_hg_molotov_tpik")
		ply:Give("weapon_hg_smokenade_tpik")

		ply.organism.recoilmul = 1.0
		ply.organism.stamina.range = 220

		ply:SetNetVar("CurPluv", "pluvfancy")

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory",inv)
	end,
    /*local tMdl = APmodule.PlayerModels[1][tbl.AModel] or APmodule.PlayerModels[2][tbl.AModel] or tbl.AModel
    ply:SetModel(istable(tMdl) and tMdl.mdl or tMdl)

    local clr = tbl.AColor
    if ply.SetPlayerColor then
        ply:SetPlayerColor(Vector(clr.r / 255,clr.g / 255,clr.b / 255))
    end
    ply:SetNWVector( "PlayerColor", Vector(clr.r / 255,clr.g / 255,clr.b / 255) )

    ply:SetSubMaterial()

    local mats = ply:GetMaterials()
    if istable(tMdl) then
        for k, v in pairs(tMdl.submatSlots) do
            local slot = 1
            for i = 1, #mats do
                if mats[i] == v then slot = i-1 break end
            end
            ply:SetSubMaterial(slot, hg.Appearance.Clothes[tMdl.sex and 2 or 1][tbl.AClothes[k]] )*/

	GunManLoot = function(ply)
		for k,v in player.Iterator() do
			timer.Simple(1,function()
				local Appearance = v:GetNetVar("Accessories",{"none"})
				if istable(Appearance) then
					Appearance[1] = "stetson"
				else
					Appearance = "stetson"
				end
				v:SetNetVar("Accessories", Appearance)
				local sex = ThatPlyIsFemale(v) and 2 or 1
				local tbl = v.CurAppearance
				tbl.AClothes["main"] = "formal"
				tbl.AClothes["pants"] = "formal"
				tbl.AClothes["boots"] = "formal"
				tbl.AColor = Color(1 * 255,0.690196 * 255,0.537255 * 255)
				hg.Appearance.ForceApplyAppearance(v,tbl)
				--v:SetSubMaterial(table.Flip(v:GetMaterials())[hg.Appearance.FuckYouModels[sex][v:GetModel()].submatSlots.main] - 1, hg.Appearance.Clothes[sex]["formal"])
				--v:SetPlayerColor(Vector(1,0.690196,0.537255))
			end)
			if v.isTraitor then continue end
			if v.isGunner then
				v:Give("weapon_winchester")
				v:Give("weapon_revolver357")
				v:Give("weapon_handcuffs")
				v:Give("weapon_handcuffs_key")
			else
				local guns = {
					"weapon_winchester",
					"weapon_revolver2",
					"weapon_doublebarrel",
					"weapon_doublebarrel_short"
				}

				local weapon = v:Give(guns[math.random(#guns)], true)
				weapon:SetClip1(weapon:GetMaxClip1())
			end

			v:SetNetVar("CurPluv", "pluvfancy")

			local inv = v:GetNetVar("Inventory")
			inv["Weapons"] = inv["Weapons"] or {}
			inv["Weapons"]["hg_sling"] = true
			v:SetNetVar("Inventory",inv)
		end
	end,
	PoliceTime = 220,
	PoliceAllowed = false,
	SkillIssue = 3,
	PoliceEquipment = function(ply)
		ply:SetPlayerClass("police")
		local glock = ply:Give("weapon_glock17")
		ply:GiveAmmo(glock:GetMaxClip1() * 3,glock:GetPrimaryAmmoType(),true)
		if math.random(0, 1) == 1 then
			hg.AddAttachmentForce(ply, glock, "holo16")
		end

		if math.random(0, 1) == 1 then
			hg.AddAttachmentForce(ply, glock, "laser3")
		end

		ply:Give("weapon_medkit_sh")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_naloxone")
		ply:Give("weapon_painkillers")
		ply:Give("weapon_handcuffs")
		ply:Give("weapon_handcuffs_key")
		ply:Give("weapon_hg_tonfa")

		local gun = ply:Give("weapon_taser")
		ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)

		hg.AddArmor(ply, {"vest2"})

		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon( hands )

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)

		ply:SetNetVar("CurPluv", "pluvberet")

		zb.GiveRole(ply, "Police Officer", Color(15,15,255))
	end
}

local bangLootTable = {
	{50, {
		{8, "weapon_bandage_sh"},
		{6, "weapon_painkillers"},
		{5, "weapon_leadpipe"},
		{4, "weapon_hg_crowbar"},
		{3, "weapon_sogknife"},
	}},
	{50, {
		{12, "*ammo*"},
		{8, "weapon_revolver2"},
		{7, "weapon_revolver357"},
		{5, "weapon_doublebarrel_short"},
		{4, "weapon_doublebarrel"},
		{3, "weapon_winchester"},
	}},
}

MODE.Types.bang = {
	Chance = 0.04,
	MinPlayers = 4,
	KarmaDisabled = true,
	CanLaunch = function()
		return CanLaunchHomicideType("bang")
	end,
	ChanceFunction = function()
		return (CanLaunchHomicideType("bang") and zb.GetWorldSize() < ZBATTLE_BIGMAP)
			and (zb.ModesChances["bang"] or zb.modes["hmcd"].Types.bang.Chance) or 0
	end,
	LootTable = bangLootTable,
	Messages = {
		[3] = "총성이 멎었지만 승자는 없었습니다.",
		[1] = "무법자들이 마을을 장악했습니다.",
		[0] = "법 집행관들이 마을을 지켜냈습니다.",
	},
	Message = "BANG!",
	TraitorLoot = function() end,
	GunManLoot = function() end,
	PoliceTime = 99999,
	PoliceAllowed = false,
	SkillIssue = 3,
	PoliceEquipment = function() end,
}

MODE.BangRoleInfo = {
	sheriff = {name = "보안관", color = Color(220, 165, 35)},
	deputy = {name = "부관", color = Color(45, 125, 220)},
	outlaw = {name = "무법자", color = Color(195, 45, 25)},
	renegade = {name = "배신자", color = Color(145, 70, 175)},
}

MODE.BangCharacters = {
	"vulture_sam",
	"sid_ketchum",
	"bart_cassidy",
	"jourdonnais",
	"slab_killer",
	"el_gringo",
	"tequila_joe",
	"greg_digger",
	"vera_custer",
	"big_spencer",
	"mick_defender",
	"suzy_lafayette",
	"paul_regret",
	"sean_mallory",
}

local function GetBangAbilityCharacter(ply)
	if not IsValid(ply) then return "" end
	return ply.BangAbilityCharacter or ply.BangCharacter or ""
end

-- BANG! only places these medicine classes in its loot pool.  Keeping the
-- list beside the mode data prevents unrelated modes and items being changed.
MODE.BangMedicineClasses = {
	weapon_bandage_sh = true,
	weapon_painkillers = true,
}

local function SetBangMedicineMultiplier(wep, multiplier)
	if not IsValid(wep) or not MODE.BangMedicineClasses[wep:GetClass()] then return end
	if not istable(wep.modeValues) then return end

	local current = math.max(tonumber(wep.BangMedicineMultiplier) or 1, 0.01)
	multiplier = math.max(tonumber(multiplier) or 1, 0.01)
	if current == multiplier then return end

	for index, value in pairs(wep.modeValues) do
		if isnumber(value) then
			wep.modeValues[index] = value / current * multiplier
		end
	end

	wep.BangMedicineMultiplier = multiplier == 1 and nil or multiplier
	if wep.SetNetVar then wep:SetNetVar("modeValues", wep.modeValues) end
end

function MODE:ResetBangMedicineMultipliers()
	for class in pairs(self.BangMedicineClasses) do
		for _, wep in ipairs(ents.FindByClass(class)) do
			SetBangMedicineMultiplier(wep, 1)
		end
	end
end

local function GetBangRoleCounts(playerCount)
	local fixedCounts = {
		[4] = {1, 0, 2, 1},
		[5] = {1, 1, 2, 1},
		[6] = {1, 1, 3, 1},
		[7] = {2, 1, 3, 1},
		[8] = {2, 1, 3, 2},
		[9] = {2, 2, 3, 2},
		[10] = {3, 1, 4, 2},
	}

	local fixed = fixedCounts[playerCount]
	if fixed then return fixed[1], fixed[2], fixed[3], fixed[4] end

	local sheriffs = math.max(1, 1 + math.floor((playerCount - 4) / 3))
	local renegades = playerCount >= 8 and math.max(2, 2 + math.floor((playerCount - 8) / 6)) or 1
	local remaining = math.max(playerCount - sheriffs - renegades, 0)
	local outlaws = math.ceil(remaining * 0.65)
	local deputies = remaining - outlaws

	return sheriffs, deputies, outlaws, renegades
end

function MODE:SetupBangRoles()
	self.BangWinner = nil
	SetGlobalEntity("HMCD_BangSheriff", NULL)
	self:ResetBangMedicineMultipliers()

	local active = {}
	for _, ply in player.Iterator() do
		ply.BangRole = nil
		ply.BangCharacter = nil
		ply.BangAbilityCharacter = nil
		ply.BangDamageTaken = nil
		ply.BangBartCooldown = nil
		ply.BangBarrelCooldown = nil
		ply.BangSidCooldown = nil
		ply.BangSlabCooldown = nil
		ply.BangElGringoCooldowns = nil
		ply.BangGregCooldown = nil
		ply.BangMickCooldown = nil
		ply.BangPaulCooldown = nil
		ply.BangSuzyCooldown = nil
		ply.BangSuzyNextCheck = nil
		ply:SetNWBool("HMCD_BangSheriff", false)
		ply:SetNWString("HMCD_BangCharacter", "")
		ply:SetNWString("HMCD_BangAbilityCharacter", "")
	end

	for _, ply in RandomPairs(player.GetAll()) do
		if ply:Team() ~= TEAM_SPECTATOR then
			active[#active + 1] = ply
		end
	end

	for _, ply in ipairs(active) do
		ply.BangRole = nil
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
		ply:SetNWBool("HMCD_BangSheriff", false)
	end

	if not IsValid(active[1]) then return end

	local sheriffCount, deputyCount, outlawCount, renegadeCount = GetBangRoleCounts(#active)
	local cursor = 0
	local characterPool = table.Copy(self.BangCharacters)

	for sheriffIndex = 1, sheriffCount do
		cursor = cursor + 1
		local sheriff = active[cursor]
		if IsValid(sheriff) then
			sheriff.BangRole = "sheriff"
			sheriff.isGunner = true
			sheriff:SetNWBool("HMCD_BangSheriff", true)
			if sheriffIndex == 1 then SetGlobalEntity("HMCD_BangSheriff", sheriff) end
		end
	end

	for _ = 1, deputyCount do
		cursor = cursor + 1
		if IsValid(active[cursor]) then active[cursor].BangRole = "deputy" end
	end

	for _ = 1, outlawCount do
		cursor = cursor + 1
		local outlaw = active[cursor]
		if IsValid(outlaw) then
			outlaw.BangRole = "outlaw"
			outlaw.isTraitor = true
		end
	end

	for _ = 1, renegadeCount do
		cursor = cursor + 1
		if IsValid(active[cursor]) then active[cursor].BangRole = "renegade" end
	end

	for _, ply in ipairs(active) do
		if #characterPool == 0 then characterPool = table.Copy(self.BangCharacters) end
		local characterIndex = math.random(#characterPool)
		ply.BangCharacter = table.remove(characterPool, characterIndex)
		ply.BangAbilityCharacter = ply.BangCharacter
		ply:SetNWString("HMCD_BangCharacter", ply.BangCharacter)
		ply:SetNWString("HMCD_BangAbilityCharacter", ply.BangAbilityCharacter)
	end

	-- Vera copies one other living participant once.  The copied ability stays
	-- fixed for the round even if that participant dies later.
	for _, vera in ipairs(active) do
		if vera.BangCharacter == "vera_custer" then
			local candidates = {}
			for _, target in ipairs(active) do
				if target ~= vera and target.BangCharacter ~= "vera_custer" then
					candidates[#candidates + 1] = target
				end
			end

			local target = table.Random(candidates)
			if IsValid(target) then
				vera.BangAbilityCharacter = GetBangAbilityCharacter(target)
				vera:SetNWString("HMCD_BangAbilityCharacter", vera.BangAbilityCharacter)
			end
		end
	end

	self.TraitorExpectedAmt = outlawCount
end

local bangSidearms = {
	"weapon_revolver2",
	"weapon_revolver357",
	"weapon_doublebarrel_short",
}

function MODE:GiveBangEquipment(ply)
	local role = ply.BangRole
	local weaponClass = role == "sheriff" and "weapon_winchester" or table.Random(bangSidearms)
	local weapon = ply:Give(weaponClass, true)
	ply.BangPrimaryWeapon = IsValid(weapon) and weapon or nil

	if IsValid(weapon) then
		local maxClip = math.max(weapon:GetMaxClip1(), 1)
		weapon:SetClip1(maxClip)
		local ammoType = weapon:GetPrimaryAmmoType()
		if ammoType and ammoType >= 0 then
			local reserveMagazines = GetBangAbilityCharacter(ply) == "big_spencer" and 2 or 1
			ply:GiveAmmo(maxClip * reserveMagazines, ammoType, true)
		end
	end

	ply:Give("weapon_bandage_sh")
	if GetBangAbilityCharacter(ply) == "sean_mallory" then
		ply:Give("weapon_hg_type59_tpik")
	end
	if role == "sheriff" then
		ply:Give("weapon_handcuffs")
		ply:Give("weapon_handcuffs_key")
		ply:Give("weapon_painkillers")
	end

	local accessories = ply:GetNetVar("Accessories", {"none"})
	if istable(accessories) then
		accessories[1] = "stetson"
		ply:SetNetVar("Accessories", accessories)
	end
	ply:SetNetVar("CurPluv", "pluvfancy")
end

local function IsBangCombatantAlive(ply)
	-- BANG! elimination is death-based.  Incapacitation and handcuffs must not
	-- prematurely decide a hidden-role round while a rescue is still possible.
	return IsValid(ply) and ply:Alive()
end

function MODE:GetBangWinner()
	local alive = {sheriff = 0, deputy = 0, outlaw = 0, renegade = 0}
	local total = 0

	for _, ply in player.Iterator() do
		if ply.BangRole and IsBangCombatantAlive(ply) then
			alive[ply.BangRole] = (alive[ply.BangRole] or 0) + 1
			total = total + 1
		end
	end

	if alive.sheriff == 0 then
		if total == 1 and alive.renegade == 1 then return "renegade" end
		if alive.outlaw > 0 then return "outlaws" end
		return
	end

	if alive.outlaw == 0 and alive.renegade == 0 then return "law" end
end

util.AddNetworkString("HMCD_BangRoleReveal")
util.AddNetworkString("HMCD_BangRoundEnd")
util.AddNetworkString("HMCD_BangVultureCorpse")

local function ClearBangSheriffTags()
	SetGlobalEntity("HMCD_BangSheriff", NULL)

	for _, ply in player.Iterator() do
		ply:SetNWBool("HMCD_BangSheriff", false)
	end
end

hook.Add("ZB_PreRoundStart", "HMCD_ClearBangSheriffTags", ClearBangSheriffTags)

local function BangChatT(ply, key, fallback)
	if ZCLang and ZCLang.ChatPrint then
		ZCLang.ChatPrint(ply, key, fallback)
	elseif IsValid(ply) then
		ply:ChatPrint(fallback)
	end
end

local bangProtectedItems = {
	weapon_hands_sh = true,
	weapon_handcuffs = true,
	weapon_handcuffs_key = true,
}

local function IsBangFirearm(wep)
	if not IsValid(wep) then return false end
	local stored = weapons.GetStored(wep:GetClass()) or weapons.Get(wep:GetClass())
	if not stored then return false end
	return stored.Base == "homigrad_base" or (stored.Primary and stored.Primary.Ammo and stored.Primary.Ammo ~= "none")
end

local function GetBangDiscardableItems(ply)
	local items = {}
	for _, wep in ipairs(ply:GetWeapons()) do
		if not bangProtectedItems[wep:GetClass()] and not wep.NoDrop and not IsBangFirearm(wep) then
			items[#items + 1] = wep
		end
	end
	return items
end

local function RemoveBangItem(ply, wep)
	if not IsValid(ply) or not IsValid(wep) then return false end
	local class = wep:GetClass()
	ply:StripWeapon(class)
	if ply.inventory and ply.inventory.Weapons then
		ply.inventory.Weapons[class] = nil
		ply:SetNetVar("Inventory", ply.inventory)
	end
	return true
end

local function DropBangItem(ply, wep)
	if not IsValid(ply) or not IsValid(wep) then return false end
	local dropPos = ply:GetShootPos() + ply:GetAimVector() * 18
	ply:DropWeapon(wep)
	if IsValid(wep) then
		wep:SetPos(dropPos)
		wep:SetVelocity(ply:GetAimVector() * 60)
	end
	return true
end

local function GetBangDamagePlayer(ent)
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return ent end
	if ent:IsRagdoll() and hg and hg.RagdollOwner then
		local owner = hg.RagdollOwner(ent)
		if IsValid(owner) and owner:IsPlayer() then return owner end
	end
end

local function IsBangRoundActive()
	local round = CurrentRound and CurrentRound()
	return round and round.Type == "bang"
end

local function GetBangSuzyRefillWeapon(ply)
	local active = ply:GetActiveWeapon()
	local preferred
	local fallback

	for _, wep in ipairs(ply:GetWeapons()) do
		if not IsBangFirearm(wep) then continue end
		local maxClip = wep:GetMaxClip1()
		local ammoType = wep:GetPrimaryAmmoType()
		if maxClip <= 0 or not ammoType or ammoType < 0 then continue end

		fallback = fallback or wep
		if wep == active then preferred = wep end
		if wep:Clip1() > 0 or ply:GetAmmoCount(ammoType) > 0 then return end
	end

	return preferred or fallback
end

hook.Add("Think", "HMCD_BangSuzyLafayette", function()
	if not IsBangRoundActive() then return end

	local now = CurTime()
	for _, ply in player.Iterator() do
		if not ply:Alive() or GetBangAbilityCharacter(ply) ~= "suzy_lafayette" then continue end
		if (ply.BangSuzyNextCheck or 0) > now then continue end
		ply.BangSuzyNextCheck = now + 0.2
		if (ply.BangSuzyCooldown or 0) > now then continue end

		local wep = GetBangSuzyRefillWeapon(ply)
		if not IsValid(wep) then continue end
		local ammoType = wep:GetPrimaryAmmoType()
		local amount = math.max(wep:GetMaxClip1(), 1)
		if ammoType < 0 or amount <= 0 then continue end

		ply:GiveAmmo(amount, ammoType, true)
		ply.BangSuzyCooldown = now + 45
		BangChatT(ply, "bang_suzy_refilled", "탄약이 모두 소진되어 한 탄창을 가져왔습니다.")
	end
end)

hook.Add("WeaponEquip", "HMCD_BangTequilaJoeMedicine", function(wep, ply)
	if not IsValid(wep) or not IsValid(ply) or not MODE.BangMedicineClasses[wep:GetClass()] then return end

	-- InitializeAdd may fill modeValues during the same creation tick.
	timer.Simple(0, function()
		if not IsValid(wep) or not IsValid(ply) or wep:GetOwner() ~= ply then return end
		local multiplier = IsBangRoundActive() and GetBangAbilityCharacter(ply) == "tequila_joe" and 2 or 1
		SetBangMedicineMultiplier(wep, multiplier)
	end)
end)

hook.Add("PlayerDroppedWeapon", "HMCD_BangTequilaJoeMedicine", function(_, wep)
	SetBangMedicineMultiplier(wep, 1)
end)

local function SaveBangDeputyKarma(ply)
	if not IsValid(ply) or ply:IsBot() or not ply.ZB_BangDeputyKarmaDirty then return end
	if not ply.guilt_SetValue then return end

	ply:guilt_SetValue(ply.Karma or 100)
	ply.ZB_BangDeputyKarmaDirty = nil
end

local function QueueBangDeputyKarmaSave(ply)
	if not IsValid(ply) or ply:IsBot() then return end
	local timerName = "HMCD_BangDeputyKarmaSave_" .. ply:SteamID64()
	timer.Create(timerName, 5, 1, function()
		SaveBangDeputyKarma(ply)
	end)
end

local function ApplyBangDeputySheriffKarma(ply)
	if not IsValid(ply) then return end
	local damage = math.max(ply.ZB_BangDeputySheriffDamage or 0, 0)
	ply.ZB_BangDeputySheriffDamage = nil
	if damage <= 0 then return end

	local karmaPenalty = math.Clamp(damage * 2, 1, 20)
	ply.Karma = math.Clamp((ply.Karma or 100) - karmaPenalty, -60, zb.MaxKarma or 100)
	ply:SetNetVar("Karma", ply.Karma)
	if not ply:IsBot() then
		ply.ZB_BangDeputyKarmaDirty = true
		QueueBangDeputyKarmaSave(ply)
	end

	if (ply.ZB_BangDeputyKarmaNotice or 0) <= CurTime() then
		ply.ZB_BangDeputyKarmaNotice = CurTime() + 1
		BangChatT(ply, "bang_deputy_sheriff_karma", "보안관을 공격하여 카르마가 감소했습니다.")
	end
end

local function IsBangHeadshot(ply, dmgInfo)
	local body = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	local headBone = IsValid(body) and body:LookupBone("ValveBiped.Bip01_Head1")
	if headBone then
		local headPos = body:GetBonePosition(headBone)
		local damagePos = dmgInfo:GetDamagePosition()
		if headPos and damagePos and damagePos:DistToSqr(headPos) <= 324 then return true end
	end
	return not IsValid(ply.FakeRagdoll) and ply:LastHitGroup() == HITGROUP_HEAD
end

hook.Add("PlayerButtonDown", "HMCD_BangSidKetchum", function(ply, button)
	if button ~= KEY_G or not IsBangRoundActive() or GetBangAbilityCharacter(ply) ~= "sid_ketchum" or not ply:Alive() then return end
	if (ply.BangSidCooldown or 0) > CurTime() then
		BangChatT(ply, "bang_skill_cooldown", "능력을 아직 다시 사용할 수 없습니다.")
		return
	end

	local items = GetBangDiscardableItems(ply)
	if #items < 2 then
		BangChatT(ply, "bang_sid_needs_items", "사용하려면 비무기 소지품이 2개 필요합니다.")
		return
	end

	table.Shuffle(items)
	RemoveBangItem(ply, items[1])
	RemoveBangItem(ply, items[2])

	local org = ply.organism
	if org then
		for _, wound in pairs(org.wounds or {}) do
			if istable(wound) and isnumber(wound[1]) then wound[1] = wound[1] * 0.7 end
		end
		for _, wound in pairs(org.arterialwounds or {}) do
			if istable(wound) and isnumber(wound[1]) then wound[1] = wound[1] * 0.85 end
		end
		org.avgpain = math.max((org.avgpain or 0) * 0.7, 0)
		org.pain = math.max((org.pain or 0) * 0.7, 0)
		org.painadd = math.max((org.painadd or 0) * 0.7, 0)
		ply.fullsend = true
	end

	ply.BangSidCooldown = CurTime() + 45
	BangChatT(ply, "bang_sid_used", "소지품 2개를 버려 출혈과 통증을 완화했습니다.")
end)

hook.Add("PreHomigradDamage", "HMCD_BangJourdonnais", function(target, dmgInfo)
	if not IsBangRoundActive() or not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then return end
	local ply = GetBangDamagePlayer(target)
	if not IsValid(ply) or GetBangAbilityCharacter(ply) ~= "jourdonnais" or IsBangHeadshot(ply, dmgInfo) then return end
	if (ply.BangBarrelCooldown or 0) > CurTime() or math.random(100) > 20 then return end

	ply.BangBarrelCooldown = CurTime() + 25
	dmgInfo:SetDamage(0)
	dmgInfo:SetDamageForce(vector_origin)
	BangChatT(ply, "bang_jourdonnais_block", "술통이 총탄을 막아냈습니다.")
end)

hook.Add("PreHomigradDamage", "HMCD_BangBigSpencer", function(target, dmgInfo)
	if not IsBangRoundActive() or dmgInfo:GetDamage() <= 0 then return end
	local ply = GetBangDamagePlayer(target)
	if not IsValid(ply) or GetBangAbilityCharacter(ply) ~= "big_spencer" then return end

	dmgInfo:ScaleDamage(1.2)
end)

local bangMickProtectedHitgroups = {
	[HITGROUP_HEAD] = true,
	[HITGROUP_CHEST] = true,
	[HITGROUP_STOMACH] = true,
}

hook.Add("PreHomigradDamage", "HMCD_BangMickDefender", function(target, dmgInfo, hitgroup)
	if not IsBangRoundActive() or not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then return end
	if not bangMickProtectedHitgroups[hitgroup] then return end

	local ply = GetBangDamagePlayer(target)
	if not IsValid(ply) or GetBangAbilityCharacter(ply) ~= "mick_defender" then return end
	if (ply.BangMickCooldown or 0) > CurTime() then return end
	if math.random(100) > 20 then return end

	ply.BangMickCooldown = CurTime() + 15
	dmgInfo:SetDamage(0)
	dmgInfo:SetDamageForce(vector_origin)
end)

local BANG_PAUL_MIN_DISTANCE = 400
local BANG_PAUL_MAX_DISTANCE = 1600
local BANG_PAUL_MAX_BLOCK_CHANCE = 0.4

hook.Add("PreHomigradDamage", "HMCD_BangPaulRegret", function(target, dmgInfo)
	if not IsBangRoundActive() or not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then return end

	local ply = GetBangDamagePlayer(target)
	if not IsValid(ply) or GetBangAbilityCharacter(ply) ~= "paul_regret" then return end
	if (ply.BangPaulCooldown or 0) > CurTime() then return end

	local attacker = GetBangDamagePlayer(dmgInfo:GetAttacker())
	if not IsValid(attacker) or attacker == ply then return end

	local distance = attacker:GetPos():Distance(ply:GetPos())
	if distance <= BANG_PAUL_MIN_DISTANCE then return end

	local distanceFraction = math.Clamp((distance - BANG_PAUL_MIN_DISTANCE) /
		(BANG_PAUL_MAX_DISTANCE - BANG_PAUL_MIN_DISTANCE), 0, 1)
	local blockChance = distanceFraction * BANG_PAUL_MAX_BLOCK_CHANCE
	if math.Rand(0, 1) > blockChance then return end

	ply.BangPaulCooldown = CurTime() + 20
	dmgInfo:SetDamage(0)
	dmgInfo:SetDamageForce(vector_origin)
end)

hook.Add("EntityFireBullets", "HMCD_BangSlabKiller", function(shooter, bullet)
	if not IsBangRoundActive() or not IsValid(shooter) or not shooter:IsPlayer() then return end
	if GetBangAbilityCharacter(shooter) ~= "slab_killer" or (shooter.BangSlabCooldown or 0) > CurTime() then return end

	shooter.BangSlabCooldown = CurTime() + 20
	bullet.Penetration = (bullet.Penetration or 5) * 1.4
	bullet.BleedMultiplier = (bullet.BleedMultiplier or 1) * 1.25
	BangChatT(shooter, "bang_slab_fired", "강화탄이 발사되었습니다.")
end)

hook.Add("PostEntityTakeDamage", "HMCD_BangCharacterDamage", function(target, dmgInfo, tookDamage)
	if not tookDamage or not IsBangRoundActive() then return end
	local victim = GetBangDamagePlayer(target)
	if not IsValid(victim) then return end
	local damage = math.max(dmgInfo:GetDamage(), 0)
	if damage <= 0 then return end
	local attacker = dmgInfo:GetAttacker()

	-- BANG! keeps the normal karma system disabled. The sole exception is a
	-- deputy shooting a sheriff, which is persisted as a regular karma loss.
	if IsValid(attacker) and attacker:IsPlayer()
		and attacker ~= victim
		and attacker.BangRole == "deputy"
		and victim.BangRole == "sheriff"
		and dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then
		-- Buckshot pellets arrive as several damage callbacks in the same tick.
		-- Batch them so one shotgun blast cannot apply the cap several times.
		attacker.ZB_BangDeputySheriffDamage = (attacker.ZB_BangDeputySheriffDamage or 0) + damage
		local penaltyTimer = "HMCD_BangDeputyKarmaHit_" .. attacker:EntIndex()
		if not timer.Exists(penaltyTimer) then
			timer.Create(penaltyTimer, 0, 1, function()
				ApplyBangDeputySheriffKarma(attacker)
			end)
		end
	end

	if GetBangAbilityCharacter(victim) == "bart_cassidy" and victim:Alive() and (victim.BangBartCooldown or 0) <= CurTime() then
		victim.BangDamageTaken = (victim.BangDamageTaken or 0) + damage
		if victim.BangDamageTaken >= 35 then
			victim.BangDamageTaken = 0
			victim.BangBartCooldown = CurTime() + 30
			local active = victim:GetActiveWeapon()
			local ammoType = IsValid(active) and active:GetPrimaryAmmoType() or -1
			if victim:HasWeapon("weapon_bandage_sh") and ammoType >= 0 then
				victim:GiveAmmo(math.max(math.floor(math.max(active:GetMaxClip1(), 6) * 0.5), 3), ammoType, true)
			else
				victim:Give("weapon_bandage_sh")
			end
			BangChatT(victim, "bang_bart_reward", "피해를 버텨내고 붕대나 탄약을 얻었습니다.")
		end
	end

	if GetBangAbilityCharacter(victim) ~= "el_gringo" then return end
	if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end
	victim.BangElGringoCooldowns = victim.BangElGringoCooldowns or {}
	if (victim.BangElGringoCooldowns[attacker] or 0) > CurTime() or math.random(100) > 35 then return end

	local items = GetBangDiscardableItems(attacker)
	if #items == 0 then return end
	victim.BangElGringoCooldowns[attacker] = CurTime() + 20
	if DropBangItem(attacker, table.Random(items)) then
		BangChatT(victim, "bang_el_gringo_triggered", "공격자가 소지품 하나를 떨어뜨렸습니다.")
		BangChatT(attacker, "bang_el_gringo_attacker", "엘 그링고를 공격하여 소지품 하나를 떨어뜨렸습니다.")
	end
end)

function MODE:EndBangRound()
	local winner = self.BangWinner or self:GetBangWinner() or "draw"
	local roles = {}

	timer.Remove("HMCDSpawnSWAT")
	timer.Remove("SpawnAdditionalPolice")
	timer.Remove("SpawnAdditionalNationalGuard")
	self.deadPoliceCount = 0
	self.swatDeployed = false
	self.spawnedPoliceCount = 0
	self.roundStartType = nil

	for _, ply in player.Iterator() do
		if ply.BangRole then
			roles[#roles + 1] = {ply = ply, role = ply.BangRole}
		end
	end

	net.Start("HMCD_BangRoundEnd")
		net.WriteString(winner)
		net.WriteUInt(#roles, 8)
		for _, info in ipairs(roles) do
			net.WriteEntity(info.ply)
			net.WriteString(info.role)
		end
	net.Broadcast()

	for _, ply in player.Iterator() do
		ApplyBangDeputySheriffKarma(ply)
		SaveBangDeputyKarma(ply)
		timer.Remove("HMCD_BangDeputyKarmaHit_" .. ply:EntIndex())
		if not ply:IsBot() then
			timer.Remove("HMCD_BangDeputyKarmaSave_" .. ply:SteamID64())
		end
		ply.ZB_BangDeputyKarmaDirty = nil
		ply.ZB_BangDeputyKarmaNotice = nil
		ply.BangRole = nil
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
		ply.BangPrimaryWeapon = nil
		ply.BangCharacter = nil
		ply.BangAbilityCharacter = nil
		ply.BangGregCooldown = nil
		ply.BangMickCooldown = nil
		ply.BangPaulCooldown = nil
		ply.BangSuzyCooldown = nil
		ply.BangSuzyNextCheck = nil
		ply:SetNWString("HMCD_BangCharacter", "")
		ply:SetNWString("HMCD_BangAbilityCharacter", "")
		ply:SetNWBool("HMCD_BangSheriff", false)
	end

	self:ResetBangMedicineMultipliers()

	ClearBangSheriffTags()
	self.BangWinner = nil
end

hook.Add("PlayerDeath", "HMCD_BangDeathRules", function(victim, inflictor, attacker)
	local round = CurrentRound and CurrentRound()
	if not round or round.Type ~= "bang" or not victim.BangRole then return end

	net.Start("HMCD_BangRoleReveal")
		net.WriteEntity(victim)
		net.WriteString(victim.BangRole)
	net.Broadcast()

	for _, greg in player.Iterator() do
		if greg ~= victim and greg:Alive() and GetBangAbilityCharacter(greg) == "greg_digger" and (greg.BangGregCooldown or 0) <= CurTime() then
			local oldHealth = greg:Health()
			local org = greg.organism
			local oldBlood = org and (org.blood or 5000) or 5000
			greg:SetHealth(math.min(oldHealth + 5, greg:GetMaxHealth()))
			if org then
				org.health = greg:Health()
				org.blood = math.min(oldBlood + 150, 5000)
				greg.fullsend = true
			end
			if greg:Health() > oldHealth or (org and org.blood > oldBlood) then
				greg.BangGregCooldown = CurTime() + 30
				BangChatT(greg, "bang_greg_healed", "다른 참가자가 제거되어 체력과 혈액을 회복했습니다.")
			end
		end
	end

	timer.Simple(0.2, function()
		if not IsValid(victim) then return end
		for _, ply in player.Iterator() do
			if GetBangAbilityCharacter(ply) == "vulture_sam" and ply:Alive() then
				net.Start("HMCD_BangVultureCorpse")
					net.WriteEntity(victim)
				net.Send(ply)
			end
		end
	end)

	if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end

	if victim.BangRole == "deputy" and attacker.BangRole == "sheriff" then
		timer.Simple(0, function()
			if not IsValid(attacker) or not attacker:Alive() then return end
			attacker:StripWeapons()
			attacker:RemoveAllAmmo()
			attacker:Give("weapon_hands_sh")
			attacker:SelectWeapon("weapon_hands_sh")
			BangChatT(attacker, "bang_penalty_deputy", "부관을 죽인 벌로 모든 무기와 탄약을 잃었습니다.")
		end)
	elseif victim.BangRole == "outlaw" then
		local activeWeapon = attacker:GetActiveWeapon()
		if IsValid(activeWeapon) then
			local ammoType = activeWeapon:GetPrimaryAmmoType()
			if ammoType and ammoType >= 0 then
				attacker:GiveAmmo(math.max(activeWeapon:GetMaxClip1(), 6), ammoType, true)
			end
		end
		attacker:Give("weapon_bandage_sh")
		BangChatT(attacker, "bang_reward_outlaw", "무법자를 처치하여 탄약과 붕대를 얻었습니다.")
	end
end)

MODE.Types.gunfreezone = {
	Chance = 0.05,
	ChanceFunction = function() return (zb.GetWorldSize() < ZBATTLE_BIGMAP) and (zb.ModesChances["gunfreezone"] or zb.modes["hmcd"].Types.gunfreezone.Chance) or 0 end,
	LootTable = MODE.LootTableStandard,
	Messages = {
        [3] = "모두 사망했습니다.",
        [1] = "살인마가 모두를 살해했습니다.",
        [0] = "살인마가",
	},
	Message = "The murderer was ",
	TraitorLoot = function(ply)
		ply:Give("weapon_buck200knife")
		ply:Give("weapon_hg_type59_tpik")
		ply:Give("weapon_adrenaline")
		ply:Give("weapon_hg_shuriken")
		ply:Give("weapon_hg_smokenade_tpik")
		ply:Give("weapon_traitor_ied")
		ply:Give("weapon_traitor_poison1")
		ply:Give("weapon_traitor_poison2")
		ply:Give("weapon_traitor_poison3")
		ply:Give("weapon_traitor_poison_consumable")
		ply:Give("weapon_traitor_suit")

		local wep = ply:Give("weapon_zoraki")
		timer.Simple(1,function() wep:ApplyAmmoChanges(2) end)

		ply.organism.stamina.range = 220

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
	end,
	GunManLoot = function(ply)
	end,
	PoliceTime = 120,
	PoliceAllowed = true,
	SkillIssue = 4,
	PoliceEquipment = function(ply)
		ply:SetPlayerClass("police")
		local glock = ply:Give("weapon_glock17")
		ply:GiveAmmo(glock:GetMaxClip1() * 3,glock:GetPrimaryAmmoType(),true)
		if math.random(0, 1) == 1 then
			hg.AddAttachmentForce(ply, glock, "holo16")
		end

		if math.random(0, 1) == 1 then
			hg.AddAttachmentForce(ply, glock, "laser3")
		end

		ply:Give("weapon_medkit_sh")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_naloxone")
		ply:Give("weapon_painkillers")
		ply:Give("weapon_handcuffs")
		ply:Give("weapon_handcuffs_key")
		ply:Give("weapon_hg_tonfa")

		local gun = ply:Give("weapon_taser")
		ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)

		hg.AddArmor(ply, {"vest2"})

		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon( hands )

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
		ply.organism.recoilmul = 0.8

		zb.GiveRole(ply, "Police Officer", Color(15,15,255))

		ply:SetNetVar("CurPluv", "pluvberet")
	end
}

MODE.Types.soe = {
	Chance = 0.2,
	ChanceFunction = function() return (zb.GetWorldSize() >= ZBATTLE_BIGMAP) and (zb.ModesChances["soe"] or zb.modes["hmcd"].Types.soe.Chance) or 0 end,
	LootTable = MODE.LootTable,
	Messages = {
        [3] = "모두 사망했습니다.",
        [1] = "배신자가 모두를 살해했습니다.",
        [0] = "배신자가",
	},
	Message = "The traitor was ",
	TraitorLoot = function(ply)
		local p22 = ply:Give("weapon_p22")
		hg.AddAttachmentForce(ply,p22,"supressor4")
		ply:Give("weapon_sogknife")
		ply:Give("weapon_hg_type59_tpik")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_adrenaline")
		ply:Give("weapon_hg_smokenade_tpik")
		ply:Give("weapon_traitor_ied")
		ply:Give("weapon_traitor_poison2")
		ply:Give("weapon_traitor_poison3")
		ply:Give("weapon_traitor_poison_consumable")
		ply.organism.recoilmul = 1
		ply.organism.stamina.range = 220

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
	end,
	GunManLoot = function(ply)
		local gun = ply:Give( ( math.random(1,2) > 1 and "weapon_remington870" ) or "weapon_kar98" )
		ply.organism.recoilmul = 1.0
		if gun:GetClass() == "weapon_kar98" then
			hg.AddAttachmentForce(ply,gun,"optic12")
		end
		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory",inv)

		ply:SetNetVar("CurPluv", "pluvboss")
	end,
	PoliceTime = 250,
	PoliceAllowed = true,
	SkillIssue = 3,
	PoliceEquipment = function(ply)
		local inv = ply:GetNetVar("Inventory") or {}
		inv["Weapons"] = inv["Weapons"] or {}
		inv["Weapons"]["hg_flashlight"] = true
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory", inv)
	
		ply:SetPlayerClass("nationalguard")
		local gun = ply:Give("weapon_fn45")
		ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
	
		gun = ply:Give("weapon_hk416")
		ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
		hg.AddAttachmentForce(ply, gun, {"holo14", "laser3", "grip3"})
	
		ply:Give("weapon_hg_grenade_tpik")
		ply:Give("weapon_melee")
	
		ply:Give("weapon_medkit_sh")
		ply:Give("weapon_bandage_sh")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_painkillers")
		ply:Give("weapon_morphine")
	
		ply.organism.recoilmul = 0.5
	
		ply:Give("weapon_handcuffs")
		ply:Give("weapon_handcuffs_key")
	
		gun = ply:Give("weapon_taser")
		ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
	
		hg.AddArmor(ply, {"vest4", "helmet1"})
	
		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon(hands)
	
		zb.GiveRole(ply, "National Guard", Color(55, 85, 0))
		ply:SetNetVar("CurPluv", "pluvberet")
	end,
	PoliceText = "National guards have arrived.",
	PoliceSound = "snd_jack_hmcd_heli2.mp3"
}

local modes = {
	"soe",
	"standard",
	"wildwest",
	"bang",
	"gunfreezone",
}

util.AddNetworkString("HMCD_RoundStart")

function MODE:GetPlySpawn(ply)
end

function MODE:SubModes()
	return modes
end

function MODE:Intermission()
	local _, roundKey = CurrentRound()
	-- Capture the selected subtype before cleanup hooks can touch round state.
	game.CleanUpMap()

	local forcedRound = zb.IsRoundForced and zb.IsRoundForced(roundKey)
	local CROUND = roundKey

	if not CROUND or CROUND == "hmcd" then
		-- hmcd is the Homicide container, not the Active Shooter subtype.
		-- Prefer the launchable subtype selected by the Homicide rotation.
		CROUND = forcedRound and "standard" or FindLaunchableHomicideType() or "standard"
	end

	local typeData = self.Types and self.Types[CROUND]
	if not forcedRound and typeData and typeData.MinPlayers and GetActiveHomicidePlayerCount() < typeData.MinPlayers then
		CROUND = FindLaunchableHomicideType() or "standard"
	end

	self.Type = CROUND
	print("[HMCD] Intermission selected=" .. tostring(roundKey) .. " resolved=" .. tostring(self.Type) .. " active=" .. tostring(GetActiveHomicidePlayerCount()))
	local player_count = 0

	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply:KillSilent()

		ply.isPolice = false
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
		ply.SubRole = nil
		ply.Profession = nil

		ply:SetupTeam(0)

		ply.organism.recoilmul = DefaultSkillIssue
		player_count = player_count + 1
	end

	MODE.TraitorFrequency = nil
	MODE.TraitorWord = nil
	MODE.TraitorWordSecond = nil
	EnsureTraitorWords()
	local traitors_needed = 1
	
	if(MODE.ShouldStartRoleRound())then
		traitors_needed = math.ceil(player_count / 9)
		
		if(player_count > 8 and math.random(1, 8) == 1)then
			traitors_needed = traitors_needed + 1
		end
	end

	MODE.TraitorExpectedAmt = traitors_needed
	local main_traitor = nil
	local traitors = {}

	-- local players = {}
	-- for i, ply in player.Iterator() do
	-- 	if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end

	-- 	players[#players + 1] = {ply, ply.Karma}
	-- end
	
	-- -- potom
	
	for i, ply in RandomPairs(player.GetAll()) do
		if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end
		if self.Type ~= "bang" and math.random(100) > (ply.Karma or 100) then continue end

		if traitors_needed > 0 then
			ply.isTraitor = true
			traitors_needed = traitors_needed - 1
			traitors[#traitors + 1] = ply

			main_traitor = ply
			ply.MainTraitor = true
		end
	end

	//MODE.NextRoundMainTraitors = MODE.NextRoundMainTraitors or {}
	for i, ply in RandomPairs(player.GetAll()) do
		if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end
		//if not MODE.NextRoundMainTraitors[ply:SteamID()] then continue end

		if traitors_needed > 0 then
			ply.isTraitor = true
			traitors_needed = traitors_needed - 1
			traitors[#traitors + 1] = ply
			
			if not main_traitor then
				main_traitor = ply
				ply.MainTraitor = true
			end
		end
	end

	if traitors_needed > 0 then
		for i, ply in RandomPairs(player.GetAll()) do
			if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end

			if traitors_needed > 0 then
				ply.isTraitor = true
				traitors_needed = traitors_needed - 1
				traitors[#traitors + 1] = ply

				if not main_traitor then
					main_traitor = ply
					ply.MainTraitor = true
				end
			end
		end
	end

	if self.Type == "bang" then
		self:SetupBangRoles()
	end

	self.saved.PoliceTime = CurTime() + math.min(self.Types[self.Type].PoliceTime * (#player.GetAll() / 4),self.Types[self.Type].PoliceTime * 2.2)
	self.PoliceSpawned = false
	self.PoliceAllowed = self.Types[self.Type].PoliceAllowed

	for k, ply in player.Iterator() do
		if(MODE.ShouldStartRoleRound())then
			net.Start("HMCD_RoundStart")	--; TODO Structure description
				net.WriteBool(ply.isTraitor)	--; Is Traitor
				net.WriteBool(ply.isGunner)	--; Is Gunner
				net.WriteString(self.Type)	--; Round Type
				net.WriteBool(false)	--; Round Started
				net.WriteString("")	--; SubRole
				net.WriteBool(ply.MainTraitor == true)	--; MainTraitor

			if(ply.isTraitor)then
				local traitorWord, traitorWordSecond = EnsureTraitorWords()
				net.WriteString(traitorWord)
				net.WriteString(traitorWordSecond)
					net.WriteUInt(MODE.TraitorExpectedAmt, MODE.TraitorExpectedAmtBits)
				else
					net.WriteString("")
					net.WriteString("")
					net.WriteUInt(0, MODE.TraitorExpectedAmtBits)
				end
				
				net.WriteString("")	--; Profession
				if self.Type == "bang" then
					net.WriteString(ply.BangRole or "")
					net.WriteString(ply.BangCharacter or "")
				end
			net.Send(ply)

			local role = self.Roles[self.Type][(ply.isTraitor and "traitor") or (ply.isGunner and "gunner") or "innocent"]

			zb.GiveRole(ply, role.name, role.color)
		end
	end

	--local pts = zb.GetMapPoints( "RandomSpawns" )
	
	local ent = ents.Create("prop_ragdoll")
	local appearance = hg.Appearance.GetRandomAppearance()
	
	local tMdl = hg.Appearance.PlayerModels[1][appearance.AModel] or hg.Appearance.PlayerModels[2][appearance.AModel] or appearance.AModel
	local mdl = istable(tMdl) and tMdl.mdl or tMdl
	
	ent:SetModel(mdl)
	
	for i, ply in RandomPairs(player.GetAll()) do
		ent:SetPos(ply:EyePos() + vector_up * 72)
	end

	--[[local forced = false
	local cntr = 32
	for i, point in RandomPairs(pts) do
		cntr = cntr - 1
		if cntr < 0 then forced = true end

		local pos = point.pos
		local tr = {}
		tr.start = pos
		tr.endpos = pos
		tr.mins = Vector(-16, -16, 0)
		tr.maxs = Vector(16, 16, 16)
		tr.collisiongroup = COLLISION_GROUP_WORLD

		local trace = util.TraceHull(tr)
		if !trace.Hit or forced then
			ent:SetPos(pos)
			
			break
		end
	end--]]

	ent:SetAngles(AngleRand(-180, 180))
	ent:Spawn()
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	hg.organism.Add(ent)
	hg.organism.Clear(ent.organism)
	ent.organism.fakePlayer = true
	hg.Appearance.ForceApplyAppearance(ent, appearance)
	ent.organism.alive = false
	ent.organism.o2[1] = 0
	ent.organism.pulse = 0

	for physNum = 0, ent:GetPhysicsObjectCount() - 1 do
		local phys = ent:GetPhysicsObjectNum(physNum)
		local bone = ent:TranslatePhysBoneToBone(physNum)
		if bone < 0 then continue end
		
		phys:SetMass(hg.IdealMassPlayer[ent:GetBoneName(bone)] or 4)
		phys:SetPos(ent:GetPos() + VectorRand(-32, 32))
	end

	if self.Type == "wildwest" or self.Type == "bang" then
		local Appearance = ent:GetNetVar("Accessories", {"none"})

		if istable(Appearance) then
			Appearance[1] = "stetson"
		else
			Appearance = "stetson"
		end
	
		ent:SetNetVar("Accessories", Appearance)
		local sex = ThatPlyIsFemale(ent) and 2 or 1
		local tbl = ent.CurAppearance
		tbl.AClothes["main"] = "formal"
		tbl.AClothes["pants"] = "formal"
		tbl.AClothes["boots"] = "formal"
		tbl.AColor = Color(1 * 255,0.690196 * 255,0.537255 * 255)
		hg.Appearance.ForceApplyAppearance(ent, tbl)

		for i = 1, 5 do
			hg.organism.AddWoundManual(ent, 50, vector_origin, angle_zero,"ValveBiped.Bip01_Head1", CurTime() + 2)
		end
	end
end

--[[concommand.Add("hmcd_call_police", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("loh.")
        return
    end

    if not MODE or not MODE.saved then
        print("fake")
        return
    end

    MODE.saved.PoliceTime = CurTime() - 1
    print("true")
end)--]]

function MODE:CheckAlivePlayers()
	local AlivePlyTbl = {
		[0] = {},
		[1] = {}
	}
	
	for _, ply in player.Iterator() do
		if(not ply:Alive())then
			continue
		end
		
		if((not ply.isTraitor)and ply.organism and ply.organism.incapacitated)then
			continue
		end
		
		if ply.isTraitor and not ply:GetNetVar("handcuffed",false) then
			--print(ply)
			AlivePlyTbl[1][#AlivePlyTbl[1] + 1] = ply
		elseif(not ply.isPolice)then
			AlivePlyTbl[0][#AlivePlyTbl[0] + 1] = ply
		end
	end
	
	return AlivePlyTbl
end
	
local deadPoliceCount = 0
local swatDeployed = false

function MODE:GetActivePlayers()
	local valid = {}

	for _, ply in player.Iterator() do
		if ply:Alive() then continue end                        
		if ply:Team() == TEAM_SPECTATOR then continue end       
		if ply.afkTime2 and ply.afkTime2 > 60 then continue end 

		valid[#valid + 1] = ply
	end

	return valid
end


MODE.deadPoliceCount = MODE.deadPoliceCount or 0
MODE.swatDeployed = MODE.swatDeployed or false
MODE.spawnedPoliceCount = MODE.spawnedPoliceCount or 0
MODE.roundStartType = MODE.roundStartType or nil

function MODE:RoundThink()
	if not self.PoliceAllowed then return end

	if self.Type ~= "soe" and not self.PoliceSpawned and self.saved.PoliceTime < CurTime() then
		if not self.Types[self.Type] or not self.Types[self.Type].PoliceAllowed then return end
		
		local available = self:GetActivePlayers()
		local max = math.min(#available, 4)
	
		if max > 0 then
			local spawned = self:SpawnForce("police", max)
			self.spawnedPoliceCount = spawned
	
			if spawned > 0 then
				self.PoliceSpawned = true
				PrintMessage(HUD_PRINTTALK, "Police have arrived.")
				EmitSound("snd_jack_hmcd_policesiren.wav", vector_origin, 0, CHAN_AUTO, 1, 125, 0, 100)
			end
		end
	end
	

	if self.Type ~= "soe" and not self.swatDeployed and self.deadPoliceCount >= (self.spawnedPoliceCount or 4) and self.spawnedPoliceCount > 0 then
		if not self.Types[self.Type] or not self.Types[self.Type].PoliceAllowed then return end
		
		self.swatDeployed = true
		local currentType = self.Type 
		
		timer.Create("HMCDSpawnSWAT", 60, 1, function()
			if zb.ROUND_STATE ~= 1 or not MODE or MODE.Type ~= currentType then return end 
			
			if not MODE.Types[MODE.Type] or not MODE.Types[MODE.Type].PoliceAllowed then return end
			
			local available = MODE:GetActivePlayers()
			local count = math.min(#available, 5)
	
			if count > 0 then
				PrintMessage(HUD_PRINTTALK, "SWAT 팀이 진입합니다!")
				EmitSound("snd_jack_hmcd_heli2.mp3", vector_origin, 0, CHAN_AUTO, 1, 125, 0, 100)
				MODE:SpawnForce("swat", count)
			end
		end)
	end
	
	if self.Type == "soe" and not self.PoliceSpawned and self.saved.PoliceTime < CurTime() then
		local available = self:GetActivePlayers()
		local count = math.min(#available, 6)
	
		if count > 0 then
			local spawned = self:SpawnForce("nationalguard", count)
			if spawned > 0 then
				self.PoliceSpawned = true
				PrintMessage(HUD_PRINTTALK, self.Types[self.Type].PoliceText or "National Guard have arrived.")
				EmitSound(self.Types[self.Type].PoliceSound or "snd_jack_hmcd_heli2.mp3", vector_origin, 0, CHAN_AUTO, 1, 125, 0, 100)
			end
		end
	end
end

function MODE:SpawnForce(teamtype, count)
    local spawned = 0
    local basepos = nil

    for i, ply in RandomPairs(player.GetAll()) do
        if ply:Alive() or ply.isTraitor or ply:Team() == TEAM_SPECTATOR or ply.afkTime2 > 60 then continue end
        if spawned >= count then break end

        ply.isPolice = true
        ply.isTraitor = false
        ply.isGunner = false
        ply:Spawn()

        if not basepos then
            basepos = zb:GetRandomSpawn()            
			ply:SetPos(basepos)
		else
			hg.tpPlayer(basepos, ply, i)
		end

        if teamtype == "police" then
            self.Types[self.Type].PoliceEquipment(ply)
        elseif teamtype == "swat" then
            self:EquipSWAT(ply, spawned + 1)
        elseif teamtype == "nationalguard" then
            self:EquipNationalGuard(ply, spawned + 1)
        end

        spawned = spawned + 1
    end

    return spawned
end

local function tbl_Random(tbl) -- when you can't even say
	return tbl[math.random(#tbl)] -- my name
end
function MODE:EquipSWAT(ply, index)
    ply:SetPlayerClass("swat")
    
    local classes = {
        [1] = function() return tbl_Random({"weapon_m4a1", "weapon_hk416"}) end, --;; Team Leader
        [2] = function() ply:Give("weapon_ram") return tbl_Random({"weapon_remington870", "weapon_m590a1"}) end, --;; Breacher
        [3] = function() return "weapon_mp5" end, --;; Pointman
        [4] = function() return "weapon_sr25" end, --;; Marksman
        [5] = function()
            ply:Give("weapon_medkit_sh")
            ply:Give("weapon_painkillers")
            ply:Give("weapon_adrenaline")
            ply:Give("weapon_needle")
            ply:Give("weapon_bigbandage_sh")
            ply:Give("weapon_bandage_sh")
            ply:Give("weapon_mannitol")
            return "weapon_m4a1"
        end
    }

    local mainWep = classes[index] and classes[index]() or "weapon_m4a1"
    local pistol = ply:Give("weapon_glock17")
	ply:GiveAmmo(pistol:GetMaxClip1() * 3, pistol:GetPrimaryAmmoType(), true)
    local gun = ply:Give(mainWep)
    ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)

    ply:Give("weapon_melee")
    ply:Give("weapon_handcuffs")
    ply:Give("weapon_handcuffs_key")
    ply:Give("weapon_hg_flashbang_tpik")

	local gun = ply:Give("weapon_taser")
	ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(),true)

	hg.AddArmor(ply, {"helmet6", "vest8", tbl_Random({"mask1", "mask2", "nightvision1"})})

    local inv = ply:GetNetVar("Inventory") or {}
    inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_sling"] = true
    inv["Weapons"]["hg_flashlight"] = true
    ply:SetNetVar("Inventory", inv)
	ply:SetNetVar("flashlight", false)

    ply.organism.recoilmul = 0.6

    ply:SetNetVar("CurPluv", "pluvberet")
    local hands = ply:Give("weapon_hands_sh")
    ply:SetActiveWeapon(hands)

    zb.GiveRole(ply, "SWAT Operative", Color(30, 30, 100))
end

function MODE:EquipNationalGuard(ply, index)
    ply:SetPlayerClass("nationalguard")
    local gun

    if index == 1 then
        gun = ply:Give("weapon_m249")
    else
        gun = ply:Give("weapon_m4a1")
    end

    ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
	local pistol = ply:Give("weapon_m9beretta")
	ply:GiveAmmo(pistol:GetMaxClip1() * 3, pistol:GetPrimaryAmmoType(), true)
    ply:Give("weapon_melee")
    ply:Give("weapon_handcuffs")
    ply:Give("weapon_handcuffs_key")
    ply:Give("weapon_walkie_talkie")
    ply:Give("weapon_bandage_sh")
    ply:Give("weapon_medkit_sh")

	local gun = ply:Give("weapon_taser")
	ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)

    hg.AddArmor(ply, {"vest4", "helmet1"})

	local inv = ply:GetNetVar("Inventory") or {}
	inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_flashlight"] = true
	inv["Weapons"]["hg_sling"] = true
	ply:SetNetVar("Inventory", inv)

	ply:SetNetVar("CurPluv", "pluvberet")
    local hands = ply:Give("weapon_hands_sh")
    ply:SetActiveWeapon(hands)
    zb.GiveRole(ply, "National Guard", Color(60, 90, 0))
end

--\\
MODE.ChoosingPlayersList = MODE.ChoosingPlayersList or {}

local gaymaps = {
	["zs_shelter"] = true,
	["gm_sirenmine_v2"] = true,
}

function MODE.StartPlayersRoleSelection()
	MODE.RoleChooseRound = true
	MODE.StartRoundTime = MODE.StartRoundTime + MODE.RoleChooseRoundStartTime

	for _, ply in player.Iterator() do
		if(ply.isTraitor and ply.MainTraitor)then	--; REDO
			net.Start("HMCD(StartPlayersRoleSelection)")
				net.WriteString("Traitor")
			net.Send(ply)

			MODE.ChoosingPlayersList[ply] = true
		end
	end
end

net.Receive("HMCD(StartPlayersRoleSelection)", function(len, ply)
	if(MODE.ChoosingPlayersList[ply])then
		MODE.ChoosingPlayersList[ply] = nil

		if(table.IsEmpty(MODE.ChoosingPlayersList))then
			MODE.StartRoundTime = 0
		end
	end
end)
// ...


util.AddNetworkString("HMCD_TraitorDeathState")
util.AddNetworkString("HMCD_RequestTraitorStatuses")


function MODE:SendTraitorDeathState(traitor, is_alive)
    if not traitor.CurAppearance then return end
    local name = traitor.CurAppearance.AName
    

    local recipients = {}
    for _, ply in player.Iterator() do
        if ply.isTraitor and ply.MainTraitor then
            table.insert(recipients, ply)
        end
    end
    
    net.Start("HMCD_TraitorDeathState")
    net.WriteString(name)
    net.WriteBool(is_alive)
    net.Send(recipients)
end


hook.Add("PlayerDeath", "HMCD_TraitorDeathTracking", function(ply, _)
    if ply.isTraitor then
        MODE:SendTraitorDeathState(ply, false)
    end
end)


hook.Add("PlayerSpawn", "HMCD_TraitorSpawnTracking", function(ply)
    if ply.isTraitor then
        MODE:SendTraitorDeathState(ply, true)
    end
end)

hook.Add("PlayerCanPickupWeapon", "HMCD_TraitorRadioPickup", function( ply, weapon )
    if ply.isTraitor and weapon:GetClass() == "weapon_walkie_talkie" then
        if ply:HasWeapon("weapon_walkie_talkie") then
            weapon:Remove()
			ply:SetActiveWeapon("weapon_walkie_talkie")
			ply:ChatPrint("You hide the additional walkie talkie.")
        end
    end
end)

net.Receive("HMCD_RequestTraitorStatuses", function(len, ply)
    if not ply.isTraitor or not ply.MainTraitor then return end
    

    for _, other_ply in player.Iterator() do
        if other_ply.isTraitor and other_ply.CurAppearance then
            local is_alive = other_ply:Alive() and (not other_ply.organism or not other_ply.organism.incapacitated)
            
            net.Start("HMCD_TraitorDeathState")
            net.WriteString(other_ply.CurAppearance.AName)
            net.WriteBool(is_alive)
            net.Send(ply)
        end
    end
end)
// ...

function MODE.ShouldStartRoleRound()
	do return false end
	return MODE.RoleChooseRoundTypes[MODE.Type] and GetGlobalBool("RolesPlus_Enable", false)
end
--//

function MODE:ShouldRoundEnd()
	if (self.RoundStartedAt or 0) + 3 > CurTime() then
		return false
	end

	if self.Type == "bang" then
		self.BangWinner = self:GetBangWinner()
		return self.BangWinner ~= nil
	end

	if(MODE.StartRoundTime and MODE.RoleChooseRound)then
		if(MODE.StartRoundTime > CurTime())then
			return false
		else
			MODE.StartRoundTime = nil

			net.Start("HMCD(EndPlayersRoleSelection)")
			net.Broadcast()
			MODE.SpawnPlayers(true)
		end
	else
		local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

		if(endround)then
			MODE.ChoosingPlayersList = {}
		end

		return endround
	end
end

function MODE:RoundStart()
	local _, selectedType = CurrentRound()
	print("[HMCD] RoundStart selected=" .. tostring(selectedType) .. " resolved=" .. tostring(self.Type) .. " active=" .. tostring(GetActiveHomicidePlayerCount()))

	local roles_choose = MODE.ShouldStartRoleRound()
	MODE.StartRoundTime = CurTime()
	MODE.RoleChooseRound = false
	self.RoundStartedAt = CurTime()
	

	self.roundStartType = self.Type
	

	self.deadPoliceCount = 0
	self.swatDeployed = false
	self.spawnedPoliceCount = 0
	

	timer.Remove("HMCDSpawnSWAT")
	
	if(roles_choose)then
		MODE.StartPlayersRoleSelection()
		PrintMessage(HUD_PRINTTALK, "Traitor is choosing roles for " .. MODE.RoleChooseRoundStartTime ..  " seconds")
	else
		MODE.ChoosingPlayersList = {}

		MODE.SpawnPlayers(true)
	end
end

function MODE:GiveEquipment()
end

function MODE:CanSpawn()
end

util.AddNetworkString("hmcd_roundend")

function MODE:EndRound()
	if self.Type == "bang" then
		self:EndBangRound()
		return
	end

	timer.Remove("HMCDSpawnSWAT")
	timer.Remove("SpawnAdditionalPolice")
    timer.Remove("SpawnAdditionalNationalGuard")
	

	self.deadPoliceCount = 0
	self.swatDeployed = false
	self.spawnedPoliceCount = 0
	self.roundStartType = nil

	local traitors, gunners = {}, {}
	local players_alive = 0
	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

	-- for _, ply in player.Iterator() do	--; Extreme optimization
		-- ply.SubRole = nil
	-- end

	for i, ply in player.Iterator() do
		if ply.isTraitor and ply:Team() ~= TEAM_SPECTATOR then
			traitors[#traitors + 1] = ply
		end
		
		if ply.isGunner and ply:Team() ~= TEAM_SPECTATOR then
			gunners[#gunners + 1] = ply
		end
		
		if(ply:Alive() and ply.organism and !ply.organism.incapacitated)then
			players_alive = players_alive + 1
		end

		ply.isPolice = false
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
		ply.SubRole = nil
		ply.Profession = nil
	end
	
	if(not winner)then
		net.Start("hmcd_roundend")
			net.WriteUInt(#traitors, MODE.TraitorExpectedAmtBits)
			
			for _, traitor in ipairs(traitors) do
				net.WriteEntity(traitor)
			end
			
			net.WriteUInt(#gunners, MODE.TraitorExpectedAmtBits)
			
			for _, gunner in ipairs(gunners) do
				net.WriteEntity(gunner)
			end
		net.Broadcast()
		
		return
	end

	if self.Type then
		if(MODE.RoleChooseRound)then
			if(winner ~= 1)then
                PrintMessage(HUD_PRINTTALK, "모든 배신자가 저지되었습니다.")
                
                for _, traitor in ipairs(traitors) do
                    net.Start("hmcd_announce_traitor_lose")
                        net.WriteEntity(traitor)
                        net.WriteBool(traitor:Alive())
                    net.Broadcast()
                    
                    hook.Run("ZB_TraitorWinOrNot", traitor, winner)
                end

                for _, traitor in ipairs(traitors) do
                    traitor:GiveSkill( -math.Rand(0.05,0.15) )
                end
            else
                for _, traitor in ipairs(traitors) do
                    traitor:GiveExp( math.random(25,40) )
                    traitor:GiveSkill( math.Rand(0.1,0.3) )
                    traitor:SetPData("zb_hmcd_t_wins",traitor:GetPData("zb_hmcd_t_wins",0) + 1)
                end
                PrintMessage(HUD_PRINTTALK, "모든 시민이 살해당했습니다.")
            end
            
            timer.Simple(2, function()
                if(players_alive == 0)then
                    PrintMessage(HUD_PRINTTALK, "아무도 살아남지 못했습니다.")
                else
                    if(players_alive == 1)then
                        PrintMessage(HUD_PRINTTALK, "도시에 단 1명의 생존자만 남았습니다.")
                    else
                        PrintMessage(HUD_PRINTTALK, "도시에 " .. players_alive .. "명의 생존자가 남았습니다.")
                    end
                end
            end)
		else
			if traitor and IsValid(traitor) then
				--local CheckAlive = #self:CheckAlivePlayers()[1]
                PrintMessage(HUD_PRINTTALK, self.Types[self.Type].Messages[winner]..(winner == 0 and (traitor:Alive() and " 제압되었습니다." or " 사망했습니다.") or ""))
                
                timer.Simple(2, function()
                    PrintMessage(HUD_PRINTTALK, self.Types[self.Type].Message..traitor:Name())
                end)

                if winner == 1 then
                    traitor:GiveExp( math.Rand(30,50) )
                    traitor:GiveSkill( math.Rand(0.15,0.3) )
                    traitor:SetPData("zb_hmcd_t_wins",traitor:GetPData("zb_hmcd_t_wins",0) + 1)
                else
                    traitor:GiveSkill( -math.Rand(0.05,0.1) )
                end
                
                hook.Run("ZB_TraitorWinOrNot", traitor, winner)
            else
                PrintMessage(HUD_PRINTTALK, self.Types[self.Type].Messages[winner]..(winner == 0 and (" 사망했습니다.") or ""))
				for _, traitor in ipairs(traitors) do
					net.Start("hmcd_announce_traitor_lose")
						net.WriteEntity(traitor)
						net.WriteBool(traitor:Alive())
					net.Broadcast()

					hook.Run("ZB_TraitorWinOrNot", traitor, winner)
				end
			end
		end
	end

	timer.Simple(2,function()
		net.Start("hmcd_roundend")
			net.WriteUInt(#traitors, MODE.TraitorExpectedAmtBits)
			
			for _, traitor in ipairs(traitors) do
				net.WriteEntity(traitor)
			end
			
			net.WriteUInt(#gunners, MODE.TraitorExpectedAmtBits)
			
			for _, gunner in ipairs(gunners) do
				net.WriteEntity(gunner)
			end
		net.Broadcast()
	end)
end

-- hook.Add("Player_Death", "HMCD_PlayerDeath", function(_, ply)
hook.Add("Player_Death", "HMCD_PlayerDeath", function(ply, _)
	local most_harm,biggest_attacker = 0,nil
	local last_attacker = nil

	if ply.isPolice then
		MODE.deadPoliceCount = (MODE.deadPoliceCount or 0) + 1
	end

	timer.Simple(.1,function()
		for attacker,attacker_harm in pairs(zb.HarmDone[ply] or {}) do
			if not IsValid(attacker) then continue end
			if most_harm < attacker_harm then
				most_harm = attacker_harm
				biggest_attacker = attacker:Name()
				last_attacker = attacker
			end
		end
		

		if ply.isTraitor then
			--local Appearance = ply.CurAppearance
			--
			--if(!Appearance)then
			--	-- Appearance = GetRandomAppearance(ply)
			--	PrintMessage(HUD_PRINTTALK, "Some traitor died.")
			--else
			--	local character_name = Appearance.AName or "error"
			--	
			--	PrintMessage(HUD_PRINTTALK, "Traitor " .. character_name .. " died.")
			--end
		
			if biggest_attacker then
				if biggest_attacker == ply:Name() then
					--timer.Simple(1,function()
					--	if not IsValid(ply) then return end
					--	local msg = (ThatPlyIsFemale(ply) and "Sh" or "H").."e suicided."
					--	PrintMessage(3,msg)
					--end)
				else
					last_attacker:GiveExp( math.random(10,15) )
					last_attacker:GiveSkill( math.Rand(0.025,0.075) )
					last_attacker:SetPData("zb_hmcd_ino_t_kills", last_attacker:GetPData("zb_hmcd_ino_t_kills",0) + 1)
					--timer.Simple(1,function()
					--	if not IsValid(ply) then return end
					--	local msg = (ThatPlyIsFemale(ply) and "Sh" or "H").."e was killed by "..biggest_attacker.."."
					--	PrintMessage(3,msg)
					--end)
				end
			else
				--timer.Simple(1,function()
				--	if not IsValid(ply) then return end
				--	local msg = (ThatPlyIsFemale(ply) and "Sh" or "H").."e died in mysterious circumstances."
				--	PrintMessage(3,msg)
				--end)
			end
		else
			if not biggest_attacker or not IsValid(ply) then return end
			
			if biggest_attacker == ply:Name() then
                ply:ChatPrint("자살했습니다.")
            elseif not biggest_attacker then
                ply:ChatPrint("사망했습니다.")
            else
                ply:ChatPrint(biggest_attacker .. "에게 살해당했습니다.")
			end
		end
	end)
end)

function MODE:CanLaunch()
	local _, currentType = CurrentRound()

	if not currentType or currentType == "hmcd" then
		-- Never inherit self.Type here: it belongs to the previous Homicide
		-- round and could leave the hmcd waiting room permanently blocked.
		return FindLaunchableHomicideType() ~= nil
	end

	if not self.Types or not self.Types[currentType] then
		currentType = "standard"
	end

	return CanLaunchHomicideType(currentType)
end

util.AddNetworkString("hmcd_roundend")

MODE.NextRoundMainTraitors = MODE.NextRoundMainTraitors or {}

concommand.Add("hmcd_request_main_traitor", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    

    if zb.ROUND_STATE == 1 then
        ply:ChatPrint("when round end")
        return
    end
    

    MODE.NextRoundMainTraitors[ply:SteamID()] = true
    ply:ChatPrint("true")
end)

hook.Add("RoundStateChange", "ResetNextRoundMainTraitors", function(old, new)
    if new == 2 then 
        MODE.NextRoundMainTraitors = {}
    end
end)

util.AddNetworkString("HMCD_UpdateTraitorAssistants")

function MODE.SpawnPlayers(spawn_with_subroles)
    local gunner_found = false

    if MODE.Type ~= "bang" then
        for i, ply in RandomPairs(player.GetAll()) do
            if ply.isTraitor or ply.isGunner or ply:Team() == TEAM_SPECTATOR then continue end
            if math.random(100) > (ply.Karma or 100) then continue end

            ply.isGunner = true
            gunner_found = true
            break
        end

        if(not gunner_found)then
            for i,ply in RandomPairs(player.GetAll()) do
                if ply.isTraitor or ply.isGunner or ply:Team() == TEAM_SPECTATOR then continue end

                ply.isGunner = true
                break
            end
        end
    end

    local player_count = 0
    for i, ply in player.Iterator() do
        if(ply:Team() != TEAM_SPECTATOR)then
            player_count = player_count + 1
        end
    end

    --= Профессии
    local professions = {}
    if(spawn_with_subroles and MODE.RoleChooseRoundTypes[MODE.Type])then
        local professions_possible_pre = MODE.RoleChooseRoundTypes[MODE.Type].Professions

        if(professions_possible_pre)then
            local professions_possible = {}
            local professions_count_to_satisfy = math.ceil(player_count / 2)

            for profession, profession_info in pairs(professions_possible_pre) do
                professions_possible[#professions_possible + 1] = {profession_info.Chance, profession}
            end

            for _, ply in RandomPairs(player.GetAll()) do
                if(ply:Team() != TEAM_SPECTATOR)then
                    if((math.random(100) <= (ply.Karma or 100)) and (math.random(1, 3) == 1 or (!ply.isTraitor and !ply.isGunner)))then
                        local profession_key, profession = hg.WeightedRandomSelect(professions_possible)
                        professions_possible[profession_key][1] = professions_possible[profession_key][1] / 2
                        ply.Profession = profession
                        professions_count_to_satisfy = professions_count_to_satisfy - 1
                        
                        if(professions_count_to_satisfy == 0)then
                            break
                        end
                    end
                end
            end
            

            if(professions_count_to_satisfy > 0)then
                for _, ply in RandomPairs(player.GetAll()) do
                    if(ply:Team() != TEAM_SPECTATOR and !ply.Profession)then
                        local profession_key, profession = hg.WeightedRandomSelect(professions_possible)
                        professions_possible[profession_key][1] = professions_possible[profession_key][1] / 2
                        ply.Profession = profession
                        professions_count_to_satisfy = professions_count_to_satisfy - 1
                        
                        if(professions_count_to_satisfy == 0)then
                            break
                        end
                    end
                end
            end
        end
    end


    local all_players = player.GetAll()
    for idx, current_ply in player.Iterator() do
        if(current_ply:Team() != TEAM_SPECTATOR)then
            current_ply.SubRole = nil

            ApplyAppearance(current_ply,nil,nil,nil,true)
            current_ply:Spawn()
            current_ply:GetRandomSpawn()

            if(!current_ply:Alive())then
                continue
            end

            current_ply:SetSuppressPickupNotices(true)
            current_ply.noSound = true

            if(MODE.Type == "supermario")then
                MODE.Types.supermario.CustomJump(current_ply)
            end

            local sub_role = nil
            if(spawn_with_subroles and MODE.RoleChooseRoundTypes[MODE.Type])then
                if(current_ply.isTraitor)then
                    local sub_role_id = MODE.Type == "soe" and (current_ply:GetInfo(MODE.ConVarName_SubRole_Traitor_SOE) or "traitor_default_soe") or (current_ply:GetInfo(MODE.ConVarName_SubRole_Traitor) or "traitor_default")
					sub_role = sub_role_id
                end

                if(current_ply.isGunner)then
                    MODE.Types[MODE.Type].GunManLoot(current_ply)
                end

                if(sub_role)then
                    if(current_ply.isGunner)then

                    elseif(current_ply.isTraitor)then
                        local role_info = MODE.SubRoles[sub_role]
                        if(!role_info or !MODE.RoleChooseRoundTypes[MODE.Type].Traitor[sub_role])then
                            sub_role = MODE.RoleChooseRoundTypes[MODE.Type].TraitorDefaultRole or "traitor_default"
                            role_info = MODE.SubRoles[sub_role]
                        end

                        if(current_ply.MainTraitor)then
                            local spawn_func = role_info.SpawnFunction
                            current_ply.SubRole = sub_role
                            spawn_func(current_ply)
                        end
                    end
                end
            elseif MODE.Type == "bang" then
                MODE:GiveBangEquipment(current_ply)
            else
                if(current_ply.isTraitor)then
                    MODE.Types[MODE.Type].TraitorLoot(current_ply)
                end

                if(current_ply.isGunner)then
                    MODE.Types[MODE.Type].GunManLoot(current_ply)
                end
            end
            
            if(MODE.Type == "soe")then
                if(current_ply.isTraitor)then
                    local walkie_talkie = current_ply:Give("weapon_walkie_talkie")
					if walkie_talkie.Frequencies then
						MODE.TraitorFrequency = MODE.TraitorFrequency or math.random(1, #walkie_talkie.Frequencies)
						walkie_talkie.Frequency = MODE.TraitorFrequency
						current_ply:ChatPrint("Walkie-Talkie Frequency = " .. walkie_talkie.Frequencies[MODE.TraitorFrequency])
					end
                end
            end

            if(gaymaps[game.GetMap()])then
                local inv = current_ply:GetNetVar("Inventory") or {}
                inv["Weapons"] = inv["Weapons"] or {}
                inv["Weapons"]["hg_flashlight"] = true
                current_ply:SetNetVar("Inventory", inv)
            end

            local profession_info = current_ply.Profession and MODE.Professions[current_ply.Profession]
            if profession_info and profession_info.SpawnFunction then
                profession_info.SpawnFunction(current_ply)
            end

            local hands = current_ply:Give("weapon_hands_sh")
            current_ply:SetActiveWeapon(hands)
			if MODE.Type == "bang" and IsValid(current_ply.BangPrimaryWeapon) then
				current_ply:SetActiveWeapon(current_ply.BangPrimaryWeapon)
			end
            current_ply:SetNetVar("flashlight", false)

            local this_player = current_ply
            
            timer.Simple(0.1, function() 
                if IsValid(this_player) then
                    this_player.noSound = false
                    this_player:SetSuppressPickupNotices(false)
                end
            end)

            timer.Simple(0.2 * idx, function()
                if not IsValid(this_player) then return end

                local traitor_amt = 0
                local traitor_assistants = {}
				local traitorWord, traitorWordSecond = "", ""
                
                if (this_player.isTraitor) then
					if MODE.Type ~= "bang" then
						traitorWord, traitorWordSecond = EnsureTraitorWords()
					end

                    for _, other_ply in player.Iterator() do
                        if (other_ply.isTraitor) then
                            traitor_amt = traitor_amt + 1
                            

                            if this_player.MainTraitor and other_ply.CurAppearance then
                                local Appearance = other_ply.CurAppearance
                                local color = Appearance.AColor or color_white
                                local name = Appearance.AName or "error"
                                local steamID = other_ply:SteamID() or ""
                                
                                if not IsColor(color) then
                                    color = Color(color.r, color.g, color.b)
                                end
                                
                                table.insert(traitor_assistants, {color, name, steamID})
                            end
                        end
                    end
                end
                

                net.Start("HMCD_RoundStart")
                    net.WriteBool(this_player.isTraitor)
                    net.WriteBool(this_player.isGunner)
                    net.WriteString(MODE.Type)
                    net.WriteBool(true)
                    net.WriteString(this_player.SubRole or "")
                    net.WriteBool(this_player.MainTraitor == true)
                    
                    if (this_player.isTraitor) then
						net.WriteString(traitorWord)
						net.WriteString(traitorWordSecond)
                        net.WriteUInt(traitor_amt, MODE.TraitorExpectedAmtBits)
                    else
                        net.WriteString("")
                        net.WriteString("")
                        net.WriteUInt(0, MODE.TraitorExpectedAmtBits)
                    end
                    
                    if (this_player.MainTraitor) then

                        for _, traitor_info in ipairs(traitor_assistants) do
                            net.WriteColor(traitor_info[1], false)
                            net.WriteString(traitor_info[2])
                        end

                        timer.Simple(0.5, function()
                            if IsValid(this_player) and this_player.isTraitor and this_player.MainTraitor then
                                net.Start("HMCD_UpdateTraitorAssistants")
                                    net.WriteUInt(#traitor_assistants, 8)
                                    
                                    for _, info in ipairs(traitor_assistants) do
                                        net.WriteColor(info[1])
                                        net.WriteString(info[2])
                                        net.WriteString(info[3])
                                    end
                                net.Send(this_player)
                            end
                        end)
                    end
                    
                    net.WriteString(this_player.Profession or "")
					if MODE.Type == "bang" then
						net.WriteString(this_player.BangRole or "")
						net.WriteString(this_player.BangCharacter or "")
					end
                net.Send(this_player)
                
                local role
                if MODE.Type == "bang" then
                    role = MODE.BangRoleInfo[this_player.BangRole]
                else
                    role = MODE.Roles[MODE.Type][(this_player.isTraitor and "traitor") or (this_player.isGunner and "gunner") or "innocent"]
                end
                if role then
                    zb.GiveRole(this_player, role.name, role.color)
                end
            end)
        end
    end
end

hook.Add("PlayerSpawn", "HMCD_UpdateTraitorsList", function(ply)
	if not ply.isTraitor then return end
	
	timer.Simple(0.5, function()
		for _, main_traitor in player.Iterator() do
			if IsValid(main_traitor) and main_traitor.isTraitor and main_traitor.MainTraitor then
				local traitor_assistants = {}
				
				for _, other_ply in player.Iterator() do
					if other_ply.isTraitor then
						local Appearance = other_ply.CurAppearance
						if Appearance then
							local color = Appearance.AColor or color_white
							local name = Appearance.AName or "error"
							local steamID = other_ply:SteamID() or ""
							
							if not IsColor(color) then
								color = Color(color.r, color.g, color.b)
							end
							
							table.insert(traitor_assistants, {color, name, steamID})
						end
					end
				end
				
				net.Start("HMCD_UpdateTraitorAssistants")
				net.WriteUInt(#traitor_assistants, 8)
				
				for _, info in ipairs(traitor_assistants) do
					net.WriteColor(info[1])
					net.WriteString(info[2])
					net.WriteString(info[3])
				end
				
				net.Send(main_traitor)
			end
		end
	end)
end)

hook.Add("PlayerDeath", "HMCD_UpdateTraitorsList", function(ply)
	if not ply.isTraitor then return end
	
	timer.Simple(0.1, function()
		if IsValid(ply) and ply.CurAppearance then
			MODE:SendTraitorDeathState(ply, false)
		end
		
		timer.Simple(0.4, function()
			for _, main_traitor in player.Iterator() do
				if IsValid(main_traitor) and main_traitor.isTraitor and main_traitor.MainTraitor then
					local traitor_assistants = {}
					
					for _, other_ply in player.Iterator() do
						if other_ply.isTraitor then
							local Appearance = other_ply.CurAppearance
							if Appearance then
								local color = Appearance.AColor or color_white
								local name = Appearance.AName or "error"
								local steamID = other_ply:SteamID() or ""
								
								if not IsColor(color) then
									color = Color(color.r, color.g, color.b)
								end
								
								table.insert(traitor_assistants, {color, name, steamID})
							end
						end
					end
					
					net.Start("HMCD_UpdateTraitorAssistants")
					net.WriteUInt(#traitor_assistants, 8)
					
					for _, info in ipairs(traitor_assistants) do
						net.WriteColor(info[1])
						net.WriteString(info[2])
						net.WriteString(info[3])
					end
					
					net.Send(main_traitor)
				end
			end
		end)
	end)
end)
