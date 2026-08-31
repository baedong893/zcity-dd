include("shared.lua")
SWEP.Category 				= "XYZ"
SWEP.Author        			= "Xyz"
SWEP.Contact 				= "Xyz - STEAM_0:0:40897086"
SWEP.Instructions 			= "Left click to activate, R to change stone, Right click to change stone ability"
SWEP.ViewModel 				= "models/weapons/v_pistol.mdl"
SWEP.WepSelectIcon = surface.GetTextureID("weapons/infinitygauntleticon")

killicon.Add("infinitygauntlet","hud/killicons/infinitygauntletkillicon",Color(255,255,255))

local function UsingOldModel()
	return GetConVar("ig_useoldmodel"):GetBool()
end

local ENT = FindMetaTable("Entity")

net.Receive("IG_StoneUsed",function()
	local ply = net.ReadEntity()
	if !ply:IsValid() then return end
	local wep = ply:GetWeapon("infinitygauntlet")
	if wep:IsValid() then
		wep:PerformStoneGlow(net.ReadUInt(4),net.ReadBool())
	end
end)

net.Receive("IG_PunchAnim",function()
	LocalPlayer():SetAnimation(PLAYER_ATTACK1)
end)

net.Receive("IG_OpenStoneMenu",function()
	local wep = LocalPlayer():GetWeapon("infinitygauntlet")
	if wep:IsValid() and !wep.stoneSpinnerDisplay then
		wep.stoneSpinnerDisplay = true
		gui.EnableScreenClicker(true)
	end
end)

net.Receive("IG_OpenAbilityMenu",function()
	local wep = LocalPlayer():GetWeapon("infinitygauntlet")
	if wep:IsValid() and !wep.stoneAbilityDisplay then
		wep.stoneAbilityDisplay = true
		gui.EnableScreenClicker(true)
	end
end)

local storedNPCCorpses = {}
hook.Add("CreateClientsideRagdoll","IG_RecordDeaths",function(npc,ragdoll)
	storedNPCCorpses[npc:EntIndex()] = ragdoll
end)

net.Receive("IG_NPCCorpseRemoved",function()
	local id = net.ReadUInt(16)
	if storedNPCCorpses[id] then
		if storedNPCCorpses[id]:IsValid() then
			storedNPCCorpses[id]:Remove()
		end
		storedNPCCorpses[id] = nil
	end
end)

function SWEP:PerformStoneGlow(stoneID,isChanneled)
	local elementName = IG_StoneData[stoneID].element
	if self.VElements then
		if istable(elementName) then
			for k,v in pairs(elementName) do
				self.VElements[v].color.a = 255
			end
		else
			self.VElements[elementName].color.a = 255
		end
	end
	if self.WElements then
		if istable(elementName) then
			for k,v in pairs(elementName) do
				self.WElements[v].color.a = 255
			end
		else
			self.WElements[elementName].color.a = 255
		end
	end
	if isChanneled then
		self:StartChannelingStone(stoneID)
	else
		self:StopChannelingStone(stoneID)
	end
end

function SWEP:StartChannelingStone(stoneID)
	self.channelingStones[stoneID] = true
end

function SWEP:StopChannelingStone(stoneID)
	self.channelingStones[stoneID] = nil
end

function SWEP:StopSelectingAbility()
	if self.selectedStone and self.selectedAbility and not IG_ZCityAbilityAllowed(self.selectedStone, self.selectedAbility) then
		self.selectedAbility = IG_ZCityFirstAllowedAbility(self.selectedStone)
	end

	self.stoneAbilityDisplay = false
	gui.EnableScreenClicker(false)
	surface.PlaySound("garrysmod/ui_hover.wav")
	net.Start("IG_SelectedAbility")
	net.WriteUInt(self.selectedAbility or 1,8)
	net.SendToServer()
end

local Rand = math.Rand
local Sin,Cos = math.sin,math.cos
local sinZeroRad,cosZeroRad = Sin(math.rad(0)),Cos(math.rad(0))
local function DrawCircle(x,y,radius,seg)
	local cir = {}
	table.insert(cir,{x = x,y = y,u = 0.5,v = 0.5})
	for i = 0,seg do
		local a = math.rad((i/seg)*-360)
		table.insert(cir,{x = x + Sin(a) * radius,y = y + Cos(a) * radius,u = Sin(a) / 2 + 0.5,v = Cos(a) / 2 + 0.5})
	end
	
	table.insert(cir,{x = x + sinZeroRad * radius,y = y + cosZeroRad * radius,u = sinZeroRad / 2 + 0.5,v = cosZeroRad / 2 + 0.5})
	
	surface.DrawPoly(cir)
end

local function RadToDeg(rad)
	return rad*(180/math.pi)
end

local function DegToRad(deg)
	return (deg*math.pi)/180
end

local function WrapString(str,wide,font)
	if font then surface.SetFont(font) end
	local pos,len,tab = 0,#str,{}
	local maxLenSplit = math.ceil(wide/surface.GetTextSize("A"))*1.5
	while pos < len do
		pos = pos + 1
		local size,_ = surface.GetTextSize(string.sub(str,0,pos))
		if size > wide then
			local c
			repeat
				pos = pos - 1
				c = string.sub(str,pos,pos)
			until c == " " or c == "," or c == "." or c == "\n" or pos <= 0
			if pos <= 0 then
				pos = maxLenSplit
			end
			table.insert(tab,string.sub(str,1,pos))
			str = string.sub(str,pos+1,len)
			pos = 0
		end
	end
	table.insert(tab,str)
	return table.concat(tab,"\n")
end

local menuColor = Color(0,0,0,240)
local optionsPerRow = 7

