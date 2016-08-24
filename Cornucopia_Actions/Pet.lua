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

local Pet = Cornucopia:CreateBar('Pet', {
	sets = 'Cornucopia_Pet_Sets',
	name = 'Pet Control',
	defaults = {
		point = 'Bottom',
		x = -254, y = 100,
	}
})

local FakeIcons = {
	PET_ATTACK_TEXTURE,
	PET_FOLLOW_TEXTURE,
	PET_MOVE_TO_TEXTURE,
	nil, nil, nil, nil,
	PET_AGGRESSIVE_TEXTURE,
	PET_DEFENSIVE_TEXTURE,
	PET_PASSIVE_TEXTURE
}


--[[ Startup ]]--

function Pet:OnInitialize()
	UIPARENT_MANAGED_FRAME_POSITIONS['PETACTIONBAR_YPOS'] = nil
	PetActionBarFrame:DisableDrawLayer('OVERLAY')
	PetActionBarFrame:SetScript('OnShow', nil)
	PetActionBarFrame:SetScript('OnHide', nil)
	PetActionBarFrame:SetParent(self)
	
	for i = 1, NUM_PET_ACTION_SLOTS do
		local button = _G['PetActionButton'..i]
		button:ClearAllPoints()
		button:SetPoint('BOTTOMLEFT', self, (i - 1) * 34 + 2, 2)
	end
	
	self:SetSize(34 * NUM_PET_ACTION_SLOTS, 33)
end


--[[ Config ]]--

function Pet:OnToolsShown()
	CornucopiaActions_StartBinder(self, true)
end

function	Pet:GetBindButtons()
	return {PetActionBarFrame:GetChildren()}
end

function Pet:OnUnlock()
	for i = 1, NUM_PET_ACTION_SLOTS do
		local button = _G['PetActionButton'..i]
		local icon = self:CreateTexture()
		local file = FakeIcons[i]
		
		icon:SetTexture(file or 'Interface/Buttons/UI-Quickslot')
		icon:SetSize(file and 30 or 54, file and 30 or 54)
		icon:SetPoint('CENTER', button)
		FakeIcons[i] = icon
	end

	hooksecurefunc('PetActionBar_Update', function()
		self:OnLock()
	end)
	self.OnUnlock = self.OnLock
end

function Pet:OnLock()
	for i, icon in pairs(FakeIcons) do
		if self.unlocked and not PetHasActionBar() then
			icon:Show()
		else
			icon:Hide()
		end
	end
	
	CornucopiaActions_UpdateBinder()
end