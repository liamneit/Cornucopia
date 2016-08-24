--[[
Copyright 2010-2012 João Cardoso
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

local LAST_BAG = 3
local L = Cornucopia.Locals
local Bags = Cornucopia:CreateBar('Bags', {
	name = 'Bags',
	sets = 'Cornucopia_Bags_Sets',
	defaults = {
		anchor = 'Menu',
		point = 'Left', relPoint = 'Right',
		x = 43, y = 2.2,
		level = 2,
	}
})


--[[ Startup ]]--

function Bags:OnInitialize()
	for i = 0, LAST_BAG do
		self:AddButton(_G['CharacterBag'..i..'Slot'], i + 1)
	end
	
	self:Update()
	self:AddButton(MainMenuBarBackpackButton, 0)
	self.AddButton = nil
end

function Bags:AddButton(button, i)
	button:ClearAllPoints()
	button:SetParent(self)
	button:SetPoint('RIGHT', -i * 32, 0)
end

function Bags:Update()
	if self.sets.one then
		for i = 0, LAST_BAG do
			_G['CharacterBag'..i..'Slot']:Hide()
		end
		
		self:SetSize(30, 30)
	else
		for i = 0, LAST_BAG do
			_G['CharacterBag'..i..'Slot']:Show()
		end
		
		self:SetSize(160, 30)
	end
end


--[[ Options ]]--

function Bags:OnOptionsShown()
	local Options = CornucopiaGroup(self, L.Layout)
	
	Options:SetChildren(function()
		Options:Create('CheckButton', 'One Bag', 'one')
	end)

	self.OnOptionsShown = nil
	self.options = {Options}
end