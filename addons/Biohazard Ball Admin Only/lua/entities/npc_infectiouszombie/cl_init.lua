include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
end

function ENT:Draw()
	self.Entity:DrawModel()
end


language.Add("npc_infectiouszombie", "Infectious Zombie")