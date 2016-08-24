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

-- Positions
local FAKE = function() end
MainMenuBar_UpdateArt = FAKE
MainMenuBar_ToPlayerArt = FAKE
MainMenuBar_ToVehicleArt = FAKE
MultiActionBar_Update = FAKE

local NO_MANAGE = {
	ExtraActionBarFrame,
	MultiBarBottomLeft,
	MultiBarBottomRight,
	MultiBarRight,
	MultiBarLeft,
	MainMenuBar
}

for _, frame in ipairs(NO_MANAGE) do
	frame.ignoreFramePositionManager = true
end

-- Frames
local disable = function(frame)
	frame:UnregisterAllEvents()
	frame.Show = FAKE
	frame:Hide()
end

disable(MainMenuBarOverlayFrame)
disable(MainMenuBarArtFrame)
disable(MultiBarRight)

MainMenuBar:SetScript("OnShow", nil)
MainMenuBarArtFrame:RegisterEvent('KNOWN_CURRENCY_TYPES_UPDATE')
MainMenuBarArtFrame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
MainMenuBarArtFrame:RegisterEvent('BAG_UPDATE')

-- Options
local disable = function(id)
  local name = 'InterfaceOptionsActionBarsPanel' .. id
  local button = _G[name]

  BlizzardOptionsPanel_CheckButton_Disable(button)
  _G[name .. 'Text'].SetTextColor = FAKE
end

disable('BottomLeft')
disable('BottomRight')
disable('RightTwo')
disable('Right')