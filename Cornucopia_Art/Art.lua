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

local Art = Cornucopia:CreateGroup('Art', {
	sets = 'Cornucopia_Art_Sets',
	name = 'Art',
	barDefaults = {
		texture = 'Interface\\Addons\\Cornucopia\\Art\\Icon',
		width = 100, height = 100,
		point = 'Center',
	},
})


--[[ Constructor ]]--

function Art:OnInitialize()
	local texture = self:CreateTexture()
	texture:SetAllPoints(true)
	
	local sets = self.sets
	sets.coord = sets.coord or {0, 1, 0, 1}
	sets.flipX = sets.flipX or 1
	sets.flipY = sets.flipY or 1
	
	self.texture = texture
	self:Update()
end

function Art:Update()
	local sets = self.sets
	local texture = self.texture
	local resizable = not sets.scaled or self:Cropping()
	local r, g, b
	
	if sets.color then
		r, g, b = unpack(sets.color)
	end
	
	if sets.grad then
		texture:SetGradient('VERTICAL', r, g, b, unpack(sets.grad))
		texture:SetTexture(1,1,1)
	else
		if sets.texture then
			texture:SetTexCoord(self:FlipCoords(unpack(sets.coord)))
			texture:SetTexture(sets.texture)
		else
			texture:SetTexture(r, g, b)
		end
		
		texture:SetGradient('VERTICAL', 1,1,1,1,1,1)
	end
	
	self.height = resizable
	self.width = resizable
	
	if self:Cropping() then
		self:UpdateOriginal()
	end
end


--[[ Methods ]]--

function Art:FlipCoords(a, b, c, d)
	if self.sets.flipX == 1 then
		if self.sets.flipY == 1 then
			return a, b, c, d
		else
			return a, b, d, c
		end
	elseif self.sets.flipY == 1 then
		return b, a, c, d
	else
		return b, a, d, c
	end
end

function Art:Cropping ()
	return self == Art.cropTarget
end