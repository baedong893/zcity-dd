local MODE = MODE


local NET_COMMANDER_MENU = 1
local NET_COMMANDER_PURCHASE = 2
local NET_REQUEST_SUPPORT = 3
local NET_COMMANDER_NOTIFICATION = 4

util.AddNetworkString("defense_commander_menu")
util.AddNetworkString("defense_commander_purchase")
util.AddNetworkString("RequestSupport")
util.AddNetworkString("defense_commander_notification")

local supportCooldown = 290 
local lastSupportRequest = 0

local function FindAirdropPosition()
    local validPlayers = {}

    for _, ply in player.Iterator() do
        if ply:Alive() and ply:Team() != TEAM_SPECTATOR then
            table.insert(validPlayers, ply)
        end
    end
    
    if #validPlayers == 0 then return nil end
    
    local centerPos = Vector(0, 0, 0)
    for _, ply in ipairs(validPlayers) do
        centerPos = centerPos + ply:GetPos()
    end
    centerPos = centerPos / #validPlayers
    

    local attempts = 20 
    for i = 1, attempts do
        local randomOffset = Vector(math.random(-800, 800), math.random(-800, 800), 0)
        local dropPos = centerPos + randomOffset
        

        local skyCheckHeight = 4000

        local skyTrace = util.TraceLine({
            start = dropPos + Vector(0, 0, skyCheckHeight),
            endpos = dropPos,
            mask = MASK_SOLID
        })
        

        if skyTrace.HitSky or not skyTrace.Hit then
            local groundTrace = util.TraceLine({
                start = dropPos + Vector(0, 0, 100),
                endpos = dropPos - Vector(0, 0, 5000),
                mask = MASK_SOLID_BRUSHONLY
            })
            
            if groundTrace.Hit then
                local finalPos = groundTrace.HitPos + Vector(0, 0, 10)
                

                local spaceCheck = util.TraceHull({
                    start = finalPos,
                    endpos = finalPos,
                    mins = Vector(-20, -20, 0),
                    maxs = Vector(20, 20, 50),
                    mask = MASK_SOLID
                })
                
                if not spaceCheck.Hit then
                    local startHeight = skyTrace.HitPos.z > 0 and skyTrace.HitPos.z or skyCheckHeight
                    local dropPathTrace = util.TraceLine({
                        start = Vector(finalPos.x, finalPos.y, startHeight),
                        endpos = finalPos,
                        mask = MASK_SOLID_BRUSHONLY,
                        filter = function(ent) 
                            return not (ent:IsPlayer() or ent:IsWeapon() or ent:GetClass():StartWith("prop_physics"))
                        end
                    })
                    
                   
                    if not dropPathTrace.Hit or dropPathTrace.HitPos:Distance(finalPos) < 50 then
                        local adjustedStartHeight = dropPathTrace.Hit 
                            and (dropPathTrace.HitPos.z + 500) 
                            or startHeight
                            
                        
                        return finalPos, Vector(finalPos.x, finalPos.y, math.min(adjustedStartHeight, skyCheckHeight))
                    else
                       
                        --print("[DEFENSE] Airdrop path blocked at height: " .. dropPathTrace.HitPos.z)
                    end
                end
            end
        end
    end
    
    --print("[DEFENSE] Could not find suitable airdrop position after " .. attempts .. " attempts")
    return nil
end


