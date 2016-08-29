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

local Toolbar = Cornucopia:CreatePanel('Toolbar', 'Top', 30)
local Dropdown = CreateFrame('Frame', '&parentDropdown', Toolbar, 'UIDropDownMenuTemplate')
local L, Buttons  = Cornucopia.Locals, {}


--[[ Startup ]]--

function Toolbar:Startup()	
	-- Close Button
	self.CloseButton:SetPoint('TOPRIGHT', 4, 1)
	self.CloseButton:SetScript('OnClick', function()
		Cornucopia:HideConfig()
	end)
	
	local corner = self:CreateTexture()
	corner:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Corner')
	corner:SetPoint('TOPRIGHT', 0, -3)
	corner:SetSize(31, 31)

	-- Border
	self.TopTileStreaks:SetPoint('TOPRIGHT', -2, -6)
	self.TopTileStreaks:SetPoint('TOPLEFT', 2, -6)
	self.Bg:SetPoint('TOPLEFT', 2, -6)
	self.TitleBg:Hide()
	
	self.TopBorder:SetTexCoord(0, 1, 0.2734375, 0.203125)
	self.TopBorder:SetPoint('TOPRIGHT', -11, 1)
	self.TopBorder:SetPoint('TOPLEFT', 8, 1)
	self.TopBorder:SetHeight(9)
	
	self.RightBorder:SetPoint('TOPRIGHT', 1, -10)
	self.TopRightCorner:SetTexCoord(0.1328125, 0.21875, 0.984375, 0.8984375)
	self.TopRightCorner:SetPoint('TOPRIGHT', 0, 1)
	self.TopRightCorner:SetSize(11, 11)
	
	self.TopLeftCorner:SetTexCoord(0.0078125, 0.1171875, 0.7421875, 0.6328125)
	self.TopLeftCorner:SetSize(14, 14)
	
	-- Buttons
	self:Update()
end

function Toolbar:Update()
	self:ClearButtons()
	self:AddDefault('Add')
	self:AddDefault('Options')
	self:AddDefault('Help')
	
	if self.bar then
		self.bar.ToolsChanged = nil
	end
	
	local bar, multiple
	for id, target in Cornucopia:IterateBars() do
		if target.selected then
			if not bar then
				bar = target
			else
				multiple = true
				break
			end
		end
	end
		
	if bar then
		self:AddSpacer()
	
		if not multiple then
			bar:Fire('OnToolsShown', self)
			bar.ToolsChanged = function() self:Update() end
			
			local buttons = bar.tools
			if buttons then
				for i, button in ipairs(buttons) do
					self:AddButton(button)
				end
			end
		
			self.bar = bar
		end
		
		self:AddDefault('Front')
		self:AddDefault('Back')
		self:AddDefault('Delete', 'Interface\\Buttons\\UI-GroupLoot-Pass-Up', {-0.05, 1.05, -0.05, 1.05})
	end
	
	self:SetSize(self.size + 30, 53)
end


--[[ Buttons ]]--

function Toolbar:AddDefault(name, icon, coord)
	self:AddButton({
		name = L[name],
		icon = icon or 'Interface\\Addons\\Cornucopia\\Art\\' .. name,
		coord = coord,
		func = self['Click'..name]
	})
end

function Toolbar:AddSpacer()
	self.size = self.size + 25
end

function Toolbar:AddButton(data)
	local button = Buttons[self.index] or self:CreateButton()
	button.text:SetPoint('TOP', button, data.anchor or 'BOTTOM')
	button.text:SetText(data.name or data.label or data.text)
	button:SetNormalTexture(data.icon)
	button.func = data.func
	button:Show()
	
	local textWidth = button.text:GetWidth()
	button:SetPoint('TOPLEFT', self.size + textWidth / 2, -8)
	
	if data.coord then
		button:GetNormalTexture():SetTexCoord(unpack(data.coord))
	end
	
	if data.spacer then
		self:AddSpacer()
	end
	
	self.size = self.size + max(29, textWidth) + 10
	self.index = self.index + 1
end

function Toolbar:CreateButton()
	local button = CreateFrame('Button', nil, self)
	button:SetScript('OnDragStart', function() self:StartMoving() end)
	button:RegisterForDrag('LeftButton')
	button:SetSize(29, 29)
	
	local text = button:CreateFontString()
	text:SetFontObject('GameFontHighlightSmall')
	button.text = text
	
	button:SetScript('OnMouseDown', function(_, ...)
		button:GetNormalTexture():SetVertexColor(.7,.7,.7)
		text:SetTextColor(.7,.7,.7)
		
		if button.func then
			button.func(self.bar, button, ...)
		end
	end)
	
	button:SetScript('OnMouseUp', function()
		button:GetNormalTexture():SetVertexColor(1,1,1)
		text:SetTextColor(1,1,1)
	end)
	
	button:SetScript('OnDragStop', function()
		button:GetScript('OnMouseUp')()
		self:StopMovingOrSizing()
	end)
	
	tinsert(Buttons, button)
	return button
end

function Toolbar:ClearButtons()
	for i, button in pairs(Buttons) do
		button:Hide()
	end
	
	self.index = 1
	self.size = -7
end


--[[ Add Bar ]]--

local bars = {}
local function AddLine(target, id, method)
	tinsert(bars, {
		text = (target.icon and ('|T'..target.icon..':0|t ') or '') .. L[target.name or id],
		notCheckable = 1,
   		func = method
	})
