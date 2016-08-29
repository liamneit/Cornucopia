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

local Inspector = Cornucopia:CreatePanel('Inspector', 'Center', 50)
local Tabs = SushiTabGroup(Inspector)
local L = Cornucopia.Locals


--[[ Startup ]]--

function Inspector:Startup()
	local WaterMark = self:CreateTexture() -- Cause it's cool
	WaterMark:SetTexture('Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-85')
	WaterMark:SetPoint('CENTER')
	WaterMark:SetSize(150, 150)
	WaterMark:SetAlpha(.1)
	
	local Shadow = CreateFrame('Frame', '$parentShadow', self, 'ShadowOverlayTemplate')
	Shadow:SetPoint('TOPRIGHT', -4, -22)
	Shadow:SetPoint('BOTTOMLEFT', 1, 3)
	Shadow:SetAlpha(.7)
	
	Tabs:SetCall('OnSelection', function(_, ...) self:ShowTab(...) end)
	Tabs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 10, 1)
	
	self.Bg:SetTexture('Interface\\FrameGeneral\\UI-Background-Marble', true, true)
	self.Startup = nil
	self:Hide()
end

function Inspector:ShowBar(bar)
	if self.bar then
		self.bar.MetricsChanged = nil
	end
	
	if not IsControlKeyDown() then
		bar:Fire('OnOptionsShown', self)
		bar.MetricsChanged = function() self.Metrics:UpdateChildren() end
		
		local tabs = self:GetTabs(bar)
		for i, panel in ipairs(tabs) do
			self:AddTab(panel)
		end

		self.bar = bar
		self.TitleText:SetText(bar:GetDisplayName())
		self:AddTab(self.Metrics)
		self:UpdateSize()
		self:Show()
		
		local name, selection = self:GetName(self.tab)
		for i, panel in ipairs(tabs) do
			if self:GetName(panel) == name then
				selection = panel
				break
			end
		end
		
		Tabs:Select(selection or Tabs:Get(self.tab) and self.tab or tabs[1] or self.Metrics)
	end
end

function Inspector:UpdateSize()
	if self.tab then
		self:SetWidth(max(self.tab:GetWidth() + 10, Tabs:GetWidth() + 20, 80))
		self:SetHeight(max(self.tab:GetHeight() + 35, 100))
	end
end


--[[ Tabs ]]--

function Inspector:ShowTab(panel)
	if self.tab then
		self.tab:Hide()
	end
	
	self.tab = panel
	self:UpdateSize()
	panel:Show()
end

function Inspector:AddTab(panel)
	panel:Hide()
	panel:SetParent(self)
	panel:ClearAllPoints()
	panel:SetPoint('TOPLEFT', 0, -30)
	panel:HookScript('OnSizeChanged', function()
		if self.tab == panel then
			self:UpdateSize()
		end
	end)
	
	Tabs:Add(panel, self:GetName(panel), panel.desc or panel.tooltip, panel.disabled)
end

function Inspector:GetName(panel)
	return panel and (panel.name or panel.label or panel.text)
end

function Inspector:GetTabs(bar)
	Tabs:Clear()
	return bar.options or self
end

Inspector:Startup()