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
local Bar = Cornucopia:CreateBar('Minimap', {
	sets = 'Cornucopia_Minimap_Sets',
	name = 'Minimap',
	vehicles = true,
	defaults = {
		buttons = {
			MiniMapWorldMapButton = 46.8,
			MiniMapTrackingButton = 167.7,
			GameTimeFrame = 28
		},
		theme = 'Warcraft',
		point = 'TopRight',
		x = -6.8, y = -22.8,
		color = {1, 1, 1},
		radius = 76,
		shape = 1,
	},
	Themes = {}
})

local Corners = {}
local SHAPES = {
	{true, true, true, true},	-- Round
	{},							-- Square
	{nil, nil, true},			-- Bottom Left
	{nil, nil, nil, true},		-- Bottom Right
	{nil, true},				-- Top Left
	{true},						-- Top Right
	{true, true},				-- Top
	{nil, nil, true, true},		-- Bottom
	{nil, true, true},			-- Left
	{true, nil, nil, true},		-- Right
}


--[[ Startup ]]--

function Bar:OnInitialize()
	-- Frames
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetParent(self)
	MinimapCluster:SetPoint('TOP', -9, 18)

	MinimapNorthTag:SetAlpha(0)
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', function(self, v)
		self:SetZoom(max(min(self:GetZoomLevels(), self:GetZoom() + v), 0))
	end)
	
	-- Buttons
	if not IsAddOnLoaded('MinimapButtonFrame') then
		self:TweakButtons()
		self:InitializeButtons(MiniMapWorldMapButton, MiniMapTrackingButton, MiniMapMailFrame)
		self:InitializeButtons(select(6, MinimapBackdrop:GetChildren()))
		self:InitializeButtons(select(4, Minimap:GetChildren()))
	else
		self.UpdateButtons = function() end
	end

	-- Border
	self:CreateCorner('BOTTOMLEFT', 0.5, 1, 0, 0.5)
	self:CreateCorner('BOTTOMRIGHT', 0, 0.5, 0, 0.5)
	self:CreateCorner('TOPRIGHT', 0, 0.5, 0.5, 1)
	self:CreateCorner('TOPLEFT', 0.5, 1, 0.5, 1)
	
	-- Clean Up
	self.TweakButtons, self.InitializeButtons, self.FindBorders, self.CreateCorner = nil
	self:SetSize(170, 170)
	self:Update()
end

function Bar:CreateCorner(point, ...)
	local texture = Minimap:CreateTexture(nil, 'ARTWORK')
	texture:SetPoint(point, Minimap, 'CENTER')
	texture:SetTexCoord(...)
	tinsert(Corners, texture)
end


--[[ Update ]]--

function Bar:Update()
	local theme = self:GetTheme()
	local shape = not theme.square and 1 or not theme.round and 2 or self.sets.shape
	
	self.corners = SHAPES[shape]
	self:UpdateButtons(theme)
	
	for	i, texture in pairs(Corners) do
		if self.corners[i] then
			texture:SetTexture(theme.round)
		else
			texture:SetTexture(theme.square)
		end
		
		if theme.colorable then
			texture:SetVertexColor(unpack(self.sets.color))
		else
			texture:SetVertexColor(1, 1, 1, 1)
		end
		
		texture:SetSize(theme.size or 80, theme.size or 80)
	end
	
	Minimap:SetMaskTexture('Interface\\Addons\\Cornucopia_Minimap\\Masks\\'..shape)
	MinimapCompassTexture:SetTexture(shape == 1 and theme.compass or nil)
end

function Bar:GetTheme()
	local theme = self.sets.theme
	return self.Themes[theme] or self.Themes['Warcraft']
end


--[[ Options ]]--

function Bar:OnOptionsShown()
	local Options = CornucopiaGroup(self, 'Appearance')

	Options:SetChildren(function()
		local Theme = Options:Create('TextureDropdown', 'Theme')
		Theme:SetSize(140, 90)
		
		for id, theme in pairs(self.Themes) do
			Theme:AddLine(id, theme.preview or theme.round or theme.square, theme.name or id)
		end
		
		Theme:AddLine('', '', 'None')
		local theme = self:GetTheme()
		
		if theme.round and theme.square then
			local Shape =  Options:Create('TextureDropdown', 'Shape')
			for shape in pairs(SHAPES) do
				Shape:AddLine(shape, 'Interface\\Addons\\Cornucopia_Minimap\\Masks\\'.. shape)
			end
		end
		
		if theme.colorable then
			 Options:Create('ColorPicker', 'Color'):EnableAlpha(true)
		end
	end)
	
	self.OnOptionsShown = nil
	self.options = {Options}
end