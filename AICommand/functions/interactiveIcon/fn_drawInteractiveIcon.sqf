#include "functions.h"

/*
	Author: [SA] Duda

	Description:
	Draws the specified interactive icon on the map

	Parameter(s):
	_this select 0: NUMBER - Interactive Icon ID
	_this select 1: NUMBER - Alpha (Optional - if set, this alpha value will be used for all drawing actions. If set to -1, alpha will not be changed)
		
	Returns: 
	Nothing
*/

private ["_interactiveIconId","_shown","_activeIconIds","_position","_state","_alpha"];
_interactiveIconId = param [0];
_alpha = param [1,-1];

_shown = AIC_fnc_getInteractiveIconShown(_interactiveIconId);
if(!_shown) exitWith {};

_state = AIC_fnc_getInteractiveIconState(_interactiveIconId);

if(_state == "UNSELECTED") then {
	_activeIconIds = (AIC_fnc_getInteractiveIconIconSet(_interactiveIconId)) select 0;
} else {
	if(_state == "SELECTED") then {
		_activeIconIds = (AIC_fnc_getInteractiveIconIconSet(_interactiveIconId)) select 1;
	};
	if(_state == "MOUSEOVER") then {
		_activeIconIds = (AIC_fnc_getInteractiveIconIconSet(_interactiveIconId)) select 2;
	};
	if(_state == "PICKEDUP") then {
		_activeIconIds = (AIC_fnc_getInteractiveIconIconSet(_interactiveIconId)) select 3;
	};
};

_position = AIC_fnc_getInteractiveIconPosition(_interactiveIconId);

{
	[_x, _position,_alpha] call AIC_fnc_drawMapIcon;
} forEach _activeIconIds;