local spinnerRadius = 150
local infinityRadius = spinnerRadius/4
function SWEP:DrawHUD()
	if self.stoneSpinnerDisplay then
		local cx,cy = gui.MousePos()
		local spinnerX,spinnerY = ScrW()/2,ScrH()/2
		surface.SetDrawColor(menuColor)
		draw.NoTexture()
		DrawCircle(spinnerX,spinnerY,spinnerRadius,50)
		
		local count = 0
		local stoneIDCorrelations = {}
		for i=1,6 do
			if self:HasStone(i) then
				count = count + 1
				stoneIDCorrelations[count] = i
			end
		end
		
		local divisionAngleSize = 360/count
		local hoveringAngle = RadToDeg(math.atan2(cy-spinnerY,cx-spinnerX)-math.pi/2)%360
		local hoveringStone = math.floor((hoveringAngle)/(divisionAngleSize))+1
		
		local hoverInfinity = false
		if self:HasStone(IG_STONE_INFINITY) then
			hoverInfinity = math.Distance(cx,cy,spinnerX,spinnerY) <= infinityRadius
			if hoverInfinity then
				hoveringStone = #IG_StoneData
			end
		end
		
		for i=1,count do
			local stoneData = IG_StoneData[stoneIDCorrelations[i]]
			if count == 2 or hoveringStone == i or hoveringStone == (i)%(count-1) or hoveringStone == i+1 then
				surface.SetDrawColor(Color(255,0,0))
			else
				surface.SetDrawColor(Color(255,255,255,20*i))
			end
			local a = math.rad((i/count)*-360)
			if count > 2 then
				surface.DrawLine(spinnerX,spinnerY,spinnerX+Sin(a)*spinnerRadius,spinnerY+Cos(a)*spinnerRadius)
			elseif count == 2 then
				surface.DrawLine(spinnerX,spinnerY-spinnerRadius,spinnerX,spinnerY+spinnerRadius)
			end
			a = a + DegToRad(divisionAngleSize/2)
			
			local drawColor
			if hoveringStone == i then
				drawColor = Color(255,0,0)
			else
				drawColor = Color(255,255,255)
			end
			
			surface.SetDrawColor(drawColor)
			surface.SetMaterial(stoneData.icon)
			local iconX,iconY = spinnerX+(Sin(a)/1.7)*spinnerRadius,spinnerY+(Cos(a)/1.7)*spinnerRadius
			if count == 1 then
				iconX,iconY = spinnerX,spinnerY
			end
			local iconW,iconH = 25,25
			surface.DrawTexturedRect(iconX-iconW/2,iconY-iconH/2,iconW,iconH)
			draw.SimpleText(stoneData.name or "",nil,iconX,iconY+iconH/2,drawColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		end
		
		surface.SetDrawColor(hoverInfinity and Color(255,0,0) or Color(255,255,255))
		draw.NoTexture()
		if self:HasStone(IG_STONE_INFINITY) then
			DrawCircle(spinnerX,spinnerY,infinityRadius,50)
			draw.SimpleText("Infinity",nil,spinnerX,spinnerY,!hoverInfinity and Color(255,0,0) or Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		
		self.selectedStone = stoneIDCorrelations[hoveringStone] or 7
		self.selectedAbility = nil
		
		draw.SimpleTextOutlined("Release R to select",nil,spinnerX,spinnerY+spinnerRadius*1.1,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,color_black)
		
		if count <= 0 then
			draw.SimpleText("You have no stones.",nil,spinnerX,spinnerY+15,Color(255,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		end
		return
	end
	if self.stoneAbilityDisplay then
		if !self.selectedStone or !self:HasStone(self.selectedStone) then return end
		local stoneData = IG_StoneData[self.selectedStone]
		if !stoneData.abilities then return end
		
		local cx,cy = gui.MousePos()
		local allowedAbilities = {}
		for abilityID in ipairs(stoneData.abilities) do
			if IG_ZCityAbilityAllowed(self.selectedStone, abilityID) then
				allowedAbilities[#allowedAbilities + 1] = abilityID
			end
		end

		local abilityCount = #allowedAbilities
		if abilityCount <= 0 then return end
		local menuWidth,menuHeight,menuSep = 120,200,10
		
		local menuX = ScrW()/2-((math.min(abilityCount,optionsPerRow))*(menuWidth+menuSep)-menuSep)/2
		local menuY = ScrH()/2-(math.ceil(abilityCount/optionsPerRow)*(menuHeight+menuSep))/2
		
		local hoveringAbility
		local thisRow = 0
		local row = 0
		local column = -1
		for _, abilityID in ipairs(allowedAbilities) do
			local ability = stoneData.abilities[abilityID]
			thisRow = thisRow + 1
			column = column + 1
			if thisRow > optionsPerRow then
				row = row + 1
				thisRow = 1
				column = 0
			end
			
			surface.SetDrawColor(menuColor)
			local panelX = menuX+(menuWidth+menuSep)*column
			local panelY = menuY+(menuHeight+menuSep)*row-menuSep*1.5
			
			if !hoveringAbility and (cx > panelX and cy > panelY and cx < panelX+menuWidth and cy < panelY+menuHeight) then
				hoveringAbility = abilityID
			end
			
			draw.RoundedBox(10,panelX,panelY,menuWidth,menuHeight,hoveringAbility == abilityID and Color(0,0,0,250) or menuColor)

			local cooldownEnd = self:GetZCityAbilityCooldownEnd(self.selectedStone, abilityID)
			local cooldownRemaining = math.max(cooldownEnd - CurTime(), 0)
			local cooldownFraction = ability.zcityCooldown and math.Clamp(cooldownRemaining / ability.zcityCooldown, 0, 1) or 0
			if cooldownFraction > 0 then
				local fillHeight = menuHeight * cooldownFraction
				local fillY = panelY + menuHeight - fillHeight
				render.SetScissorRect(panelX, fillY, panelX + menuWidth, panelY + menuHeight, true)
				draw.RoundedBox(10, panelX, panelY, menuWidth, menuHeight, Color(35, 150, 85, 155))
				render.SetScissorRect(0, 0, 0, 0, false)
				surface.SetDrawColor(100, 255, 155, 220)
				surface.DrawLine(panelX + 3, fillY, panelX + menuWidth - 3, fillY)
			end

			surface.SetDrawColor(Color(255,255,255))
			surface.SetFont("DermaDefault")
			
			local textColor = hoveringAbility == abilityID and Color(255,0,0) or Color(255,255,255)
			
			--local numberText = "["..tostring(abilityID).."]"
			local numberText = "["..(self.abilityBindings[self.selectedStone][abilityID] or "UNBOUND").."]"
			local numberW,numberH = surface.GetTextSize(numberText)
			surface.SetTextColor(Color(255,0,0))
			surface.SetTextPos(panelX+menuWidth/2-numberW/2,panelY)
			surface.DrawText(numberText)
			local titleW,titleH = surface.GetTextSize(ability.name)
			surface.SetTextColor(textColor)
			surface.SetTextPos(panelX+menuWidth/2-titleW/2,panelY+numberH)
			surface.DrawText(ability.name)
			local titleLineY = panelY+titleH+numberH+5
			surface.DrawLine(panelX,titleLineY,panelX+menuWidth,titleLineY)
			
			/*if _G["KEY_"..abilityID] then
				if input.IsKeyDown(_G["KEY_"..abilityID]) then
					self.selectedAbility = abilityID
					self:StopSelectingAbility()
					return
				end
			end*/
			
			local description = WrapString(ability.description,menuWidth-1)
			local descW,descH = surface.GetTextSize(description)
			draw.DrawText(description,"DermaDefault",panelX+5,panelY+titleH+numberH+10,textColor)
			surface.DrawLine(panelX,titleLineY+descH+10,panelX+menuWidth,titleLineY+descH+10)
			
			if hoveringAbility == abilityID then
				self.selectedAbility = abilityID

				if cooldownRemaining > 0 then
					draw.DrawText(math.ceil(cooldownRemaining) .. "s cooldown", "DermaDefault", panelX + menuWidth / 2, panelY + menuHeight - 30, Color(150, 255, 185), TEXT_ALIGN_CENTER)
				else
					draw.DrawText("Release to select","DermaDefault",panelX+menuWidth/2,panelY+menuHeight-30,textColor,TEXT_ALIGN_CENTER)
				end
				draw.DrawText("Press number to bind","DermaDefault",panelX+menuWidth/2,panelY+menuHeight-50,textColor,TEXT_ALIGN_CENTER)
			end
		end
		
		return
	end
end

hook.Add("PlayerBindPress","IG_PressButtons",function(ply,bind,press)
	local wep = ply:GetActiveWeapon()
	if wep:IsValid() and wep:GetClass() == "infinitygauntlet" then
		if bind:sub(0,4) == "slot" then
			local num = tonumber(bind:sub(5,5))
			if press then
				if wep.stoneAbilityDisplay then
					if wep.selectedStone and wep.selectedAbility then
						if not IG_ZCityAbilityAllowed(wep.selectedStone, wep.selectedAbility) then return true end

						local prevBoundData = wep.boundNumbers[num]
						if prevBoundData then
							wep.abilityBindings[prevBoundData[1]][prevBoundData[2]] = nil
							wep.boundNumbers[num] = nil
						end
						for k,v in pairs(wep.boundNumbers) do
							if v[1] == wep.selectedStone and v[2] == wep.selectedAbility then
								wep.boundNumbers[k] = nil
							end
						end
						wep.abilityBindings[wep.selectedStone][wep.selectedAbility] = num
						wep.boundNumbers[num] = {wep.selectedStone,wep.selectedAbility}
						return true
					end
				elseif wep.boundNumbers[num] then
					if not IG_ZCityAbilityAllowed(wep.boundNumbers[num][1], wep.boundNumbers[num][2]) then
						wep.boundNumbers[num] = nil
						return true
					end

					if IG_StoneData[wep.boundNumbers[num][1]].abilities[wep.boundNumbers[num][2]].isChanneled then
						wep.channelingBinds[num] = wep.boundNumbers[num]
					end
					net.Start("IG_StoneUsed")
					net.WriteUInt(wep.boundNumbers[num][1],4)
					net.WriteUInt(wep.boundNumbers[num][2],8)
					net.SendToServer()
					return true
				end
			elseif !wep.stoneAbilityDisplay then
				if wep.channelingBinds[num] then
					net.Start("IG_StopChanneling")
					net.WriteUInt(wep.channelingBinds[num][1],4)
					net.SendToServer()
					wep.channelingBinds[num] = nil
					return true
				end
			end
		elseif (bind == "invnext" or bind == "invprev") and table.Count(wep.channelingStones) > 0 then
			net.Start("IG_ChannelMousewheeled")
			net.WriteBool(bind == "invprev")
			net.SendToServer()
			return true
		end
	end
end)

local function MakeStoneParticleFunction(color1,color2)
	return function(emitter,pos)
		pos = pos + VectorRand()*5
		local p = emitter:Add("sprites/physg_glow1",pos)
		p:SetVelocity(Vector(Rand(-1,1),Rand(-1,1),Rand(.1,1))*Rand(1,25))
		p:SetRoll(Rand(-.5, .5))
		p:SetDieTime(Rand(.5,.7))
		p:SetStartAlpha(math.random(150,200))
		p:SetEndAlpha(0)
		p:SetStartSize(Rand(2,5))
		p:SetEndSize(Rand(5, 10))
		p:SetColor(color1.r,color1.g,color1.b)
		
		local spd = 1
		local p = emitter:Add("sprites/physg_glow1",pos)
		p:SetVelocity(Vector(Rand(-spd,spd),Rand(-spd,spd),Rand(spd/10,spd))*Rand(spd,spd))
		p:SetGravity(VectorRand())
		p:SetRoll(Rand(-.5, .5))
		p:SetDieTime(Rand(.5,1.1))
		p:SetStartAlpha(math.random(150,200))
		p:SetEndAlpha(0)
		p:SetStartSize(Rand(8,15))
		p:SetEndSize(Rand(10,10))
		p:SetColor(color2.r,color2.g,color2.b)
		p:SetCollide(true)
	end
end

local MakeSpaceStoneParticle = MakeStoneParticleFunction(Color(0,0,255),Color(18,130,167))
local MakeRealityStoneParticle = MakeStoneParticleFunction(Color(245,6,6),Color(114,51,24))
local MakeMindStoneParticle = MakeStoneParticleFunction(Color(241,144,19),Color(142,79,8))
local MakePowerStoneParticle = MakeStoneParticleFunction(Color(76,15,116,255),Color(42,8,116))
local MakeSoulStoneParticle = MakeStoneParticleFunction(Color(165,69,0,255),Color(108,43,0))

local function MakeStoneGlowDraw(particleFunc)
	return function(ent,data)
		if data.nextParticle and data.nextParticle > CurTime() then return end
		data.nextParticle = CurTime()+.1
		local emitter = ParticleEmitter(ent:GetPos())
		if ent != LocalPlayer() and ent:GetBoneCount() and ent:GetBoneCount() >= 10 then
			local count = ent:GetBoneCount()-1
			for bone=0,count*GetConVar("ig_particlescale"):GetFloat() do
				local matrix = ent:GetBoneMatrix(bone)
				if matrix then
					particleFunc(emitter,matrix:GetTranslation())
				end
			end
		else
			local obbMin, obbMax = ent:OBBMins(),ent:OBBMaxs()
			local count = ent:GetModelRadius()
			if count then
				for i=0,count*GetConVar("ig_particlescale"):GetFloat() do
					particleFunc(emitter,ent:LocalToWorld(Vector(Rand(obbMin.x,obbMax.x),Rand(obbMin.y,obbMax.y),Rand(obbMin.z,obbMax.z))))
				end
			end
		end
		emitter:Finish()
	end
end

local soulBondMat = Material("sprites/tp_beam001")
local entityEffects = {
	spacestone_glow = {
		Draw = MakeStoneGlowDraw(MakeSpaceStoneParticle)
	},
	realitytone_glow = {
		Draw = MakeStoneGlowDraw(MakeRealityStoneParticle)
	},
	mindstone_glow = {
		Draw = MakeStoneGlowDraw(MakeMindStoneParticle)
	},
	powerstone_glow = {
		Draw = MakeStoneGlowDraw(MakePowerStoneParticle)
	},
	soulstone_glow = {
		Draw = MakeStoneGlowDraw(MakeSoulStoneParticle)
	},
	soulbond = {
		Draw = function(ent,data)
			if ent:Health() <= 0 then return end
			local pos = ent:GetPos()+ent:OBBCenter()
			render.SetMaterial(soulBondMat)
			for linked,v in pairs(data) do
				if linked:IsValid() then
					render.DrawBeam(pos,linked:GetPos()+linked:OBBCenter(),5,0,0,IG_StoneData[IG_STONE_SOUL].color)
				end
			end
		end
	},
	copyBoneStruct = {
		BuildBonePositions = function(ent,data)
			for k,v in pairs(data.bones) do
				ent:SetBonePosition(k,ent:LocalToWorld(v[1]),ent:LocalToWorldAngles(v[2]))
			end
		end
	},
	motion_disabled = {
		Draw = function(ent,data)
			if !data.cycle then
				data.cycle = ent:GetCycle() or 0
			end
			ent:SetAnimTime(CurTime()+data.cycle)
		end,
		UpdateAnims = function(ent,data)
			if !ent:GetNumPoseParameters() then return end
			if !data.pose then
				data.pose = {}
				for i=0,ent:GetNumPoseParameters() do
					local name = ent:GetPoseParameterName(i)
					if name then
						local val = ent:GetPoseParameter(name)
						data.pose[name] = val
					end
				end
			end
			for k,v in pairs(data.pose) do
				ent:SetPoseParameter(k,v)
			end
		end
	}
}

local activeEffects = {}
function ENT:IG_EnableEffect(effect,data)
	local effectData = entityEffects[effect]
	if !effectData then return end
	data = data or {}
	
	if effectData.BuildBonePositions then
		local buildFunc = effectData.BuildBonePositions
		self:AddCallback("BuildBonePositions",function(ent)
			buildFunc(ent,data)
		end)
	end
	if !effectData.Draw and !effectData.UpdateAnims then return end

	if !activeEffects[self] then
		activeEffects[self] = {}
	end
	activeEffects[self][effect] = data
end

local entityEffectsWaiting = {}
net.Receive("IG_EnableEntityEffect",function()
	local entID = net.ReadUInt(16)
	if net.ReadBool() then
		if Entity(entID):IsValid() then
			Entity(entID):IG_EnableEffect(net.ReadString(),net.ReadTable())
		else
			entityEffectsWaiting[entID] = entityEffectsWaiting[entID] or {}
			entityEffectsWaiting[entID][#entityEffectsWaiting[entID]+1] = {net.ReadString(),net.ReadTable()}
		end
	else
		entityEffectsWaiting[entID] = nil
		local data = activeEffects[Entity(entID):IsValid() and Entity(entID) or entID]
		if data then
			data[net.ReadString()] = nil
		end
	end
end)

hook.Add("OnEntityCreated","IG_EntityEffectWait",function(ent)
	if entityEffectsWaiting[ent:EntIndex()] then
		for k,v in pairs(entityEffectsWaiting[ent:EntIndex()]) do
			ent:IG_EnableEffect(unpack(v))
		end
	end
end)

net.Receive("IG_ClearEntityEffect",function()
	local entID = net.ReadUInt(16)
	entityEffectsWaiting[entID] = nil
	activeEffects[Entity(entID):IsValid() and Entity(entID) or entID] = nil
end)

hook.Add("PostDrawTranslucentRenderables","IG_DrawEntityEffects",function()
	for ent,data in pairs(activeEffects) do
		if !ent:IsValid() then activeEffects[ent] = nil continue end
		for effectType,effectData in pairs(data) do
			entityEffects[effectType].Draw(ent,effectData)
		end
	end
end)

hook.Add("UpdateAnimation","IG_DrawEntityEffects",function()
	for ent,data in pairs(activeEffects) do
		if !ent:IsValid() then activeEffects[ent] = nil continue end
		for effectType,effectData in pairs(data) do
			if entityEffects[effectType].UpdateAnims then
				entityEffects[effectType].UpdateAnims(ent,effectData)
			end
		end
	end
end)

local invisMod = {
	["$pp_colour_addr"] 		= 211/255,
	["$pp_colour_addg"] 		= 19/255,
	["$pp_colour_addb"] 		= 19/255,
	["$pp_colour_brightness"] 	= -1.46,
	["$pp_colour_contrast"] 	= .16,
	["$pp_colour_colour"] 		= .23,
	["$pp_colour_mulr"] 		= 1,
	["$pp_colour_mulg"] 		= 1,
	["$pp_colour_mulb"] 		= 1,
}

hook.Add("RenderScreenspaceEffects","IG_Effects",function()
	local ply = LocalPlayer()
	if ply:IsValid() and ply:GetNWBool("IG_Invis") then
		DrawColorModify(invisMod)
	end
end)

local soulVisionMod = {
	["$pp_colour_addr"] 		= 206/255,
	["$pp_colour_addg"] 		= 122/255,
	["$pp_colour_addb"] 		= 32/255,
	["$pp_colour_brightness"] 	= -.88,
	["$pp_colour_contrast"] 	= .2,
	["$pp_colour_colour"] 		= 0,
	["$pp_colour_mulr"] 		= 1,
	["$pp_colour_mulg"] 		= 1,
	["$pp_colour_mulb"] 		= 1,
}

hook.Add("PreDrawEffects","IG_DrawSoulVision",function()
	if LocalPlayer():GetNWBool("IG_SoulVision",false) == false then return end
	DrawColorModify(soulVisionMod)
	local ang = EyeAngles()
	ang = Angle(ang.p+90,ang.y,0)
	
	cam.Start3D2D(EyePos()+EyeAngles():Forward()*10,ang,1)
	render.SetBlend(0)
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)
	render.SetStencilReferenceValue(15)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	
	surface.SetDrawColor(206,143,33,255)
	local w,h = ScrW(),ScrH()
	for _,v in ipairs(ents.GetAll()) do
		if (v:IsPlayer() or v:IsNPC()) and v:Health() > 0 then
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
			
			local prevNoDraw = v:GetNoDraw()
			v:SetNoDraw(false)
			local prevRenderMode = v:GetRenderMode()
			v:SetRenderMode(RENDERMODE_TRANSALPHADD)
			v:DrawModel()
			v:SetRenderMode(prevRenderMode)
			v:SetNoDraw(prevNoDraw)
			
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			
			surface.DrawRect(-w,-h,w*2,h*2)
		end
	end
	render.SetStencilEnable(false)
	render.SetBlend(1)
	cam.End3D2D()
end)

local havePutMouseIn = false
hook.Add("Think","IG_StopCursorDeathed",function()
	local ply = LocalPlayer()
	if ply:IsValid() then
		local wep = ply:GetWeapon("infinitygauntlet")
		if IG_ZCityIsInfinityStoneRound() and zb and zb.ROUND_STATE ~= 1 and IsValid(wep) then
			wep.stoneAbilityDisplay = false
			wep.stoneSpinnerDisplay = false
			gui.EnableScreenClicker(false)
		end

		if ply:Alive() then
			havePutMouseIn = false
		elseif !havePutMouseIn then
			havePutMouseIn = true
			gui.EnableScreenClicker(false)
		end
	end
end)

local function ScreenScaleW(wide)
	return wide*(ScrW()/640)
end

local function ScreenScaleH(tall)
	return tall*(ScrH()/480)
end

local function ScreenScale(wide,tall)
	return ScreenScaleW(wide),ScreenScaleH(tall)
end

local border = 2
local function BlackStyled(self,w,h)
	draw.RoundedBox(5,0,0,w,h,color_white)
	draw.RoundedBox(5,border,border,w-border*2,h-border*2,color_black)
end
local function RedFilled(self,w,h)
	draw.RoundedBox(5,0,0,w,h,Color(200,0,0))
end
local function DarkerGray(self,w,h)
	draw.RoundedBox(5,0,0,w,h,Color(45,45,45))
end

local lawDefiningMenu

local function CreateLawEditor(laws)
	if IsValid(lawDefiningMenu) then lawDefiningMenu:Remove() end
	local selectedLaw
	local mainFrame = vgui.Create("DFrame")
	lawDefiningMenu = mainFrame
	mainFrame:SetTitle("Universal Law Defining")
	mainFrame:SetSize(ScreenScale(500,400))
	mainFrame:Center()
	mainFrame:MakePopup()
	mainFrame.Paint = BlackStyled
	
	local lawScroll = vgui.Create("DScrollPanel",mainFrame)
	lawScroll:Dock(LEFT)
	lawScroll:SetPos(ScreenScaleW(2),ScreenScaleH(3))
	local scrollX,scrollY = lawScroll:GetPos()
	lawScroll:SetWide(ScreenScaleW(85))
	lawScroll:SetTall(mainFrame:GetTall()-scrollY*2)
	
	local lawLayout = vgui.Create("DIconLayout",lawScroll)
	lawLayout:SetSize(lawScroll:GetSize())
	
	local lawPanel = vgui.Create("Panel",mainFrame)
	lawPanel:Dock(FILL)
	--lawPanel.Paint = BlackStyled
	
	local function SelectLaw(law)
		selectedLaw = law
		local lawData = laws[law]
		local abilityData = IG_StoneData[IG_STONE_INFINITY].abilities[5]
		local events = abilityData.events
		local actions = abilityData.actions
		local arguments = abilityData.arguments
		local conditionals = abilityData.conditionals
		local types = abilityData.types
		
		for k,v in ipairs(lawPanel:GetChildren()) do
			v:Remove()
		end
		
		local lawPanelScroll = vgui.Create("DScrollPanel",lawPanel)
		lawPanelScroll:Dock(FILL)
		
		local lawPanelLayout = vgui.Create("DIconLayout",lawPanelScroll)
		lawPanelLayout:SetSize(lawScroll:GetSize())
		
		local eventPanel = vgui.Create("Panel",lawPanelScroll)
		eventPanel:Dock(TOP)
		eventPanel:SetTall(ScreenScaleH(90))
		
		local title = vgui.Create("DLabel",eventPanel)
		title:SetFont("Trebuchet24")
		title:SetText(law)
		title:SizeToContents()
		local titleX = ScreenScaleW(5)
		title:Dock(TOP)
		title:DockMargin(titleX,0,0,0)
		
		local eventLabel = vgui.Create("DLabel",eventPanel)
		eventLabel:SetFont("Trebuchet24")
		eventLabel:SetText("Event")
		eventLabel:Dock(TOP)
		eventLabel:DockMargin(titleX,0,0,0)
		
		local eventList = vgui.Create("DComboBox",eventPanel)
		eventList:SetValue("Select Event")
		eventList:Dock(TOP)
		eventList:DockMargin(titleX,0,0,0)
		
		for k,v in pairs(events) do
			eventList:AddChoice(k)
		end
		
		eventPanel:InvalidateLayout(true)
		
		local applyEventBtn = vgui.Create("DButton",eventPanel)
		applyEventBtn:SetTall(ScreenScaleH(15))
		applyEventBtn:SetText("Save & Apply")
		applyEventBtn:Dock(TOP)
		applyEventBtn:DockMargin(titleX,ScreenScaleH(20),0,0)
		
		function applyEventBtn:DoClick()
			local writingLaw = laws[law]
			if writingLaw then
				if !writingLaw.event then
					chat.AddText(Color(255,0,0),"You must select an event before applying!")
					return
				end
				net.Start("IG_DefineLaw")
				net.WriteIGLaw(law,writingLaw)
				net.SendToServer()
			end
		end
		
		local function CreateArgumentEditor(parent,alignmentPanel,readTable,writeTable)
			local argumentMeta = arguments[readTable.type]
			local argumentSettings = {}
			if argumentMeta.settings then--Base off the argument type default value
				table.Merge(argumentSettings,table.Copy(argumentMeta.settings))
			end
			table.Merge(argumentSettings,readTable) --Next, replace the previous default with the event data default.
			
			local argumentEditor = argumentMeta.frame(argumentMeta.noDock and alignmentPanel or parent,writeTable and writeTable.value,argumentSettings,writeTable)
			if !argumentMeta.noDock then
				argumentEditor:Dock(TOP)
				argumentEditor:DockMargin(alignmentPanel:GetDockMargin())
			else
				alignmentPanel:SetMouseInputEnabled(true)
				argumentEditor:SetPos(alignmentPanel:GetWide()+ScreenScaleW(2),0)
			end
			
			return argumentEditor
		end
		
		local function CreateConditional(parent,alignmentPanel,writeTable,rebuildFunction,xOff)
			local totalAlignmentWidth = alignmentPanel:GetWide()+ScreenScaleW(5)+(xOff or 0)
			for k,v in ipairs(alignmentPanel:GetChildren()) do
				totalAlignmentWidth = totalAlignmentWidth + v:GetWide()
			end
			
			local argumentList = vgui.Create("DComboBox",alignmentPanel)
			
			local function GetTargetArgument()
				return writeTable.conditional and writeTable.conditional.targetArgument or argumentList.targetArgument
			end
			
			argumentList:SetWide(ScreenScaleW(80))
			argumentList:SetPos(totalAlignmentWidth)
			argumentList:SetSortItems(false)
			argumentList:SetValue(GetTargetArgument() and events[lawData.event].arguments[GetTargetArgument()].name or "Select Argument For Conditional")
			for argID,argumentData in pairs(events[lawData.event].arguments) do
				argumentList:AddChoice(argumentData.name,argID)
			end
			
			local typeList = vgui.Create("DComboBox",alignmentPanel)
			
			local function GetTargetType()
				return writeTable.conditional and writeTable.conditional.type or typeList.type
			end
			
			typeList:SetWide(ScreenScaleW(80))
			typeList:SetPos(argumentList:GetPos()+argumentList:GetWide())
			typeList:SetSortItems(false)
			function typeList:BuildOptions()
				self:Clear()
				if !GetTargetArgument() then
					self:SetValue("Select Argument First")
					return
				end
				if GetTargetType() then
					typeList.type = GetTargetType()
					typeList:SetValue(types[GetTargetType()] and types[GetTargetType()].name or GetTargetType())
				else
					self:SetValue("Select Type")
				end
				
				local argumentType = events[lawData.event].arguments[GetTargetArgument()].type
				for k,v in ipairs(abilityData.findTypesCompatible(argumentType,{selectibleType=true})) do
					typeList:AddChoice(types[v].name or v,v)
				end
			end
			
			typeList:BuildOptions()
			
			function argumentList:OnSelect(index,argumentName,argumentID)
				if argumentID == GetTargetArgument() then return end
				self.targetArgument = argumentID
				
				if writeTable.conditional then
					writeTable.conditional.targetArgument = argumentID
					writeTable.conditional.type = nil
					writeTable.conditional.conditional = nil
					rebuildFunction()
				else
					typeList:BuildOptions()
				end
			end
			
			local conditionalsList = vgui.Create("DComboBox",alignmentPanel)
			conditionalsList:SetWide(ScreenScaleW(80))
			conditionalsList:SetPos(typeList:GetPos()+typeList:GetWide())
			conditionalsList:SetSortItems(false)
			function conditionalsList:BuildOptions()
				self:Clear()
				if !GetTargetType() then
					self:SetValue("Select Type First")
					return
				end
				self:SetValue(writeTable.conditional and writeTable.conditional.conditional or "Select Condition")
				self:AddChoice("Nothing")
				local type = GetTargetType()
				for conditionalName,conditionalData in pairs(conditionals) do
					if abilityData.typeFitsFilter(type,conditionalData.types) then
						self:AddChoice(conditionalName)
					end
				end
			end
			conditionalsList:BuildOptions()
			
			local invertLabel = vgui.Create("DLabel",alignmentPanel)
			invertLabel:SetPos(conditionalsList:GetPos()+conditionalsList:GetWide())
			invertLabel:SetText("Invert Conditional")
			invertLabel:SizeToContents()
			
			local invertBox = vgui.Create("DCheckBox",alignmentPanel)
			invertBox:SetPos(invertLabel:GetPos()+invertLabel:GetWide())
			function invertBox:OnChange(val)
				if writeTable.conditional then
					self.invert = val
					writeTable.conditional.invert = val
				end
			end
			if writeTable.conditional then
				invertBox:SetValue(writeTable.conditional.invert)
			else
				invertBox:SetValue(false)
			end
			
			function typeList:OnSelect(index,typeName,typeClass)
				if typeClass == GetTargetType() then return end
				self.type = typeClass
				
				if writeTable.conditional then
					writeTable.conditional.type = typeClass
					writeTable.conditional.conditional = nil
					rebuildFunction()
				else
					conditionalsList:BuildOptions()
				end
			end
			
			function conditionalsList:OnSelect(index,conditional)
				if !GetTargetArgument() then return end
				if conditional == "Nothing" then
					writeTable.conditional = nil
				else
					writeTable.conditional = {
						conditional = conditional,
						targetArgument = GetTargetArgument(),
						type = GetTargetType(),
						invert = invertBox.invert,
						arguments = {},
					}
				end
				rebuildFunction()
			end
			
			local totalHeight = 0
			
			if writeTable.conditional and writeTable.conditional.conditional then
				local conditional = writeTable.conditional
				local conditionalData = conditionals[conditional.conditional]
				local conditionalName = vgui.Create("DLabel",parent)
				conditionalName:SetFont("Trebuchet18")
				conditionalName:SetText("[IF] "..conditional.conditional)
				conditionalName:Dock(TOP)
				local x = alignmentPanel:GetDockMargin()
				conditionalName:DockMargin(x+ScreenScaleW(2),0,0,0)
				conditionalName:SizeToContents()
				
				totalHeight = totalHeight+conditionalName:GetTall()
				
				if conditionalData.arguments then
					for k,argumentData in ipairs(conditionalData.arguments) do
						if !conditional.arguments[k] then
							conditional.arguments[k] = {}
						end
						
						local argumentName = vgui.Create("DLabel",parent)
						argumentName:SetFont("Trebuchet18")
						argumentName:SetText(argumentData.name..":")
						argumentName:Dock(TOP)
						argumentName:DockMargin(conditionalName:GetDockMargin())
						argumentName:SizeToContents()
						
						local argumentEditor = CreateArgumentEditor(parent,argumentName,argumentData,conditional.arguments[k])
						
						totalHeight = totalHeight+argumentName:GetTall()+argumentEditor:GetTall()
					end
				end
			end
			return totalHeight
		end
		
		local function BuildEventOptions()
			local eventData = events[lawData.event]
			if IsValid(lawPanelScroll.optionsPanel) then
				lawPanelScroll.optionsPanel:Remove()
			end
			local optionsPanel = vgui.Create("DScrollPanel",lawPanelScroll)
			lawPanelScroll.optionsPanel = optionsPanel
			optionsPanel:Dock(FILL)
			optionsPanel:SetTall(ScreenScaleH(20))
			lawPanelScroll.Paint = DarkerGray
			
			if eventData.returns then
				local returnPanel = vgui.Create("Panel",optionsPanel)
				returnPanel:Dock(TOP)
				
				local function BuildReturnOptions()
					returnPanel:SetTall(50)
					for k,v in ipairs(returnPanel:GetChildren()) do
						v:Remove()
					end
					
					local totalHeight = ScreenScaleH(20)
					
					if !lawData.returns then
						lawData.returns = {}
					end
					
					local returnDesc = vgui.Create("DLabel",returnPanel)
					returnDesc:SetFont("Trebuchet18")
					returnDesc:SetText(eventData.returns.name..":")
					returnDesc:Dock(TOP)
					returnDesc:DockMargin(titleX,0,0,0)
					returnDesc:SizeToContents()
					returnDesc:SetMouseInputEnabled(true)
					
					local argEditor
					if !lawData.returns.conditional then
						argEditor = CreateArgumentEditor(returnPanel,returnDesc,eventData.returns,lawData.returns)
						totalHeight = totalHeight+argEditor:GetTall()
					end
					
					if eventData.returns.type == "bool" then
						totalHeight = totalHeight+CreateConditional(returnPanel,returnDesc,lawData.returns,BuildReturnOptions)
					end
					
					returnPanel:SetTall(totalHeight)
				end
				
				BuildReturnOptions()
			end
			
			--List arguments of the action for editing
			local argumentsMade = 0
			local argumentID = 1
			for k,v in pairs(eventData.arguments) do
				if v == NULL then continue end
				
				local compatibleTypes = abilityData.findTypesCompatible(v.type,{selectibleType=true})
				local actionCount = 0
				for k,type in pairs(compatibleTypes) do
					for actionName,actionData in pairs(actions) do
						if abilityData.typeFitsFilter(type,actionData.types) then
							actionCount = actionCount + 1
						end
					end
				end
				
				if actionCount == 0 then continue end
				
				local thisArgID = argumentID
				local curLawActionsData = lawData.actions[argumentID]
				
				--Label for the argument
				local x,y = titleX,ScreenScaleH(20*argumentsMade)
				local nameLabel = vgui.Create("DLabel",optionsPanel)
				nameLabel:SetFont("Trebuchet24")
				nameLabel:SetText(v.name)
				nameLabel:Dock(TOP)
				nameLabel:DockMargin(x,0,0,0)
				optionsPanel:InvalidateLayout(true)
				nameLabel:SizeToContents()
				nameLabel:SetMouseInputEnabled(true)
				
				--Actions selection list for the event argument.
				local typeList = vgui.Create("DComboBox",nameLabel)
				typeList:SetValue("Select Type")
				local labelX,labelY = nameLabel:GetPos()
				typeList:SetWide(ScreenScaleW(80))
				typeList:SetPos(nameLabel:GetWide()+ScreenScaleW(5))
				typeList:SetSortItems(false)
				
				for k,v in ipairs(compatibleTypes) do
					typeList:AddChoice(types[v].name or v,v)
				end
				
				if curLawActionsData and curLawActionsData[1] then
					typeList.selectedType = curLawActionsData[1].type
					typeList:SetValue(types[typeList.selectedType].name)
				end
				
				--Actions selection list for the event argument.
				local actionsList = vgui.Create("DComboBox",nameLabel)
				local labelX,labelY = nameLabel:GetPos()
				actionsList:SetWide(ScreenScaleW(80))
				actionsList:SetPos(nameLabel:GetWide()+typeList:GetWide()+ScreenScaleW(5))
				actionsList:SetSortItems(false)
				function actionsList:BuildOptions()
					self:Clear()
					if !typeList.selectedType then
						self:SetValue("Select Type First")
						return
					end
					self:SetValue("Select Action")
					self:AddChoice("Nothing")
					for actionName,actionData in pairs(actions) do
						if abilityData.typeFitsFilter(typeList.selectedType,actionData.types) then
							self:AddChoice(actionName)
						end
					end
				end
				actionsList:BuildOptions()
				
				function actionsList:OnSelect(index,value)
					if value == "Nothing" then
						self.selectedAction = nil
					else
						self.selectedAction = value
					end
				end
				
				local addActionBtn = vgui.Create("DButton",nameLabel)
				addActionBtn:SetText("+ Add Action")
				addActionBtn:SetWide(ScreenScaleW(30))
				addActionBtn:SetPos(nameLabel:GetWide()+actionsList:GetWide()+typeList:GetWide()+ScreenScaleW(5))
				
				local argumentsPanel = vgui.Create("Panel",optionsPanel)
				argumentsPanel:Dock(TOP)
				argumentsPanel:DockMargin(x,0,0,0)
				argumentsPanel.Paint = RedFilled
				local argumentsPanelBaseTall = 20
				
				local function BuildArgumentActions()
					for k,v in ipairs(argumentsPanel:GetChildren()) do
						v:Remove()
					end
					
					if !curLawActionsData then return end
					
					local totalHeight = 0
					
					--Build all actions for the event argument
					for k,argAction in ipairs(curLawActionsData) do
						local actionData = actions[argAction.action]
						
						--if !abilityData.typeFitsFilter(typeList.selectedType,actionData.types) then continue end
						if !typeList.selectedType or typeList.selectedType != argAction.type then continue end
						
						--Action name label
						local actionName = vgui.Create("DLabel",argumentsPanel)
						actionName:SetFont("Trebuchet18")
						actionName:SetText(argAction.action)
						actionName:Dock(TOP)
						actionName:DockMargin(x-ScreenScaleW(2),0,0,0)
						actionName:SizeToContents()
						actionName:SetMouseInputEnabled(true)
						
						local removeActionBtn = vgui.Create("DButton",actionName)
						removeActionBtn:SetText("X")
						removeActionBtn:SetWide(ScreenScaleW(10))
						removeActionBtn:SetPos(actionName:GetWide()+removeActionBtn:GetWide())
						function removeActionBtn:DoClick()
							table.remove(curLawActionsData,k)
							if #curLawActionsData <= 0 then
								lawData.actions[thisArgID] = nil
							end
							BuildArgumentActions()
						end
						
						totalHeight = totalHeight+actionName:GetTall()+CreateConditional(argumentsPanel,actionName,argAction,BuildArgumentActions,ScreenScaleW(10))
						
						local x = x + ScreenScaleW(5)
						if actionData.arguments then
							--Build arguments for each action
							for i,argumentData in ipairs(actionData.arguments) do
								if !argAction.arguments[i] then
									argAction.arguments[i] = {}
								end
								local argumentName = vgui.Create("DLabel",argumentsPanel)
								argumentName:SetFont("Trebuchet18")
								argumentName:SetText(argumentData.name..":")
								argumentName:Dock(TOP)
								argumentName:DockMargin(actionName:GetDockMargin())
								argumentName:SizeToContents()
								
								local argumentEditor = CreateArgumentEditor(argumentsPanel,argumentName,argumentData,argAction.arguments[i])
								
								totalHeight = totalHeight+argumentName:GetTall()+argumentEditor:GetTall()
							end
						end
					end
					argumentsPanel:SetTall(argumentsPanelBaseTall+totalHeight)
				end
				
				function typeList:OnSelect(index,name,type)
					self.selectedType = type
					actionsList:BuildOptions()
					BuildArgumentActions()
				end
				
				function addActionBtn:DoClick()
					if actionsList.selectedAction and typeList.selectedType then
						if !curLawActionsData then
							curLawActionsData = {}
							lawData.actions[thisArgID] = curLawActionsData
						end
						curLawActionsData[#curLawActionsData+1] = {
							action = actionsList.selectedAction,
							type = typeList.selectedType,
							arguments = {}
						}
						BuildArgumentActions()
					end
				end
				
				BuildArgumentActions()
				
				argumentsMade = argumentsMade + 1
				argumentID = argumentID + 1
			end
		end
		
		function eventList:OnSelect(index,value)
			if value != lawData.event then
				lawData.event = value
				lawData.actions = {}
				SelectLaw(law)
			end
		end
		
		eventList:SetValue(lawData.event or "Select Event")
		if lawData.event then
			BuildEventOptions()
		end
	end
	
	local layoutBtnWide,layoutBtnTall = lawScroll:GetWide()-ScreenScaleW(3),ScreenScaleH(15)
	
	local newLawBtn = vgui.Create("DButton",lawLayout)
	newLawBtn:SetSize(layoutBtnWide,ScreenScaleH(20))
	newLawBtn:SetText("New Law")
	
	local function AddLaw(name,data)
		if name == "" then return end
		data = data or {}
		
		local lawBtn = vgui.Create("DButton",lawLayout)
		lawBtn:SetSize(layoutBtnWide,layoutBtnTall)
		lawBtn:SetText(name)
		data.button = lawBtn
		
		function lawBtn:DoClick()
			SelectLaw(name)
		end
		
		local deleteBtn = vgui.Create("DButton",lawBtn)
		deleteBtn:SetSize(16,16)
		deleteBtn:SetText("X")
		deleteBtn:SetPos(1,lawBtn:GetTall()/2-deleteBtn:GetTall()/2)
		
		function deleteBtn:DoClick()
			if selectedLaw == name then
				for k,v in ipairs(lawPanel:GetChildren()) do
					v:Remove()
				end
			end
			net.Start("IG_DeleteLaw")
			net.WriteString(name)
			net.SendToServer()
			laws[name] = nil
			lawBtn:Remove()
		end
		
		laws[name] = data
		
		SelectLaw(name)
	end
	
	function newLawBtn:DoClick()
		Derma_StringRequest("Law Name","Name:","Law"..table.Count(laws)+1,function(str)
			if !laws[str] then
				AddLaw(str)
			end
		end)
	end
	
	lawLayout:Add(newLawBtn)
	
	for k,v in pairs(laws) do
		AddLaw(k,v)
		SelectLaw(k)
	end
end
/*
CreateLawEditor{
	test = {
		event = "Entity Emit Sound",
		actions = {
			{--Argument #1 actions
			}
		},
		returns = {
			value = 0,
		}
	}
}
*/

net.Receive("IG_URMenu",function()
	CreateLawEditor(net.ReadTable())
end)

net.Receive("IG_SyncLaw",function()
	IG_StoneData[IG_STONE_INFINITY].abilities[5]:defineLaw(net.ReadIGLaw())
end)

net.Receive("IG_DeleteLaw",function()
	IG_StoneData[IG_STONE_INFINITY].abilities[5]:deleteLaw(net.ReadString())
end)

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

function SWEP:UpdateAppearence()
	if !IsValid(self.Owner) then return end
	local usingElements = {}
	for k,v in pairs(IG_StoneData) do
		if self.channelingStones[k] then
			if istable(v.element) then
				for l,o in pairs(v.element) do
					usingElements[o] = true
				end
			else
				usingElements[v.element] = true
			end
		end
	end
	local colorChange = 90*FrameTime()
	
	if !UsingOldModel() then
		local minAlpha = 15
		local vm = self.Owner:GetViewModel()
		if !vm:IsValid() then return end
		local glows = {}
		for k,v in pairs(IG_StoneData) do
			if k < 7 then
				local hasStone = self:HasStone(k)
				vm:SetBodygroup(k,hasStone and 0 or 1)
				glows[v.element] = hasStone
			end
		end
		
		for k,v in pairs(IG_StoneData) do
			for index,element in pairs(istable(v.element) and v.element or {v.element}) do
				if usingElements[element] then continue end
				local color = self.WElements[element].color
				if !glows[element] then
					color.a = 0
				elseif color.a > minAlpha then
					color.a = math.max(color.a - colorChange,minAlpha)
				end
				
				local color = self.VElements[element].color
				if !glows[element] then
					color.a = 0
					continue
				elseif color.a > minAlpha then
					color.a = math.max(color.a - colorChange,minAlpha)
				end
			end
		end
		
		return
	end
	
	if !self.VElements.gauntlet then return end
	
	for k,v in pairs(IG_StoneData) do
		if k < 7 then
			self.VElements.gauntlet.bodygroup[k] = self:HasStone(k) and 0 or 1
			self.WElements.gauntlet.bodygroup[k] = self:HasStone(k) and 0 or 1
		end
		for index,element in pairs(istable(v.element) and v.element or {v.element}) do
			if usingElements[element] then continue end
			local color = self.WElements[element].color
			if color.a > 0 then
				color.a = math.max(color.a - colorChange,0)
			end
			
			local color = self.VElements[element].color
			if color.a > 0 then
				color.a = math.max(color.a - colorChange,0)
			end
		end
	end
end

--SWEP Constructer stuff
do

SWEP.vRenderOrder = nil
function SWEP:ViewModelDrawn()
	local vm = self.Owner:GetViewModel()
	if !IsValid(vm) then return end
	
	if (!self.VElements) then return end
	
	self:UpdateBonePositions(vm)

	if (!self.vRenderOrder) then
		
		// we build a render order because sprites need to be drawn after models
		self.vRenderOrder = {}

		for k, v in pairs(self.VElements) do
			if (v.type == "Model") then
				table.insert(self.vRenderOrder, 1, k)
			elseif (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.vRenderOrder, k)
			end
		end
		
	end

	for k, name in ipairs(self.vRenderOrder) do
	
		local v = self.VElements[name]
		if (!v) then self.vRenderOrder = nil break end
		if (v.hide) then continue end
		
		local model = v.modelEnt
		local sprite = v.spriteMaterial
		
		if (!v.bone) then continue end
		local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
		
		if (!pos) then continue end
		if (v.type == "Model" and IsValid(model)) then

			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			model:SetAngles(ang)
			//model:SetModelScale(v.size)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix("RenderMultiply", matrix)
			
			if (v.material == "") then
				model:SetMaterial("")
			elseif (model:GetMaterial() != v.material) then
				model:SetMaterial(v.material)
			end
			
			if (v.skin and v.skin != model:GetSkin()) then
				model:SetSkin(v.skin)
			end
			
			if (v.bodygroup) then
				for k, v in pairs(v.bodygroup) do
					if (model:GetBodygroup(k) != v) then
						model:SetBodygroup(k, v)
					end
				end
			end
			
			if (v.surpresslightning) then
				render.SuppressEngineLighting(true)
			end
			
			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)
			
			if (v.surpresslightning) then
				render.SuppressEngineLighting(false)
			end
			
		elseif (v.type == "Sprite" and sprite) then
			
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			
		elseif (v.type == "Quad" and v.draw_func) then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			
			cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
			cam.End3D2D()

		end
		
	end
end

SWEP.wRenderOrder = nil
function SWEP:DrawWorldModel()
	if !IsValid(self.Owner) then self:DrawModel() return end
	if IsValid(self.Owner) and self.Owner:GetNoDraw() then return end
	
	if (self.ShowWorldModel == nil or self.ShowWorldModel) then
	
		self:DrawModel()
	end
	
	if (!self.WElements) then return end
	
	self:UpdateAppearence()
	
	if (!self.wRenderOrder) then

		self.wRenderOrder = {}

		for k, v in pairs(self.WElements) do
			if (v.type == "Model") then
				table.insert(self.wRenderOrder, 1, k)
			elseif (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.wRenderOrder, k)
			end
		end

	end
	
	if (IsValid(self.Owner)) then
		bone_ent = self.Owner
	else
		// when the weapon is dropped
		bone_ent = self
	end
	
	for k, name in pairs(self.wRenderOrder) do
	
		local v = self.WElements[name]
		if (!v) then self.wRenderOrder = nil break end
		if (v.hide) then continue end
		
		local pos, ang
		
		if (v.bone) then
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
		else
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
		end
		
		if (!pos) then continue end
		
		local model = v.modelEnt
		local sprite = v.spriteMaterial
		
		if (v.type == "Model" and IsValid(model)) then
			if bone_ent:GetModel():find("thanos") then
				continue
			end

			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			model:SetAngles(ang)
			//model:SetModelScale(v.size)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix("RenderMultiply", matrix)
			
			if (v.material == "") then
				model:SetMaterial("")
			elseif (model:GetMaterial() != v.material) then
				model:SetMaterial(v.material)
			end
			
			if (v.skin and v.skin != model:GetSkin()) then
				model:SetSkin(v.skin)
			end
			
			if (v.bodygroup) then
				for k, v in pairs(v.bodygroup) do
					if (model:GetBodygroup(k) != v) then
						model:SetBodygroup(k, v)
					end
				end
			end
			
			if (v.surpresslightning) then
				render.SuppressEngineLighting(true)
			end
			
			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)
			
			if (v.surpresslightning) then
				render.SuppressEngineLighting(false)
			end
			
		elseif (v.type == "Sprite" and sprite) then
			
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			
		elseif (v.type == "Quad" and v.draw_func) then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			
			cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
			cam.End3D2D()

		end
		
	end
	
end
function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
	
	local bone, pos, ang
	if (tab.rel and tab.rel != "") then
		
		local v = basetab[tab.rel]
		
		if (!v) then return end
		
		// Technically, if there exists an element with the same name as a bone
		// you can get in an infinite loop. Let's just hope nobody's that stupid.
		pos, ang = self:GetBoneOrientation(basetab, v, ent)
		
		if (!pos) then return end
		
		pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
		ang:RotateAroundAxis(ang:Up(), v.angle.y)
		ang:RotateAroundAxis(ang:Right(), v.angle.p)
		ang:RotateAroundAxis(ang:Forward(), v.angle.r)
			
	else
	
		bone = ent:LookupBone(bone_override or tab.bone)

		if (!bone) then return end
		
		pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = ent:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end
		
		if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
			ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r // Fixes mirrored models
		end
	
	end
	
	return pos, ang
end
function SWEP:CreateModels(tab)

	if (!tab) then return end

	// Create the clientside models here because Garry says we can't do it in the render hook
	for k, v in pairs(tab) do
		if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
				string.find(v.model, ".mdl") and file.Exists (v.model, "GAME")) then
			
			v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
			if (IsValid(v.modelEnt)) then
				v.modelEnt:SetPos(self:GetPos())
				v.modelEnt:SetAngles(self:GetAngles())
				v.modelEnt:SetParent(self)
				v.modelEnt:SetNoDraw(true)
				v.createdModel = v.model
			else
				v.modelEnt = nil
			end
			
		elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
			and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
			
			local name = v.sprite.."-"
			local params = { ["$basetexture"] = v.sprite }
			// make sure we create a unique name based on the selected options
			local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
			for i, j in pairs(tocheck) do
				if (v[j]) then
					params["$"..j] = 1
					name = name.."1"
				else
					name = name.."0"
				end
			end

			v.createdSprite = v.sprite
			v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
			
		end
	end
	
end

local allbones
local hasGarryFixedBoneScalingYet = false

function SWEP:UpdateBonePositions(vm)
	
	if self.ViewModelBoneMods then
		
		if (!vm:GetBoneCount()) then return end
		
		// !! WORKAROUND !! //
		// We need to check all model names :/
		local loopthrough = self.ViewModelBoneMods
		if (!hasGarryFixedBoneScalingYet) then
			allbones = {}
			for i=0, vm:GetBoneCount() do
				local bonename = vm:GetBoneName(i)
				if (self.ViewModelBoneMods[bonename]) then 
					allbones[bonename] = self.ViewModelBoneMods[bonename]
				else
					allbones[bonename] = { 
						scale = Vector(1,1,1),
						pos = Vector(0,0,0),
						angle = Angle(0,0,0)
					}
				end
			end
			
			loopthrough = allbones
		end
		// !! ----------- !! //
		
		for k, v in pairs(loopthrough) do
			local bone = vm:LookupBone(k)
			if (!bone) then continue end
			
			// !! WORKAROUND !! //
			local s = Vector(v.scale.x,v.scale.y,v.scale.z)
			local p = Vector(v.pos.x,v.pos.y,v.pos.z)
			local ms = Vector(1,1,1)
			if (!hasGarryFixedBoneScalingYet) then
				local cur = vm:GetBoneParent(bone)
				while(cur >= 0) do
					local pscale = loopthrough[vm:GetBoneName(cur)].scale
					ms = ms * pscale
					cur = vm:GetBoneParent(cur)
				end
			end
			
			s = s * ms
			// !! ----------- !! //
			
			if vm:GetManipulateBoneScale(bone) != s then
				vm:ManipulateBoneScale(bone, s)
			end
			if vm:GetManipulateBoneAngles(bone) != v.angle then
				vm:ManipulateBoneAngles(bone, v.angle)
			end
			if vm:GetManipulateBonePosition(bone) != p then
				vm:ManipulateBonePosition(bone, p)
			end
		end
	else
		self:ResetBonePositions(vm)
	end
	   
end
 
function SWEP:ResetBonePositions(vm)
	
	if (!vm:GetBoneCount()) then return end
	for i=0, vm:GetBoneCount() do
		vm:ManipulateBoneScale(i, Vector(1, 1, 1))
		vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
		vm:ManipulateBonePosition(i, Vector(0, 0, 0))
	end
	
end

function table.FullCopy(tab)

	if (!tab) then return nil end
	
	local res = {}
	for k, v in pairs(tab) do
		if (type(v) == "table") then
			res[k] = table.FullCopy(v) // recursion ho!
		elseif (type(v) == "Vector") then
			res[k] = Vector(v.x, v.y, v.z)
		elseif (type(v) == "Angle") then
			res[k] = Angle(v.p, v.y, v.r)
		else
			res[k] = v
		end
	end
	
	return res
	
end

end
