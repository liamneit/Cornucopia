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

local GetPosition, GetPoint, IsDependant, IteratePoints, CodePoint, DecodePoint, OpositePoints = Cornucopia:ProvideUtility()
local L = Cornucopia.Locals
local _ = nil


--[[ Startup ]]--

function Cornucopia:InitializeConfig()
	local config = CreateFrame('Button', nil, Cornucopia)
	config:SetScript('OnDoubleClick', function(_, ...) self:Fire('OnDoubleClick', ...) end)
	config:SetScript('OnClick', function(_, ...) self:Fire('OnClick', ...) end)
	
	config:SetScript('OnDragStop', function() self:OnMovingStop() end)
	config:SetScript('OnDragStart', function() self:OnMovingStart() end)
	config:SetScript('OnMouseDown', function() self:OnMouseDown() end)
	
	config:SetFrameLevel(self:GetFrameLevel())
	config:RegisterForDrag('LeftButton')
	config:RegisterForClicks('AnyUp')
	config:SetFrameStrata('HIGH')
	config:SetAllPoints(self)
	config:EnableMouse(true)
	
	local overlay = CreateFrame('Frame', nil, config)
	overlay:SetAllPoints(config)
	overlay:Hide()
	
	self.overlay, self.config = overlay, config
	self:CreateLineBorder(overlay)
	self:SetMovable(true)
	self.id = id

	for x, y in IteratePoints() do
		if x ~= y then
			self:CreateSizer(x, y)
		end
	end
	
	if self.sets.hide then
		self:Remove()
	end
end

function Cornucopia:CreateSizer(x, y)
	local sizer = CreateFrame('Frame', nil, self.overlay)
	sizer:SetPoint('CENTER', self, (OpositePoints[y] or '') .. (OpositePoints[x] or ''))
	sizer:SetScript('OnMouseDown', function() self:OnSizingStart(x, y) end)
	sizer:SetScript('OnMouseUp', function() self:OnSizingStop() end)
	
	sizer:SetBackdrop({bgFile = 'Interface\\ChatFrame\\ChatFrameBackground'})
	sizer:SetBackdropColor(0, 0, 0)
	sizer:EnableMouse(true)
	sizer:SetHeight(6)
	sizer:SetWidth(6)
	
	local backdrop = sizer:CreateTexture()
	backdrop:SetPoint('BOTTOMRIGHT', -1, 1)
	backdrop:SetPoint('TOPLEFT', 1, -1)
	backdrop:SetTexture(1, 1, 1)
end

function Cornucopia:Remove(id)
	if self.group then
		self.group.sets[self.index] = nil
		self.Bars[id] = nil
	else
		self.sets.hide = true
	end
	
	self.config:Hide()
	self:Hide()
end


--[[ Selecting ]]--

function Cornucopia:OnMouseDown ()
	if not self.selected then
		self:ClearSelectedBars()
		self.Inspector:ShowBar(self)
	end
	
	self:ShowOverlay()
	self.Toolbar:Update()
	self:TriggerTutorial(4)
end

function Cornucopia:ShowOverlay()
	self.selected = true
	
	for id, bar in self:IterateBars() do
		if IsDependant(bar, self) then
			bar.overlay:SetAlpha(bar.selected and 1 or .5)
			bar.overlay:Show()
		end
	end
end

function Cornucopia:HideOverlay()
	for id, bar in self:IterateBars() do
		if IsDependant(bar, self) then
			bar.overlay:SetAlpha(0)
		end
	end
end


--[[ Moving ]]--

function Cornucopia:OnMovingStart()
	for id, bar in self:IterateBars() do
		if bar.selected then
			bar:StartMoving()
		end
	end
end

function Cornucopia:StartMoving()
	local cursorX, cursorY = GetCursorPosition()
	local startX, startY = GetPosition(self, 'Left', 'Bottom')
	local Xoff, Yoff = startX - cursorX, startY - cursorY
	
	self:HideOverlay()
	self:SetScript('OnUpdate', function()
		local x, y = GetCursorPosition()
		local scale = self:GetEffectiveScale()
		
		self:Reposition('BOTTOMLEFT', (x + Xoff) / scale, (y + Yoff) / scale)
		self:HideRulers()
		
		if self:RulersEnabled() then
			local x, y = GetPosition(self)
			local bestX, bestY = 5, 5
			
			for id, bar in self:IterateBars() do
				if bar:IsShown() and not bar.selected and not IsDependant(bar, self) then
					x, y, bestX, bestY = self:CenterBar(bar, x, y, bestX, bestY)
				end
			end
			x, y, bestX, bestY = self:CenterBar(UIParent, x, y, bestX, bestY)
			
			self:Reposition('Center', x / scale, y / scale)
		end
	end)
