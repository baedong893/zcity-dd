AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local clr = Color(100, 100, 100)

local function SpawnStoredItem(crate, class, pos)
	if not isstring(class) or class == "" then return end

	local item = ents.Create(class)
	if not IsValid(item) then return end

	item:SetPos(pos or crate:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), 10))
	item:SetAngles(crate:GetAngles())
	item:Spawn()
	return item
end

function ENT:InitializeInventory()
	if self.ZCityAirdropInventoryInitialized then return true end

	local contents = self:GetNWString("Contents", "")
	if contents == "" then return false end

	self.ZCityAirdropInventoryInitialized = true
	self.inventory = {
		Weapons = {},
		Ammo = {},
		Armor = {},
		Attachments = {},
		Supplies = {}
	}
	self.armors = self.armors or {}

	local slot = 0
	for _, class in ipairs(string.Explode(",", contents)) do
		class = string.Trim(class)
		if class ~= "" then
			slot = slot + 1
			self.inventory.Supplies[tostring(slot)] = class
		end
	end

	-- From this point onward the inventory is the only source of truth. This
	-- prevents searched items from being spawned a second time when broken.
	self:SetNWString("Contents", "")
	self:SetNetVar("Inventory", self.inventory)
	self:SyncArmor()
	return true
end

function ENT:Initialize()
	self:SetModel("models/props_junk/wood_crate001a.mdl")
	self:SetMaterial("models/props_pipes/guttermetal01a")
	self:SetColor(clr)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetHealth(100)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	self:InitializeInventory()

	timer.Create("CrateSmokeEffect_" .. self:EntIndex(), 1, 0, function()
		if IsValid(self) then
			local effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			util.Effect("eff_smokweed", effectData)
		end
	end)
end

function ENT:Use(activator)
	if not IsValid(activator) or not activator:IsPlayer() or not activator:Alive() then return end
	if activator:KeyDown(IN_ATTACK2) then return end
	if not self:InitializeInventory() then return end
	activator:OpenInventory(self)
end

function ENT:OnTakeDamage(dmginfo)
	self:SetHealth(self:Health() - dmginfo:GetDamage())
	if self:Health() <= 0 then
		self:BreakCrate()
	end
end

function ENT:BreakCrate()
	if self.ZCityAirdropBroken then return end
	self.ZCityAirdropBroken = true
	self:InitializeInventory()

	local supplies = self.inventory and self.inventory.Supplies or {}
	for _, class in pairs(supplies) do
		SpawnStoredItem(self, class)
	end

	if self.inventory then
		self.inventory.Supplies = {}
		self:SetNetVar("Inventory", self.inventory)
	end
	self:Remove()
end

function ENT:OnRemove()
	if timer.Exists("CrateSmokeEffect_" .. self:EntIndex()) then
		timer.Remove("CrateSmokeEffect_" .. self:EntIndex())
	end
end
