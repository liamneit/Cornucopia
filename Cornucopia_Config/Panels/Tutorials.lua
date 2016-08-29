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


local Tutorials = LibStub('CustomTutorials-2.1')
local L, ExampleBar = Cornucopia.Locals, select(2, next(Cornucopia.Bars))

Tutorials.RegisterTutorials(Cornucopia, {
	savedvariable = 'Cornucopia_Tutorials',
	{
		title = 'Welcome to Cornucopia!',
		text = 'Welcome to |cffffd200Cornucopia|r, by |cffffd200Jaliborc|r. These tutorials should help you to learn how to configure your interface using the exciting tools Cornucopia has to offer.|n|nStart by clicking on the new |cffffd200flashing button|r on your Minimap.',
		image = 'Interface\\Addons\\Cornucopia\\Art\\Icon',
		shine = CornucopiaButton,
		height = 200,
	},
	{
		title = 'Configuration Mode',
		text = "Great! Now you're on |cffffd200Configuration Mode|r.|n|nConfiguring your interface is much alike making a presentation: there are several objects (bars) which you can select, move, resize and configure. You can then add or remove bars as you wish to best suit your needs.|n|nClick on the |cffffd200suggested bar|r to proceed.",
		image = 'Interface\\Addons\\Cornucopia\\Art\\Selector',
		shineTop = 10, shineBottom = -10, shineRight = 10,  shineLeft = -10,
		shine = ExampleBar
	},
	{
		title = 'Inspector',
		text = "The window which has just shown up is the |cffffd200Inspector|r. It appears when you select a single bar, and it contains options related to the bar you've selected.|n|nEach bar may have it's own options, so it may take a while to explore them all.",
		shineTop = 8, shineBottom = -8, shineRight = 8, shineLeft = -8,
		point = 'LEFT', relPoint = 'RIGHT',
		anchor = CornucopiaInspector,
		shine = CornucopiaInspector,
		x = 20,
	},
	{
		title = 'Toolbar',
		text = 'Next is the |cffffd200Toolbar|r. It provides tools related to no bar specifically, such as adding a new bar (|TInterface\\Addons\\Cornucopia\\Art\\Add:0|t) or configuring Cornucopia (|TInterface\\Addons\\Cornucopia\\Art\\Options:0|t).|n|nIf you want to watch these tutorials again, you can also click on the |cffffd200Help|r button (|TInterface\\Addons\\Cornucopia\\Art\\Help:0|t).',
		shineTop = 3, shineBottom = -7, shineRight = 5, shineLeft = -7,
		point = 'TOP', relPoint = 'BOTTOM',
		anchor = CornucopiaToolbar,
		shine = CornucopiaToolbar,
		y = -10,
	},
})

function Cornucopia:TriggerTutorial(...)
	Tutorials.TriggerTutorial(Cornucopia, ...)
end

function Cornucopia:ResetTutorials()
	Tutorials.ResetTutorials(Cornucopia)
end

Cornucopia:TriggerTutorial(1)