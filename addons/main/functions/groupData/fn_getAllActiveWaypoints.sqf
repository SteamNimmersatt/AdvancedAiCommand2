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

"DEBUG - fn_getAllActiveWaypoints called." call AIC_fnc_log;

private _group = param [0];
private _allWaypointsContainer = _group getVariable ["AIC_Waypoints",[0,[]]];

if (count _allWaypointsContainer < 1) then {
	private _errorMsg = "ERROR - fn_getAllActiveWaypoints encountered an empty _allWaypointsContainer array.";
	_errorMsg call AIC_fnc_log;
	throw _errorMsg;
};

"DEBUG - fn_getAllActiveWaypoints - _allWaypointsContainer size " + str (count _allWaypointsContainer)  call AIC_fnc_log;

private _waypointsRevision = _allWaypointsContainer select 0;
private _allWaypointsArray = _allWaypointsContainer select 1;

if (isNil "_allWaypointsArray") exitWith {
	private _errorMsg = "ERROR - fn_getAllActiveWaypoints - _allWaypointsArray is nil.";
	_errorMsg call AIC_fnc_log;
	throw _errorMsg;
};
// TODO remove
"DEBUG - fn_getAllActiveWaypoints - _allWaypointsArray size " + str (count _allWaypointsArray)  call AIC_fnc_log;

private _activeWaypoints = [];
{
	private _waypoint = _x;

	private _logMsg = "fn_getAllActiveWaypoints - Processing a waypoint. Type: " + (typeName _waypoint) + ", Length: " + str (count _waypoint);
	_logMsg call AIC_fnc_log;

	_logMsg = "fn_getAllActiveWaypoints - waypoint: " + ([_waypoint] call AIC_fnc_toStringWaypoint);
	_logMsg call AIC_fnc_log;

	private _isDisabled = _waypoint select AIC_Waypoint_Array_Pos_Disabled;
	if (!_isDisabled) then {
		_activeWaypoints pushBack _waypoint;
	};
} forEach _allWaypointsArray;

[_waypointsRevision, _activeWaypoints];