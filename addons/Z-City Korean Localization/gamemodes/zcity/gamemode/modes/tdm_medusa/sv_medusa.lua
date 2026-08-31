local MODE = MODE

local medusaZoneCooldown = 0

local function MakeDissolver(ent, position, dissolveType)
	local dissolver = ents.Create("env_entity_dissolver")
	timer.Simple(5, function()
		if IsValid(dissolver) then dissolver:Remove() end
	end)

	if not IsValid(dissolver) then return end

	dissolver.Target = "medusa_dissolve" .. ent:EntIndex()
	dissolver:SetKeyValue("dissolvetype", dissolveType or 0)
	dissolver:SetKeyValue("magnitude", 0)
	dissolver:SetPos(position)
	dissolver:SetPhysicsAttacker(ent)
	dissolver:Spawn()

	ent:SetName(dissolver.Target)
	ent:Fire("Open")
	dissolver:Fire("Dissolve", dissolver.Target, 0)
	dissolver:Fire("Kill", "", 0.1)

	return dissolver
end

local function KillAndDissolvePlayer(ply)
	if ply.ZCityMedusaDissolving then return end
	ply.ZCityMedusaDissolving = true

	local pos = ply:GetPos()
	ply:Kill()

	timer.Simple(0.05, function()
		if IsValid(ply) then
			ply.ZCityMedusaDissolving = nil
		end

		local dissolveTargets = {}
		local function AddTarget(ent)
			if IsValid(ent) and ent:GetClass() == "prop_ragdoll" then
				dissolveTargets[ent] = true
			end
		end

		if IsValid(ply) then
			AddTarget(ply.FakeRagdoll)
			AddTarget(ply.OldRagdoll)
			AddTarget(ply.FakeRagdollOld)
			AddTarget(ply:GetNWEntity("FakeRagdoll"))
			AddTarget(ply:GetNWEntity("FakeRagdollOld"))
			AddTarget(ply:GetNWEntity("RagdollDeath"))
		end

		for _, ent in ipairs(ents.FindInSphere(pos, 128)) do
			if IsValid(ent) and ent:GetClass() == "prop_ragdoll" then
				local owner = hg and hg.RagdollOwner and hg.RagdollOwner(ent)
				if ent:GetOwner() == ply or ent.ply == ply or owner == ply then
					dissolveTargets[ent] = true
				end
			end
		end

		for ent in pairs(dissolveTargets) do
			MakeDissolver(ent, ent:GetPos(), 0)
		end
	end)
end

function MODE:CanLaunch()
	return true
end

function MODE:RoundStart()
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		ply:StripWeapons()
		ply:RemoveAllAmmo()
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true
		local beam = ply:Give("weapon_petrificationbeam_ammo")
		if IsValid(beam) then
			ply:SelectWeapon("weapon_petrificationbeam_ammo")
		end
		zb.GiveRole(ply, "Medusa", Color(80, 200, 120))
		timer.Simple(0.1, function()
			if IsValid(ply) then
				ply.noSound = false
				ply:SetSuppressPickupNotices(false)
			end
		end)
	end
end

function MODE:GiveEquipment()
end

hook.Add("Think", "ZCityMedusaDeathZone", function()
	local round = CurrentRound()
	if not round or round.name ~= "medusa" then return end
	if medusaZoneCooldown > CurTime() then return end
	if not zonepoint then return end

	medusaZoneCooldown = CurTime() + 0.5

	local radius = MODE.GetZoneRadius()
	local radiusSqr = radius * radius

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then continue end
		if ply:GetPos():DistToSqr(zonepoint) > radiusSqr then
			KillAndDissolvePlayer(ply)
		end
	end
end)
