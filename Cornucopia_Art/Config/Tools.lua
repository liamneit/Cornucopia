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

if not IsAddOnLoaded('Cornucopia_Art') then
	return
end

local L = Cornucopia.Locals
local Art = Cornucopia:GetGroup('Art')
local GlowBox = SushiGlowBox()
GlowBox:SetText(L['Resize the image to hide undesired areas.'])
GlowBox:SetCall('OnClose', function()
	Art.cropTarget:OnDoubleClick()
end)


--[[ Toggle Events ]]--

function Art:OnDoubleClick ()
	local sets = self.sets
	if not sets.texture then
		return
	end
	
	local original = self.original or self:CreateTexture(nil, 'BACKGROUND')
	local coord = sets.coord
	
	if self:Cropping() then
		Art.cropTarget, self.maxWidth, self.maxHeight = nil
		original:Hide()
		GlowBox:Hide()
	else
		-- Glow box
		if Art.cropTarget then
			Art.cropTarget:OnDoubleClick()
		end
		
		GlowBox:Show()
		GlowBox:SetPoint('BOTTOM', original, 'TOP', -4, 25)
		Art.cropTarget = self
		
		-- Faded full image
		self.maxHeight = sets.height / (coord[4] - coord[3])
		self.maxWidth = sets.width / (coord[2] - coord[1])
		self.origWidth, self.origHeight = self.maxWidth, self.maxHeight
		
		original:SetSize(self.maxWidth, self.maxHeight)
		original:SetVertexColor(.7,.7,.7, .5)
		original:Show()
	end
	
	self:Fire('MetricsChanged')
	self.original = original
	self:Update()
end

function Art:OnFlipHorizontal ()
	self.sets.flipX = self.sets.flipX * -1
	self:Update()
end

function Art:OnFlipVertical ()
	self.sets.flipY = self.sets.flipY * -1
	self:Update()
end


--[[ Drag Events ]]--

function Art:OnResizeStart (...)
	if not self:Cropping() then
		return
	end

	local xPoint, yPoint = self:FlipPoints (...)
	local coord = self.sets.coord
	
	if xPoint == 1 then
		self.maxWidth = self.origWidth * (1 - coord[1])
	elseif xPoint == -1 then
		self.maxWidth = self.origWidth * coord[2]
	end
	
	if yPoint == 1 then
		self.maxHeight = self.origHeight * (1 - coord[3])
	elseif yPoint == -1 then
		self.maxHeight = self.origHeight * coord[4]
	end
end

function Art:OnResize (...)
	if not self:Cropping() then
		return
	end

	local xPoint, yPoint = self:FlipPoints (...)
	local width, height = self:GetSize()
	local coord = self.sets.coord

	-- dragging
	if xPoint == 1 then
		coord[2] = coord[1] + width / self.origWidth
	elseif xPoint == -1 then
		coord[1] = coord[2] - width / self.origWidth
	end
	
	if yPoint == 1 then
		coord[4] = coord[3] + height / self.origHeight
	elseif yPoint == -1 then
		coord[3] = coord[4] - height / self.origHeight
	end
	
	-- inspector resize
	if xPoint == 0 and yPoint == 0 then
		local off = width / self.origWidth / 2
		coord[2] = .5 + off
		coord[1] = .5 - off
		
		local off = height / self.origHeight / 2
		coord[4] = .5 + off
		coord[3] = .5 - off
	end

	self:Update()
end
		
function Art:OnLock ()
	if self:Cropping() then
		self.original:Hide()
		GlowBox:Hide()
	end
end

function Art:OnUnlock ()
	if self:Cropping() then
		self.original:Show()
		GlowBox:Show()
	end
	
	self:ToggleTools()
end


--[[ Methods ]]--

function Art:UpdateOriginal ()
	local sets = self.sets
	local coord = sets.coord
	
	local yOff = self.origHeight * (1 - coord[3] - coord[4]) * sets.flipY
	local xOff = self.origWidth * (1 - coord[1] - coord[2]) * sets.flipX
	
	self.original:SetTexture(sets.texture)
	self.original:SetPoint('CENTER', xOff / 2, - yOff / 2)
	self.original:SetTexCoord(self:FlipCoords(0, 1, 0, 1))
end

function Art:FlipPoints (xPoint, yPoint)
	xPoint = xPoint == 'Left' and 1 or xPoint == 'Right' and -1 or 0
	yPoint = yPoint == 'Top' and 1 or yPoint == 'Bottom' and -1 or 0
	
	return xPoint * self.sets.flipX, yPoint * self.sets.flipY
end


--[[ Buttons ]]--

Art.tools = {
	{
		icon = 'Interface\\Addons\\Cornucopia\\Art\\Crop',
		func = Art.OnDoubleClick,
		label = L['Crop']
	},
	{
		icon = 'Interface\\Addons\\Cornucopia\\Art\\Flip.tga',
		coord = {0,1, 1,1, 0,0, 1,0}, -- rotates 90 degrees
		func = Art.OnFlipHorizontal,
		anchor = 'BOTTOMRIGHT',
		label = L['Flip'],
	},
	{
		icon = 'Interface\\Addons\\Cornucopia\\Art\\Flip.tga',
		func = Art.OnFlipVertical,
		spacer = true
	},
}