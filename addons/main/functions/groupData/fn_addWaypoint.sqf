#include "\z\aicommand2\addons\main\functions\functions.h"

/*
	Author: [SA] Duda
	
	Description:
	Adds a waypoint to a group
	
	Parameter(s):
	_this select 0: group - group to add the waypoint to
	_this select 1: ARRAY - Waypoint params (see waypoint.h). Positon "AIC_Waypoint_ArrayIndex_Index" must be nil.
	
	Returns:
	ARRAY: Waypoint (see waypoint.h)
*/


AIC_fnc_initArrayItem = {
	params ["_array", "_indexToInitialize", "_initializationValue"];
	private _arrayLength = count _array;

	if (_arrayLength > _indexToInitialize) then {
		private _item = _array select _indexToInitialize;
		if (isNil "_item") then {
			_array set [_indexToInitialize, _initializationValue];
		}
	} else {
		_array pushBack _initializationValue;
		_array set [_indexToInitialize, _initializationValue];
	};
};

AIC_fnc_addWaypointInitNilWaypointParams = {
	params ["_waypointParams"];
	private _arrayLength = count _waypointParams;
	private _defaultVal = "";

	private _wpDisabledDefaultVal = false;
	[_waypointParams, AIC_Waypoint_ArrayIndex_Disabled, _wpDisabledDefaultVal] call AIC_fnc_initArrayItem;

	private _wpTypeDefaultVal = "MOVE";
	[_waypointParams, AIC_Waypoint_ArrayIndex_Type, _wpTypeDefaultVal] call AIC_fnc_initArrayItem;

	private _wpStatementDefaultVal = "";
	[_waypointParams, AIC_Waypoint_ArrayIndex_Statement, _wpStatementDefaultVal] call AIC_fnc_initArrayItem;

	private _wpConditionDefaultVal = "true";
	[_waypointParams, AIC_Waypoint_ArrayIndex_Condition, _wpConditionDefaultVal] call AIC_fnc_initArrayItem;

	private _wpDurationDefaultVal = 0;
	[_waypointParams, AIC_Waypoint_ArrayIndex_Duration, _wpDurationDefaultVal] call AIC_fnc_initArrayItem;
};


private _group = param [0];
private _waypointParams = param [1];

private _wpIndex = _waypointParams select AIC_Waypoint_ArrayIndex_Index;
if (!isNil "_wpIndex") exitWith {
	private _msg = "fn_addWaypoint was given a waypoint with index != nil (AIC_Waypoint_ArrayIndex_Index). The index must be nil.";
	[AIC_LOGLEVEL_ERROR, _msg] call AIC_fnc_log;
	throw msg;
};

private _wpPosition = _waypointParams select AIC_Waypoint_ArrayIndex_Position;
if (isNil "_wpPosition") exitWith {
	private _msg = "fn_addWaypoint was given a waypoint params without a position (AIC_Waypoint_ArrayIndex_Position).";
	[AIC_LOGLEVEL_ERROR, _msg] call AIC_fnc_log;
	throw msg;
};

// Init waypoint params
[_waypointParams] call AIC_fnc_addWaypointInitNilWaypointParams;

// Get all currently known waypoints
private _allWaypointsContainer = _group getVariable ["AIC_Waypoints", [0, []]];
private _revision = _allWaypointsContainer select 0;
private _allWaypointsArray = _allWaypointsContainer select 1;

// Set waypoint index
private _wpIndex = count _allWaypointsArray; // the length of the array storing all waypoints is the index of the new waypoint
_waypointParams set [AIC_Waypoint_ArrayIndex_Index, _wpIndex];

// Add waypoint to the other waypoints
_allWaypointsArray pushBack _waypointParams;

// Increase the "revision" for the next waypoint
_revision = _revision + 1;
_group setVariable ["AIC_Waypoints", [_revision, _allWaypointsArray], true];

private _logMsg = "fn_addWaypoint added a waypoint: " + ([_waypointParams] call AIC_fnc_toStringWaypoint);
[AIC_LOGLEVEL_DEBUG, _logMsg] call AIC_fnc_log;

_waypointParams;