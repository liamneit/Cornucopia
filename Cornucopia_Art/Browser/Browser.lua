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

if not IsAddOnLoaded('Cornucopia_Art') then
	return
end

local Art = Cornucopia:GetGroup('Art')
local Appear = Art.appear

local BUTTON_TEX = 'Interface\\Buttons\\UI-SpellbookIcon-%sPage-%s'
local Browser = CreateFrame('ScrollFrame', 'CornucopiaArtBrowser', Appear, 'HybridScrollFrameTemplate')

local Dir, Folder = CornucopiaArt_DataBase, ''
local Structure, Queue = {}, {}


--[[ Startup ]]--

function Browser:Startup()
	local bar = CreateFrame('Slider', '$parentBar', self, 'MinimalHybridScrollBarTemplate')
	bar:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', -14, 15)
	bar:SetPoint('TOPLEFT', self, 'TOPRIGHT', -14, -18)
	bar.trackBG:SetPoint('BOTTOMRIGHT', -3, -17)
	
	local folder = self:CreateFontString(nil, nil, 'GameFontHighlightLeft')
	folder:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 65, -12)
	
	local left = self:CreateSplit('Char-Inner-Left')
	left:SetPoint('BOTTOMLEFT', 0, -32)
	left:SetPoint('TOPLEFT')

	local right = self:CreateSplit('Char-Inner-Left', bar)
	right:SetPoint('BOTTOMRIGHT', self, -11, -2)
	right:SetPoint('TOPRIGHT', self, -11, 0)
	
	local bottom = self:CreateSplit('Char-Inner-Bottom')
	bottom:SetPoint('BOTTOMRIGHT', 6, -5)
	bottom:SetPoint('BOTTOMLEFT', 3, -5)
	
	local bg = self:CreateTexture(nil, 'BACKGROUND')
	bg:SetPoint('TOPRIGHT', bottom, 0, -3)
	bg:SetPoint('TOPLEFT', bottom, 0, -3)
	bg:SetTexture(0,0,0)
	bg:SetHeight(28)
	
	self.Folder = folder
	self:CreateButton('Next', 36)
	self:CreateButton('Prev', 10)
	self:SetPoint('BOTTOMRIGHT', 0, 29)
	self:SetPoint('TOPRIGHT', 0, 9)
	self.Startup, self.CreateSplit, self.CreateButton = nil
	self:SetSize(260, 300)
	self:updateButtons()
	
	HybridScrollFrame_CreateButtons(self, 'CornucopiaArtBrowser_ButtonTemplate', 4, -3, 'TOPLEFT', 'TOPLEFT', 0, -TOKEN_BUTTON_OFFSET)
	Appear.Browser = self
end

function Browser:CreateSplit(template, parent)
	local split = (parent or self):CreateTexture(nil, nil, template)
	split:ClearAllPoints()
	return split
end

function Browser:CreateButton(name, x)
	local button = CreateFrame('Button', nil, self)
	button:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight')
	button:SetDisabledTexture(BUTTON_TEX:format(name, 'Disabled'))
	button:SetPushedTexture(BUTTON_TEX:format(name, 'Down'))
	button:SetNormalTexture(BUTTON_TEX:format(name, 'Up'))
	button:SetPoint('BOTTOMLEFT', x, -31)
	button:SetSize(26, 26)
	button:SetScript('OnClick', function()
		self:Navigate(name)
	end)
	
	self[name] = button
end


--[[ Navigation ]]--

function Browser:update()
	local self = self or Browser
	local offset = HybridScrollFrame_GetOffset(self)
	local numFiles = #Dir - 1
	
	for i, button in pairs(self.buttons) do
		local index = i + offset
		
		if index <= numFiles then
			local target = Dir[index + 1]
			local isFile = type(target) == 'string'
			
			button.icon:SetTexture(isFile and (Folder .. target) or  'Interface\\Addons\\Cornucopia\\Art\\Folder')
			button.text:SetText(isFile and target or target[1])
			button.isFile = isFile
			button.target = target
			button:Show()
			
			if mod(index, 2) == 0 then
				button.stripe:Show()
			else
				button.stripe:Hide()
			end
		else
			button:Hide()
		end
	end
	
	HybridScrollFrame_Update(self, numFiles * 25, #self.buttons * 25)
end

function Browser:updateButtons()
	if Folder == '' then
		self.Folder:SetText('World of Warcraft')
		self.Prev:Disable()
	else
		self.Folder:SetText(Folder:sub(0,-2):match('([^\\]+)$'))
		self.Prev:Enable()
	end
	
	if #Queue == 0 then
		self.Next:Disable()
	else
		self.Next:Enable()
	end
end

function Browser:Navigate(direction)
	if direction == 'Prev' then
		tinsert(Queue, {Folder, tremove(Structure)})
		self:SetValue(Folder:sub(0,-2):match('^(.+\\).-$'), tremove(Structure) or CornucopiaArt_DataBase)
	else
		local last = tremove(Queue)
		self:SetValue(last[1], last[2])
	end
end

function Browser:Select(button)
	wipe(Queue)
	self:SetValue(Folder .. button.text:GetText() .. (button.isFile and '' or '\\'), button.target)
end

function Browser:SetValue(value, target)
	local folder, file = (value or ''):match('^(.+\\)(.-)$')

	if folder and file ~= '' then
		self.bar:UseTexture(value)
	end
	
	if folder ~= Folder then
		if target then
			self:SetDir(target)
		else
			wipe(Structure) wipe(Queue)
			self:SetDir(CornucopiaArt_DataBase)
			
			if folder then
				for step in folder:gmatch('[^\\]+') do
					for i, line in ipairs(Dir) do
						if line[1] == step then
							self:SetDir(Dir[i])
							break
						end
					end
				end
			end
		end
		
		Folder = folder or ''
		self:updateButtons()
		self:update()
	end
end

function Browser:SetDir(dir)
	Dir = dir
	tinsert(Structure, dir)
end

Browser:Startup()