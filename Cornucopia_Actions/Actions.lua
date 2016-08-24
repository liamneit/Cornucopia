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

local Actions = Cornucopia:CreateGroup('Actions', {
	templates = 'SecureHandlerStateTemplate',
	sets = 'Cornucopia_Actions_Sets',
	name = 'Action Buttons',
	defaults = {
		{
			point = 'BottomRight', relPoint = 'Bottom',
			x = -4, y = 1.5,
			states = {
				['bonusbar:5'] = true,
				['stancing'] = true,
			},
			columns = 12, rows = 1,
			start = '1:1', spacing = 3,
			level = 2,
			ids = {}
		},
	},
	barDefaults = {
		point = 'CENTER',
		ids = {}, states = {},
		start = '1:1', rows = 1,
		spacing = 3,
		level = 2,
	},
	IDs = {}
})

local class = select(2, UnitClass('player'))
local IDs = Actions.IDs
local Stances, Stealth

if class == 'DRUID' then
	Stances, Stealth = {'stance:1', 'stance:3'}, 'stealth,stance:3'
elseif class == 'WARRIOR' then
	Stances = {'stance:2', 'stance:3'}
elseif class == 'MONK' then
	Stances = {'stance:2'}
elseif class == 'ROGUE' then
	Stances, Stealth = {'stance:3'}, 'stealth'
elseif class == 'PRIEST' then
	Stances = {'stance:1'}
elseif class == 'WARLOCK' then
	Stances = {'stance:2'}
else
	Stances = {}
end

for i = 1, 120 do
	IDs[i] = i
end


--[[ Startup ]]--

function Actions:OnInitialize()
	self:SetAttribute('_onstate-pages', [[control:ChildUpdate('pages', newstate)]])
	self.OnLock = self.OnUnlock
	self:Update()
	
	for _,id in pairs(self.sets.ids) do
		for index,i in pairs(IDs) do
			if id == i then
				tremove(IDs, index)
				break
			end
		end
	end
end

function Actions:OnRemove()
	local sets = self.sets
	for _,id in pairs(sets.ids) do
		tinsert(IDs, id)
	end
	sort(IDs)
	
	for i = 1, sets.rows * sets.columns do
		self:RemoveButton(i)
	end
end

function Actions:Update()
	local sets = self.sets
	local bottom, left = strsplit(':', sets.start)
	local columns, rows = sets.columns, sets.rows
	local numButtons = columns * rows
	local spacing = sets.spacing
	local size = 39 + spacing
	local ids = sets.ids
	
	self:SetAttribute('state-pages', '0') -- Force Update
	self:SetWidth(size * columns - spacing)
	self:SetHeight(size * rows - spacing)
	self:UpdateStates()
	
	local numPages = self.pages
	if #ids == 0 then
		for i = 1, numPages * numButtons do
			ids[i] = tremove(IDs, 1)
		end
	end
	
	for i = 1, numButtons do
		local x = mod(i - 1, columns)
		local y = ceil(i / columns) - 1
		
		if bottom == '1' then x = columns - 1 - x end
		if left == '1' then y = rows - 1 - y end
		
		local button = self:GetButton(i) or self:NewButton(i)
		button:SetPoint('TOPRIGHT', self, -x * size - 2, -y * size - 2)
		button:SetAttribute('statehidden', nil)
		--button:Show()
		
		button:SetAttribute('id-2', 120 + numButtons + i)
		button:SetAttribute('id-1', 120 + i)
		
		for page = 1, numPages do
			button:SetAttribute('id'..page, ids[numButtons * (page - 1) + i])
		end
		
		local name = button:GetName()
		_G[name..'HotKey']:SetAlpha(sets.hideKeys and 0 or 1)
		_G[name..'Name']:SetAlpha(sets.hideMacros and 0 or 1)
	end
	
	RegisterStateDriver(self, 'pages', self.states)
end


--[[ Buttons ]]--

function Actions:NewButton(i)
	local button = CreateFrame('CheckButton', 'CornucopiaAction'..i..'Bar'..self.index, self, 'ActionBarButtonTemplate')
	button:SetID(0)
	button:SetAttribute('_childupdate-pages', [[
		self:SetAttribute('action', self:GetAttribute('id'..message))
	]])
	
	return button
end

function Actions:RemoveButton(i)
	local button = self:GetButton(i)
	button:SetAttribute('statehidden', true)
	button:Hide()
				
	local key = GetBindingKey('CLICK '..button:GetName()..':LeftButton')
	if key then
		SetBinding(key, nil)
		SaveBindings(GetCurrentBindingSet())
	end
end

function Actions:GetButton(i)
	return _G['CornucopiaAction'..i..'Bar'..self.index]
end

function Actions:GetNumButtons()
	return self.sets.rows * self.sets.columns
end


--[[ States ]]--

function Actions:UpdateStates()
	self.pages = 1
	
	local states = self:AddState('mod:ctrl') .. self:AddState('mod:shift') .. self:AddState('mod:alt')
	local stances, stealth, posess = ''
	
	-- Stealth & Possess
	posess = self:AddState('bonusbar:5', states, nil, true)
	stealth = self:AddState(Stealth, states, 'stealth')
	
	-- Situations
	states = self:AddState('group:raid', states) .. states
	states = self:AddState('combat', states) .. states
	
	-- Stances
	for _, stance in pairs(Stances) do
		stances = self:AddState(stance, states, 'stancing') .. stances
	end
	
	-- Help & Talent Forms
	stances =  self:AddState('stance:5', states) .. stances
	stances =  self:AddState('help', states) .. stances

	self.states = posess .. stealth .. stances .. states .. 1
end

function Actions:AddState(state, original, arg, page)
	if self.sets.states[(arg or state)] then
		local add = ''
		for orig in gmatch(original or '', '%[([^;]+)%]') do
			add = add .. self:GetState(state .. ', ' .. orig, page and -2)
		end
		return add .. self:GetState(state, page and -1)
	end
	return ''
end

function Actions:GetState(state, page)
	if not page then
		self.pages = self.pages + 1
	end
	return '['..state..']'..(page or self.pages)..';'
end