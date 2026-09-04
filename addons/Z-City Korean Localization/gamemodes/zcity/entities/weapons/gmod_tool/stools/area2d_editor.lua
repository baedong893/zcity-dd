TOOL.Category = "Z-City"
TOOL.Name = "공용 아이템 스폰 구역"
TOOL.Command = nil
TOOL.ConfigName = ""

local zoneColor = Color(55, 210, 95, 230)

if CLIENT then
	language.Add("tool.area2d_editor.name", "공용 아이템 스폰 구역")
	language.Add("tool.area2d_editor.desc", "모든 모드의 절차적 아이템 생성을 허용할 2D 구역을 설정합니다.")
	language.Add("tool.area2d_editor.0", "좌클릭: 점 추가 | 우클릭: 마지막 점 취소 | 재장전: 구역 삭제")
end

local function CanEdit(ply)
	return IsValid(ply) and ply:IsAdmin()
end

function TOOL:GetSelectedAreaID()
	return zb and zb.ItemSpawnArea and zb.ItemSpawnArea.ID
end

function TOOL:LeftClick(trace)
	local ply = self:GetOwner()
	if not CanEdit(ply) then return false end
	if CLIENT then return true end

	local areaId = self:GetSelectedAreaID()
	if not areaId then
		ply:ChatPrint("공용 아이템 스폰 구역 시스템이 아직 준비되지 않았습니다.")
		return false
	end

	if not trace.Hit or trace.HitSky then
		ply:ChatPrint("유효한 지면이나 구조물을 조준해야 합니다.")
		return false
	end

	local success = zb.Area2D.AddPoint(areaId, trace.HitPos)
	if not success then return false end

	local pointCount = #zb.Area2D.GetPointData(areaId)
	ply:ChatPrint("[" .. areaId .. "] 점 #" .. pointCount .. " 추가됨. 점 3개부터 닫힌 구역이 됩니다.")
	return true
end

