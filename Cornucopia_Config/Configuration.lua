--[[

Edited by LiamNeit 2016

Copyright 2010-2013 João Cardoso
Cornucopia is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of Cornucopia.

Cornucopia is free software: you can redistribute it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Cornucopia is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Cornucopia. If not, see <http://www.gnu.org/licenses/>.
--]]

local GetPosition = Cornucopia:ProvideUtility()
local L = Cornucopia.Locals

local CanOpen = CanOpenPanels
function CanOpenPanels()
	return not Cornucopia:IsShown() and CanOpen()
end

local Sides, _ = {
	{'BottomRight', 'BottomLeft'},
	{'TopRight', 'BottomRight'},
	{'TopLeft', 'BottomLeft'},
	{'TopLeft', 'TopRight'}
}

local MoveKeys = {
	RIGHT = {1, 0},
	LEFT = {-1, 0},
	DOWN = {0, -1},
	UP = {0, 1}
}

StaticPopupDialogs['DELETE_CORNUCOPIA_BARS'] = {
	text = L['Are you sure you want to delete all the selected bars?'],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		Cornucopia:DeleteSelectedBars()
	end,
	
	preferredIndex = STATICPOPUP_NUMDIALOGS, timeout = 0,
	hideOnEscape = 1, showAlert = 1,
	exclusive = 1, whileDead = 1
}


--[[ Startup ]]--

function Cornucopia:StartupConfig()
	local Selector = CreateFrame('Frame', nil, self)
	Selector:SetBackdrop({bgFile = 'Interface\\ChatFrame\\ChatFrameBackground'})
	Selector:SetBackdropColor(1, 1, 1, .15)
	Selector:SetFrameStrata('DIALOG')
	
	local Keyboard = CreateFrame('Frame', nil, self)
	Keyboard:SetScript('OnKeyDown', function(_,...) self:OnKeyDown(...) end)
	Keyboard:SetScript('OnKeyUp', function(_,...) self:OnKeyUp(...) end)
	Keyboard:EnableKeyboard(true)
	
	self:SetScript('OnEvent', function(self, event) self[event](self) end)
	self:SetScript('OnMouseDown', self.ClearSelectedBars)
	self:SetScript('OnDragStart', self.ShowSelector)
	self:SetScript('OnDragStop', self.HideSelector)
	self:SetScript('OnMouseWheel', function() end)
	self:RegisterEvent('PLAYER_LOGOUT')
	self:RegisterEvent('ADDON_LOADED')

	self:SetBackdrop({bgFile = 'Interface\\ChatFrame\\ChatFrameBackground'})
	self:CreateLineBorder(Selector, .5)
	self:RegisterForDrag('LeftButton')
	self:EnableMouseWheel(true)
	self:EnableMouse(true)
	self:SetFrameLevel(1)
	self:SetAllPoints()
	self:Hide()
	
	self.RulerX = self:CreateLine(1, GetScreenHeight() * 3, 1, 1, 1)
	self.RulerY = self:CreateLine(GetScreenWidth() * 3, 1, 1, 1, 1)
	self.Selector, self.Keyboard = Selector, Keyboard
	self.StartupConfig = nil
	
	for id, bar in self:IterateBars() do
		bar:InitializeConfig(id)
	end
end

function Cornucopia:UpdateBackdrop()
	self:SetBackdropColor(0, 0, 0, Cornucopia_Opaque and 1 or .65)
end


--[[ Events ]]--

function Cornucopia:ADDON_LOADED()
	if self.Inspector and self.Toolbar then
		self.Inspector:SetPoint('CENTER', Cornucopia_InspectorX or 0, Cornucopia_InspectorY or 0)
		self.Toolbar:SetPoint('TOP', Cornucopia_ToolbarX or 0, Cornucopia_ToolbarY or 0)
		self:UnregisterEvent('ADDON_LOADED')
		self:UpdateBackdrop()
	end
