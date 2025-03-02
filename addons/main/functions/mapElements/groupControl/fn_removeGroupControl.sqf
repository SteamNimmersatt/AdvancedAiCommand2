#include "..\..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Remove the specified group control

	Parameter(s):
	_this select 0: STRING - group control id

	Returns: 
	Nothing
*/

private ["_groupControlId","_groupControls"];

_groupControlId = param [0];
if(isNil "_groupControlId") exitWith {};

[_groupControlId] call AIC_fnc_deleteMapElement;

[[_groupControlId] call AIC_fnc_getGroupControlInteractiveIcon] call AIC_fnc_removeInteractiveIcon;

{
	[_x] call AIC_fnc_removeInteractiveIcon;
} forEach (AIC_fnc_getGroupControlWaypointIcons(_groupControlId));

[_groupControlId] call AIC_fnc_removeGroupControlGroup;
[_groupControlId] call AIC_fnc_removeGroupControlInteractiveIcon;
AIC_fnc_setGroupControlWaypointIcons(_groupControlId,nil);
AIC_fnc_setGroupControlAddingWaypoints(_groupControlId,nil);
AIC_fnc_setGroupControlWaypointRevision(_groupControlId,nil);
AIC_fnc_setGroupControlColor(_groupControlId,nil);
AIC_fnc_setGroupControlType(_groupControlId,nil);
AIC_fnc_setGroupControlActions(_groupControlId,nil);
AIC_fnc_setGroupControlActionsRevision(_groupControlId,nil);

_groupControls = AIC_fnc_getGroupControls();
_groupControls = _groupControls - [_groupControlId];
AIC_fnc_setGroupControls(_groupControls);
