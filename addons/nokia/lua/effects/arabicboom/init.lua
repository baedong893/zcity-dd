-- Disabled arabicboom effect.
-- Kept only so old references to util.Effect("arabicboom", ...) do not error.
function EFFECT:Init(data)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
