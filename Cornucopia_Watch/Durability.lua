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


local Durability = Cornucopia:CreateBar('Durability', {
	vehicles = true,
	sets = 'Cornucopia_Durability_Settings',
	name = 'Durability & Vehicle Seats',
	defaults = {
		relPoint = 'BottomRight',
		anchor = 'Objectives',
		point = 'TopRight',
	}
})


--[[ Startup ]]--

function Durability:OnInitialize()
	DurabilityFrame:SetParent(self)
	DurabilityFrame:SetPoint('TOPRIGHT')
	DurabilityFrame.SetPoint = function() end
	
	VehicleSeatIndicator:SetParent(self)
	VehicleSeatIndicator:SetPoint('TOPRIGHT')
	VehicleSeatIndicator.SetPoint = function() end
	
	local SetAlerts = DurabilityFrame_SetAlerts
	DurabilityFrame_SetAlerts = function(...)
		SetAlerts(...)
		self:UpdateSize()
	end
end

function Durability:UpdateSize()
	if VehicleSeatIndicator:IsShown() then
		self:SetSize(VehicleSeatIndicator:GetWidth(), VehicleSeatIndicator:GetHeight())
		
	elseif not DurabilityFrame:IsShown() then
		self:SetSize(0.1, 0.1)
		
	else
		local offWeapon = (DurabilityShield:IsShown() or DurabilityOffWeapon:IsShown() or DurabilityRanged:IsShown()) and 23 or 0
		local weapon = DurabilityWeapon:IsShown() and 15 or 0
		
		self.SetPoint(DurabilityFrame, 'TOPRIGHT', -offWeapon + 25, -2)
		self:SetSize(48 + weapon + offWeapon, 81)
	end
end


--[[ Unlocking ]]--

function Durability:OnLock()
	INVENTORY_ALERT_COLORS[0] = nil
	DurabilityFrame_SetAlerts()
end

function Durability:OnUnlock()
	INVENTORY_ALERT_COLORS[0] = INVENTORY_ALERT_COLORS[1]
	DurabilityFrame_SetAlerts()
end