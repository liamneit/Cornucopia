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

local Cornucopia = CreateFrame('Button', 'Cornucopia')

BINDING_HEADER_CORNUCOPIA = 'Cornucopia'
FRAMELOCK_STATES.VEHICLES = {}
tinsert(FRAMELOCK_STATE_PRIORITIES, "VEHICLES")


--[[ Startup ]]--

function Cornucopia:Startup()
	self:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
	self:RegisterEvent('UNIT_ENTERING_VEHICLE')
	self:RegisterEvent('UNIT_EXITED_VEHICLE')
	self:RegisterEvent('VARIABLES_LOADED')
	
	self.__index = self
	self.Bars = {}; self.Groups = {}; self.Locals = {}
end

function Cornucopia:VARIABLES_LOADED()
	-- Bars & Groups
	for id, group in self:IterateGroups() do
		group:InitializeGroup(id)
	end
	
	for id, bar in self:IterateBars() do
		bar:InitializeBar()
	end
	
	-- Settings
	if Cornucopia_HideButton then
		CornucopiaButton:Hide()
	end
	
	if not Cornucopia_Tutorials then
		LoadAddOn('Cornucopia_Config')
	end

	self:ToggleVehicle()
end


--[[ Vehicle ]]--

function Cornucopia:ToggleVehicle()
	OverrideActionBar:ClearAllPoints()

	if Cornucopia_HideVehicle then
		OverrideActionBar:SetPoint('LEFT', OverrideActionBar:GetParent(), 'RIGHT', 500, 0)
	else
		OverrideActionBar:SetPoint('BOTTOM')
	end
end

function Cornucopia:UNIT_ENTERING_VEHICLE()
	if not Cornucopia_HideVehicle then
		AddFrameLock("VEHICLES")
	end
end

function Cornucopia:UNIT_EXITED_VEHICLE()
	RemoveFrameLock("VEHICLES")
end


--[[ Bars ]]--

function Cornucopia:CreateBar (id, data)
	local bar = CreateFrame('Frame', 'Cornucopia'..id..'Frame', UIParent, data.templates or self.templates)
	for k,v in pairs(data) do bar[k] = v end
	
	self.Bars[id] = bar
	return setmetatable(bar, self)
end

function Cornucopia:InitializeBar ()
	local sets = self:InitializeSets()
	self:SetPoint(sets.point, self.Bars[sets.anchor] or UIParent, sets.relPoint or sets.point, sets.x or 0, sets.y or 0)
	self:SetSize(sets.width or 1, sets.height or 1)
	self:SetFrameLevel(sets.level or 1)
	self:SetScale(sets.scale or 1)
	self:SetAlpha(sets.alpha or 1)
	self:SetClampedToScreen(true)
	
	if not self.petBattles then
		self:AddToFrameLock('PETBATTLES')
	end
	
	if not self.vehicles then
		self:AddToFrameLock('VEHICLES')
	end

	if sets.hide then
		self:Hide()
	end

	self:Fire('OnInitialize')
end

function Cornucopia:AddToFrameLock (lock)
	FRAMELOCK_STATES[lock][self:GetName()] = 'hidden'
end

function Cornucopia:IterateBars ()
	return pairs(self.Bars)
end

function Cornucopia:GetBar (id)
	return self.Bars[id]
end


--[[ Groups ]]--

function Cornucopia:CreateGroup(id, data)
	data.group = data
	data.__index = data
	
	self.Groups[id] = data
	return setmetatable(data, self)
end

function Cornucopia:InitializeGroup(id)
	for i, sets in pairs(self:InitializeSets()) do
		self:CreateBar(id .. i, {
			sets = sets,
			index = i
		})
	end
end

function Cornucopia:IterateGroups()
	return pairs(self.Groups)
end

function Cornucopia:GetGroup(id)
	return self.Groups[id]
end


--[[ Methods ]]--

function Cornucopia:ToggleConfig()
	EnableAddOn('Cornucopia_Config')

	if LoadAddOn('Cornucopia_Config') then
		Cornucopia:ShowConfig()
	else
		UIErrorsFrame:AddMessage('Cannot load Cornucopia Config', 1, .1, .1)
	end
end

function Cornucopia:InitializeSets()
	local sets = self.sets or {}
	local value = _G[sets] or type(sets) == 'table' and sets or self.defaults
	
	self.defaults = nil
	self.sets = value
	
	_G[sets] = value
	return value
end

function Cornucopia:Fire(call, ...)
	if self[call] then
		self[call](self, ...)
	end
end

Cornucopia:Startup()