function TOOL:RightClick()
	local ply = self:GetOwner()
	if not CanEdit(ply) then return false end
	if CLIENT then return true end

	local areaId = self:GetSelectedAreaID()
	if not areaId then
		ply:ChatPrint("공용 아이템 스폰 구역 시스템이 아직 준비되지 않았습니다.")
		return false
	end

	local success, reason = zb.Area2D.RemoveLastPoint(areaId)
	if not success then
		if reason == "empty_area" then ply:ChatPrint("[" .. areaId .. "] 취소할 점이 없습니다.") end
		return false
	end

	ply:ChatPrint("[" .. areaId .. "] 마지막 점을 취소했습니다. 현재 " .. #zb.Area2D.GetPointData(areaId) .. "개입니다.")
	return true
end

function TOOL:Reload()
	local ply = self:GetOwner()
	if not CanEdit(ply) then return false end
	if CLIENT then return true end

	local areaId = self:GetSelectedAreaID()
	if not areaId then
		ply:ChatPrint("공용 아이템 스폰 구역 시스템이 아직 준비되지 않았습니다.")
		return false
	end

	if not zb.Area2D.Clear(areaId) then return false end
	ply:ChatPrint("[" .. areaId .. "] 구역의 모든 점을 삭제했습니다.")
	return true
end

function TOOL:Allowed()
	return CanEdit(self:GetOwner())
end

function TOOL:Deploy()
	if SERVER then
		local ply = self:GetOwner()
		if CanEdit(ply) and zb and zb.SendSpecificPointsToPly and zb.Area2D then
			zb.SendSpecificPointsToPly(ply, zb.Area2D.PointGroup)
		end
	end

	return true
end

if CLIENT then
	local function Cross2D(first, second, third)
		return (second.x - first.x) * (third.y - first.y) - (second.y - first.y) * (third.x - first.x)
	end

	local function PointInTriangle(point, first, second, third, winding)
		local firstCross = Cross2D(first, second, point) * winding
		local secondCross = Cross2D(second, third, point) * winding
		local thirdCross = Cross2D(third, first, point) * winding
		return firstCross > 0.01 and secondCross > 0.01 and thirdCross > 0.01
	end

	-- surface.DrawPoly fills a concave polygon as a triangle fan, which draws
	-- long triangles across cut-outs. Ear clipping keeps the fill inside the
	-- actual outline and falls back to outline-only for invalid polygons.
	local function TriangulatePolygon(points)
		if #points < 3 then return {} end

		local signedArea = 0
		for index, point in ipairs(points) do
			local nextPoint = points[index % #points + 1]
			signedArea = signedArea + point.x * nextPoint.y - nextPoint.x * point.y
		end
		if math.abs(signedArea) <= 0.01 then return {} end

		local winding = signedArea > 0 and 1 or -1
		local remaining = {}
		for index = 1, #points do remaining[index] = index end

		local triangles = {}
		local safety = #points * #points
		while #remaining > 3 and safety > 0 do
			safety = safety - 1
			local clippedEar = false

			for listIndex = 1, #remaining do
				local previousIndex = remaining[(listIndex - 2) % #remaining + 1]
				local currentIndex = remaining[listIndex]
				local nextIndex = remaining[listIndex % #remaining + 1]
				local previousPoint = points[previousIndex]
				local currentPoint = points[currentIndex]
				local nextPoint = points[nextIndex]

				if Cross2D(previousPoint, currentPoint, nextPoint) * winding > 0.01 then
					local containsPoint = false
					for _, candidateIndex in ipairs(remaining) do
						if candidateIndex ~= previousIndex and candidateIndex ~= currentIndex and candidateIndex ~= nextIndex then
							if PointInTriangle(points[candidateIndex], previousPoint, currentPoint, nextPoint, winding) then
								containsPoint = true
								break
							end
						end
					end

					if not containsPoint then
						triangles[#triangles + 1] = {previousPoint, currentPoint, nextPoint}
						table.remove(remaining, listIndex)
						clippedEar = true
						break
					end
				end
			end

			if not clippedEar then return {} end
		end

		if #remaining == 3 then
			triangles[#triangles + 1] = {
				points[remaining[1]],
				points[remaining[2]],
				points[remaining[3]]
			}
		end

		return triangles
	end

	function TOOL:GetClientPointData()
		local areaId = self:GetSelectedAreaID()
		if not areaId or not zb or not zb.Area2D then return {}, areaId end

		local stored = zb.ClPoints and zb.ClPoints[zb.Area2D.PointGroup] or {}
		return zb.Area2D.GetPointData(areaId, stored), areaId
	end

	function TOOL:DrawHUD()
		if not CanEdit(LocalPlayer()) then return end

		local pointData, areaId = self:GetClientPointData()
		local screenPoints = {}
		local allVisible = #pointData >= 3
		for index, point in ipairs(pointData) do
			local drawPos = Vector(point.pos.x, point.pos.y, tonumber(point.displayZ) or 0)
			local screen = (drawPos + Vector(0, 0, 6)):ToScreen()
			screenPoints[index] = {x = screen.x, y = screen.y, u = 0, v = 0, visible = screen.visible}
			if not screen.visible then allVisible = false end
		end

		if allVisible then
			draw.NoTexture()
			surface.SetDrawColor(55, 210, 95, 35)
			for _, triangle in ipairs(TriangulatePolygon(screenPoints)) do
				surface.DrawPoly(triangle)
			end
		end

		surface.SetDrawColor(zoneColor)
		for index, point in ipairs(screenPoints) do
			if point.visible then
				surface.DrawRect(point.x - 4, point.y - 4, 8, 8)
				draw.SimpleText(index, "DermaDefaultBold", point.x, point.y - 13, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local nextPoint = screenPoints[index + 1]
			if not nextPoint and #screenPoints >= 3 then nextPoint = screenPoints[1] end
			if nextPoint and point.visible and nextPoint.visible then
				surface.DrawLine(point.x, point.y, nextPoint.x, nextPoint.y)
			end
		end

		local label = areaId and "공용 아이템 스폰 구역" or "구역 시스템 준비 안 됨"
		draw.SimpleText(label .. ": " .. #pointData .. "개 점", "DermaDefaultBold", ScrW() * 0.5, 42, zoneColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function TOOL:DrawToolScreen(width, height)
		surface.SetDrawColor(18, 26, 20)
		surface.DrawRect(0, 0, width, height)
		draw.SimpleText("Z-CITY", "DermaLarge", width * 0.5, height * 0.3, zoneColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("ITEM SPAWN", "DermaDefaultBold", width * 0.5, height * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Z축 무시", "DermaDefault", width * 0.5, height * 0.65, Color(190, 205, 195), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function TOOL.BuildCPanel(panel)
		panel:AddControl("Header", {
			Description = "모든 모드가 공유하는 아이템 스폰 허용 구역을 만듭니다. 점을 외곽선 순서대로 찍으십시오. 판정은 X/Y만 사용합니다."
		})
		panel:Help("좌클릭: 다음 점 추가")
		panel:Help("우클릭: 마지막 점 취소")
		panel:Help("재장전: 구역 전체 삭제")
		panel:Help("점이 3개 미만이면 아이템 스폰 제한을 적용하지 않습니다.")
		panel:Help("플레이어, NPC, 자기장, 레드존에는 영향을 주지 않습니다.")
	end
end
