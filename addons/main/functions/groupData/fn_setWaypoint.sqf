#include "..\functions.h"

/*
	Author: [SA] Duda
	
	Description:
	Sets a waypoint for a group
	
	Parameter(s):
	_this select 0: group - group to set waypoint
	_this select 1: ARRAY - waypoint (array, see waypoint.h)
	
	Returns: 
	Nothing
	
*/

private _group = param [0, nil];
if (isNil "_group") exitWith {
	"ERROR - fn_setWaypoint was called a nil group argument." call AIC_fnc_log;
};
private _waypoint = param [1, nil];
if (isNil "_waypoint") exitWith {
	"ERROR - fn_setWaypoint was called with a nil waypoint arguent." call AIC_fnc_log;
};

private _waypointIndex = _waypoint select 0;

private _waypoints = (_group getVariable ["AIC_Waypoints", [0, []]]);
private _revision = _waypoints select 0;
private  _waypointsArray = _waypoints select 1;

_waypointsArray set [_waypointIndex, _waypoint];
_revision = _revision + 1;
_group setVariable ["AIC_Waypoints", [_revision, _waypointsArray], true];