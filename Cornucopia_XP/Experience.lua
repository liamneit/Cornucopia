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

local Experience = Cornucopia:CreateBar('Experience', {
	name = 'Experience',
	sets = 'Cornucopia_XP_Sets',
	width = true, height = true,
	defaults = {
		hide = UnitLevel('player') == MAX_PLAYER_LEVEL or IsXPUserDisabled(),
		point = 'BOTTOM',
		width = 1024, height = 11,
		level = 0,
		y = 41.9,
	}
})

function Experience:OnInitialize()
	MainMenuBarMaxLevelBar:SetScript('OnShow', nil)
	MainMenuBarMaxLevelBar:SetScript('OnHide', nil)
	
	MainMenuExpBar:DisableDrawLayer('OVERLAY')
	MainMenuExpBar:SetParent(self)
	MainMenuExpBar:SetPoint('BOTTOM')
	MainMenuExpBar:SetPoint('TOP')
	
	ExhaustionTick:SetScript('OnShow', ExhaustionTick.Hide)
	ExhaustionTick:Hide()
	
	self.UpdateWidth = self.UpdateWidth
	self:UpdateWidth()
end

function Experience:UpdateWidth()
	if GetRestState() then
		MainMenuExpBar_SetWidth(self:GetWidth())
		self:SetScript('OnSizeChanged', self.UpdateWidth)
		self:SetScript('OnEvent', nil)
		self:UnregisterAllEvents()
	else
		self:SetScript('OnEvent', self.UpdateWidth)
		self:RegisterEvent('PLAYER_ENTERING_WORLD')
	end
end