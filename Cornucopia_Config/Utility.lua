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

local xPoints = {'Right', 'Left', ''}
local yPoints = {'Top', 'Bottom', ''}
local OpositePoints = {
	Left = 'Right',
	Right = 'Left',
	Top = 'Bottom',
	Bottom = 'Top',
}


--[[ Widget Status ]]--

local function GetPoint(frame, point, i)
	local value
	if point and point ~= '' then
		value = frame['Get' .. point](frame)
	else
		value = select(i, frame:GetCenter())
	end
	
	return value * frame:GetEffectiveScale()
end

local function GetRelativePoint(frame, point, target, relPoint, i)
	return GetPoint(frame, point, i) - GetPoint(target or UIParent, relPoint or point, i)
end

local function GetPosition(frame, x, y, target, relX, relY)
	return GetRelativePoint(frame, x, target, relX, 1), GetRelativePoint(frame, y, target, relY, 2)
end

local function IsDependant(frame, target)
	local anchor = select(2, frame:GetPoint(1))
	return frame == target or anchor and (anchor == target or IsDependant(anchor, target))
end


--[[ Database ]]--

local function IteratePoints()
	local x, y = 0, 1
	return function()
		if x > 2 then
			y = y + 1
			x = 0
		end
		
		if y < 4 then
			x = x + 1
			return xPoints[x], yPoints[y]
		end
	end
end

local function CodePoint(point)
	return point ~= '' and point or 'Center'
end

local function DecodePoint(point)
	local x, y
	for _, xPoint in pairs(xPoints) do
		if point and strmatch(point, xPoint) then
			x = xPoint
			break
		end
	end
	
	for _, yPoint in pairs(yPoints) do
		if point and strmatch(point, yPoint) then
			y = yPoint
			break
		end
	end
	
	return x, y
end

function Cornucopia:ProvideUtility()
	return GetPosition, GetPoint, IsDependant, IteratePoints, CodePoint, DecodePoint, OpositePoints, xPoints, yPoints
end