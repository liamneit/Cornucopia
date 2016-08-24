local L = Cornucopia.Locals

--Cornucopia_DEV = {}
setmetatable(L, L)
L.__index = function(L, k)
	--Cornucopia_DEV[k] = true
	return k
end

L['CannotConfig'] = 'Cannot configure interface while in combat!'
L['Add'] = 'Add Bar'
L['Back'] = 'Send to Back'
L['Front'] = 'Bring to Front'
L['BottomLeft'] = 'Bottom Left'
L['BottomRight'] = 'Bottom Right'
L['TopLeft'] = 'Top Left'
L['TopRight'] = 'Top Right'

L['BinderTip'] = 'Mouse over a button and press a key to set a binging.|nPressing "Esc" will remove the binding.'
L['MinimapButtonDesc'] = 'If you do not want to use the minimap|nbutton to enter configuration mode,|nyou can set a key binding for it.'
L['VehicleArtDesc'] = 'If enabled, the standard vehicle|ninterface will be shown.'
L['RulersDesc'] = 'You can hold "Alt" to temporarily|ndisable/enable the rulers.'

L["EventsDesc"] = "These options allow you to make the actions in your bar to |cffffffffchange|r depending of the |cffffffffsituation|r you're in."
L["IDsDesc"] = "Unfortunately, the game client only allows you to have up to |cffffffff120 different actions|r.|n|nThe number of actions you spend increases with the number of |cffffffffbuttons|r you use and |cffffffffevents|r you enable."

L["StanceDesc"] =  "If enabled, the actions in this bar will change when you enter |cffffffff%s|r."
L["CombatStancesDesc"] = "If enabled, the actions in this bar will change depending of the |cffffffffCombat Stance|r you're in."
L["ShapeshiftingDesc"] = "If enabled, the actions in this bar will change depending of the |cffffffffAnimal Form|r you're in."
L["TalentFormsDesc"] = "If enabled, the actions in this bar will change when entering |cffffffffMoonkin|r or |cffffffffTree of Life|r forms."
L["StealthDesc"] = "If enabled, the actions in this bar will change when entering |cffffffff%s|r."

L["FriendlyDesc"] = "If enabled, the actions in this bar will change when targeting a |cfffffffffriendly player or mob|r.\n\nGood for placing buffs and healing abilities!"
L["KeyDesc"] = "If enabled, the actions in this bar will change when holding the |cffffffff%s|r key on your keyboard."
L["CombatDesc"] = "If enabled, the actions in this bar will change depending of you being in |cffffffffcombat|r or not."
L["GroupDesc"] = "If enabled, the actions in this bar will change depending of you being in a |cffffffffgroup|r or not."
L["VehicleDesc"] = "If enabled, this action bar will show |cffffffffVehicle Abilities|r when you enter one."