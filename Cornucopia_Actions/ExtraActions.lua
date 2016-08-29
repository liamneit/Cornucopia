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

local Frame = ExtraActionBarFrame
local Button = Frame.button
local Extra = Cornucopia:CreateBar('ExtraActions', {
	sets = 'Cornucopia_ExtraAction_Sets',
	name = 'Extra Action',
	defaults = {
		point = 'Bottom',
		x = 0, y = 150,
	}
})

function Extra:OnInitialize()
	Frame:SetScript('OnHide', nil)
	Frame:SetParent(self)
	Frame:SetAllPoints()
	
	self:SetSize(Button.style:GetWidth(), 80)
end

function Extra:OnUnlock()
	Frame:Show()
	Frame:SetAlpha(1)
	Button.style:SetTexture('Interface\\ExtraButton\\Default.blp')
	Button:Show()
	
	local fake = self.fake or Button:CreateTexture()
	fake:SetTexture('Interface\\Icons\\Spell_Nature_WispSplodeGreen')
	fake:SetAllPoints()
	fake:Show()
	self.fake = fake
end

function Extra:OnLock()
	if HasExtraActionBar() then
		ExtraActionBar_OnShow(Frame)
	else
		Frame:Hide()
	end

	self.fake:Hide()
end

function Extra:OnToolsShown()
	CornucopiaActions_StartBinder (self)
end

function	Extra:GetBindButtons()
	return {Button}
end