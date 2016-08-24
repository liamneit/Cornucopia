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

local Menu = Cornucopia:CreateBar('Menu', {
	name = 'Menu',
	sets = 'Cornucopia_Menu_Sets',
	defaults = {
		point = 'BottomLeft', relPoint = 'Bottom',
		x = 5, y = 1.8,
		level = 2,
	}
})

local buttons = {
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	GuildMicroButton,
	PVPMicroButton,
	LFDMicroButton,
	EJMicroButton,
	RaidMicroButton,
	MainMenuMicroButton,
	HelpMicroButton
}

function Menu:OnInitialize()
	self:SetSize(#buttons * 25, 36)
	
	for i, button in pairs(buttons) do
		button:SetParent(self)
		button:SetPoint('BOTTOMLEFT', (i - 1) * 25, 0)
	end
	buttons = nil
end