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

local Buffs = Cornucopia:GetBar('Buffs')
local Debuffs = Cornucopia:CreateBar('Debuffs', {
  buttonTemplate = 'CornucopiaDebuffTemplate',
  consolidation = false,
  filter = 'HARMFUL',
  weapons = false,

  name = 'Debuffs',
  sets = 'Cornucopia_Debuffs_Sets',
  defaults = {
    point = 'TopRight', relPoint = 'BottomRight',
    anchor = 'Buffs', x = 0, y = -2,
    columns = 8, rows = 2,
    start = 'TopRight',
    spacing = 5,
  }
})

for k,v in pairs(Buffs) do
  Debuffs[k] = Debuffs[k] == nil and v or Debuffs[k]
end