local function CreateFallingAirdrop(items, requester)
    local dropPos, startPos = FindAirdropPosition()
    
    if not dropPos then
       
        local spawnPoints = zb.GetMapPoints("DEFENSE_POINT")
        if spawnPoints and #spawnPoints > 0 then
            local selectedPoint = spawnPoints[math.random(#spawnPoints)]
            dropPos = selectedPoint.pos
            
            local upTrace = util.TraceLine({
                start = dropPos,
                endpos = dropPos + Vector(0, 0, 3000),
                mask = MASK_SOLID_BRUSHONLY
            })
            
            if upTrace.Hit then
                startPos = Vector(dropPos.x, dropPos.y, upTrace.HitPos.z - 100)
            else
                startPos = dropPos + Vector(0, 0, 2000)
            end
        else
            if IsValid(requester) then
                requester:ChatPrint("보급품을 전달할 적절한 장소를 찾을 수 없습니다. 나중에 다시 시도해 주세요.")
            end
            return false
        end
    end
    

    local crate = ents.Create("ent_airdrop")
    if not IsValid(crate) then
        if IsValid(requester) then
            requester:ChatPrint("보급 상자를 생성하지 못했습니다. 포인트를 환불합니다.")
        end
        return false
    end

    crate:SetPos(startPos)
    crate:SetNWString("Contents", table.concat(items, ","))
    crate:Spawn()
    

    crate.TargetPos = dropPos
    crate.FallSpeed = 150 

    local light = ents.Create("light_dynamic")
    light:SetPos(crate:GetPos())
    light:SetKeyValue("brightness", "5")
    light:SetKeyValue("distance", "200")
    light:Fire("Color", "255 0 0")
    light:SetParent(crate)
    light:Spawn()
    light:Activate()
    

    local smoke = ents.Create("env_smoketrail")
    smoke:SetPos(crate:GetPos())
    smoke:SetKeyValue("spawnrate", "20")
    smoke:SetKeyValue("startsize", "10")
    smoke:SetKeyValue("endsize", "50")
    smoke:SetKeyValue("startcolor", "200 200 200")
    smoke:SetKeyValue("endcolor", "150 150 150")
    smoke:SetKeyValue("lifetime", "15")
    smoke:SetParent(crate)
    smoke:Spawn()
    smoke:Activate()

    crate:EmitSound("ambient/machines/train_horn_distant1.wav", 100, 100)
    

    local fallTimer = "airdrop_fall_" .. crate:EntIndex()
    timer.Create(fallTimer, 0.05, 0, function()
        if not IsValid(crate) then 
            timer.Remove(fallTimer)
            return 
        end
        
        local curPos = crate:GetPos()
        local distToTarget = curPos:Distance(crate.TargetPos)
        local fallVector = (crate.TargetPos - curPos):GetNormalized() * math.min(crate.FallSpeed * 0.05, distToTarget)
        
        crate:SetPos(curPos + fallVector)
        

        if IsValid(light) then
            if CurTime() % 1 < 0.5 then
                light:Fire("TurnOn", "", 0)
            else
                light:Fire("TurnOff", "", 0)
            end
        end
 
        if distToTarget < 10 then
            timer.Remove(fallTimer)
            crate:EmitSound("physics/metal/metal_box_impact_hard" .. math.random(1, 3) .. ".wav", 100)
            
            if IsValid(light) then light:Remove() end
            if IsValid(smoke) then smoke:Remove() end
            

            for _, player in player.Iterator() do
                if player:Alive() and player:Team() ~= TEAM_SPECTATOR then
                    if IsValid(requester) then
                        player:ChatPrint("지휘관 " .. requester:Nick() .. "님의 보급품이 도착했습니다!")
                    else
                        player:ChatPrint("보급품이 도착했습니다!")
                    end
                end
            end
        end
    end)
    
    return true
end


local function SpawnSupportTeam(requester)
    if not IsValid(requester) then return false end
    
    local pos = requester:GetPos()
    local spawnPoints = {}
    

    for i = 1, 8 do
        local angle = math.rad(i * 45)
        local spawnPos = pos + Vector(math.cos(angle) * 150, math.sin(angle) * 150, 0)
        
        local trace = util.TraceLine({
            start = spawnPos + Vector(0, 0, 50),
            endpos = spawnPos - Vector(0, 0, 100),
            mask = MASK_SOLID_BRUSHONLY,
            filter = requester
        })
        
        if trace.Hit then
            local spaceCheck = util.TraceHull({
                start = trace.HitPos + Vector(0, 0, 10),
                endpos = trace.HitPos + Vector(0, 0, 10),
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 72),
                mask = MASK_SOLID_BRUSHONLY,
                filter = requester
            })
            
            if not spaceCheck.Hit then
                table.insert(spawnPoints, trace.HitPos + Vector(0, 0, 10))
            end
        end
    end
    
    if #spawnPoints < 2 then
        if IsValid(requester) then
            requester:ChatPrint("지원 팀을 배치할 공간이 부족합니다!")
        end
        return false
    end
    

    local supportModels = {
        "models/player/combine_soldier.mdl",
        "models/player/combine_super_soldier.mdl",
        "models/player/police.mdl",
        "models/player/urban.mdl",
        "models/player/riot.mdl",
        "models/player/gasmask.mdl"
    }
    

    local supportWeapons = {
        "weapon_ar15",
        "weapon_akm",
        "weapon_mp5",
        "weapon_m249"
    }
    

    local teamSize = math.random(3, 4)
    local successfulSpawns = 0
    
    for i = 1, teamSize do
        if #spawnPoints == 0 then break end
        
        local spawnIndex = math.random(1, #spawnPoints)
        local spawnPos = spawnPoints[spawnIndex]
        table.remove(spawnPoints, spawnIndex)
        

        local npc = ents.Create("npc_citizen")
        if not IsValid(npc) then continue end
        
        npc:SetPos(spawnPos)
        npc:SetAngles(Angle(0, math.random(0, 360), 0))
        npc:SetModel(supportModels[math.random(#supportModels)])
        npc:SetKeyValue("citizentype", "3") 
        npc:SetKeyValue("expressiontype", "2") 
        npc:SetKeyValue("spawnflags", "256") 
        npc:SetKeyValue("SquadName", "CommanderSupportTeam_" .. requester:EntIndex())
        

        npc:Spawn()
        npc:Activate()
        
        local weapon = supportWeapons[math.random(#supportWeapons)]
        npc:Give(weapon)
        

        npc:AddEntityRelationship(requester, D_LI, 99)
        for _, player in player.Iterator() do
            if player:IsPlayer() and player:Alive() and player:Team() != TEAM_SPECTATOR then
                npc:AddEntityRelationship(player, D_LI, 99)
                player:AddEntityRelationship(npc, D_LI, 99)
            end
        end
        

        npc:SetTarget(requester)
        npc:SetSchedule(SCHED_FOLLOW)
        
        npc.IsSupportTeamMember = true
        
        successfulSpawns = successfulSpawns + 1
    end
    
    if successfulSpawns > 0 then
        requester:ChatPrint("지원 팀이 " .. successfulSpawns .. "명의 병사와 함께 배치되었습니다")
        

        for _, player in player.Iterator() do
            if player:Alive() and player:Team() != TEAM_SPECTATOR and player != requester then
                player:ChatPrint("지휘관 " .. requester:Nick() .. "님이 지원 팀을 호출했습니다!")
            end
        end
        
        requester:EmitSound("ambient/levels/streetwar/city_battle" .. math.random(1, 7) .. ".wav")
        
        return true
    end
    
    return false
end


local function RespawnDeadPlayers(requester)
    if not IsValid(requester) then return false end
    
    local MODE = CurrentRound()
    if not MODE then return false end
    

    local deadPlayers = {}
    for _, ply in player.Iterator() do
        if not ply:Alive() and ply:Team() != TEAM_SPECTATOR then
            table.insert(deadPlayers, ply)
        end
    end
    
    if #deadPlayers == 0 then
        if IsValid(requester) then
            requester:ChatPrint("부활시킬 죽은 플레이어가 없습니다!")
        end
        return false
    end
    

    if #deadPlayers > 4 then
        table.Shuffle(deadPlayers)
        local selectedPlayers = {}
        for i = 1, 4 do
            table.insert(selectedPlayers, deadPlayers[i])
        end
        deadPlayers = selectedPlayers
    end
    

    local spawnPoints = MODE.GetUsualPlayerSpawnPoints and MODE:GetUsualPlayerSpawnPoints() or {}
    if not spawnPoints or #spawnPoints == 0 then
        if IsValid(requester) then
            requester:ChatPrint("사용 가능한 스폰 지점이 없습니다!")
        end
        return false
    end
    
   
    local function EquipBaseGear(ply)
        if not ply or not IsValid(ply) then return end
        
        local inv = ply:GetNetVar("Inventory")
        if not inv or not inv["Weapons"] then return end
        
        inv["Weapons"]["hg_sling"] = true
        ply:SetNetVar("Inventory", inv)

        local weaponClass = DEFENSE_WEAPONS[0][math.random(#DEFENSE_WEAPONS[0])]
        local gun = ply:Give(weaponClass)
        
        timer.Simple(0.2, function()
            if IsValid(ply) and IsValid(gun) then
                if gun.GetMaxClip1 and isfunction(gun.GetMaxClip1) then
                    local ammoAmount = gun:GetMaxClip1() * 3
                    ply:GiveAmmo(ammoAmount, gun:GetPrimaryAmmoType(), true)
                else
                    ply:GiveAmmo(30, ply:GetWeapon(weaponClass):GetPrimaryAmmoType(), true)
                end
                pcall(function()
                    hg.AddAttachmentForce(ply, gun, DEFENSE_ATTACHMENTS[0][math.random(#DEFENSE_ATTACHMENTS[0])])
                end)
            end
        end)
        
        pcall(function()
            hg.AddArmor(ply, DEFENSE_ARMOR[0][math.random(#DEFENSE_ARMOR[0])])
        end)
        
        ply:Give("weapon_melee")
        ply:Give("weapon_hg_rgd_tpik")
        ply:Give("weapon_walkie_talkie")
        ply:Give("weapon_bandage_sh")
        ply:Give("weapon_tourniquet")
        

        local role = ply:GetNWString("PlayerRole", "")
        if role == "Medic" then
            ply:Give("weapon_medkit_sh")
            local wep = ply:Give("weapon_bloodbag")
            timer.Simple(0.2, function() 
                if IsValid(wep) then 
                    wep.modeValues = wep.modeValues or {}
                    wep.modeValues[1] = 1 
                    wep.bloodtype = "o-" 
                end 
            end)
            ply:Give("weapon_painkillers")
            ply:Give("weapon_betablock")
            ply:Give("weapon_adrenaline")
            ply:Give("weapon_morphine")
        elseif role == "Engineer" then
            ply:Give("weapon_hammer")
            ply:Give("weapon_ducttape")
            ply:Give("weapon_hg_pipebomb_tpik")
            ply:Give("weapon_claymore")
            ply:GiveAmmo(40, "Nails", true)
        end
    end
    

    local respawnedCount = 0
    for _, ply in ipairs(deadPlayers) do
        if IsValid(ply) and not ply:Alive() and ply:Team() != TEAM_SPECTATOR then

            local spawnPoint = spawnPoints[math.random(#spawnPoints)]
            local spawnPos = MODE.GetGroundedPlayerSpawn and MODE:GetGroundedPlayerSpawn(spawnPoint) or spawnPoint.pos
            

            ply:Spawn()
            

            ply:SetPos(spawnPos)
            ply:SetLocalVelocity(vector_origin)

            if spawnPoint.ang then
                ply:SetEyeAngles(Angle(0, spawnPoint.ang.y, 0))
            end
            

            ply:SetSuppressPickupNotices(true)
            ply.noSound = true
            
            EquipBaseGear(ply)
            
            timer.Simple(0.1, function()
                if IsValid(ply) then
                    local hands = ply:Give("weapon_hands_sh")
                    if IsValid(hands) then
                        ply:SelectWeapon("weapon_hands_sh")
                    end
                end
            end)
            
            ply:SetSuppressPickupNotices(false)
            ply.noSound = false
            

            local effectData = EffectData()
            effectData:SetOrigin(ply:GetPos() + Vector(0, 0, 30))
            util.Effect("ManhackSparks", effectData)
            
            ply:EmitSound("items/suitchargeok1.wav")
            
            respawnedCount = respawnedCount + 1
        end
    end
    
    if respawnedCount > 0 then

        for _, player in player.Iterator() do
            player:ChatPrint("지휘관 " .. requester:Nick() .. "님이 증원군을 호출했습니다! " .. respawnedCount .. "명의 플레이어가 부활했습니다!")
        end
        

        for _, ply in player.Iterator() do
            ply:EmitSound("ambient/alarms/combine_bank_alarm_loop1.wav")
        end
        
        timer.Simple(2, function()
            for _, ply in player.Iterator() do
				if not IsValid(ply) then return end
                ply:StopSound("ambient/alarms/combine_bank_alarm_loop1.wav")
            end
        end)
        
        return true
    end
    
    return false
end


local function FindItemByEntity(entityName)
    for category, items in pairs(DEFENSE_COMMANDER_ITEMS) do
        for _, item in ipairs(items) do
            if item.entity == entityName then
                return item
            end
        end
    end
    return nil
end


local lastSupportResult = nil
local lastSupportTime = 0

net.Receive("RequestSupport", function(len, ply)
    if not ply.LastSupportRequestTime then ply.LastSupportRequestTime = 0 end
    if CurTime() - ply.LastSupportRequestTime < 2 then return end
    ply.LastSupportRequestTime = CurTime()
    
    if ply:GetNWString("PlayerRole") != "Commander" then return end
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then return end

    if CurTime() - lastSupportRequest < supportCooldown then
ply:ChatPrint("잠시 기다려 주십시오.")
        return
    end

    if ply.organism and ply.organism.otrub then
        ply:ChatPrint("wtf") -- 원문 유지 (당혹감을 나타내는 표현이므로 그대로 둠)
        return
    end

    local supportType = net.ReadString()

    if not DEFENSE_SUPPORT_ITEMS[supportType] then return end
    
    local orderId = string.upper(util.CRC(ply:SteamID() .. CurTime() .. math.random(1, 10000)):sub(1, 7))
    lastSupportRequest = CurTime()

    
    ply:ChatPrint("주문 번호 #" .. orderId .. "가 오고 있습니다!")

    local delay = math.random(20, 40)
    local timerName = "airdrop_timer_" .. orderId

    if MODE and MODE.CreateTimer then
        MODE:CreateTimer(timerName, delay, 1, function()
            if math.random(1, 100) <= 5 then
                if IsValid(ply) then
                    ply:ChatPrint(DEFENSE_FAILED_MESSAGES[math.random(#DEFENSE_FAILED_MESSAGES)])
                end
                return
            end
            
            local items = DEFENSE_SUPPORT_ITEMS[supportType] or {}
            local success = CreateFallingAirdrop(items, ply)
            
            if not success and IsValid(ply) then
                ply:ChatPrint("적절한 투하 장소를 찾는 데 실패했습니다.")
            end
        end)
    end
end)


net.Receive("defense_commander_purchase", function(len, ply)
    if not ply.LastPurchaseTime then ply.LastPurchaseTime = 0 end
    if CurTime() - ply.LastPurchaseTime < 1 then return end
    ply.LastPurchaseTime = CurTime()
    
    if not IsValid(ply) or ply:GetNWString("PlayerRole") ~= "Commander" or not ply:Alive() then return end
    
    if ply.organism and ply.organism.otrub then
        net.Start("defense_commander_notification")
        net.WriteString("현재 상태에서는 주문을 할 수 없습니다!")
        net.WriteInt(0, 16)
        net.Send(ply)
        return
    end
    
    local MODE = CurrentRound()
    if not MODE or MODE.name ~= "defense" then return end
    

    if len > 8192 then 
        ply:Kick("Net message overflow")
        return 
    end
    
    local items = net.ReadTable()
    if not istable(items) then return end

    local requestCount = 0
    for _ in pairs(items) do
        requestCount = requestCount + 1
        if requestCount > 20 then return end
    end

    if requestCount == 0 then return end

    local totalCost = 0
    local regularCost = 0
    local itemEntities = {}
    local specialItems = {}
    local requestedQuantities = {}
    
    
    for _, item in pairs(items) do
        if not istable(item) or not isstring(item.entity) then return end
        
        local foundItem = FindItemByEntity(item.entity)
        if not foundItem then return end

        local rawQuantity = tonumber(item.quantity)
        if not rawQuantity or rawQuantity ~= rawQuantity or rawQuantity == math.huge or rawQuantity == -math.huge then return end
        if rawQuantity < 1 or rawQuantity > 10 or math.floor(rawQuantity) ~= rawQuantity then return end

        local quantity = rawQuantity
        requestedQuantities[item.entity] = (requestedQuantities[item.entity] or 0) + quantity
        if requestedQuantities[item.entity] > 10 then return end

        local price = tonumber(foundItem.price)
        if not price or price < 0 then return end

        local itemCost = price * quantity
        totalCost = totalCost + itemCost
        
        if foundItem.special then
            table.insert(specialItems, {
                item = foundItem,
                quantity = quantity
            })
        else
            regularCost = regularCost + itemCost
            for i = 1, quantity do
                table.insert(itemEntities, foundItem.entity)
            end
        end
    end
    
    local currentPoints = ply:GetNWInt("CommanderPoints", 0)
    
    if totalCost > currentPoints then
        net.Start("defense_commander_notification")
        net.WriteString("이 주문을 위한 보급 포인트가 부족합니다!")
        net.WriteInt(0, 16)
        net.Send(ply)
        return
    end
    

    ply:SetNWInt("CommanderPoints", currentPoints - totalCost)
    
    net.Start("defense_commander_notification")
    net.WriteString("주문이 성공적으로 접수되었습니다! 보급품이 투하 중입니다.")
    net.WriteInt(-totalCost, 16)
    net.Send(ply)
    
    local failedSpecialCost = 0
    
    for _, specialItem in ipairs(specialItems) do
        for i = 1, specialItem.quantity do
            local success = false

            if specialItem.item.entity == "support_team" then
                success = SpawnSupportTeam(ply) == true
            elseif specialItem.item.entity == "player_reinforcements" then
                success = RespawnDeadPlayers(ply) == true
            end

            if not success then failedSpecialCost = failedSpecialCost + specialItem.item.price end
        end
    end
    

    if #itemEntities > 0 then
        timer.Simple(5, function()
            if CurrentRound() ~= MODE or zb.ROUND_STATE ~= 1 or not IsValid(ply) then
                return
            end

            local success = CreateFallingAirdrop(itemEntities, ply)
            
            if not success and IsValid(ply) then
                local refundAmount = regularCost
                
                if refundAmount > 0 and IsValid(ply) then
                    local newPoints = ply:GetNWInt("CommanderPoints", 0) + refundAmount
                    ply:SetNWInt("CommanderPoints", newPoints)
                    
                    net.Start("defense_commander_notification")
                    net.WriteString("적절한 투하 장소를 찾지 못했습니다. 일반 항목에 대한 포인트가 환불되었습니다.")
                    net.WriteInt(refundAmount, 16)
                    net.Send(ply)
                end
            end
        end)
    end
    
    if failedSpecialCost > 0 and IsValid(ply) then
        net.Start("defense_commander_notification")
        net.WriteString("일부 특별 항목을 처리할 수 없습니다. 부분 환불이 이루어졌습니다.")
        net.WriteInt(failedSpecialCost, 16)
        net.Send(ply)
        
        local newPoints = ply:GetNWInt("CommanderPoints", 0) + failedSpecialCost
        ply:SetNWInt("CommanderPoints", newPoints)
    end
end)


net.Receive("defense_commander_menu", function(len, ply)

    if not ply.LastMenuRequestTime then ply.LastMenuRequestTime = 0 end
    if CurTime() - ply.LastMenuRequestTime < 1 then return end
    ply.LastMenuRequestTime = CurTime()
    
    if not IsValid(ply) or ply:GetNWString("PlayerRole") ~= "Commander" or not ply:Alive() then return end

    if ply.LastMenuSendTime and CurTime() - ply.LastMenuSendTime < 5 then
        return 
    end
    ply.LastMenuSendTime = CurTime()
    
    net.Start("defense_commander_menu")
    net.WriteTable(DEFENSE_COMMANDER_ITEMS)
    net.Send(ply)
end)

hook.Add("RoundEnd", "CleanupSupportTeam", function()
    for _, ent in ents.Iterator() do
        if IsValid(ent) and ent.IsSupportTeamMember then
            SafeRemoveEntity(ent)
        end
    end
end)
