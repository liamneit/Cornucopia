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


local Objectives = Cornucopia:CreateBar('Objectives', {
	vehicles = true,
	sets = 'Cornucopia_Objectives_Settings',
	name = 'Objectives',
	minWidth = 120,
	width = true,
	defaults = {
		relPoint = 'BottomRight',
		point = 'TopRight',
		anchor = 'Capture',
		width = 214,
	}
})

local FakeQuests = {
	"The Harvest Festival#",
	"Get Thrall a banana. Give Hellscream the peel.",
	"Wrath of the Glich King#",
	"Bugs Found: 3/5",
	"Bugs Reported: 0/5",
	"Lost in General Chat#",
	"Find Jaliborc's wife. No, not in the Barrens."
}


--[[ Startup ]]--

function Objectives:OnInitialize()
	InterfaceOptionsObjectivesPanelWatchFrameWidth:Hide()
	
	WatchFrame:SetParent(self)
	WatchFrame:SetClampedToScreen(nil)
	WatchFrame:SetPoint('TOPRIGHT', 5, 0)
	WatchFrame:SetPoint('BOTTOMLEFT', 0, -GetScreenHeight())
	WatchFrame.IsUserPlaced = function() return true end
	WatchFrame.ClearAllPoints = function() end
		
	local UpdateFrame = WatchFrame_Update
	function WatchFrame_Update()
		if not WatchFrame.updating then
			local off = self:ShowObjectives() and 30 or 5
			WATCHFRAME_MAXLINEWIDTH = not self.unlocked and self.sets.width or self:GetWidth()
			WatchFrame:SetPoint('TOPLEFT', off, 0)
			
			tinsert(WATCHFRAME_OBJECTIVEHANDLERS, self.UpdateHeight)
			UpdateFrame()
			tremove(WATCHFRAME_OBJECTIVEHANDLERS)
			
			self:UpdateSize(off)
		end
	end
	
	local Collapse = WatchFrame_Collapse
	function WatchFrame_Collapse()
		Collapse(WatchFrame)
		self:UpdateSize()
	end
end

function Objectives:UpdateSize(off)
	if WatchFrameHeader:IsShown() then
		if WatchFrame.collapsed then
			if not self.unlocked then
				self:SetWidth(WATCHFRAME_COLLAPSEDWIDTH + 5)
			end
			self:SetHeight(25)
			
		elseif not self.unlocked then
			self:SetWidth(self.sets.width + off)
		end
	else
		self:SetSize(0.1, 0.1)
	end
end

function Objectives:UpdateHeight(lastLine, _, maxWidth)
	if type(lastLine) == 'table' and lastLine.GetBottom then -- Just for safety, you never know
		Objectives:SetHeight((Objectives:GetTop() or 0) - (lastLine:GetBottom() or 0) + 4)
	end
	return lastLine, maxWidth, 0, 0
end

function Objectives:ShowObjectives()
	for i = 1, 4 do
		local button = _G['poiWatchFrameLines'..i..'_1']
		if button and button:IsShown() then
			return true
		end
	end
end


--[[ Unlocking ]]--

function Objectives:OnLock()
	WATCHFRAME_OBJECTIVEHANDLERS = self.handlers
	WatchFrame_Update()
	
	if self.collapsed then
		WatchFrame_Collapse()
	else	
		WatchFrameLines:Show()
	end
	
	for i, line in pairs(FakeQuests) do
		line:Reset()
	end
end

function Objectives:OnUnlock()
	if type(FakeQuests[1]) == 'string' then
		for i, text in pairs(FakeQuests) do
			local line = WatchFrame.lineCache:GetFrame()
			local text, isHeader = strsplit('#', text)

			line.string, line.isHeader = text, isHeader
			line:SetParent(self)
			FakeQuests[i] = line
		end
	end

	self:SetWidth(self.sets.width)
	self.handlers, self.collapsed = WATCHFRAME_OBJECTIVEHANDLERS, WatchFrame.collapsed
	WATCHFRAME_OBJECTIVEHANDLERS = {self.DisplayFakeQuests}
	WatchFrame_Expand(WatchFrame)
	WatchFrameLines:Hide()
end

function Objectives:DisplayFakeQuests()
	local maxWidth = 0
	
	for i, line in pairs(FakeQuests) do
		local isHeader = line.isHeader
		local lastLine = FakeQuests[i-1]
		
		line:Reset()
		line:Show()
		
		WatchFrame_SetLine(
			line,
			lastLine or WatchFrameHeader,
			isHeader and -WATCHFRAME_QUEST_OFFSET or WATCHFRAMELINES_FONTSPACING,
			isHeader and true,
			line.string,
			isHeader and 0 or 1
		)
		
		maxWidth = max(maxWidth, line.text:GetWidth() + line.dash:GetWidth())
	end
	
	return FakeQuests[7], maxWidth, 3, 0
end