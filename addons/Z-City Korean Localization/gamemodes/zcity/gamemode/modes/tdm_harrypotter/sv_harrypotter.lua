local MODE = MODE

local spellBooks = {
	{class = "entity_hpwand_spell_expelliarmus", spell = "Expelliarmus"},
	{class = "entity_hpwand_spell_stupefy", spell = "Stupefy"},
	{class = "entity_hpwand_spell_petrificus_totalus", spell = "Petrificus Totalus"},
	{class = "entity_hpwand_spell_alohomora", spell = "Alohomora"},
	{class = "entity_hpwand_spell_tarantallegra", spell = "Tarantallegra"},
	{class = "entity_hpwand_spell_expulso", spell = "Expulso"},
	{class = "entity_hpwand_spell_crucio", spell = "Crucio"},
	{class = "entity_hpwand_spell_avada_kedavra", spell = "Avada kedavra"},
	{class = "entity_hpwand_spell_confringo", spell = "Confringo"},
	{class = "entity_hpwand_spell_hail_of_bullets", spell = "Hail of bullets"}
}

local attackSpellBooks = {
	{class = "entity_hpwand_spell_expulso", spell = "Expulso"},
	{class = "entity_hpwand_spell_crucio", spell = "Crucio"},
	{class = "entity_hpwand_spell_avada_kedavra", spell = "Avada kedavra"},
	{class = "entity_hpwand_spell_confringo", spell = "Confringo"},
	{class = "entity_hpwand_spell_hail_of_bullets", spell = "Hail of bullets"}
}

local supportSpellBooks = {
	{class = "entity_hpwand_spell_expelliarmus", spell = "Expelliarmus"},
	{class = "entity_hpwand_spell_stupefy", spell = "Stupefy"},
	{class = "entity_hpwand_spell_petrificus_totalus", spell = "Petrificus Totalus"},
	{class = "entity_hpwand_spell_alohomora", spell = "Alohomora"},
	{class = "entity_hpwand_spell_tarantallegra", spell = "Tarantallegra"}
}

local spellBooksPerPlayer = 4
local minSpellBookCount = #spellBooks
local maxSpellBookCount = 40
local spellBookSpawnMinDistance = 180
local spellBookSpawnRadiusMin = 120
local spellBookSpawnRadiusMax = 700

local spellByBookClass = {}
for _, data in ipairs(spellBooks) do
	spellByBookClass[data.class] = data.spell
end

local spawnClasses = {
	"info_player_start", "info_player_deathmatch", "info_player_combine", "info_player_rebel",
	"info_player_counterterrorist", "info_player_terrorist", "info_player_axis",
	"info_player_allies", "gmod_player_start", "info_player_teamspawn",
	"ins_spawnpoint", "aoc_spawnpoint", "dys_spawn_point", "info_player_pirate",
	"info_player_viking", "info_player_knight", "diprip_start_team_blue", "diprip_start_team_red",
	"info_player_red", "info_player_blue", "info_player_coop", "info_player_human", "info_player_zombie",
	"info_player_zombiemaster", "info_player_fof", "info_player_desperado", "info_player_vigilante", "info_survivor_rescue"
}

local function IsHarryPotterRound()
	local round = CurrentRound()
	return round and round.name == "harrypotter"
end

local harryPotterAttackStun = 0.65
local harryPotterAttackButtons = bit.bor(IN_ATTACK, IN_ATTACK2)

local function IsHarryPotterWand(wep)
	return IsValid(wep) and wep:GetClass() == "weapon_hpwr_stick"
end

local function StunHarryPotterAttack(ply)
	if not IsValid(ply) or not ply:Alive() then return end

	local stunUntil = CurTime() + harryPotterAttackStun
	ply.ZCityHarryPotterAttackStunUntil = math.max(ply.ZCityHarryPotterAttackStunUntil or 0, stunUntil)
	ply:SetNWFloat("ZCityHarryPotterAttackStunUntil", ply.ZCityHarryPotterAttackStunUntil)

	local wep = ply:GetActiveWeapon()
	if IsHarryPotterWand(wep) then
		wep:SetNextPrimaryFire(stunUntil)
		wep:SetNextSecondaryFire(stunUntil)
	end
