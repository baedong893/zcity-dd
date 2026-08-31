HpwRewrite.CategoryNames = HpwRewrite.CategoryNames or { }

local categoryKeys = {
	DestrExp = "#category_destrexp",
	Fight = "#category_fight",
	Generic = "#category_generic",
	Healing = "#category_healing",
	Lighting = "#category_lighting",
	Physics = "#category_physics",
	Protecting = "#category_protecting",
	Special = "#category_special",
	Unforgivable = "#category_unforgivable"
}

function HpwRewrite:RefreshCategoryNames(oldLanguage)
	local oldToNew = {}

	for id, key in pairs(categoryKeys) do
		local newName = self.Language:GetWord(key)

		if oldLanguage then
			local oldName = self.Language:GetWord(key, oldLanguage)
			if oldName then oldToNew[oldName] = newName end
		end

		self.CategoryNames[id] = newName
	end

	if CLIENT and next(oldToNew) and self.Spells then
		for _, spell in pairs(self.Spells) do
			if type(spell.Category) == "table" then
				for k, category in pairs(spell.Category) do
					spell.Category[k] = oldToNew[category] or category
				end
			else
				spell.Category = oldToNew[spell.Category] or spell.Category
			end
		end

		if self.Categories then
			table.Empty(self.Categories)
			self:AddCategory(self.Language:GetWord("#favcategory"))

			for _, spell in pairs(self.Spells) do
				if type(spell.Category) == "table" then
					for _, category in pairs(spell.Category) do self:AddCategory(category) end
				else
					self:AddCategory(spell.Category)
				end
			end
		end
	end
end

HpwRewrite:RefreshCategoryNames()
