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

local Actions = Cornucopia.Groups['Actions']
if not IsAddOnLoaded('Cornucopia_Actions') then
	return
end

local StancesTitle, StancesDesc, StancesIcon, StealthIcon
local class = select(2, UnitClass('player'))
local L = Cornucopia.Locals
local IDs = Actions.IDs

if class == 'DRUID' then
	StancesTitle, StancesDesc, StancesIcon, StealthIcon = TUTORIAL_TITLE61_DRUID, L.ShapeshiftingDesc, 768, 5215
elseif class == 'WARRIOR' then
	StancesTitle, StancesDesc, StancesIcon = TUTORIAL_TITLE61_WARRIOR, L.CombatStancesDesc, 2457
elseif class == 'MONK' then
	StancesTitle, StancesDesc, StancesIcon = TUTORIAL_TITLE61_WARRIOR, L.CombatStancesDesc, 103985
elseif class == 'ROGUE' then
	StancesIcon, StealthIcon = 51713, 1784
elseif class == 'PRIEST' then
	StancesIcon = 15473
elseif class == 'WARLOCK' then
	StancesIcon = 103958
end


--[[ IDs Meter ]]--

local Meter = CreateFrame('Frame', 'CornucopiaActions_IDsMeter', nil, 'CapProgressBarTemplate')
Meter.text = _G[Meter:GetName() .. "Text"]
Meter.cap1:SetVertexColor(.45, .45, .95)
Meter.cap2:SetVertexColor(.45, .95, .45)
Meter.cap1Marker:Hide()
Meter.cap2Marker:Hide()
Meter:SetWidth(188)
Meter.bottom = 5
Meter.left = 14

Meter:SetScript('OnEnter', function()
	GameTooltip:SetOwner(Meter, 'ANCHOR_BOTTOM', 0, -5)
	GameTooltip:SetText(L.IDsDesc, nil, nil, nil, nil, 1)
	GameTooltip:Show()
end)

Meter:SetScript('OnLeave', function()
	GameTooltip:Hide()
end)


--[[ Events ]]--

