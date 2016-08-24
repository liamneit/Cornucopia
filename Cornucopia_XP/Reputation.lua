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

local Reputation = Cornucopia:CreateBar('Reputation', {
	name = 'Reputation',
	sets = 'Cornucopia_Rep_Sets',
	width = true, height = true,
	defaults = {
		hide = true, --hide = not GetWatchedFactionInfo() or nil,
		point = 'BOTTOM',
		width = 1024,
		height = 8,
		y = 54
	}
})

function Reputation:OnInitialize()
	ReputationWatchBar:UnregisterEvent('PLAYER_LEVEL_UP')
	ReputationWatchBar:UnregisterEvent('DISABLE_XP_GAIN')
	ReputationWatchBar:UnregisterEvent('ENABLE_XP_GAIN')
	ReputationWatchBar:SetScript('OnShow', nil)
	ReputationWatchBar:SetScript('OnHide', nil)
	ReputationWatchBar:SetParent(self)
	ReputationWatchBar:SetAllPoints()

	ReputationWatchStatusBar:DisableDrawLayer('OVERLAY')
	ReputationWatchStatusBar:SetPoint('BOTTOM')
	
	local fake = function() end
	ReputationWatchBar.ClearAllPoints = fake
	ReputationWatchBar.SetPoint = fake
	
	self:SetScript('OnSizeChanged', function()
		ReputationWatchStatusBar:SetWidth(self:GetWidth())
	end)
end