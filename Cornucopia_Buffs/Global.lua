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

local Debuffs = Cornucopia:GetBar('Debuffs')
local Buffs = Cornucopia:GetBar('Buffs')

function BuffFrame_Update()
	if Buffs.auras then
		Buffs.auras.set('consolidateTo', GetCVarBool('consolidateBuffs'))
	end
end

function BuffFrame_UpdatePositions()
  Debuffs:Update()
  Debuffs:UpdateSize()

  Buffs:Update()
  Buffs:UpdateSize()
end

function Cornucopia_AuraUpdate(self)
  AuraButton_UpdateDuration(self, (self.expire - GetTime()) / self.ratio)
end 

local function disable(f)
  f:SetScript('OnShow', f.Hide)
  f:UnregisterAllEvents()
  f:Hide()
end

disable(BuffFrame)
disable(ConsolidatedBuffs)
disable(TemporaryEnchantFrame)