function Actions:OnAddAttempt()
	self.barDefaults.columns = min(3, #IDs)
	self.cannotAdd = #IDs == 0
end

function Actions:OnUnlock()
	for i = 1, self:GetNumChildren() do
		local button = select(i, self:GetChildren())
		button:SetAttribute('showgrid', button:GetAttribute('showgrid') + (self.unlocked and 1 or -1))
		
		if self.unlocked then
			ActionButton_ShowGrid(button)
		else
			ActionButton_HideGrid(button)
		end
	end
	
	CornucopiaActions_UpdateBinder()
end


--[[ Bindings ]]--

function Actions:OnToolsShown()
	CornucopiaActions_StartBinder(self)
end

function Actions:GetBindButtons()
	return {self:GetChildren()}
end


--[[ Options ]]--

function Actions:OnOptionsShown()
	local sets = self.sets
	local ids = sets.ids
	
	local Layout, States = self:CreatePanel('Layout'), self:CreatePanel('Events')
	local Help = SushiHelpButton(States)
	Help:SetPoint('TOPRIGHT', 60, 3)
	Help:SetTip(L.EventsDesc)
	
	-- Layout
	do
		local function CreateSlider(label, min, max, method)
			local slider = Layout:Create('Slider', label, nil, method)
			slider:SetRange(min, max)
			return slider
		end
		
		local function UpdateSize(new)
			local old = sets.rows * sets.columns
			local numPages = self.pages
			
			for page = 1, numPages do
				for i = old + 1, new do
					tinsert(ids, new * (page - 1) + i, tremove(IDs, 1))
				end
			end
			
			for page = numPages, 1, -1 do
				for i = old, new + 1, -1 do
					tinsert(IDs, 1, tremove(ids, old * (page - 1) + i))
				end
			end
			
			for i = new + 1, old do
				self:RemoveButton(i)
			end
		end
	
		Layout:SetChildren(function()
			local Start = Layout:Create('Dropdown', 'Start From', 'start')
			Start:AddLine(':', L.TopRight)
			Start:AddLine('1:', L.TopLeft)
			Start:AddLine(':1', L.BottomRight)
			Start:AddLine('1:1', L.BottomLeft)
			
			local columns, rows = sets.columns, sets.rows
			local freeRatio = (#IDs + #ids) / self.pages
			
			CreateSlider('Columns', 1, min(20, floor(freeRatio / rows)), function(v) UpdateSize(v * rows) end)
			CreateSlider('Rows', 1, min(20, floor(freeRatio / columns)), function(v) UpdateSize(v * columns) end)
			CreateSlider('Spacing', 0, 10).bottom = 20
			
			Layout:Create('CheckButton', 'Hide Bindings', 'hideKeys')
			Layout:Create('CheckButton', 'Hide Macro Names', 'hideMacros')
			Layout:Bind(Meter)
		end)
	end
	
	-- States
	do
		local function AddIds(old)
			local numButtons = self:GetNumButtons()
			local newPages = self.pages
			local new = self.states
			
			for page = 2, newPages do
				local state = strmatch(new, '%[([^;]+)%]'..page..';')
				if state and not strmatch(old, state) then
					for i = 1, numButtons do
						tinsert(ids, numButtons * (page - 1) + 1, tremove(IDs, 1))
					end
				end
			end
		end
		
		local function RemoveIds(old, oldPages)
			local numButtons = self:GetNumButtons()
			local new = self.states

			for page = oldPages, 2, -1 do
				local state = strmatch(old, '%[([^;]+)%]'..page)
				if state and not strmatch(new, state) then
					for i = 1, numButtons do
						tinsert(IDs, 1, tremove(ids, numButtons * (page - 1) + 1))
					end
				end
			end
			sort(IDs)
		end
		
		local function CanEnable(arg) -- big hack, may want to look at it
			sets.states[arg] = true
			self:UpdateStates()
			
			local can = (self:GetNumButtons() * self.pages) < (#IDs + #ids)
			
			sets.states[arg] = nil
			self:UpdateStates()
			
			return can
		end
		
		local function Create(text, tip, icon, arg)
			local value = sets.states[arg]
			local enabled = value or CanEnable(arg)
			local text, tip = L[text], L[tip]
			
			if strmatch(tip, '%%s') then
				tip = tip:format(text)
			end
			
			local check = States:CreateChild('IconCheck')
			check:SetDisabled(not enabled)
			check:SetChecked(value)
			check:SetText(text)
			check:SetIcon(icon)
			check:SetTip(tip)
			
			check:SetCall('OnInput', function(_, enable)
				local states, pages = self.states, self.pages
				sets.states[arg] = enable
				
				self:UpdateStates()
				if enable then
					AddIds(states, pages)
				else
					RemoveIds(states, pages)
				end
			end)
			return check
		end
		
		local function CreateSpell(text, tip, spell, arg)
			return Create(text or GetSpellInfo(spell), tip, GetSpellTexture(spell), arg)
		end
		
		States:SetChildren(function()
			if StancesIcon then
				CreateSpell(StancesTitle, StancesDesc or 'StanceDesc', StancesIcon, 'stancing')
			end
			
			if class == 'DRUID' then
				CreateSpell('Talent Forms', 'TalentFormsDesc', 24858, 'stance:5')
			end
			
			if StealthIcon then
				CreateSpell(nil, 'StealthDesc', StealthIcon, 'stealth')
			end
						
			Create('Vehicle & Possess', 'VehicleDesc', 'Interface\\Icons\\Inv_Misc_Wrench_02', 'bonusbar:5')
			Create('Friendly Target', 'FriendlyDesc', 'Interface\\Icons\\Spell_Holy_DivineProvidence', 'help')
			Create(COMBAT, 'CombatDesc', 'Interface\\Icons\\Ability_Warrior_Challange', 'combat')
			Create(GROUP, 'GroupDesc', 'Interface\\Icons\\INV_Misc_GroupNeedMore', 'group:raid')
			
			Create('Ctrl', 'KeyDesc', 'Interface\\Addons\\Cornucopia\\Art\\Keyboard', 'mod:ctrl')
			Create('Shift', 'KeyDesc', 'Interface\\Addons\\Cornucopia\\Art\\Keyboard', 'mod:shift')
			Create('Alt', 'KeyDesc', 'Interface\\Addons\\Cornucopia\\Art\\Keyboard', 'mod:alt').bottom = 23
			
			States:Bind(Meter)
		end)
	end
	
	self.options = {Layout, States}
	self.OnOptionsShown = false
end

function Actions:CreatePanel (...)
	local frame = CornucopiaGroup(self, ...)
	frame:SetCall('OnUpdate', function()
		self:UpdateMeter()
		self:Update()
	end)
	
	return frame
end

function Actions:UpdateMeter()
	local pointSize = Meter:GetWidth() / 120
	local selected = #self.sets.ids * pointSize
	local used = 120 - #IDs

	Meter.text:SetText(used .. ' / 120')
	Meter.cap2:SetWidth(max(used * pointSize - selected, 0.1))
	Meter.cap1:SetWidth(selected)
end