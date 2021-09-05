local module = {}
local Studio = settings().Studio

local BoundColors = {}

Studio.ThemeChanged:Connect(function()
	for _, v in pairs(BoundColors) do
		local object,property,styleGuide,modifier = v[1],v[2],v[3],v[4]

		object[property] = module:GetColor(styleGuide, modifier)
		if object.Parent == nil then
			table.remove(BoundColors, table.find(BoundColors, object))
		end
	end
end)

function module:SyncColors(object, property, styleGuide, modifier)
	local foundIt = false
	for i, v in pairs(BoundColors) do
		if v[1] == object and v[2] == property then
			v[3] = styleGuide
			v[4] = modifier
			foundIt = true
		end
	end
	if not foundIt then
		table.insert(BoundColors, {object,property,styleGuide,modifier})
	end
	object[property] = module:GetColor(styleGuide, modifier)
end

function module:GetColor(styleGuide, modifier)
	return Studio.Theme:GetColor(styleGuide, modifier)
end

return module
