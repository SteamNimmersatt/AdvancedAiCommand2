#include "..\..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Draws the specified interactive icon on the map

	Parameter(s):
	_this select 0: NUMBER - Interactive Icon ID
	_this select 1: GROUP  - The group associated with the icon
		
	Returns: 
	Nothing
*/

private _interactiveIconId = param [0];
private _group = param [1];

if(!AIC_fnc_getMapElementVisible(_interactiveIconId)) exitWith {};

private _state = AIC_fnc_getInteractiveIconState(_interactiveIconId);

private ["_activeIconIds"];
private _interactiveIconIdSet = AIC_fnc_getInteractiveIconIconSet(_interactiveIconId);
if(_state == "UNSELECTED") then {
	_activeIconIds = _interactiveIconIdSet select 0;
} else {
	if(_state == "SELECTED") then {
		_activeIconIds = _interactiveIconIdSet select 1;
	};
	if(_state == "MOUSEOVER") then {
		_activeIconIds = _interactiveIconIdSet select 2;
	};
	if(_state == "PICKEDUP") then {
		_activeIconIds = _interactiveIconIdSet select 3;
	};
};

private _position = AIC_fnc_getInteractiveIconPosition(_interactiveIconId);

{
	private _isInForeground = AIC_fnc_getMapElementForeground(_interactiveIconId);
	[_x, _position, _isInForeground, _group] call AIC_fnc_drawMapIcon;
} forEach _activeIconIds;