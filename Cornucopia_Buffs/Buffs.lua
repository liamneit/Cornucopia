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

local L = Cornucopia.Locals
local Buffs = Cornucopia:CreateBar('Buffs', {
  vehicles = true,
  buttonTemplate = 'CornucopiaBuffTemplate',
  consolidation = true,
  filter = 'HELPFUL',
  weapons = 1,

  sets = 'Cornucopia_Buffs_Sets',
  name = 'Buffs',
  defaults = {
  start = 'TopRight',
    point = 'TopRight',
    columns = 8, rows = 4,
    x = -204, y = -12,
    spacing = 5,
  }
})

local function GetDurationOff()
	return SHOW_BUFF_DURATIONS == '1' and 8 or 0
end

local function GetMetrics(self)
	local sets = self.sets
	local size = sets.spacing + 30
	return sets, sets.rows, sets.columns, size, size + GetDurationOff()
end


--[[ Startup ]]--

function Buffs:OnInitialize()
	local auras, set = self:NewHeader('auras', self)
	auras:SetScript('OnSizeChanged', function() self:UpdateSize() end)
	auras:SetPoint('TOPRIGHT', -1, -1)

	if self.consolidation then
		local proxy = CornucopiaConsolidateProxy
		local consolidate = self:NewHeader('consolidate', auras)
		local box = CreateFrame('Frame', nil, consolidate, 'ChatConfigBoxTemplate')

		consolidate:SetPoint('TOPRIGHT', proxy, 'BOTTOMLEFT')
		consolidate:SetFrameStrata('TOOLTIP')
		consolidate:SetScale(.75)
		consolidate.box = box

		box:SetFrameLevel(box:GetFrameLevel() - 1)
		box:SetPoint('TOPRIGHT', consolidate, 7, 7)

		proxy:SetFrameRef('target', consolidate)
		set('consolidateHeader', consolidate)
		set('consolidateProxy', proxy)
	end

	self:Update()
	self.auras:Show()
end

function Buffs:NewHeader(name, parent)
	local header = CreateFrame('Frame', '$parent' .. name, parent, 'SecureAuraHeaderTemplate')
	local set = function(...) header:SetAttribute(...) end

  	set('weaponTemplate', self.weapons and self.buttonTemplate)
	set('template', self.buttonTemplate)
	set('includeWeapons', self.weapons)
	set('filter', self.filter)

	set('sortMethod', 'TIME')
	set('sortDirection', '-')
	set('unit', 'player')
	set('minHeight', 1)
	set('minWidth', 1)

	header.set = set
	self[name] = header
	return header, set
end


--[[ Update ]]--

function Buffs:Update()
	self:UpdateHeader(self.consolidate)
	self:UpdateHeader(self.auras)
end

function Buffs:UpdateHeader(header)
	local set = type(header) == 'table' and header.set
	if set then
		local sets, rows, columns, width, height = GetMetrics(self)
		local start = sets.start

		set('_ignore', true)
		set('xOffset', (start:match('Left') and 1 or -1) * width)
		set('wrapYOffset', (start:match('Bottom') and 1 or -1) * height)
 		set('point', start)

		set('maxWraps', sets.rows)
		set('_ignore', nil)
		set('wrapAfter', sets.columns)
	end
end


function Buffs:UpdateSize()
	if self.auras and not self.unlocked then
		local width, height = self.auras:GetSize()
		local off = GetDurationOff()

		if self.consolidate then
			self.consolidate.box:SetPoint('BOTTOMLEFT', self.consolidate, -7, -7 - off)
		end

		self:SetSize(width + 2, height + 2 + off)
	end
end


--[[ Unlocking ]]--

function Buffs:OnUnlock()
	self.fakes = self.fakes or {}
	self.auras:SetAlpha(0)
	self:UpdateFakes()
end

function Buffs:OnLock()
	self.auras:SetAlpha(1)
 	self:UpdateSize()
	self:HideFakes()
end


--[[ Faking ]]--

function Buffs:UpdateFakes()
	local sets, rows, columns, width, height = GetMetrics(self)
	local total = rows * columns

	self:SetSize(columns * width - 3, rows * height - 3)
	self:HideFakes()

	for i = 1, total do
		local button = self.fakes[i] or CreateFrame('Button', '$parentFakeAura' .. i, self, self.buttonTemplate)
		button:SetPoint('TOPRIGHT', mod(1 - i, -columns) * width - 1, (1 - ceil(i / columns)) * height - 1)
		button:Show()

		local name = button:GetName()
		if self.filter == 'HARMFUL' then
			local color = DebuffTypeColor['none']
			_G[name .. 'Border']:SetVertexColor(color.r, color.g, color.b)
		else
			_G[name .. 'Border']:Hide()
		end

		_G[name .. 'Icon']:SetTexture('Interface\\Icons\\Temp')
		AuraButton_UpdateDuration(button, total * 56 / i)
		self.fakes[i] = button
	end
end

function Buffs:HideFakes()
	for i, button in ipairs(self.fakes) do
		button:Hide()
	end
end


--[[ Options ]]--

function Buffs:OnOptionsShown()
	local Options = CornucopiaGroup(self, 'Layout')
	Options:SetWidth(180)
	
	Options:SetChildren(function()
    	local Start = Options:Create('Dropdown', 'Grow From', 'start')
		Start:AddLine('TopRight', L.TopRight)
    	Start:AddLine('TopLeft', L.TopLeft)
    	Start:AddLine('BottomRight', L.BottomRight)
		Start:AddLine('BottomLeft', L.BottomLeft)

		Options:Create('Slider', 'Columns'):SetRange(1, 20)
		Options:Create('Slider', 'Rows'):SetRange(1, 20)

		local Spacing = Options:Create('Slider', 'Spacing')
		Spacing:SetRange(0, 10)
		Spacing.bottom = 15
	end)

	Options:SetCall('OnInput', function()
		self:UpdateFakes()
    	self:Update()
	end)

	self.OnOptionsShown = nil
	self.options = {Options}
end