end

function Cornucopia:PLAYER_LOGOUT()
	Cornucopia_ToolbarX, Cornucopia_ToolbarY = GetPosition(self.Toolbar, _, 'Top')
	Cornucopia_InspectorX, Cornucopia_InspectorY = GetPosition(self.Inspector)
end

function Cornucopia:PLAYER_REGEN_DISABLED()
	UIErrorsFrame:AddMessage(L.CannotConfig, 1, .1, .1)
	self:HideConfig(true)
end


--[[ Widgets ]]--

function Cornucopia:CreatePanel(name, point, level)
	local panel = CreateFrame('Frame', '$parent'..name, self, 'BasicFrameTemplate')
	panel:SetScript('OnDragStop', panel.StopMovingOrSizing)
	panel:SetScript('OnDragStart', panel.StartMoving)
	panel:SetFrameStrata('DIALOG')
	panel:RegisterForDrag('LeftButton')
	panel:SetClampedToScreen(true)
	panel:SetFrameLevel(level)
	panel:EnableMouse(true)
	panel:SetToplevel(true)
	panel:SetMovable(true)
	panel:SetPoint(point)
	
	self[name] = panel
	return panel
end

function Cornucopia:CreateLineBorder(parent, alpha)
	for i, points in pairs(Sides) do
		local a, b = unpack(points)
		local line = self.CreateLine(parent, 1, 1, .633,.633,.633, alpha or 1)
		line:SetPoint(a) line:SetPoint(b)
	end
end

function Cornucopia:CreateLine(width, height, ...)
	local ruler = self:CreateTexture()
	ruler:SetSize(width, height)
	ruler:SetTexture(...)
	return ruler
end


--[[ Selector ]]--

function Cornucopia:ShowSelector()
	local scale = self:GetEffectiveScale()
	local x1, y1 = GetCursorPosition()
	
	self.Selector:Show()
	self.Selector:SetScript('OnUpdate', function()
		local x2, y2 = GetCursorPosition()
		local left, right = min(x1, x2), max(x1, x2)
		local top, bottom = max(y1, y2), min(y1, y2)
		
		self.Selector:SetPoint('TOPRIGHT', self, 'BOTTOMLEFT', right / scale, top / scale)
		self.Selector:SetPoint('BOTTOMLEFT', left / scale, bottom / scale)
		self:ClearSelectedBars(true)
		
		for id, bar in self:IterateBars() do
			if bar:IsShown() then
				local Top, Right = GetPosition(bar, 'Top', 'Right', _, 'Bottom', 'Left')
				local Bottom, Left = GetPosition(bar, 'Bottom', 'Left')
				
				if max(bottom, Bottom) < min(top, Top) and max(left, Left) < min(right, Right) then
					bar:ShowOverlay()
				end
			end
		end
		
		self.Toolbar:Update()
	end)
end

function Cornucopia:HideSelector()
	self.Selector:SetScript('OnUpdate', nil)
	self.Selector:Hide()
end


--[[ Keyboard ]]--

function Cornucopia:OnKeyDown(key)
	local control = IsControlKeyDown()
	local bind1, bind2 = GetBindingKey('Toggle Configuration Mode')
	local screen1, screen2 = GetBindingKey('SCREENSHOT')

	if MoveKeys[key] then
		self:OnMove(key)
	elseif key == 'BACKSPACE' or key == 'DELETE' or key == 'X' and control then
		self:OnDelete()
	elseif key == 'A' and control then
		self:OnSelectAll()
	elseif key == 'C' and control then
		-- Copy
	elseif key == 'V' and control then
		-- Paste
	elseif key == 'ESCAPE' then
		self:OnEscape()
	elseif key == bind1 or key == bind2 then
		self:HideConfig()
	elseif key == screen1 or key == screen2 then
		RunBinding('SCREENSHOT')
	end
end

