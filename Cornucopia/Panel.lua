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

local Panel = CreateFrame('Frame', 'CornucopiaInterfaceOptionsPanel')
Panel.name = 'Cornucopia'

hooksecurefunc('InterfaceOptionsList_DisplayPanel', function(target)
	if target == Panel then
		local loaded, reason = LoadAddOn('Cornucopia_Config')
		if not loaded then
			local string = Panel:CreateFontString(nil, nil, 'GameFontHighlight')
			string:SetText(format('"Cornucopia_Config" could not be loaded because the addon is %s', strlower(_G['ADDON_'..reason])))
			string:SetPoint('RIGHT', -40, 0)
			string:SetPoint('LEFT', 40, 0)
			string:SetHeight(30)
		else
			InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL)
			Cornucopia:ToggleConfig()
		end 
	end
end)

InterfaceOptions_AddCategory(Panel)