end

function Cornucopia:CenterBar(target, x, y, bestX, bestY)
	local targetX, targetY = GetPosition(target)
	local xOff, yOff = GetPosition(self, _, _, target)
	
	if abs(xOff) <= bestX then
		self:ShowRuler('X', target)
		bestX = xOff
		x = targetX
	end
					
	if abs(yOff) <= bestY then
		self:ShowRuler('Y', target)
		bestY = yOff
		y = targetY
	end
	
	return x, y, bestX, bestY
end

function Cornucopia:OnMovingStop()
	for id, bar in self:IterateBars() do
		if bar.selected then
			bar:SetScript('OnUpdate', nil)
			bar:SetClosestPosition()
			bar:ShowOverlay()
		end
	end
	
	self:HideRulers()
end


--[[ Sizing ]]--

function Cornucopia:OnSizingStart(xPoint, yPoint)
	self:Fire('OnResizeStart', xPoint, yPoint)
	self:HideOverlay()
	
	local scale, officialScale = self:GetEffectiveScale(), self:GetScale()
	local changeHeight, changeWidth = self.height, self.width
	local height, width = self:GetHeight(), self:GetWidth()
	
	local minWidth, minHeight, maxWidth, maxHeight = self:GetMinMaxSizes()
	minWidth, minHeight, maxWidth, maxHeight = minWidth * scale, minHeight * scale, maxWidth * scale, maxHeight * scale
	
	local parentX, parentY = GetPoint(UIParent, xPoint, 1), GetPoint(UIParent, yPoint, 2)
	local x, y = GetPosition(self, xPoint, yPoint)
	
	self:Reposition(yPoint .. xPoint, x / scale, y / scale)
	self:SetScript('OnUpdate', function()
		local cursorX, cursorY = GetCursorPosition()
		local centerX = abs(x + cursorX - parentX) / 2
		local centerY = abs(y + cursorY - parentY) / 2
		local h = abs(cursorY - parentY) - abs(y)
		local w = abs(cursorX - parentX) - abs(x)
		
		local rulers = self:RulersEnabled()
		self:HideRulers()
		
		if self.height or self.width then
			-- Height & Width
			local h = self.height and yPoint ~= '' and min(max(h, minHeight), maxHeight)
			local w = self.width and  xPoint ~= '' and min(max(w, minWidth), maxWidth)
			
			self:SetHeight(h and h / scale or height)
			self:SetWidth(w and w / scale or width)
			
			if rulers then
				for id, bar in self:IterateBars() do
					local bestX, bestY = 5, 5
					if bar ~= self and bar:IsShown() then
						local barX, barY = GetPosition(bar, _, _, _, xPoint, yPoint)
						local xOff, yOff = abs(barX) - centerX, abs(barY) - centerY
						
						if w and abs(xOff) <= bestX then
							self:SetWidth((w + xOff * 2) / scale)
							self:ShowRuler('X', bar)
							bestX = xOff
						end
									
						if h and abs(yOff) <= bestY then
							self:SetHeight((h + yOff * 2) / scale)
							self:ShowRuler('Y', bar)
							bestY = yOff
						end
					end
				end
			end
		else
			-- Scale
			local parentScale = scale / officialScale
			self:Rescale(max(h / height, w / width) / parentScale, xPoint, yPoint, x, y)
			
			if rulers then
				for id, bar in self:IterateBars() do
					local bestX, bestY = 5, 5
					if bar ~= self and bar:IsShown() then
						local barX, barY = GetPosition(bar, _, _, _, xPoint, yPoint)
						local xOff, yOff = abs(barX) - centerX, abs(barY) - centerY
						
						if xPoint ~= '' and abs(xOff) <= bestX then
							self:Rescale((w + xOff * 2) / width / parentScale, xPoint, yPoint, x, y)
							self:ShowRuler('X', bar)
							bestX = xOff
						end
						
						if yPoint ~= '' and abs(yOff) <= bestY then
							self:Rescale((h + yOff * 2) / height / parentScale, xPoint, yPoint, x, y)
							self:ShowRuler('Y', bar)
							bestY = yOff
						end
					end
				end
			end
		end
		
		self:Fire('OnResize', xPoint, yPoint)
	end)
