local MODE = MODE
MODE.name = "hmcd"
MODE.PrintName = "Homicide"

--\\
MODE.TraitorExpectedAmtBits = 13
--//

--\\Sub Roles
MODE.ConVarName_SubRole_Traitor_SOE = "hmcd_subrole_traitor_soe"
MODE.ConVarName_SubRole_Traitor = "hmcd_subrole_traitor"

if(CLIENT)then
	MODE.ConVar_SubRole_Traitor_SOE = CreateClientConVar(MODE.ConVarName_SubRole_Traitor_SOE, "traitor_default_soe", true, true, "Select traitor role in State of Emergency homicide mode")
	MODE.ConVar_SubRole_Traitor = CreateClientConVar(MODE.ConVarName_SubRole_Traitor, "traitor_default", true, true, "Select murder role in Standard homicide modes")
end

--; TODO
--; Инженер - шахид бомба + иеды

MODE.SubRoles = {
	--=\\Traitor
	--==\\
	--; https://youtu.be/zP7ux8WsYYI?si=S-Uw2EAehGR5WD3D
    ["traitor_default"] = {
        Name = "데포코(기본)",
        Description = [[기본 설정입니다.
이 순간을 위해 오랫동안 준비해왔습니다.
당신은 살인을 돕기 위해 다양한 무기, 독극물, 폭발물, 수류탄, 그리고 당신이 가장 아끼는 튼튼한 대형 칼과 추가 탄창이 포함된 소음기 권총으로 무장했습니다.]],
        Objective = "당신은 주머니 속에 아이템, 독극물, 폭발물, 그리고 무기들로 무장했습니다. 이곳의 모두를 살해하십시오.",
		SpawnFunction = function(ply)
			local wep = ply:Give("weapon_zoraki")
			
			timer.Simple(1, function()
				wep:ApplyAmmoChanges(2)
			end)
			
			ply:Give("weapon_buck200knife")	
			ply:Give("weapon_hg_rgd_tpik")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_shuriken")
			ply:Give("weapon_hg_smokenade_tpik")
			ply:Give("weapon_traitor_ied")
			ply:Give("weapon_traitor_poison1")
			ply:Give("weapon_traitor_suit")
			ply:Give("weapon_hg_jam")
			-- ply:Give("weapon_traitor_poison2")
			-- ply:Give("weapon_traitor_poison3")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
    ["traitor_default_soe"] = {
        Name = "데포코(기본)",
        Description = [[기본 설정입니다.
이 순간을 위해 오랫동안 준비해왔습니다.
당신은 살인을 돕기 위해 다양한 무기, 독극물, 폭발물, 수류탄, 그리고 당신이 가장 아끼는 튼튼한 대형 칼과 추가 탄창이 포함된 소음기 권총으로 무장했습니다.]],
        Objective = "당신은 주머니 속에 아이템, 독극물, 폭발물, 그리고 무기들로 무장했습니다. 이곳의 모두를 살해하십시오.",
		SpawnFunction = function(ply)
			if not IsValid(ply) then return end
			local p22 = ply:Give("weapon_p22")
			if not IsValid(p22) then return end
			ply:GiveAmmo(p22:GetMaxClip1() * 1, p22:GetPrimaryAmmoType(), true)
			
			hg.AddAttachmentForce(ply, p22, "supressor4")
			ply:Give("weapon_sogknife")	
			ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_walkie_talkie")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			ply:Give("weapon_traitor_ied")
			ply:Give("weapon_traitor_poison2")
			ply:Give("weapon_traitor_poison3")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory",inv)
		end,
	},
	--==//
	
	--==\\
    ["traitor_infiltrator"] = {
        Name = "침투 요원",
        Description = [[뒤에서 사람의 목을 꺾어 처치할 수 있습니다.
쓰러진 플레이어(래그돌)가 있다면 해당 플레이어로 완벽하게 변장할 수 있습니다.
단검, 에피펜, 연막탄 외에는 다른 무기나 도구가 지급되지 않습니다.
치밀한 수 싸움을 즐기는 분들을 위한 직업입니다.]],
        Objective = "당신은 교란의 전문가입니다. 신중하게 행동하며 한 명씩 처치하십시오.",
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_infiltrator_soe"] = {
        Name = "침투 요원",
        Description = [[뒤에서 사람의 목을 꺾어 처치할 수 있습니다.
쓰러진 플레이어(래그돌)가 있다면 해당 플레이어로 완벽하게 변장할 수 있습니다.
단검, 에피펜, 연막탄 외에는 다른 무기나 도구가 지급되지 않습니다.
치밀한 수 싸움을 즐기는 분들을 위한 직업입니다.]],
        Objective = "당신은 교란의 전문가입니다. 신중하게 행동하며 한 명씩 처치하십시오.",
		SpawnFunction = function(ply)
			local taser = ply:Give("weapon_taser")
			
			ply:GiveAmmo(taser:GetMaxClip1() * 2, taser:GetPrimaryAmmoType(), true)
			ply:Give("weapon_sogknife")
			-- ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_walkie_talkie")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade_tpik")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	--==//
	
	--==\\
	--; СДЕЛАТЬ ЕМУ ЛУТ ДРУГИХ ИГРОКОВ ДАЖЕ ПОКА У НИХ НЕТ ПУШКИ В РУКАХ
	--; Сделать ему вырубание по вагус нерву
	["traitor_assasin"] = {
        Name = "암살자",
        Description = [[어느 각도에서든 상대를 빠르게 무장 해제시킬 수 있습니다.
뒤에서 공격할 시 더 빠르게 무장 해제합니다.
상대가 쓰러진 상태(래그돌)라면 정면에서도 더 빠르게 무장 해제합니다.
총기 사용 능력이 뛰어납니다.
추가 스태미나를 보유하고 있습니다 (다른 배신자보다 +80 유닛).
무전기가 지급됩니다.
속전속결을 즐기는 분들을 위한 직업입니다.]],
        Objective = "당신은 총기와 무장 해제의 전문가입니다. 무장한 적의 무기를 빼앗아 역으로 이용하십시오.",
		SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")	
			-- ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_hg_smokenade_tpik")
			-- ply:Give("weapon_hg_shuriken")
			
			ply.organism.recoilmul = 0.8
			ply.organism.stamina.max = 300
			--local inv = ply:GetNetVar("Inventory", {}) // WHY SOMEONE COMMENTED THIS
			--inv["Weapons"]["hg_flashlight"] = true
			
			--ply:SetNetVar("Inventory", inv) // BUT NOT THIS???
		end,
	},
	["traitor_assasin_soe"] = {
        Name = "암살자",
        Description = [[어느 각도에서든 상대를 빠르게 무장 해제시킬 수 있습니다.
뒤에서 공격할 시 더 빠르게 무장 해제합니다.
상대가 쓰러진 상태(래그돌)라면 정면에서도 더 빠르게 무장 해제합니다.
총기 사용 능력이 뛰어납니다.
추가 스태미나를 보유하고 있습니다 (다른 배신자보다 +80 유닛).
무전기가 지급됩니다.
속전속결을 즐기는 분들을 위한 직업입니다.]],
        Objective = "당신은 총기와 무장 해제의 전문가입니다. 무장한 적의 무기를 빼앗아 역으로 이용하십시오.",
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")	
			ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_walkie_talkie")
			-- ply:Give("weapon_hg_smokenade_tpik")
			-- ply:Give("weapon_hg_shuriken")
			
			ply.organism.recoilmul = 0.4
			ply.organism.stamina.max = 300
			--local inv = ply:GetNetVar("Inventory", {}) // WHY SOMEONE COMMENTED THIS
			--inv["Weapons"]["hg_flashlight"] = true
			
			--ply:SetNetVar("Inventory", inv) // BUT NOT THIS???
		end,
	},
	--==//
	
	--==\\
	["traitor_chemist"] = {
        Name = "화학자",
        Description = [[다양한 화학 작용제와 에피펜, 단검을 보유하고 있습니다.
모든 화학 작용제에 대해 일정 수준의 저항력을 가지고 있습니다.
공기 중의 화학 작용제 존재 여부와 그 농도를 감지할 수 있습니다.]],
        Objective = "자신의 지식을 타인을 해치는 데 사용하기로 결심한 화학자입니다. 모든 것에 독을 퍼뜨리십시오.",
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_traitor_poison1")
			ply:Give("weapon_traitor_poison2")
			ply:Give("weapon_traitor_poison3")
			ply:Give("weapon_traitor_poison4")
			ply:Give("weapon_traitor_poison_consumable")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
			CleanChemicalsOfPlayer(ply)
		end,
	},
	--==//
	--==\\
	["traitor_cannibal"] = {
		Name = "식인종",
		Description = [[시체를 먹어 체력을 회복할 수 있습니다.
시체를 끝까지 먹어 해골 상태로 만든 뒤 한 번 더 먹으면 시체와 주변의 피, 뼈, 살점 잔해가 사라집니다.
마체테, 식인 도구, 곰덫, 마취총이 지급됩니다.]],
		Objective = "당신은 식인종입니다. 마체테로 희생자를 만들고 흔적도 남기지 말고 먹어 치우십시오.",
		SpawnFunction = function(ply)
			if not IsValid(ply) then return end
			local machete = ply:Give("weapon_hg_machete")
			if IsValid(machete) then
				-- The base machete is a NoHolster world item, so the common homicide
				-- loadout's final switch to hands immediately drops it. This role's
				-- issued machete must remain available alongside its other tools.
				machete.NoHolster = false
			end
			ply:Give("weapon_cannibalism")
			ply:Give("weapon_beartrap_homigrad")
			ply:Give("weapon_tranquilizer")
		end,
	},
	--==//
	-- ["traitor_demoman"] = {
		-- Name = "Demoman",
		-- Description = [[Has many explosives.
-- Can rig certain items with bombs
-- (Radio, certain consumables, etc.)]],
		-- Objective = "You're the ultimate chemist who decided to use knowledge to hurt others.",
		-- SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")
			-- ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_hg_pipebomb_tpik")
			-- ply:Give("weapon_hg_smokenade_tpik")
			-- ply:Give("weapon_traitor_ied")
			-- ply:Give("weapon_walkie_talkie")
			
			-- ply.organism.stamina.max = 220
			-- local inv = ply:GetNetVar("Inventory", {})
			-- inv["Weapons"]["hg_flashlight"] = true
			
			-- ply:SetNetVar("Inventory", inv)
		-- end,
	-- },
	["traitor_zombie"] = {
        Name = "좀비",
        Description = [[다른 플레이어를 소리 없이 감염시킬 수 있습니다.
감염된 플레이어는 의사에 의해 치료될 수 있습니다.
모든 플레이어가 치료되면 좀비는 패배합니다.
사망하는 대신, 무작위로 다른 감염된 플레이어의 몸으로 전이됩니다.
무기나 도구가 전혀 지급되지 않습니다.
좀비임에도 불구하고 평범한 인간의 외형을 유지합니다.]],
        Objective = "당신은 좀비입니다. 승리하기 위해 모두를 감염시키십시오. 의사를 피하십시오.",
		SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")	
			-- ply:Give("weapon_adrenaline")
			
			-- ply.organism.stamina.max = 220
			-- local inv = ply:GetNetVar("Inventory", {})
			-- inv["Weapons"]["hg_flashlight"] = true
			
			-- ply:SetNetVar("Inventory", inv)
		end,
	},
	--=//
}
--//

--\\Professions
MODE.ProfessionsRoundTypes = {
	["standard"] = true,
	["soe"] = true,
}

MODE.Professions = {
	["doctor"] = {
		Name = "의사",
		SpawnFunction = function(ply)
			ply:Give("weapon_bandage_sh")
		end,
	},
	["huntsman"] = {
		Name = "사냥꾼",
		SpawnFunction = function(ply)
			--; It's a bad practice to give professions any weapons or tools
		end,
	},
	["engineer"] = {
		Name = "기술자",
		SpawnFunction = function(ply)
			ply:Give("weapon_ducttape")
		end,
	},
	["cook"] = {
		Name = "요리사",
		SpawnFunction = function(ply)
			ply:Give("weapon_smallconsumable")
		end,
	},
	["builder"] = {
		Name = "건설자",
		SpawnFunction = function(ply)
			local inv = ply:GetNetVar("Inventory") or {}
			inv["Weapons"] = inv["Weapons"] or {}
			inv["Weapons"]["hg_flashlight"] = true
			ply:SetNetVar("Inventory", inv)
		end,
	},
}
--//

--\\
--; Названия перменных чуть чуть конченные получились, нужно будет подумать как улучшить
--; ужас
MODE.FadeScreenTime = 1.5
MODE.DefaultRoundStartTime = 6
MODE.RoleChooseRoundStartTime = 10

MODE.RoleChooseRoundTypes = {
	["standard"] = {
		TraitorDefaultRole = "traitor_default",
		Traitor = {
			["traitor_default"] = true,
			["traitor_infiltrator"] = true,
			["traitor_chemist"] = true,
			["traitor_assasin"] = true,
			["traitor_cannibal"] = true,
			--; ОБЪЕДЕНИТЬ ХИМИКА И ДИВЕРСАНТА!!! наверное
			-- ["traitor_demoman"] = true,
		},
		Professions = {
			["doctor"] = {
				Chance = 1,
			},
			["huntsman"] = {
				Chance = 1,
			},
			["engineer"] = {
				Chance = 1,
			},
			["cook"] = {
				Chance = 1,
			},
			["builder"] = {
				Chance = 1,
			},
		},
	},
	["soe"] = {
		TraitorDefaultRole = "traitor_default_soe",
		Traitor = {
			["traitor_default_soe"] = true,
			["traitor_infiltrator_soe"] = true,
			-- ["traitor_chemist_soe"] = true,
			["traitor_assasin_soe"] = true,
			-- ["traitor_demoman_soe"] = true,
		},
		Professions = {
			["doctor"] = {
				Chance = 1,
			},
			["huntsman"] = {
				Chance = 1,
			},
			["engineer"] = {
				Chance = 1,
			},
			["cook"] = {
				Chance = 1,
			},
		},
	},
}
--//

MODE.Roles = {}
MODE.Roles.soe = {
	traitor = {
		name = "Traitor",
		color = Color(190,0,0)
	},

	gunner = {
		name = "Innocent",
		color = Color(158,0,190)
	},

	innocent = {
		name = "Innocent",
		color = Color(0,120,190)
	},
}

MODE.Roles.standard = {
	traitor = {
		objective = "이 순간을 위해 오랫동안 준비해왔습니다. 모두 죽이십시오.",
		name = "살인자",
		color = Color(190,0,0)
	},

	gunner = {
		name = "방관자",
		color = Color(158,0,190)
	},

	innocent = {
		name = "방관자",
		color = Color(0,120,190)
	},
}

MODE.Roles.wildwest = {
	traitor = {
		objective = "이 순간을 위해 오랫동안 준비해왔습니다. 모두 죽이십시오.",
		name = "살인자",
		color = Color(190,0,0)
	},

	gunner = {
		name = "방관자",
		color = Color(159,85,0)
	},

	innocent = {
		name = "방관자",
		color = Color(159,85,0)
	},
}

-- BANG! uses four private roles.  These three entries are only compatibility
-- fallbacks for the common Homicide code; the private role HUD uses BangRole.
MODE.Roles.bang = {
	traitor = {
		name = "무법자",
		color = Color(190, 45, 25)
	},
	gunner = {
		name = "보안관",
		color = Color(220, 165, 35)
	},
	innocent = {
		name = "서부의 총잡이",
		color = Color(80, 150, 210)
	},
}

function MODE:HG_MovementCalc_2(mul, ply, cmd, mv)
	if self.Type ~= "bang" or (zb.ROUND_START or 0) + 10 <= CurTime() or not cmd then return end

	cmd:RemoveKey(IN_ATTACK)
	cmd:RemoveKey(IN_ATTACK2)
	if mv then
		mv:RemoveKey(IN_ATTACK)
		mv:RemoveKey(IN_ATTACK2)
	end
end

function MODE:PlayerCanLegAttack(ply)
	if self.Type == "bang" and (zb.ROUND_START or 0) + 10 > CurTime() then
		return false
	end
end

MODE.Roles.gunfreezone = {
	traitor = {
		name = "살인자",
		color = Color(190,0,0)
	},

	gunner = {
		name = "무고한 자",
		color = Color(0,120,190)
	},

	innocent = {
		name = "무고한 자",
		color = Color(0,120,190)
	},
}

MODE.Roles.supermario = {
    traitor = {
        objective = "당신은 사악한 마리오입니다! 사방을 점프하며 모두를 쓰러뜨리십시오.",
        name = "배신자 마리오",
        color = Color(190,0,0)
    },

    gunner = {
        objective = "당신은 영웅 마리오입니다! 점프 능력을 사용해 배신자를 저지하십시오.",
        name = "영웅 마리오",
        color = Color(158,0,190)
    },

    innocent = {
        objective = "당신은 구경꾼 마리오입니다. 살아남아서 배신자의 함정을 피하십시오!",
        name = "시민 마리오",
        color = Color(0,120,190)
    },
}

function MODE.GetPlayerTraceToOther(ply, aim_vector, dist)
	local trace = hg.eyeTrace(ply, dist, nil, aim_vector)
	
	if(trace)then
		local aim_ent = trace.Entity
		local other_ply = nil
		
		if(IsValid(aim_ent))then
			if(aim_ent:IsPlayer())then
				other_ply = aim_ent
			elseif(aim_ent:IsRagdoll())then
				if(IsValid(aim_ent.ply))then
					other_ply = aim_ent.ply
				end
			end
		end
		
		return aim_ent, other_ply, trace
	else
		return nil
	end
end
