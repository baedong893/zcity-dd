zb = zb or {}
zb.Area2D = zb.Area2D or {}

local AREA = zb.Area2D

AREA.PointGroup = "ZCITY_2D_AREAS"
AREA.MaximumIDLength = 64

function AREA.NormalizeID(areaId)
	if not isstring(areaId) then return end

	areaId = string.lower(string.Trim(areaId))
	areaId = string.gsub(areaId, "%s+", "_")
	areaId = string.gsub(areaId, "[^%w_%-]", "")
	areaId = string.sub(areaId, 1, AREA.MaximumIDLength)
	if areaId == "" then return end

	return areaId
end

local function ResolveRawPoints(rawPoints)
	if istable(rawPoints) then return rawPoints end

	if SERVER and zb.GetMapPoints then
		return zb.GetMapPoints(AREA.PointGroup) or {}
	end

	return zb.ClPoints and zb.ClPoints[AREA.PointGroup] or {}
end

function AREA.GetPointData(areaId, rawPoints)
	areaId = AREA.NormalizeID(areaId)
	if not areaId then return {} end

	local points = {}
	for _, point in ipairs(ResolveRawPoints(rawPoints)) do
		if istable(point) and AREA.NormalizeID(point.areaId) == areaId and isvector(point.pos) then
			points[#points + 1] = point
		end
	end

	return points
end

function AREA.GetPolygon(areaId, rawPoints)
	local polygon = {}
	for _, point in ipairs(AREA.GetPointData(areaId, rawPoints)) do
		polygon[#polygon + 1] = Vector(point.pos.x, point.pos.y, 0)
	end

	return polygon
end

local function IsPointOnEdge(pos, first, second)
	local edgeX = second.x - first.x
	local edgeY = second.y - first.y
	local pointX = pos.x - first.x
	local pointY = pos.y - first.y
	local edgeLengthSqr = edgeX * edgeX + edgeY * edgeY
	if edgeLengthSqr <= 0.0001 then
		return pointX * pointX + pointY * pointY <= 0.0001
	end

	local cross = edgeX * pointY - edgeY * pointX
	if math.abs(cross) > 0.01 then return false end

	local dot = pointX * edgeX + pointY * edgeY
	if dot < 0 then return false end

	return dot <= edgeLengthSqr
end

-- Boundary points count as inside. An undefined polygon intentionally imposes
-- no restriction so consumers remain compatible with maps that have no area.
function AREA.IsPointInside(pos, polygon)
	if not isvector(pos) then return false end
	polygon = polygon or {}
	if #polygon < 3 then return true end

	local point2D = Vector(pos.x, pos.y, 0)
	local inside = false
	local previous = #polygon

	for index = 1, #polygon do
		local currentPoint = polygon[index]
		local previousPoint = polygon[previous]
		if IsPointOnEdge(point2D, previousPoint, currentPoint) then return true end

		local crossesY = (currentPoint.y > point2D.y) ~= (previousPoint.y > point2D.y)
		if crossesY then
			local edgeX = (previousPoint.x - currentPoint.x) * (point2D.y - currentPoint.y) / (previousPoint.y - currentPoint.y) + currentPoint.x
			if point2D.x < edgeX then inside = not inside end
		end

		previous = index
	end

	return inside
end

-- One map-wide item spawn boundary is shared by every mode. The Area2D
-- backend stays generic, while loot systems consume only this well-known ID.
zb.ItemSpawnArea = zb.ItemSpawnArea or {}
zb.ItemSpawnArea.ID = "item_spawn_area"

function zb.ItemSpawnArea.GetPolygon(rawPoints)
	return AREA.GetPolygon(zb.ItemSpawnArea.ID, rawPoints)
end

function zb.ItemSpawnArea.IsAllowed(pos, polygon)
	return AREA.IsPointInside(pos, polygon or zb.ItemSpawnArea.GetPolygon())
end