end

local function ShowBar(bar)
	bar:UpdatePosition()
	bar.config:Show()
	bar:OnMouseDown()
	bar:Show()
	Toolbar:ClickFront() -- Better solution maybe?
	
	bar.sets.hide = nil
	bar:Fire('OnAdd')
	bar:Fire('OnUnlock')
end

function Toolbar:ClickAdd(button)
	wipe(bars)
	
	for id, group in Cornucopia:IterateGroups() do
		if group.OnAddAttempt then
			group:OnAddAttempt()
		end
	
		if not group.cannotAdd and (not group.limit or group.limit < #group.sets) then
			AddLine(group, id, function()
    			local sets = CopyTable(group.barDefaults or {})
    			local index = 1
    			
    			while group.sets[index] do
    				index = index + 1
    			end
    			group.sets[index] = sets
				
				local bar = group:CreateBar(id .. index, {
					index = index,
					sets = sets
				})
				
				bar:InitializeBar()
				bar:InitializeConfig()
				ShowBar(bar)
    		end)
		end
	end
	
	for id, bar in Cornucopia:IterateBars() do
		if bar.sets.hide then
			AddLine(bar, id, function()
				ShowBar(bar)
    		end)
		end
	end
	
	if #bars == 0 then
		bars[1] = {
			text = L['There are no bars to be added'],
			disabled = true,
			notCheckable = 1,
		}
	end
	
	EasyMenu(bars, Dropdown, button, 0, -13, 'MENU')
end


--[[ Options / Help ]]--

local options = {
	{
	    text = ENABLE,
	    notCheckable = 1,
	    isTitle = 1
   	},
	{
	    text = L['Rulers'],
	    tooltipTitle = L['Rulers'],
	    tooltipText = L.RulersDesc,
	    func = function() Cornucopia_HideRulers = not Cornucopia_HideRulers or nil end,
	    checked = function() return not Cornucopia_HideRulers end,
	    tooltipOnButton = 1,
	    isNotRadio = 1
   	},
   	{
	    text = L['Minimap Button'],
	    tooltipTitle = L['Minimap Button'],
	    tooltipText = L.MinimapButtonDesc,
	    func = function()
	    	if Cornucopia_HideButton then
	    		CornucopiaButton:Show()
	    		Cornucopia_HideButton = nil
	    	else
	    		CornucopiaButton:Hide()
	    		Cornucopia_HideButton = true
	    	end
	    end,
	    
	    checked = function() return not Cornucopia_HideButton end,
	    tooltipOnButton = 1,
	    isNotRadio = 1
   	},
   	{
	    text = L['Vehicle Art'],
	    tooltipTitle = L['Vehicle Art'],
	    tooltipText = L.VehicleArtDesc,
	    func = function()
	    	Cornucopia_HideVehicle = not Cornucopia_HideVehicle or nil
			Cornucopia:ToggleVehicle()
	    end,
	    
	    checked = function() return not Cornucopia_HideVehicle end,
	    tooltipOnButton = 1,
	    isNotRadio = 1
   	},
   	{
	    text = L['Background'],
	    notCheckable = 1,
		isTitle = 1
   	},
	{
	    text = L['Translucent'],
	    checked = function() return not Cornucopia_Opaque end,
	    func = function()
	    	Cornucopia_Opaque = nil
	    	Cornucopia:UpdateBackdrop()
	    end,
   	},
   	{
	    text = L['Opaque'],
		checked = function() return Cornucopia_Opaque == true end,
	    func = function()
	    	Cornucopia_Opaque = true
	    	Cornucopia:UpdateBackdrop()
	    end,
   	},
}

function Toolbar:ClickOptions(button)
	EasyMenu(options, Dropdown, button, 0, -13, 'MENU')
end

function Toolbar:ClickHelp()
	Cornucopia:ResetTutorials()
	Cornucopia:TriggerTutorial(2, true)
end


--[[ Send to Front/Back ]]--

local function GetFrameLevels(frame)
	local base = frame:GetFrameLevel()
	local top = base
	
	for i = 1, frame:GetNumChildren() do
		local cBase, cTop = GetFrameLevels(select(i, frame:GetChildren()))
		base = min(base, cBase)
		top = max(top, cTop)
	end
	
	return base, top
end

function Toolbar:ClickFront()
	local back, front = math.huge, 1
	for id, bar in Cornucopia:IterateBars() do
		local base, top = GetFrameLevels(bar)
		if bar.selected then
			back = min(back, base)
		else
			front = max(front, top)
		end
	end
	
	local diff = front - back + 1
	for id, bar in Cornucopia:IterateBars() do
		if bar.selected then
			bar:SetLevel(bar:GetFrameLevel() + diff)
		end
	end
end

function Toolbar:ClickBack()
	local back, front = math.huge, 1
	for id, bar in Cornucopia:IterateBars() do
		if bar.selected then
			local base, top = GetFrameLevels(bar)
			front = max(front, top)
			back = min(back, base)
		end
	end
	
	local size = front - back
	for id, bar in Cornucopia:IterateBars() do
		if bar.selected then
			bar:SetLevel(bar:GetFrameLevel() - back)
		else
			bar:SetLevel(bar:GetFrameLevel() + size)
		end
	end
end


--[[ Delete ]]--

function Toolbar:ClickDelete()
	Cornucopia:OnDelete()
end

Toolbar:Startup()