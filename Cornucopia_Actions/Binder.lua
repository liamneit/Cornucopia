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

if not IsAddOnLoaded('Cornucopia_Actions') then
	return
end

function CornucopiaActions_UpdateBinder() end -- Fake me

function CornucopiaActions_StartBinder(...)
	local bar, buttons, hidden, key
	local overlays = {}
	
	local binder = SushiGlowBox()
	binder:SetText(Cornucopia.Locals['BinderTip'])
	binder:SetCall('OnClose', function()
		bar = nil
	end)
	
	local function NewOverlay()
		local overlay = binder:CreateFontString(nil, nil, 'GameFontGreenLarge')
		overlay.bg = binder:CreateTexture('BACKGROUND')
		overlay.bg:SetTexture(0, 0, 0, .5)
		tinsert(overlays, overlay)
		return overlay
	end
	
	local function ResetOverlays()
		for i, overlay in ipairs(overlays) do
			overlay.bg:Hide()
			overlay:Hide()
		end
	end
	
	local function ShowOverlays()
		for i, button in ipairs(buttons) do
			if (hidden or button:IsVisible()) then
	 	     	local text = GetBindingKey('CLICK '..button:GetName()..':LeftButton') or ' '
		      	local overlay = overlays[i] or NewOverlay()
		      	overlay:SetFont(overlay:GetFont(), min(button:GetHeight(), button:GetWidth() / (#text)^0.8) * button:GetEffectiveScale())
		      	overlay:SetPoint('CENTER', button)
		      	overlay:SetText(text)
		      	overlay:Show()
				
		      	overlay.bg:SetAllPoints(button)
		      	overlay.bg:Show()
			end
		end
	end
	
	binder.Toggle = function(new)
		bar = bar ~= new and new
		binder.Update()
	end
	
	binder.Update = function()
		ResetOverlays()

		if bar and bar.unlocked then
			buttons = bar:GetBindButtons()
			hidden = bar.bindHidden
			ShowOverlays()
			
			binder:SetPoint('BOTTOM', bar, 'TOP', -4, 25)
			binder:Show()
		else
			binder:Hide()
		end
	end
	
	binder.OnKey = function(_, value)
		if binder:IsVisible() then
			local old = GetBindingKey(key)
			if old then
				SetBinding(old, nil)
			end
	
			if value ~= 'ESCAPE' then
				KeyBindingFrame_LoadUI()
				KeyBindingFrame.selected = key
				KeyBindingFrame.buttonPressed = KeyBindingFrameBinding1Key1Button
				KeyBindingFrame_OnKeyDown(nil, value)
				KeyBindingFrame.selected = nil
			end
	
			SaveBindings(GetCurrentBindingSet())
			binder:Update()
		end
	end
	
	binder:SetScript('OnUpdate', function()
		binder:EnableKeyboard(nil)
	
		for i, button in ipairs(buttons) do
			if (hidden or button:IsVisible()) and MouseIsOver(button) then
				key = 'CLICK '..button:GetName()..':LeftButton'
				binder:EnableKeyboard(true)
			end
		end
	end)
	
	binder:SetScript('OnMouseWheel', function(binder, d)
		if d > 0 then
			binder:OnKey('MOUSEWHEELUP')
		else
			binder:OnKey('MOUSEWHEELDOWN')
		end
	end)
	
	binder:SetScript('OnKeyDown', binder.OnKey)
	binder:Hide()
	
	binder.icon = 'Interface\\Addons\\Cornucopia\\Art\\Hotkeys'
	binder.label = KEY_BINDINGS_MAC
	binder.func = binder.Toggle
	binder[1] = binder

	-- Actual API --
	function CornucopiaActions_StartBinder(self, hidden)
		--self.OnClick = binder.OnKeyDown
		self.OnClick = binder.OnKey
		self.OnDoubleClick = binder.Toggle
		self.OnUnlock = self.OnUnlock or binder.Update
		self.OnLock = self.OnLock or binder.Update
		self.bindHidden = hidden
		self.OnToolsShown = nil
		self.tools = binder
	end
	
	CornucopiaActions_UpdateBinder = binder.Update
	CornucopiaActions_StartBinder(...)
end