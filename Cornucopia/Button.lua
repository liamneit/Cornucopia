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

local Button = CreateFrame('Button', 'CornucopiaButton', MinimapBackdrop)
Button:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
Button:SetPoint('CENTER', -68.24, 11.86)
Button:SetHeight(31) Button:SetWidth(31)

local border = Button:CreateTexture(nil, 'OVERLAY')
border:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
border:SetPoint('TOPLEFT')
border:SetSize(52, 52)

local icon = Button:CreateTexture(nil, 'ARTWORK')
icon:SetTexture('Interface\\Addons\\Cornucopia\\Art\\Icon')
icon:SetTexCoord(.1, .9, 0, 1)
icon:SetPoint('CENTER', 3, 1)
icon:SetSize(21, 27)

local background = Button:CreateTexture(nil, 'BACKGROUND')
background:SetTexture(0, 0, 0, .3)
background:SetPoint('CENTER', 0, 1)
background:SetSize(17, 17)


--[[ Click ]]--

Button:SetScript('OnClick', function()
	Cornucopia:ToggleConfig()
end)

Button:SetScript('OnMouseDown', function()
	background:SetTexture(0, 0, 0, .7)
	icon:SetVertexColor(.4, .4, .4)
	icon:SetPoint('CENTER', 4, -1)
end)

Button:SetScript('OnMouseUp', function()
	background:SetTexture(0, 0, 0, .3)
	icon:SetPoint('CENTER', 2, 1)
	icon:SetVertexColor(1, 1, 1)
end)


--[[ Tooltip ]]--

Button:SetScript('OnEnter', function()
	GameTooltip_AddNewbieTip(Button, MicroButtonTooltipText('Cornucopia ', 'CORNUCOPIA'), 1,1,1, 'Toggles the configuration mode.')
end)

Button:SetScript('OnLeave', function()
	GameTooltip:Hide()
end)