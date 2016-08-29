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

local fake = function() end
local Button = MainMenuBarVehicleLeaveButton
local Leave = Cornucopia:CreateBar('Leave', {
	sets = 'Cornucopia_Leave_Sets',
	name = 'Leave Vehicle',
	defaults = {
		level = 2,
		point = 'BottomLeft', relPoint = 'Bottom',
		x = 345.1, y = 7.5,
		scale = 0.895,
	}
})

function Leave:OnInitialize()
	Button:UnregisterAllEvents()
	Button:RegisterEvent('UNIT_ENTERED_VEHICLE')
	Button:RegisterEvent('UNIT_EXITED_VEHICLE')
	Button:SetScript('OnEvent', self.OnEvent)
	Button:SetParent(self)
	Button:ClearAllPoints()
	Button:SetPoint('CENTER')
	
	MainMenuBarVehicleLeaveButton_Update = fake
	MainMenuBarVehicleLeaveButton_OnEvent = fake
	
	self.OnLock, self.OnUnlock = self.Update, self.Update
	self:SetSize(32, 32)
	self:Update()
end

function Leave:OnEvent(event, unit)
	if unit == 'player' or event == 'VEHICLE_UPDATE' then
		Leave:Update()
	end
end

function Leave:Update()
	if CanExitVehicle() or Leave.unlocked then
		Button:RegisterEvent('VEHICLE_UPDATE')
		Button:Show()
	else
		Button:UnregisterEvent('VEHICLE_UPDATE')
		Button:Hide()
	end
end