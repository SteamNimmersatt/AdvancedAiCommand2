#include "functions.h"
#include "..\interactiveIcon\functions.h"
#include "..\groupData\functions.h"
#include "..\commandControl\functions.h"
#include "..\properties.h"

/*
	Author: [SA] Duda

	Description:
	Draws the specified group control (including waypoints) on the map

	Parameter(s):
	_this select 0: STRING - Group Control ID
	_this select 1: NUMBER - Alpha (Optional - if set, this alpha value will be used for all drawing actions. If set to -1, alpha will not be changed)
		
	Returns: 
	Nothing
*/

private ["_groupControlId","_alpha"];

_groupControlId = param [0];
_alpha = param [1,-1];

if!(AIC_fnc_getGroupControlShown(_groupControlId)) exitWith {};

private ["_group","_icon","_groupPosition","_goCode"];

_group = AIC_fnc_getGroupControlGroup(_groupControlId);
_groupPosition = position leader _group;
_icon = AIC_fnc_getGroupControlInteractiveIcon(_groupControlId);
_goCode = AIC_fnc_getGroupGoCode(_group);

// Set current position to group's position

AIC_fnc_setInteractiveIconPosition(_icon,_groupPosition);	

// Draw the interactive icon at the group's position

[_icon,_alpha] call AIC_fnc_drawInteractiveIcon;

// Draw go code on top of the icon if group is waiting for go code

if(!isNil "_goCode") then {
	if(_goCode == "ALPHA") then {
		[A_GO_CODE_ICON,_groupPosition,_alpha] call AIC_fnc_drawMapIcon;
	};
	if(_goCode == "BRAVO") then {
		[B_GO_CODE_ICON,_groupPosition,_alpha] call AIC_fnc_drawMapIcon;
	};
};

// Draw waypoints

private ["_waypointIcons"];

_waypointIcons = AIC_fnc_getGroupControlWaypointIcons(_groupControlId);

// Draw the lines between the waypoints

private ["_priorWaypointPosition","_lineFromPosition","_lineToPosition","_lineColor"];

if(_alpha >= 0) then {
	_lineColor = ((AIC_fnc_getGroupControlColor(_groupControlId)) select 1) + [_alpha];
} else {
	_lineColor = ((AIC_fnc_getGroupControlColor(_groupControlId)) select 1) + [1];
};

{
	if(isNil "_priorWaypointPosition") then {
		// Draw line back to group
		_lineFromPosition = _groupPosition;
	} else {
		// Draw line back to last waypoint position
		_lineFromPosition = _priorWaypointPosition;
	};
	_lineToPosition = AIC_fnc_getInteractiveIconPosition(_x select 1);
	_priorWaypointPosition = _lineToPosition;
	AIC_MAP_CONTROL drawLine [
		_lineFromPosition,
		_lineToPosition,
		_lineColor
	];
} forEach _waypointIcons;

// If user adding waypoints, draw a line between the last waypoint or group and the cursor

if(AIC_fnc_getGroupControlAddingWaypoints(_groupControlId)) then {
	if(isNil "_priorWaypointPosition") then {
		_priorWaypointPosition = _groupPosition;
	};
	AIC_MAP_CONTROL drawLine [
		(AIC_fnc_getMouseMapPosition()),
		_priorWaypointPosition,
		_lineColor
	];
	//hint str (AIC_fnc_getMouseMapPosition());
};

// Draw the waypoint interactive icons on top of the line

{
	[_x select 1,_alpha] call AIC_fnc_drawInteractiveIcon;
} forEach _waypointIcons;