end

function Cornucopia:OnSizingStop()
	local sets = self.sets
	if self.height or self.width then
		sets.height = self.height and self:GetHeight() or sets.height
		sets.width = self.width and self:GetWidth() or sets.width
	else
		sets.scale = self:GetScale()
	end
	
	self:SetScript('OnUpdate', nil)
	self:CalculatePosition()
	self:ShowOverlay()
	self:HideRulers()
end

function Cornucopia:Rescale(scale, xPoint, yPoint, x, y)
	self:SetScale(min(max(scale, self.minScale or 0.2), self.maxScale or 3))
	self:Reposition(yPoint .. xPoint, x / self:GetEffectiveScale(), y / self:GetEffectiveScale())
end

function Cornucopia:GetMinMaxSizes()
	return self.minWidth or 5, self.minHeight or 5, self.maxWidth or GetScreenWidth(), self.maxHeight or GetScreenHeight()
end


--[[ Position ]]--

function Cornucopia:SetClosestPosition()
	local sets, distance = self.sets
	local anchor = self:GetBar(sets.anchor) or UIParent
	local scale = self:GetEffectiveScale()
	
	for xPoint, yPoint in IteratePoints() do
		local x, y = GetPosition(self, xPoint, yPoint, anchor)
		local d = sqrt(x^2 + y^2)
			
		if not distance or d < distance then
			sets.point = CodePoint(yPoint .. xPoint)
			sets.relPoint = nil
			sets.y = y / scale
			sets.x = x / scale
			distance = d
		end
	end
	
	self:UpdatePosition()
end

function Cornucopia:CalculatePosition()
	local sets = self.sets
	local anchor = self:GetBar(sets.anchor) or UIParent
	local scale = (sets.scale or 1) * UIParent:GetScale()
	local xPoint, yPoint = DecodePoint(sets.point)
	local relX, relY = DecodePoint(sets.relPoint)
	
	local x, y = GetPosition(self, xPoint, yPoint, anchor, relX, relY)
	sets.x = x / scale
	sets.y = y / scale
	
	self:UpdatePosition()
end

function Cornucopia:UpdatePosition()
	local sets = self.sets
	self:Reposition(sets.point, self:GetBar(sets.anchor) or UIParent, sets.relPoint or sets.point, sets.x or 0, sets.y or 0)
	self.Inspector.Metrics:UpdateChildren()
end

function Cornucopia:Reposition(...)
	self:ClearAllPoints()
	self:SetPoint(...)
end


--[[ Rulers ]]--

function Cornucopia:RulersEnabled()
	if IsAltKeyDown() then
		return Cornucopia_HideRulers
	else
		return not Cornucopia_HideRulers
	end
end

function Cornucopia:ShowRuler(id, target)
	local ruler = self['Ruler'..id]
	ruler:SetParent(self.config)
	ruler:Show()
	
	if id == 'X' then
		ruler:SetPoint('BOTTOM', self:GetBottom() < target:GetBottom() and self or target)
		ruler:SetPoint('TOP', self:GetTop() > target:GetTop() and self or target)
	else
		ruler:SetPoint('RIGHT', self:GetRight() > target:GetRight() and self or target)
		ruler:SetPoint('LEFT', self:GetLeft() < target:GetLeft() and self or target)
	end
end

function Cornucopia:HideRulers()
	self.RulerX:Hide()
	self.RulerY:Hide()
end


--[[ Misc ]]--

function Cornucopia:SetLevel(level)
	self.config:SetFrameLevel(level)
	self:SetFrameLevel(level)
	self.sets.level = level
end

function Cornucopia:GetDisplayName()
	return L[self.name or self.id] .. (self.group and (' #'..self.index) or '')
end