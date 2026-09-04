zb = zb or {}
zb.Area2D = zb.Area2D or {}

local AREA = zb.Area2D
local zeroAngle = Angle(0, 0, 0)

local function CopyOtherAreas(areaId)
	local output = {}
	for _, point in ipairs(zb.GetMapPoints(AREA.PointGroup, true) or {}) do
		if not istable(point) or AREA.NormalizeID(point.areaId) ~= areaId then
			output[#output + 1] = point
		end
	end

	return output
end

function AREA.SavePointData(areaId, pointData)
	areaId = AREA.NormalizeID(areaId)
	if not areaId then return false, "invalid_area_id" end

	local allPoints = CopyOtherAreas(areaId)
	local savedAreaPoints = {}
	for _, point in ipairs(pointData or {}) do
		local pos = istable(point) and point.pos or point
		if isvector(pos) then
			local storedPoint = {
				areaId = areaId,
				pos = Vector(pos.x, pos.y, 0),
				ang = zeroAngle,
				displayZ = tonumber(istable(point) and point.displayZ) or pos.z
			}
			allPoints[#allPoints + 1] = storedPoint
			savedAreaPoints[#savedAreaPoints + 1] = storedPoint
		end
	end

	zb.SaveMapPoints(AREA.PointGroup, allPoints)
	if zb.SendPointGroup then zb.SendPointGroup(AREA.PointGroup, allPoints) end

	local polygon = AREA.GetPolygon(areaId, savedAreaPoints)
	hook.Run("ZB_Area2DSaved", areaId, polygon)
	return true, polygon
end

function AREA.AddPoint(areaId, pos)
	if not isvector(pos) then return false, "invalid_position" end

	local pointData = AREA.GetPointData(areaId)
	pointData[#pointData + 1] = {
		pos = Vector(pos.x, pos.y, 0),
		displayZ = pos.z
	}

	return AREA.SavePointData(areaId, pointData)
end

function AREA.RemoveLastPoint(areaId)
	local pointData = AREA.GetPointData(areaId)
	if #pointData == 0 then return false, "empty_area" end

	table.remove(pointData)
	return AREA.SavePointData(areaId, pointData)
end

function AREA.Clear(areaId)
	return AREA.SavePointData(areaId, {})
end
