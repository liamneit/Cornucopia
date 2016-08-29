--[[

Edited by LiamNeit 2016

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

local Bar = Cornucopia:GetBar('Minimap')
local Borders = {}


--[[ Startup ]]--

function Bar:TweakButtons()
	-- Map Button
	local WorldMapBorder = MiniMapWorldMapButton:CreateTexture(nil, 'OVERLAY')
	WorldMapBorder:SetPoint('TOPLEFT', -1, 2)
	WorldMapBorder:SetSize(54, 54)
	MiniMapWorldMapButton:SetScale(.9)
	tinsert(Borders, WorldMapBorder)
	
	local WorldIcon = MiniMapWorldMapButton:GetNormalTexture()
	WorldIcon:ClearAllPoints() WorldIcon:SetPoint('CENTER', -2, 2)
	WorldIcon:SetTexture('Interface/WorldMap/UI-World-Icon')
	WorldIcon:SetTexCoord(0, 1, 0, 1)
	WorldIcon:SetSize(22, 22)
	
	local WorldPushed = MiniMapWorldMapButton:GetPushedTexture()
	WorldPushed:ClearAllPoints() WorldPushed:SetPoint('CENTER', -2, 2)
	WorldPushed:SetTexture('Interface/WorldMap/UI-World-Icon')
	WorldPushed:SetVertexColor(.8, .8, .8)
	WorldPushed:SetTexCoord(0, 1, 0, 1)
	WorldPushed:SetSize(22, 22)
	
	local WorldLight = MiniMapWorldMapButton:GetHighlightTexture()
	WorldLight:SetTexture('Interface/Minimap/UI-Minimap-ZoomButton-Highlight')
	WorldLight:ClearAllPoints() WorldLight:SetPoint('CENTER', -1, 2)
	WorldLight:SetSize(34, 34)
	
	-- Others
	local GameTimeBorder = GameTimeFrame:CreateTexture(nil, 'OVERLAY')
	GameTimeBorder:SetPoint('TOPLEFT', -3, 1)
	GameTimeBorder:SetSize(70, 70)
	GameTimeFrame:SetScale(0.73)
	tinsert(Borders, GameTimeBorder)
	
	MiniMapTrackingButton:ClearAllPoints()
	MiniMapTracking:SetPoint('TOPLEFT', MiniMapTrackingButton)
	
	MiniMapTrackingIconOverlay:ClearAllPoints()
	MiniMapTrackingIconOverlay:SetPoint('TOPLEFT', 7, -7)
	MiniMapTrackingIconOverlay:SetPoint('BOTTOMRIGHT', -7, 7)
	MinimapZoomOut:Hide() MinimapZoomIn:Hide() MinimapBorder:Hide()
	
	if CornucopiaButton then
		CornucopiaButton:SetFrameStrata('DIALOG')
	end
end

function Bar:InitializeButtons(...)
	for i = 1, select('#', ...) do
		local button = select(i, ...)
		button:RegisterForDrag('LeftButton')
		button:SetMovable(true)
		
		button:SetScript('OnDragStart', function()
			local scale = Minimap:GetEffectiveScale()
			local mapX, mapY = Minimap:GetCenter()
			local name = button:GetName()
			
			self:SetScript('OnUpdate', function()
				local cursorX, cursorY = GetCursorPosition(UIParent)
				local angle = 180 - atan2(cursorY / scale - mapY , mapX - cursorX / scale)
				
				if name then
					self.sets.buttons[name] = angle
				end
				self:SetButtonPosition(button, angle)
			end)
			
			button:StartMoving()
		end)
			
		button:SetScript('OnDragStop', function()
			self:SetScript('OnUpdate', nil)
			
			local up = button:GetScript('OnMouseUp')
			if up then
				up(button)
			end
			button:StopMovingOrSizing()
		end)
		
		self:FindBorder(button:GetRegions())
	end
end

function Bar:FindBorder(...)
	for i = 1, select('#', ...) do
		local region = select(i, ...)
		if region.GetTexture and region:GetTexture() == 'Interface\\Minimap\\MiniMap-TrackingBorder' then
			return tinsert(Borders, region)
		end
	end
end


--[[ Update ]]--

function Bar:UpdateButtons(theme)
	for name, angle in pairs(self.sets.buttons) do
		local button = _G[name]
		if button then
			self:SetButtonPosition(button, angle)
		end
	end
	
	for i, texture in pairs(Borders) do
		texture:SetTexture(theme.button or 'Interface\\Minimap\\MiniMap-TrackingBorder')
	end
end

function Bar:SetButtonPosition(button, angle)
	local scale, x, y = button:GetScale()
	local radius = self.sets.radius / scale
	
	if self.corners[ceil(angle / 90)] then
		x = radius * cos(angle) - 1
		y = radius * sin(angle) - 1
	else
		x = max(-radius, min(110 / scale * cos(angle) - 1, radius))
		y = max(-radius, min(110 / scale * sin(angle) - 1, radius))
	end
	 
	button:ClearAllPoints()
	button:SetPoint('CENTER', Minimap, 'CENTER', x, y)
end