ENT.Type = "anim"
ENT.PrintName = "IED Disabled"
ENT.Author = ""
ENT.Contact = ""
ENT.Purpose = "Disabled IED entity for the Z City report phone."
ENT.Instructions = ""

ENT.Spawnable = false
ENT.AdminOnly = true
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true

if SERVER then
	AddCSLuaFile("shared.lua")

	function ENT:Initialize()
		-- Safety lock:
		-- This entity used to be the explosive spawned by weapon_ied_arabic.
		-- The Z City report-phone version must never create an IED.
		-- If another addon/old SWEP still creates chev_ied, remove it immediately.
		self.Boom = false
		self:SetNoDraw(true)
		self:SetNotSolid(true)

		timer.Simple(0, function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end

	function ENT:Think()
		if IsValid(self) then
			self:Remove()
		end

		return false
	end

	function ENT:Explosion()
		-- Disabled. No damage, no effects, no sound.
		if IsValid(self) then
			self:Remove()
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		-- Disabled. Taking damage must not trigger explosion.
		return true
	end
end

if CLIENT then
	function ENT:Draw()
		-- Hidden disabled entity.
	end
end