function Cornucopia:OnKeyUp()
	self.Keyboard:SetScript('OnUpdate', nil)
end

function Cornucopia:OnMove(key)
	local x, y = unpack(MoveKeys[key])
	local delay = 0
	
	if IsShiftKeyDown() then
		x, y = x * 10, y * 10
	end
	
	self.Keyboard:SetScript('OnUpdate', function(_, elapsed)
		delay = delay - elapsed
		
		if delay <= 0 then
			for id, bar in self:IterateBars() do
				if bar.selected then
					bar.sets.x = (bar.sets.x or 0) + x
					bar.sets.y = (bar.sets.y or 0) + y
					bar:UpdatePosition()
				end
			end
			
			delay = .1
		end
	end)
end

function Cornucopia:OnSelectAll()
	self:ClearSelectedBars(true)
	for id, bar in self:IterateBars() do
		bar:ShowOverlay()
	end
	
	self.Toolbar:Update()
end

function Cornucopia:OnDelete()
	for id, bar in self:IterateBars() do
		if bar.selected and bar.group then
			return StaticPopup_Show('DELETE_CORNUCOPIA_BARS')
		end
	end
	
	self:DeleteSelectedBars()
end

function Cornucopia:OnEscape()
	if DropDownList1:IsShown() then
		DropDownList1:Hide()
	elseif CornucopiaInspector:IsShown() then
		CornucopiaInspector:Hide()
	else
		Cornucopia:HideConfig()
	end
end


--[[ Toggle ]]--

function Cornucopia:ToggleConfig()
	if self:IsShown() then
		self:HideConfig()
	else
		self:ShowConfig()
	end
end

function Cornucopia:ShowConfig()
	if not InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
		self:TriggerTutorial(2)
		self:SetAlpha(0)
		self:Show()
		
		self:SetScript('OnUpdate', function(self, elapsed)
			local alpha = self:GetAlpha() + elapsed * 3
			if alpha >= 1 then
				self:SetScript('OnUpdate', nil)
			end
			
			self:SetAlpha(alpha)
		end)
		
		for id, bar in self:IterateBars() do
			bar.unlocked = true
			bar:Fire('OnUnlock')
		end
		
		CloseAllWindows() -- Twice for Game Menu
		CloseAllWindows()
	else
		UIErrorsFrame:AddMessage(L.CannotConfig, 1, .1, .1)
	end
end

function Cornucopia:HideConfig(force)
	self:UnregisterEvent('PLAYER_REGEN_DISABLED')
	self:SetScript('OnUpdate', function(self, elapsed)
		local alpha = self:GetAlpha() - elapsed * 3
		if alpha <= 0 then
			self:SetScript('OnUpdate', nil)
			self.Selector:Hide()
			self:Hide()
		end
		
		self:SetAlpha(alpha)
	end)
	
	if force then
		self:SetAlpha(0)
		self:GetScript('OnUpdate')(self, 0)
	end
	
	for id, bar in self:IterateBars() do
		bar.unlocked = nil
		bar:Fire('OnLock')
	end
end


--[[ Selected Frames ]]--

function Cornucopia:DeleteSelectedBars()
	-- Detach
	for id, bar in self:IterateBars() do
		if bar.overlay:IsShown() then
			bar.sets.anchor = nil
			bar:SetClosestPosition()
		end
	end
	
	-- Remove
	for id, bar in self:IterateBars() do
		if bar.selected then
			bar:Fire('OnRemove')
			bar:Remove(id)
		end
	end

	self:ClearSelectedBars()
end

function Cornucopia:ClearSelectedBars(force)
	if not IsShiftKeyDown() or force then
		for id, bar in self:IterateBars() do
			bar.overlay:Hide()
			bar.selected = nil
		end
	end
	
	self.Inspector:Hide()
	self.Toolbar:Update()
end

Cornucopia:SetFrameStrata('WORLD')
Cornucopia:StartupConfig()