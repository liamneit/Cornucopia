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


local Capture,_ = Cornucopia:CreateBar('Capture', {
	vehicles = true,
	sets = 'Cornucopia_Capture_Settings',
	name = 'Capture Timers',
	defaults = {
		point = 'TopRight',
		x = 0, y = -182,
	}
})


--[[ Startup ]]--

function Capture:OnInitialize()
	local Update = WorldStateAlwaysUpFrame_Update
	WorldStateAlwaysUpFrame_Update = function(...)
		Update(...)
		self:UpdateSize()
	end
end

function Capture:UpdateSize()
	local numCaptures
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		local capture = _G['WorldStateCaptureBar'..i]
		capture:SetParent(self)
		capture:SetPoint('TOPRIGHT', 0, 26 - 26 * i)
		capture.SetPoint = function() end
		
		if capture:IsShown() then
			numCaptures = i
		else
			break
		end
	end
	
	if numCaptures then
		self:SetHeight(numCaptures * 26)
		self:SetWidth(173)
	else
		self:SetSize(0.1, 0.1)
	end
end


--[[ Unlocking ]]--

function Capture:OnLock()
	WORLD_PVP_OBJECTIVES_DISPLAY = self.Display
	GetNumWorldStateUI = self.GetNumStates
	GetWorldStateUIInfo = self.GetState
	WorldStateAlwaysUpFrame_Update()
end

function Capture:OnUnlock()
	self.Display = WORLD_PVP_OBJECTIVES_DISPLAY
	self.GetNumStates = GetNumWorldStateUI
	self.GetState = GetWorldStateUIInfo
	
	function GetWorldStateUIInfo(i)
		if i == 1 then
			return 1, 1, _,_,_,_,_,_, 'CAPTUREPOINT', 50, 30
		else
			return self.GetState(i)
		end
	end
	
	function GetNumWorldStateUI()
		return max(self.GetNumStates(), 1)
	end
	
	WORLD_PVP_OBJECTIVES_DISPLAY = '1'
	WorldStateAlwaysUpFrame_Update()
end