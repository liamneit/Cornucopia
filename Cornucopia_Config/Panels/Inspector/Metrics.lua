--[[
Copyright 2010-2013 João Cardoso
Cornucopia is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of Cornucopia.

Cornucopia is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cornucopia is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cornucopia. If not, see <http://www.gnu.org/licenses/>.
--]]


local GetPosition, GetPoint, IsDependant, IteratePoints, CodePoint, DecodePoint = Cornucopia:ProvideUtility()
local Metrics = SushiGroup()
local L = Cornucopia.Locals
local bar, sets


--[[ Startup ]]--

function Metrics:Startup()
	self:SetWidth(250)
	self:SetContent(self.Update)
	self:SetOrientation('HORIZONTAL')
	
	self.name = L.Metrics
	self.Startup = nil
end

function Metrics:Update()
	local parent = self:GetParent()
	if parent then
		bar = parent.bar
	end

	if bar then
		sets = bar.sets
		
		-- Anchor
		self:AnchorDropdown()
		self:PointsDropdown('With', 'point')
		self:PointsDropdown('To', 'relPoint')
		self:OffsetEditBox('X', 'x')
		self:OffsetEditBox('Y', 'y')
		
		-- Size
		self:ScaleSlider()
		if bar.width or bar.height then
			local minWidth, minHeight, maxWidth, maxHeight = bar:GetMinMaxSizes()
			self:SizeSlider('Height', 'height', 'SetHeight', minHeight, maxHeight)
			self:SizeSlider('Width', 'width', 'SetWidth', minWidth, maxWidth)
		end
		
		-- Opacity
		self:OpacitySlider()
	end
end


--[[ Common ]]--

function Metrics:HeaderChild(kind, name, width)
	local header = self:CreateChild('Header')
	header:SetFont('GameFontHighlight')
	header:SetUnderlined(true)
	header:SetText(L[name])

	local child = self:CreateChild(kind)
	child:SetWidth(width)
	child.top = 3
	return child
end

function Metrics:SmallChild(kind, width, name)
	local child = self:CreateChild(kind)
	child:SetLabel(L[name])
	child:SetWidth(width)
	child:SetSmall(true)
	return child
end


--[[ Anchor ]]--

function Metrics:AnchorDropdown()
	local t = {}
	local drop = self:HeaderChild('Dropdown', 'Anchor', 260)
	drop:SetValue(sets.anchor or UIParent)
	drop:AddLine(UIParent, L['Screen'])

	-- Create array of names and sort
	for id, target in Cornucopia:IterateBars() do
		if not IsDependant(target, bar) then
			tinsert(t, target:GetDisplayName())
		end
	end
	sort(t)

	-- Associate names to frames
	for _, name in pairs(t) do
		for id, target in Cornucopia:IterateBars() do
			if target:GetDisplayName() == name then
				drop:AddLine(id, name)
				break
			end
		end
	end
	
	drop:SetCall('OnInput', function(_, v)
		sets.anchor = v ~= UIParent and v or nil
		bar:CalculatePosition()
	end)
end

function Metrics:PointsDropdown(name, arg)
	local drop = self:SmallChild('Dropdown', 140, name, arg)
	drop.right = -20
	
	drop:SetValue(sets[arg] or sets['point'] or '')
	drop:SetCall('OnInput', function(_, v)
		sets[arg] = v
		bar:CalculatePosition()
	end)
	
	for x, y in IteratePoints() do
		local point = CodePoint(y..x)
		drop:AddLine(point, L[point])
	end
end

function Metrics:OffsetEditBox(name, arg)
	local box = self:SmallChild('EditBox', 97, name, arg)
	local value = (sets[arg] or 0) * 100 + 0.5
	
	box.right = 0
	box.bottom = 8
	box:SetCursorPosition(0)
	box:SetValue(floor(value) / 100)
	box:SetCall('OnInput', function(_, v)
		if tonumber(v) then
			sets[arg] = v
			bar:UpdatePosition()
		end
	end)
end


--[[ Size & Opacity ]]--

function Metrics:ScaleSlider()
	local maximun = min(GetScreenHeight() / bar:GetHeight(), GetScreenWidth() / bar:GetWidth(), bar.maxScale or 3)
	self:PercentSlider('Size', sets.scale, bar.minScale or 0.2, maximun, function(scale)
		sets.scale = scale
		bar:CalculatePosition()
		bar:SetScale(scale)
	end)
end

function Metrics:OpacitySlider()
	self:PercentSlider('Opacity', sets.alpha, 0, 1, function(alpha)
		sets.alpha = alpha
		bar:SetAlpha(alpha)
	end).bottom = 15
end

function Metrics:PercentSlider(name, value, min, max, method)
	local slider = self:HeaderChild('Slider', name, 230)
	slider:SetRange(min * 100, max * 100)
	slider:SetValue((value or 1) * 100)
	slider:SetRangeText('', '')
	slider:SetPattern('%s%')
	slider.bottom = 6
	
	slider:SetCall('OnInput', function(_, v)
		method(v / 100)
	end)
	return slider
end

function Metrics:SizeSlider(name, arg, method, min, max)
	local slider = self:SmallChild('Slider', 110, name, arg)
	local scale = bar:GetScale()

	slider:SetRange((min or 5) / scale, max / scale)
	slider:SetValueText(not bar[arg] and '')
	slider:SetDisabled(not bar[arg])
	slider:SetValue(sets[arg] or 0)
	slider:SetRangeText('', '')
	slider.bottom = 12
	slider.right = -3
	
	slider:SetCall('OnInput', function(_, v)
		local xPoint, yPoint = DecodePoint(sets.point)
		bar:Fire('OnResizeStart', xPoint, yPoint)
		
		sets[arg] = v
		bar[method](bar, v)
		bar:Fire('OnResize', xPoint, yPoint)
	end)
end


--[[ The End ]]--

Cornucopia.Inspector.Metrics = Metrics
Metrics:Startup()