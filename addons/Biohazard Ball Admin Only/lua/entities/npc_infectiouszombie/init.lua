AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.PrintName		= "Infectious Zombie"
ENT.Author			= "jmoak3"
ENT.Information		= "Zombie that makes more zombies"

ENT.Spawnable			= true
ENT.AdminOnly			= false
ENT.Base				= "base_nextbot"

ENT.AttackWarmUpTime = 1
if (ENT.ZombieType == "fast") then
	ENT.AttackWarmUpTime = 0.5
end
ENT.IgnorePlayer = 0
ENT.MeleeAnims = {"swing"}
ENT.MeleeAttacking = false
ENT.Death = Sound("npc/zombie/zombie_die1.wav")
ENT.Taunt = Sound("npc/zombie/zombie_voice_idle1.wav")
ENT.AttackSound = Sound("npc/zombie/claw_strike1.wav")
ENT.ZombieType = InfectConfig.ZombieType
ENT.Damage = InfectConfig.ZombieDamage
ENT.HeadshotOnly = InfectConfig.HeadshotOnly
ENT.InfectChance = InfectConfig.InfectScratchChance

function ENT:Initialize()
	self.Kid = ents.Create("npc_bullseye")
	self.Kid:SetPos( self:GetPos() + Vector(0, 0, -1) + self:GetForward()*-5 )
	self.Kid:SetHealth(9999999)
	self.Kid:Spawn()
	self.Kid:SetParent(self, 1)
	--self.Kid:SetLocalPos(self:GetPos() + self:GetForward()*-1 + Vector(0, 0, 10))
	
	if (self.ZombieType == "classic") then
		self:SetModel("models/zombie/classic.mdl")
	elseif (self.ZombieType == "fast") then
		self:SetModel("models/zombie/fast.mdl")
	else
		self:SetModel("models/zombie/classic.mdl")
	end
	
	self.LoseTargetDist	= 2000	-- How far the enemy has to be before we lose them
	self.SearchRadius 	= 1000	-- How far to search for enemies
	
	util.PrecacheSound(self.AttackSound)
	self:SetHealth(InfectConfig.Health/2)
end

function ENT:SetEnemy(ent)
	self.Enemy = ent
end
function ENT:GetEnemy()
	return self.Enemy
end

function ENT:CutEmUp()
	if (!self:IsValid()) then return end
	local attackableEnts = ents.FindInSphere(self:GetPos() + self:GetForward()*50, 25)
	local hit = false
	if (self.Kid == nil) then return end
	if (attackableEnts != nil) then
		for _,i in pairs(attackableEnts) do
			if (i:GetClass() != self:GetClass() && i != self && i != nil && i:GetClass() != self.Kid:GetClass() && 
					(i:IsNPC() || (i:IsPlayer() && i:Alive() && !(i:GetActiveWeapon():IsValid() && i:GetActiveWeapon():GetClass() == "weapon_zombie")) 
					|| i:GetClass() == "prop_physics" || i:GetClass() == "prop_physics_multiplayer" || i:GetClass() == "prop_dynamic")) then
				i:TakeDamage(self.Damage, self)
				if (math.random(1, self.InfectChance) == 1) then self:Infect(i) end
				
				if (i:IsPlayer()) then
					i:ViewPunch(Angle(math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage, math.random(-1, 1)*self.Damage))
				end
				if (i:GetClass() == "prop_physics" || i:GetClass() == "prop_physics_multiplayer" || i:GetClass() == "prop_dynamic") then
					local phys = i:GetPhysicsObject()
					if (phys != nil && phys != NULL && phys:IsValid()) then
						phys:ApplyForceCenter(self:GetForward():GetNormalized()*20000 + Vector(0, 0, 3))
					end
					hit = true
				end
			end
		end
		self:EmitSound(self.AttackSound, 200, math.random(80, 100))
		timer.Create("meleeCoolDownTimer"..self.Entity:EntIndex(), 0.8, 1, 
			function()
				self.MeleeAttacking = false
				self.loco:SetDesiredSpeed( 75 )
			self:StartActivity( ACT_WALK )
			end)
	end
end

function ENT:Attack()
	if (self:IsValid() == false) then
		return
	end
	if (self:HaveEnemy() == false) then
		return
	end
	local function NoCutEmUp()
		self.MeleeAttacking = false
	end

	
	local function DoCutEmUp()
		self:CutEmUp()
	end
		
	if (math.random(1, 500) == 1) then 
		self:StopSound(self.Taunt)
		self:EmitSound(self.Taunt, 350, math.random(20,60)) 
	end
		
	
	if (self:GetEnemy():GetPos():Distance(self:GetPos()) < 70  || self:HasPropInFrontOfMe()) then
		if (self.MeleeAttacking == false) then
			self:StopSound(self.Taunt)
			self:EmitSound(self.Taunt, 350, math.random(100,160)) 
			timer.Create("meleeWarmUpTimer"..self.Entity:EntIndex(), self.AttackWarmUpTime, 1, function() self:CutEmUp() end )
			self.loco:SetDesiredSpeed( 0 )
			self:StartActivity( ACT_MELEE_ATTACK1 )
			self.MeleeAttacking = true
		end
	end
