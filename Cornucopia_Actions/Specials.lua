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

local class = select(2, UnitClass('player'))
if class == 'MAGE' then
	return
end

local Specials = Cornucopia:CreateBar('Stances', {
	sets = 'Cornucopia_Stances_Sets',
	name = 'Special Actions',
	defaults = {
		point = 'BottomLeft',
		relPoint = 'Bottom',
		x = -470, y = 56,
	}
})

function Specials:OnInitialize()
	UIPARENT_MANAGED_FRAME_POSITIONS['MultiCastActionBarFrame'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['PossessBarFrame'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['StanceBarFrame'] = nil

	if class ~= 'SHAMAN' then
		-- Stances
		ActionBarController:UnregisterEvent('ACTIONBAR_PAGE_CHANGED')
		
		StanceBarFrame:DisableDrawLayer('BACKGROUND') -- remove default cluster artwork: left
		StanceBarFrame:DisableDrawLayer('BORDER') -- right
		StanceBarFrame:SetParent(self)
		StanceBarFrame:Show()
		
		for i = 1, NUM_STANCE_SLOTS do
			local button = _G['StanceButton'..i]
			button:ClearAllPoints()
			button:SetPoint('LEFT', self, (i-1) * 42 + 3, 0)
			button:SetSize(35, 35)
		end
		
		function StanceBar_Update()
			if not InCombatLockdown() then
				self:SetSize(max(42 * GetNumShapeshiftForms() - 2, 1), 42)
			end
			
			--StanceBar_UpdateState()
		end
		
		StanceBar_Update()
	else
		-- Totems
		MultiCastActionBarFrame:SetParent(self)
		MultiCastActionBarFrame:SetPoint('BOTTOMLEFT', 2, 0)
		MultiCastActionBarFrame.SetPoint = function() end
	
		local Update = MultiCastActionBarFrame_Update
		local IsShown = function(frame)
			return frame:IsShown() and 1 or 0
		end
		
		function MultiCastActionBarFrame_Update(multiCast)
			if not InCombatLockdown() then
				Update(multiCast)
				local numButtons = multiCast.numActiveSlots + IsShown(MultiCastSummonSpellButton) + IsShown(MultiCastRecallSpellButton)
				
				self:SetSize(max(38 * numButtons, 1), 37)
			end
		end
		
		MultiCastActionBarFrame_Update(MultiCastActionBarFrame)
	end
	
	-- Possess
	PossessBarFrame:SetParent(self)
	PossessBarFrame:UnregisterEvent('ACTIONBAR_PAGE_CHANGED')
	PossessBarFrame:DisableDrawLayer('BACKGROUND')
	PossessBarFrame:DisableDrawLayer('BORDER')
	PossessBarFrame:SetPoint('BOTTOMLEFT')
end

function Specials:OnToolsShown()
	CornucopiaActions_StartBinder (self)
end

function Specials:GetBindButtons()
	if class ~= 'SHAMAN' then
		return {StanceBarFrame:GetChildren()}
	else
		local buttons = {MultiCastSummonSpellButton, MultiCastRecallSpellButton}

		for i = 1, MultiCastActionBarFrame.numActiveSlots do
			tinsert(buttons, _G['MultiCastActionButton' .. i])
		end
		return buttons
	end
end