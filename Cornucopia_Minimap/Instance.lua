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

local Bar = Cornucopia:CreateBar('Instance', {
	sets = 'Cornucopia_Instance_Sets',
	name = 'Instance',
	defaults = {
		anchor = 'Zone',
		point = 'TopLeft',
		relPoint = 'Left',
		x = 19, y = -8,
		level = 10,
	}
})


--[[ Startup ]]--

function Bar:OnInitialize()
	local Update = MiniMapInstanceDifficulty_Update
	function MiniMapInstanceDifficulty_Update()
		Update()
		
		if GuildInstanceDifficulty:IsShown() then
			self:SetSize(41, 47)
		else
			if select(2, MiniMapInstanceDifficultyTexture:GetTexCoord()) < 0.5 then
				self:SetHeight(47)
			else
				self:SetHeight(35)
			end
			self:SetWidth(37)
		end
	end
	
	MiniMapInstanceDifficulty:SetParent(self)
	MiniMapInstanceDifficulty:SetPoint('TOPLEFT')
	GuildInstanceDifficulty:SetParent(self)
	GuildInstanceDifficulty:SetPoint('TOPLEFT', 0, 1)
end


--[[ Config ]]--

function Bar:OnLock()
	GuildInstanceDifficulty:SetScript('OnShow', nil)
	MiniMapInstanceDifficulty:SetScript('OnHide', nil)
	MiniMapInstanceDifficulty_Update()
end

function Bar:OnUnlock()
	MiniMapInstanceDifficultyText:SetText(MiniMapInstanceDifficultyText:GetText() or 13)
	MiniMapInstanceDifficulty:SetScript('OnHide', MiniMapInstanceDifficulty.Show)
	MiniMapInstanceDifficulty:Show()
	
	GuildInstanceDifficulty:SetScript('OnShow', MiniMapInstanceDifficulty.Hide)
	GuildInstanceDifficulty:Hide()
end