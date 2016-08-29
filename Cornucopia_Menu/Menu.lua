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

local Menu = Cornucopia:CreateBar('Menu', {
	name = 'Menu',
	sets = 'Cornucopia_Menu_Sets',
	defaults = {
		point = 'BottomLeft', relPoint = 'Bottom',
		-- x = 5, y = 1.8,
		level = 2,
		y = 26.51506546949789,
	        x = -622.4663246334246,
	}
})

function Menu:OnInitialize()
	

	self:SetSize(#MICRO_BUTTONS * 25, 36)
	self:SetScript('OnShow', self.OnShow)
	self:OnShow()
end

function Menu:OnShow()
	UpdateMicroButtonsParent(self)
	---MoveMicroButtons('BOTTOMLEFT', self, 'BOTTOMLEFT', 0,0)
	-- Just set Anchor but do not Refresh for 5.4.1
	CharacterMicroButton:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 0,0);
end



