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

local Group = LibStub('Poncho-1.0')(nil, 'CornucopiaGroup', nil, nil, SushiGroup)
local L = Cornucopia.Locals

function CornucopiaGroup (target, text, ...)
	local group = Group(...)
	group.target = target
	group.text = text
	
	return group
end


--[[ Events ]]--

function Group:OnAcquire ()
	SushiGroup.OnAcquire (self)
	
	self:SetCall('OnUpdate', self.OnUpdate)
	self:SetWidth(150)
end

function Group:OnUpdate ()
	self.target:Update()
end


--[[ Methods ]]--

function Group:Create(class, text, arg, method)
	local arg = arg or strlower(text)
	local value = self.target.sets[arg]
	local child = self:CreateChild(class)
	child:SetValue(type(value) == 'table' and unpack(value) or value)
	child:SetLabel(L[text])
	
	child:SetCall('OnInput', function(_, ...)
		if method then
			method(...)
		end

		self.target.sets[arg] = select('#', ...) > 1 and {...} or ...
	end)
	
	return child
end