end

function ENT:Think()
	if (!self.Kid:IsValid()) then self:SetHealth(0) return end 
	local dmg = 9999999 - self.Kid:Health()
	local fdmg = self:Health() - dmg
	self:SetHealth(fdmg)
	local ignore = GetConVarNumber("ai_ignoreplayers")
	if (ignore != self.IgnorePlayer) then
		self.IgnorePlayer = ignore
		self:HaveEnemy()
	end
	self:Attack()
end

function ENT:HasPropInFrontOfMe()
	local entstoattack = ents.FindInSphere(self:GetPos() + self:GetForward()*50,25)
	for _,i in pairs(entstoattack) do
		if (i:GetClass() == "prop_physics" || i:GetClass() == "prop_physics_multiplayer" || i:GetClass() == "prop_dynamic") then
			return true
		end
	end
	return false
end

function ENT:HandleRelations(i)	
	i:AddEntityRelationship(self.Kid, 1, 99)
	
	if (i:GetClass() == "npc_citizen") then
		i:AddEntityRelationship(self.Kid, 2, 99)
	end
end

function ENT:HaveEnemy()
	return self:FindEnemy()
end

function ENT:FindEnemy()
	local _ents = ents.FindInSphere( self:GetPos(), self.SearchRadius )
	local bestDist = self.SearchRadius
	local currDist = bestDist
	if (self.Kid == nil || !self.Kid:IsValid()) then return end
	local ignore = GetConVarNumber("ai_ignoreplayers")
	self.IgnorePlayer = ignore
	for k, i in pairs( _ents ) do
		if (i:IsValid() && i:GetClass() != self.Kid:GetClass() && i:GetClass()!="npc_infectiouszombie" && 
					(i:IsNPC() || (ignore == 0 && i:IsPlayer() && i:Alive() && 
							!(i:GetActiveWeapon():IsValid() && i:GetActiveWeapon():GetClass() == "weapon_zombie")))) then
			if (i:GetClass()!="npc_infectiouszombie" && !i:IsPlayer()) then
				self:HandleRelations(i)
			end
			
			currDist = i:GetPos():Distance(self:GetPos())
			if (currDist < bestDist) then
				bestDist = currDist
				self:SetEnemy(i)
			end
		end
	end	
	if (bestDist == self.SearchRadius) then
		self:SetEnemy(nil)
		return false
	end
	if (self:GetEnemy():IsValid()) then
		return true
	end
	return false
end

----------------------------------------------------
-- ENT:RunBehaviour()
-- This is where the meat of our AI is
----------------------------------------------------
function ENT:RunBehaviour()
	-- This function is called when the entity is first spawned. It acts as a giant loop that will run as long as the NPC exists
	while ( true ) do
		-- Lets use the above mentioned functions to see if we have/can find a enemy
		if ( self:HaveEnemy() ) then
			-- Now that we have an enemy, the code in this block will run
			self.loco:FaceTowards(self:GetEnemy():GetPos())	-- Face our enemy
			self:StartActivity( ACT_WALK )			-- Set the animation
			self.loco:SetDesiredSpeed( 75 )		-- Set the speed that we will be moving at. Don't worry, the animation will speed up/slow down to match
			self:ChaseEnemy() 						-- The new function like MoveToPos.
			
			self:Attack()
			self:StartActivity( ACT_IDLE )
			-- Now once the above function is finished doing what it needs to do, the code will loop back to the start
			-- unless you put stuff after the if statement. Then that will be run before it loops
		else
			-- Since we can't find an enemy, lets wander
			-- Its the same code used in Garry's test bot
			self:StartActivity( ACT_WALK )			-- Walk anmimation
			self.loco:SetDesiredSpeed( 75 )		-- Walk speed
			self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400 ) -- Walk to a random place within about 400 units (yielding)
			self:StartActivity( ACT_IDLE )
		end
		-- At this point in the code the bot has stopped chasing the player or finished walking to a random spot
		-- Using this next function we are going to wait 2 seconds until we go ahead and repeat it 
		coroutine.wait(1)
		
	end

end	

function ENT:ChaseEnemy( options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )		-- Compute the path towards the enemies position

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self:HaveEnemy() ) do
	
		if ( path:GetAge() > 0.1 ) then					-- Since we are following the player we have to constantly remake the path
			path:Compute(self, self:GetEnemy():GetPos())-- Compute the path towards the enemy's position again
		end
		path:Update( self )								-- This function moves the bot along the path
		
		if ( options.draw ) then path:Draw() end
		-- If we're stuck, then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end
				
		coroutine.yield()

	end

	return "ok"

end

function ENT:OnRemove()
	timer.Remove("meleeCoolDownTimer"..self.Entity:EntIndex())
	timer.Remove("meleeWarmUpTimer"..self.Entity:EntIndex())
	if (self != nil && self.Kid != nil && self.Kid:IsValid()) then self.Kid:Remove() end
end
