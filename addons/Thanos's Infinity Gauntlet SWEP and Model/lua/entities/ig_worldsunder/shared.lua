ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.PrintName 	= "World Sunder"
ENT.Name 		= "World Sunder"
ENT.Spawnable 	= false

ENT.lifetime = 10
ENT.maxRadius = 9999

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"StartTime")
end

function ENT:GetPercent()
	return math.min(1,((CurTime()-self:GetStartTime())/self.lifetime))
end

function ENT:GetRadius()
	return self:GetPercent()*self.maxRadius
end

if SERVER then return end
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	local bounds = Vector(999999,999999,999999)
	self:SetRenderBounds(-bounds,bounds)
end

local maskColor = Color(0,0,0,0)
local purplegoop = Material("xyz/effects/infinitygauntlet/purplegoop")
local web = Material("xyz/effects/infinitygauntlet/web")
local circleDetail = 25

local function DrawOverlay(pos,radius,innerRadius,color,material)
	render.SetStencilEnable(true)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilWriteMask(3)
	render.SetStencilTestMask(3)
	
	render.ClearStencil()
	render.SetColorMaterial()
	
	render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
	
	render.SetStencilReferenceValue(2)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.DrawSphere(pos,-radius,circleDetail,circleDetail,maskColor)
	render.SetStencilZFailOperation(STENCILOPERATION_INCR)
	render.SetStencilReferenceValue(2)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.DrawSphere(pos,radius,circleDetail,circleDetail,maskColor)
	render.SetStencilZFailOperation(STENCILOPERATION_INCR)
	render.SetStencilReferenceValue(2)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.DrawSphere(pos,-innerRadius,circleDetail,circleDetail,maskColor)
	render.SetStencilZFailOperation(STENCILOPERATION_DECR)
	render.SetStencilReferenceValue(2)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.DrawSphere(pos,innerRadius,circleDetail,circleDetail,maskColor)
	
	render.SetMaterial(material)
	render.SetStencilReferenceValue(2)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.DrawSphere(pos,-radius,circleDetail,circleDetail,color)
	render.SetStencilEnable(false)
end

function ENT:Draw()
	local pos = self:GetPos()
	local percent = self:GetPercent()
	local radius = self:GetRadius()
	local color = IG_StoneData[IG_STONE_POWER].color
	color = Color(color.r,color.g,color.b,(1-percent)*255*2)
	
	DrawOverlay(pos,radius,0,color,purplegoop)
	color.a = color.a*2
	DrawOverlay(pos,radius,radius-500,color,web)
end