end

local function ClearHarryPotterAttackStun(ply)
	if not IsValid(ply) then return end
	ply.ZCityHarryPotterAttackStunUntil = nil
	ply:SetNWFloat("ZCityHarryPotterAttackStunUntil", 0)
end

local function AddUniqueSpawnPosition(positions, used, pos)
	if not pos or type(pos) ~= "Vector" then return end

	local key = math.Round(pos.x) .. ":" .. math.Round(pos.y) .. ":" .. math.Round(pos.z)
	if used[key] then return end

	used[key] = true
	positions[#positions + 1] = pos + Vector(0, 0, 24)
end

local function GetSpawnPositions()
	local positions = {}
	local used = {}
	local points = zb.GetMapPoints and zb.GetMapPoints("Spawnpoint") or {}

	for _, point in ipairs(points or {}) do
		AddUniqueSpawnPosition(positions, used, point.pos)
	end

	if #positions <= 0 then
		for _, class in ipairs(spawnClasses) do
			for _, ent in ipairs(ents.FindByClass(class)) do
				if IsValid(ent) then
					AddUniqueSpawnPosition(positions, used, ent:GetPos())
				end
			end
		end
	end

	if #positions <= 0 then
		for _, ply in player.Iterator() do
			if ply:Alive() then
				AddUniqueSpawnPosition(positions, used, ply:GetPos() + Vector(0, 0, 24))
			end
		end
	end

	if #positions <= 0 then
		positions[1] = Vector(0, 0, 128)
	end

	return positions
end

local function ShufflePositions(positions)
	local shuffled = table.Copy(positions)

	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	return shuffled
end

local function GetHarryPotterPlayerCount()
	local count = 0

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		count = count + 1
	end

	return math.max(count, 1)
end

local function BuildSpellBookSpawnList(count)
	local attackCount = math.floor(count * 0.5)
	local supportCount = count - attackCount
	local out = {}

	for i = 1, attackCount do
		out[#out + 1] = attackSpellBooks[((i - 1) % #attackSpellBooks) + 1]
	end

	for i = 1, supportCount do
		out[#out + 1] = supportSpellBooks[((i - 1) % #supportSpellBooks) + 1]
	end

	for i = #out, 2, -1 do
		local j = math.random(i)
		out[i], out[j] = out[j], out[i]
	end

	return out
end

local function AddFieldBasePosition(positions, used, pos)
	if not isvector(pos) then return end

	local key = math.Round(pos.x / 128) .. ":" .. math.Round(pos.y / 128)
	if used[key] then return end

	used[key] = true
	positions[#positions + 1] = pos
end

local function GetFieldBasePositions()
	local positions = {}
	local used = {}

	for _, pos in ipairs(GetSpawnPositions()) do
		AddFieldBasePosition(positions, used, pos)
	end

	return positions
end

local function IsFarEnoughFromPositions(pos, positions, minDistance)
	local minDistSqr = minDistance * minDistance

	for _, other in ipairs(positions) do
		if pos:DistToSqr(other) < minDistSqr then
			return false
		end
	end

	return true
end

local function FindValidFieldPosition(basePositions, usedPositions)
	if #basePositions <= 0 then return nil end

	for _ = 1, 60 do
		local base = table.Random(basePositions)
		local angle = math.rad(math.Rand(0, 360))
		local dist = math.Rand(spellBookSpawnRadiusMin, spellBookSpawnRadiusMax)
		local offset = Vector(math.cos(angle) * dist, math.sin(angle) * dist, math.Rand(-32, 96))
		local start = base + offset + Vector(0, 0, 192)

		local tr = util.TraceLine({
			start = start,
			endpos = start - Vector(0, 0, 768),
			mask = bit.bor(MASK_SOLID, MASK_WATER)
		})

		if tr.Hit and not tr.HitSky and not tr.StartedSolid and tr.MatType ~= MAT_SLOSH and tr.HitTexture ~= "TOOLS/TOOLSNODRAW" and tr.HitTexture ~= "**studio**" and tr.HitTexture ~= "**empty**" then
			local pos = tr.HitPos + Vector(0, 0, 24)
			local hull = util.TraceHull({
				start = pos,
				endpos = pos + Vector(0, 0, 36),
				mins = Vector(-8, -8, 0),
				maxs = Vector(8, 8, 24),
				mask = MASK_SOLID
			})

			if not hull.Hit and not hull.StartedSolid and IsFarEnoughFromPositions(pos, usedPositions or {}, spellBookSpawnMinDistance) then
				return pos
			end
		end
	end
end

local function GetFieldSpellBookPositions(count)
	local positions = {}
	local basePositions = GetFieldBasePositions()
	local fallbackPositions = ShufflePositions(GetSpawnPositions())

	for i = 1, count do
		local pos = FindValidFieldPosition(basePositions, positions)
		if not pos and #fallbackPositions > 0 then
			local fallback = fallbackPositions[((i - 1) % #fallbackPositions) + 1]
			pos = FindValidFieldPosition({fallback}, positions) or fallback
		end

		if pos then
			positions[#positions + 1] = pos
		end
	end

	return positions
end

local function FindPistolPosition(bookPositions, spawnPositions)
	local firstPos
	local secondPos
	local bestDist = 0

	for i = 1, #bookPositions do
		for j = i + 1, #bookPositions do
			local dist = bookPositions[i]:DistToSqr(bookPositions[j])
			if dist > bestDist then
				bestDist = dist
				firstPos = bookPositions[i]
				secondPos = bookPositions[j]
			end
		end
	end

	local pos = table.Random(spawnPositions)
	if firstPos and secondPos then
		local center = (firstPos + secondPos) * 0.5
		local closestDist

		for _, spawnPos in ipairs(spawnPositions) do
			local dist = spawnPos:DistToSqr(center)
			if not closestDist or dist < closestDist then
				closestDist = dist
				pos = spawnPos
			end
		end
	end

	local tr = util.TraceLine({
		start = pos + Vector(0, 0, 128),
		endpos = pos - Vector(0, 0, 512),
		mask = MASK_SOLID_BRUSHONLY
	})

	if tr.Hit then
		return tr.HitPos + Vector(0, 0, 24)
	end

	return pos
end

local function SpawnHarryPotterPistol(pos)
	if not weapons.GetStored("weapon_glock17") then
		print("[HarryPotter] Missing pistol weapon: weapon_glock17")
		return
	end

	local pistol = ents.Create("weapon_glock17")
	if not IsValid(pistol) then return end

	pistol.ZCityHarryPotterSpawnedItem = true
	pistol:SetPos(pos)
	pistol:Spawn()
	pistol:Activate()

	local phys = pistol:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
end

local function ClearSpawnedPistol()
	for _, ent in ipairs(ents.FindByClass("weapon_glock17")) do
		if IsValid(ent) and ent.ZCityHarryPotterSpawnedItem then
			ent:Remove()
		end
	end
end

local function GiveDefaultWandSkin(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not HpwRewrite or not HpwRewrite.PlayerGiveSpell or not HpwRewrite.DefaultSkin then return end

	ply.HpwRewrite = ply.HpwRewrite or {}
	HpwRewrite:PlayerGiveSpell(ply, HpwRewrite.DefaultSkin, nil, true)
end

local function ForgetHarryPotterSpells(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not HpwRewrite then return end

	ply.HpwRewrite = ply.HpwRewrite or {}

	if HpwRewrite.PlayerStopLearning then
		HpwRewrite:PlayerStopLearning(ply)
	end

	timer.Remove("hpwrewrite_learnspell" .. ply:EntIndex())

	for _, data in ipairs(spellBooks) do
		if HpwRewrite.PlayerRemoveSpell then
			HpwRewrite:PlayerRemoveSpell(ply, data.spell)
		end

		if HpwRewrite.PlayerRemoveLearnableSpell then
			HpwRewrite:PlayerRemoveLearnableSpell(ply, data.spell)
		end

		if HpwRewrite.EraseSpell then
			HpwRewrite:EraseSpell(ply, data.spell)
		end

		if HpwRewrite.EraseLearnableSpell then
			HpwRewrite:EraseLearnableSpell(ply, data.spell)
		end

		if HpwRewrite.RemoveFromCache then
			HpwRewrite:RemoveFromCache(ply, data.spell)
		end
	end

	if HpwRewrite.GetWand then
		local wand = HpwRewrite:GetWand(ply)
		if IsValid(wand) then
			if wand.HPWRemoveCurSpell then
				wand:HPWRemoveCurSpell()
			end

			if wand.HPWSetWandSkin and HpwRewrite.DefaultSkin then
				wand:HPWSetWandSkin(HpwRewrite.DefaultSkin)
			end
		end
	end
end

local function GiveHarryPotterSpellNow(ply, spellName)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	if not HpwRewrite or not HpwRewrite.GetSpell or not HpwRewrite.PlayerGiveSpell then return false end
	if not HpwRewrite:GetSpell(spellName) then return false end

	ply.HpwRewrite = ply.HpwRewrite or {}

	if HpwRewrite.PlayerStopLearning then
		HpwRewrite:PlayerStopLearning(ply)
	end

	timer.Remove("hpwrewrite_learnspell" .. ply:EntIndex())

	if not HpwRewrite.PlayerHasSpell or not HpwRewrite:PlayerHasSpell(ply, spellName) then
		HpwRewrite:PlayerGiveSpell(ply, spellName, nil, true)
	end

	if HpwRewrite.PlayerRemoveLearnableSpell then
		HpwRewrite:PlayerRemoveLearnableSpell(ply, spellName)
	end

	if HpwRewrite.EraseLearnableSpell then
		HpwRewrite:EraseLearnableSpell(ply, spellName)
	end

	local wand = HpwRewrite.GetWand and HpwRewrite:GetWand(ply)
	if IsValid(wand) and wand.HPWSetCurrentSpell then
		local current = wand:GetWandCurrentSpell()
		if current == "" or not HpwRewrite.CanUseSpell or not HpwRewrite:CanUseSpell(ply, current) then
			wand:HPWSetCurrentSpell(spellName)
		end
	end

	return true
end

local function ClearSpawnedSpellBooks()
	ClearSpawnedPistol()

	for _, data in ipairs(spellBooks) do
		for _, ent in ipairs(ents.FindByClass(data.class)) do
			if IsValid(ent) and ent.ZCityHarryPotterBook then
				ent:Remove()
			end
		end
	end
end

local function SpawnSpellBooks()
	ClearSpawnedSpellBooks()
	local playerCount = GetHarryPotterPlayerCount()
	local bookCount = math.Clamp(playerCount * spellBooksPerPlayer, minSpellBookCount, maxSpellBookCount)
	local spawnPositions = ShufflePositions(GetFieldSpellBookPositions(bookCount))
	local bookPositions = {}
	local bookList = BuildSpellBookSpawnList(bookCount)

	if #spawnPositions <= 0 then
		spawnPositions = ShufflePositions(GetSpawnPositions())
	end

	if #spawnPositions <= 0 then return end

	local owner
	for _, ply in player.Iterator() do
		if ply:Alive() then
			owner = ply
			break
		end
	end
	owner = owner or Entity(0)

	for i = 1, bookCount do
		local data = bookList[i]
		if not data then continue end
		if scripted_ents.GetStored(data.class) == nil then
			print("[HarryPotter] Missing spell book entity: " .. data.class)
			continue
		end

		local book = ents.Create(data.class)
		if not IsValid(book) then continue end

		book.ZCityHarryPotterBook = true
		book.ZCityHarryPotterSpell = data.spell
		book.Owner = owner
		book.CheckCanSpawn = function() return true end

		if book.SetupOwner and IsValid(owner) then
			book:SetupOwner(owner)
		end

		local pos = spawnPositions[((i - 1) % #spawnPositions) + 1]
		bookPositions[#bookPositions + 1] = pos
		book:SetPos(pos)
		book:Spawn()
		book:Activate()

		local phys = book:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
	end

	SpawnHarryPotterPistol(FindPistolPosition(bookPositions, spawnPositions))
end

function MODE:CanLaunch()
	return true
end

function MODE:Intermission()
	game.CleanUpMap()

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		ApplyAppearance(ply)
		ply:SetupTeam(0)
		ClearHarryPotterAttackStun(ply)
	end
end

function MODE:RoundStart()
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end

		ForgetHarryPotterSpells(ply)
		ply:StripWeapons()
		ply:RemoveAllAmmo()
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true

		local wand = ply:Give("weapon_hpwr_stick")
		if IsValid(wand) then
			ply:SelectWeapon("weapon_hpwr_stick")
		end

		GiveDefaultWandSkin(ply)
		zb.GiveRole(ply, "Wizard", Color(120, 80, 255))

		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply.noSound = false
				ply:SetSuppressPickupNotices(false)
			end
		end)
	end

	timer.Simple(1, function()
		if not IsHarryPotterRound() then return end
		SpawnSpellBooks()
	end)
end

function MODE:GiveEquipment()
end

function MODE:PlayerDeath(ply)
	ForgetHarryPotterSpells(ply)
	ClearHarryPotterAttackStun(ply)
end

hook.Add("KeyPress", "ZCityHarryPotterAttackStun", function(ply, key)
	if not IsHarryPotterRound() then return end
	if key ~= IN_ATTACK and key ~= IN_ATTACK2 then return end
	if not IsHarryPotterWand(ply:GetActiveWeapon()) then return end
	if (ply.ZCityHarryPotterAttackStunUntil or 0) > CurTime() then return end

	timer.Simple(0, function()
		if not IsHarryPotterRound() or not IsValid(ply) or not IsHarryPotterWand(ply:GetActiveWeapon()) then return end
		StunHarryPotterAttack(ply)
	end)
end)

hook.Add("StartCommand", "ZCityHarryPotterAttackStun", function(ply, cmd)
	if not IsHarryPotterRound() then return end
	if (ply.ZCityHarryPotterAttackStunUntil or 0) <= CurTime() then return end

	cmd:RemoveKey(harryPotterAttackButtons)
	cmd:SetForwardMove(0)
	cmd:SetSideMove(0)
	cmd:SetUpMove(0)
end)

hook.Add("PlayerUse", "ZCityHarryPotterInstantSpellBook", function(ply, ent)
	if not IsHarryPotterRound() then return end
	if not IsValid(ply) or not IsValid(ent) then return end

	local spellName = ent.ZCityHarryPotterSpell or spellByBookClass[ent:GetClass()]
	if not spellName then return end

	if GiveHarryPotterSpellNow(ply, spellName) then
		ent:EmitSound("garrysmod/save_load1.wav", 60)
		SafeRemoveEntity(ent)
		return false
	end
end)

hook.Add("PlayerDeath", "ZCityHarryPotterForgetSpells", function(ply)
	if not IsHarryPotterRound() then return end
	ForgetHarryPotterSpells(ply)
end)

hook.Add("ZB_PreRoundStart", "ZCityHarryPotterForgetSpells", function()
	for _, ply in player.Iterator() do
		ForgetHarryPotterSpells(ply)
		ClearHarryPotterAttackStun(ply)
	end

	ClearSpawnedSpellBooks()
end)
