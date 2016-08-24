--[[
Copyright 2010-2012 João Cardoso
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

local Minimap = Cornucopia:GetBar('Minimap')
local Bar = Cornucopia:CreateBar('Zone', {
	sets = 'Cornucopia_Zone_Sets',
	name = 'Zone',
	defaults = {
		background = 'Warcraft', 
		point = 'Bottom', relPoint = 'Top',
		anchor = 'Minimap',
		y = -6,
	}
})

function Bar:OnInitialize() -- ALL TEMP!! NOT DONE!!
	MinimapZoneTextButton:SetParent(self)
	MinimapZoneTextButton:SetPoint('CENTER', 5, 0)
	
	--MinimapBorderTop:SetParent(self)
	--MinimapBorderTop:SetTexCoord(1, 0, 1, 0)
	--MinimapBorderTop:SetAllPoints()
	MinimapBorderTop:Hide() -- For now, disabled
	
	self:SetSize(160, 32)
end