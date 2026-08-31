HpwRewrite.Language = HpwRewrite.Language or { }
HpwRewrite.Language.Languages = HpwRewrite.Language.Languages or { }

HpwRewrite.Language.CurrentLanguage = "en"

function HpwRewrite.Language:AddLanguage(codename, name)
	if self.Languages[codename] then return end

	self.Languages[codename] = { }
	self.Languages[codename].Name = name
	self.Languages[codename].Dictonary = { }

	print("[Wand] Added " .. name .. " language")
end

function HpwRewrite.Language:AddWord(lCodeName, index, word)
	local lang = self.Languages[lCodeName] 
	if not lang then print("[Wand] Language " .. lCodeName .. " not found!") return end

	lang.Dictonary[index] = word
end

function HpwRewrite.Language:GetWord(index, lCodeName)
	lCodeName = lCodeName or self.CurrentLanguage
	local lang = self.Languages[lCodeName]
	if not lang then print("[Wand] Language " .. lCodeName .. " not found!") return end

	local word = lang.Dictonary[index]

	if not word then 
		lang = self.Languages["en"] -- Default one

		if lang then
			word = lang.Dictonary[index]

			if not word then
				print("[Wand] Word " .. index .. " not found!") 
				return index
			end

			return word
		end
	end

	return word
end

function HpwRewrite.Language:SetLanguage(lCodeName)
	lCodeName = string.lower(tostring(lCodeName or ""))
	if not self.Languages[lCodeName] then return false end

	local oldLanguage = self.CurrentLanguage
	self.CurrentLanguage = lCodeName

	if HpwRewrite.RefreshCategoryNames then
		HpwRewrite:RefreshCategoryNames(oldLanguage)
	end

	if CLIENT and HpwRewrite.VGUI then
		HpwRewrite.VGUI.ShouldUpdate = true
	end

	return true
end

HpwRewrite:IncludeFolder("hpwrewrite/language", true)

-- Defaulting to ENGLISH if your homelang is not found

local cvar = GetConVar("gmod_language")
if cvar then
	HpwRewrite.Language:SetLanguage(cvar:GetString())
else
 	print("[Wand] Can't find 'gmod_language' variable!")
end

local customlang = HpwRewrite.CVars.Language
if customlang then
	local val = customlang:GetString()
	HpwRewrite.Language:SetLanguage(val)

	if CLIENT then
		cvars.AddChangeCallback("hpwrewrite_cl_language", function(cvarName, old, new)
			if HpwRewrite.Language:SetLanguage(new) then
				print("[Wand] Loaded " .. HpwRewrite.Language.CurrentLanguage .. " language!")
			end
		end)
	end
end

print("[Wand] Loaded " .. HpwRewrite.Language.CurrentLanguage .. " language!")
