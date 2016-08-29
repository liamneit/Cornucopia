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

if not IsAddOnLoaded('Cornucopia_Art') then
	return
end


local Appear = CornucopiaGroup(nil, 'Appearance')
local Art = Cornucopia:GetGroup('Art')
Art.options = {Appear}
Art.appear = Appear


--[[ Events ]]--

function Art:OnOptionsShown()
	local sets = self.sets
	
	Appear.target = self
	Appear:SetChildren(function()
		local type = Appear:Create('Dropdown', 'Type')
		type:SetValue(sets.texture and 1 or sets.grad and 3 or 2)
		type:AddLine(1, 'Image')
		type:AddLine(2, 'Color')
		type:AddLine(3, 'Gradient')
		
		type:SetCall('OnInput', function(_, v)
			if self.cropping then
				self:OnDoubleClick()
			end
		
			sets.texture, sets.grad = nil
			sets.flipX, sets.flipY = 1, 1
		
			if v == 1 then
				sets.texture = 'Interface\\Addons\\Cornucopia\\Art\\Icon'
				sets.color = nil
			else
				if not sets.color then
					sets.color = {YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b}
				end
				
				if v == 3 then
					sets.grad = {LIGHTYELLOW_FONT_COLOR.r, LIGHTYELLOW_FONT_COLOR.g, LIGHTYELLOW_FONT_COLOR.b}
				end
			end
			
			self:ToggleTools()
			self:Fire('ToolsChanged')
		end)
		
		if sets.texture then			
			Appear:Create('EditBox', 'File', 'texture'):SetCall('OnInput', function(_, v)
				self.sets.texture = gsub(gsub(v, '/', '\\'), '^Interface\\Addons', 'Interface\\AddOns')
			end)
			
			Appear:Create('CheckButton', 'Constrain Porportional', 'scaled')
			Appear:SetSize(200 + Appear.Browser:GetWidth(), 220)
			Appear:SetResize('NONE')
			
			Appear.Browser.bar = self
			Appear.Browser:update()
			Appear.Browser:Show()
		else
			Appear.Browser:Hide()
			Appear:Create('ColorPicker', sets.grad and 'Start' or 'Color', 'color')
			Appear:SetResize('VERTICAL')
			Appear:SetWidth(200)
			
			if sets.grad then
				Appear:Create('ColorPicker', 'End', 'grad')
			end
		end
	end)
end


--[[ Methods ]]--

function Art:ToggleTools()
	if self.sets.texture then
		self.tools = nil
	else
		self.tools = false
	end
end

function Art:UseTexture(path)
	self.sets.texture = path
	self.appear:Update()
	self:Update()
end