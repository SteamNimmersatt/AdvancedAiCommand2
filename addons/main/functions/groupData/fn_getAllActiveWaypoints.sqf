#include "\z\aicommand2\addons\main\functions\functions.h"

/*
	Author: [SA] Duda

	Description:
	Get all active waypoints for a group

	Parameter(s):
	_this select 0: GROUP - group to get all waypoints

	Returns: 
	ARRAY: [
		NUMBER: Waypoint revision,
		ARRAY: All active waypoints
	]
*/

private _group = param [0];
private _allWaypointsContainer = _group getVariable ["AIC_Waypoints",[0,[]]];

if (count _allWaypointsContainer < 1) then {
	private _errorMsg = "ERROR - fn_getAllActiveWaypoints encountered an empty _allWaypointsContainer array.";
	_errorMsg call AIC_fnc_log;
	throw _errorMsg;
};

private _waypointsRevision = _allWaypointsContainer select 0;
private _allWaypointsArray = _allWaypointsContainer select 1;

if (isNil "_allWaypointsArray") exitWith {
	private _errorMsg = "ERROR - fn_getAllActiveWaypoints - _allWaypointsArray is nil.";
	_errorMsg call AIC_fnc_log;
	throw _errorMsg;
};

private _activeWaypoints = [];
{
	private _waypoint = _x;
	private _isDisabled = _waypoint select AIC_Waypoint_Array_Pos_Disabled;
	if (!_isDisabled) then {
		_activeWaypoints pushBack _waypoint;
	};
} forEach _allWaypointsArray;

[_waypointsRevision, _activeWaypoints];