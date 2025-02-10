#include "..\functions.h"

_colorRed = [1,0,0];
_colorGreen = [0,1,0];
_colorBlue = [0,0,1];
_colorYellow = [1,1,0];
_colorPurple = [1,0,1];
_colorPink = [1,0.8,1];
_colorCyan = [0,1,1];
_colorBlack = [0,0,0];
_colorWhite = [1,1,1];

AIC_COLOR_RED = ["RED",_colorRed];
AIC_COLOR_GREEN = ["GREEN",_colorGreen];
AIC_COLOR_BLUE = ["BLUE",_colorBlue];
AIC_COLOR_YELLOW = ["YELLOW",_colorYellow];
AIC_COLOR_PURPLE = ["PURPLE",_colorPurple];
AIC_COLOR_PINK = ["PINK",_colorPink];
AIC_COLOR_CYAN = ["CYAN",_colorCyan];
AIC_COLOR_BLACK = ["BLACK",_colorBlack];
AIC_COLOR_WHITE = ["WHITE",_colorWhite];

_colors = [AIC_COLOR_RED,AIC_COLOR_GREEN,AIC_COLOR_BLUE,AIC_COLOR_YELLOW,AIC_COLOR_PURPLE,AIC_COLOR_PINK,AIC_COLOR_CYAN,AIC_COLOR_BLACK,AIC_COLOR_WHITE];
_groupIconTypes = ["inf","air","motor_inf","mech_inf","armor","plane","uav","art","mortar","maint","med","support","boat"];

_wpIconTypes = ["MOVE"];


// "Group selector" icons (round circle around the group icon)
AIC_UNSELECTED_GROUP_SELECTOR_ICON = ["\z\aicommand2\addons\main\images\group_selector_dashed.paa",28,28,0,_colorBlack + [0.5]] call AIC_fnc_createMapIcon;
AIC_SELECTED_GROUP_SELECTOR_ICON = ["\z\aicommand2\addons\main\images\group_selector.paa",28,28,0,_colorBlack + [1]] call AIC_fnc_createMapIcon;
AIC_MOUSE_OVER_GROUP_SELECTOR_ICON = ["\z\aicommand2\addons\main\images\group_selector_dashed.paa",30,30,0,_colorBlack + [0.8]] call AIC_fnc_createMapIcon;
AIC_PICKED_UP_SELECTOR_ICON = ["\z\aicommand2\addons\main\images\group_selector.paa",30,30,1,_colorBlack + [1]] call AIC_fnc_createMapIcon;


{
	_color = _x;
	{
		private _iconType = _x;

		private _variableNameSuffix = toUpper (_color select 0)+"_"+toUpper _iconType;
		
		private _iconPath = format ["\A3\ui_f\data\map\markers\nato\b_%1",_iconType];
		private _iconSize = 20;
		private _iconAlpha = 0;
		
		private _variableNamePrefix = "AIC_UNSELECTED_GROUP_ICON_";
		private _iconColorUnselected = (_color select 1) + [0.5];
		private _iconUnselected = [_iconPath,_iconSize,_iconSize,_iconAlpha,_iconColorUnselected] call AIC_fnc_createMapIcon;
		missionNamespace setVariable [_variableNamePrefix + _variableNameSuffix,_iconUnselected];

		private _variableNamePrefix = "AIC_SELECTED_GROUP_ICON_";
		private _iconColorSelected = (_color select 1) + [1];
		private _iconSelected = [_iconPath,_iconSize,_iconSize,_iconAlpha,_iconColorSelected] call AIC_fnc_createMapIcon;
		missionNamespace setVariable [_variableNamePrefix + _variableNameSuffix,_iconSelected];

		private _variableNamePrefix = "AIC_MOUSE_OVER_GROUP_ICON_";
		private _iconColorMouseOver = (_color select 1) + [0.8];
		private _iconMouseover = [_iconPath,_iconSize,_iconSize,_iconAlpha,_iconColorMouseOver] call AIC_fnc_createMapIcon;
		missionNamespace setVariable [_variableNamePrefix + _variableNameSuffix,_iconMouseover];

		private _variableNamePrefix = "AIC_PICKED_UP_GROUP_ICON_";
		private _iconSizePickedUp = 22;
		private _iconAlphaPickedUp = 1;
		private _iconPickedUp = [_iconPath,_iconSizePickedUp,_iconSizePickedUp,_iconAlphaPickedUp,_iconColorSelected] call AIC_fnc_createMapIcon;
		missionNamespace setVariable [_variableNamePrefix + _variableNameSuffix,_iconPickedUp];

	} forEach _groupIconTypes;
} forEach _colors;

{
	_color = _x;
	{
		_iconType = _x;
		missionNamespace setVariable ["AIC_UNSELECTED_WP_ICON_"+toUpper (_color select 0)+"_"+toUpper _iconType,(["\z\aicommand2\addons\main\images\wp_"+toLower _iconType+"_icon.paa",12,12,0,(_color select 1) + [0.5]] call AIC_fnc_createMapIcon)];
		missionNamespace setVariable ["AIC_SELECTED_WP_ICON_"+toUpper (_color select 0)+"_"+toUpper _iconType,(["\z\aicommand2\addons\main\images\wp_"+toLower _iconType+"_icon.paa",12,12,0,(_color select 1) + [1]] call AIC_fnc_createMapIcon)];
		missionNamespace setVariable ["AIC_MOUSE_OVER_WP_ICON_"+toUpper (_color select 0)+"_"+toUpper _iconType,(["\z\aicommand2\addons\main\images\wp_"+toLower _iconType+"_icon.paa",14,14,0,(_color select 1) + [0.8]] call AIC_fnc_createMapIcon)];
		missionNamespace setVariable ["AIC_PICKED_UP_WP_ICON_"+toUpper (_color select 0)+"_"+toUpper _iconType,(["\z\aicommand2\addons\main\images\wp_"+toLower _iconType+"_icon.paa",14,14,1,(_color select 1) + [1]] call AIC_fnc_createMapIcon)];
	} forEach _wpIconTypes;
} forEach _colors;

