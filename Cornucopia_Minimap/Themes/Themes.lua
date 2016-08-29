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

local Minimap = Cornucopia:GetBar('Minimap')
local Path = 'Interface\\Addons\\Cornucopia_Minimap\\Themes\\%s\\%s'
local L = Cornucopia.Locals

function Minimap:NewTheme(id, data)
	self.Themes[id] = data
end

Minimap:NewTheme('Warcraft', {
	round = Path:format('Warcraft', 'Round'),
	square = Path:format('Warcraft', 'Square'),
	zone = 'Interface/Minimap/UI-Minimap-Border',
	size = 81
})

Minimap:NewTheme('Diablo', {
	round = Path:format('Diablo', 'Round'),
	button = Path:format('Diablo', 'Button'),
	size = 103
})

Minimap:NewTheme('Tooltip', {
	round = Path:format('Tooltip', 'Round'),
	square = Path:format('Tooltip', 'Square'),
	colorable = true
})

Minimap:NewTheme('Thin', {
	name = 'Thin',
	round = Path:format('Thin', 'Round'),
	square = Path:format('Thin', 'Square'),
	colorable = true
})


--[[
List of attributes supported by Cornucopia Minimap
======================================================
.name		= [STRING, nil]  	-- Name of the theme
.preview	= [TEXTURE, nil]	-- Preview image shown at the selection panel
.round		= [TEXTURE, nil]  	-- The circular border texture
.square 	= [TEXTURE, nil] 	-- The square border texture
.size		= [NUMBER, nil] 	-- Height and width used for .round and .square
.button 	= [TEXTURE, nil]	-- Border texture for the minimap buttons
.zone		= [TEXTURE, nil]	-- Background texture for the zone text
.clock		= [TEXTURE, nil]	-- Background texture for the minimap clock
.compass	= [TEXTURE, nil]	-- Rotative compass texture
.colorable 	= [true, nil]		-- Allows the minimap border to be colored
======================================================
Feel free to give suggestions
--]]