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

	private _wpStateDefaultVal = AIC_Waypoint_State_Drafted;
	[_waypointParams, AIC_Waypoint_ArrayIndex_State, _wpStateDefaultVal] call AIC_fnc_initArrayItem;

	private _wpTypeDefaultVal = "MOVE";
	[_waypointParams, AIC_Waypoint_ArrayIndex_Type, _wpTypeDefaultVal] call AIC_fnc_initArrayItem;

	private _wpStatementDefaultVal = "";
	[_waypointParams, AIC_Waypoint_ArrayIndex_Statement, _wpStatementDefaultVal] call AIC_fnc_initArrayItem;

	private _wpConditionDefaultVal = "true";
	[_waypointParams, AIC_Waypoint_ArrayIndex_Condition, _wpConditionDefaultVal] call AIC_fnc_initArrayItem;

	private _wpDurationDefaultVal = 0;
	[_waypointParams, AIC_Waypoint_ArrayIndex_Duration, _wpDurationDefaultVal] call AIC_fnc_initArrayItem;

	// No default fly-in height — new waypoints should not enforce any altitude
	// unless the player explicitly set one (group-level or waypoint-level).
	// The array still has to carry those indices, to prevent zero-divisor errors in
	// HEMTT sqfc compiled bytecode.
	//
	// This cannot go through AIC_fnc_initArrayItem: assigning nil to a variable in SQF
	// leaves that variable undefined, so building the [_waypointParams, index, value]
	// argument array threw "Undefined variable" on every single waypoint placed.
	// Growing the array leaves the new slots nil, which is exactly what is wanted here.
	private _requiredLength = AIC_Waypoint_ArrayIndex_FlyInHeightAsl + 1;
	if (count _waypointParams < _requiredLength) then {
		_waypointParams resize _requiredLength;
	};
};


private _group = param [0];
private _waypointParams = param [1];

// If the group was actively defending, placing a new waypoint cancels defending mode.
// This allows the server-side waypoint manager to resume controlling waypoints.
if (_group getVariable ["AIC_IsDefending", false]) then {
	_group setVariable ["AIC_IsDefending", false, true];
	missionNamespace setVariable [format ["AIC_IsDefending_%1", groupId _group], false, true];
	[AIC_LOGLEVEL_DEBUG, format["Cleared defending state for group %1 (new waypoint placed)", groupId _group]] call AIC_fnc_log;
};

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

// Inherit group-level fly-in height if set and this waypoint has no explicit height
private _groupFlyInHeightMode = _group getVariable ["AIC_Last_FlyInHeightMode", nil];
if (!isNil "_groupFlyInHeightMode") then {
	if (_groupFlyInHeightMode == "ASL") then {
		private _wpFlyInHeightAslValue = _waypointParams select AIC_Waypoint_ArrayIndex_FlyInHeightAsl;
		// Only override if the waypoint doesn't already have an explicit ASL height
		if (isNil "_wpFlyInHeightAslValue") then {
			private _groupFlyInHeightAsl = _group getVariable ["AIC_Last_FlyInHeightAsl", nil];
			if (!isNil "_groupFlyInHeightAsl") then {
				_waypointParams set [AIC_Waypoint_ArrayIndex_FlyInHeightAsl, _groupFlyInHeightAsl];
				_waypointParams set [AIC_Waypoint_ArrayIndex_FlyInHeight, nil];
			};
		};
	} else {
		// AGL mode
		private _wpFlyInHeightValue = _waypointParams select AIC_Waypoint_ArrayIndex_FlyInHeight;
		if (isNil "_wpFlyInHeightValue") then {
			private _groupFlyInHeight = _group getVariable ["AIC_Last_FlyInHeight", nil];
			if (!isNil "_groupFlyInHeight") then {
				_waypointParams set [AIC_Waypoint_ArrayIndex_FlyInHeight, _groupFlyInHeight];
				_waypointParams set [AIC_Waypoint_ArrayIndex_FlyInHeightAsl, nil];
			};
		};
	};
};

// Get all currently known waypoints
private _allWaypointsContainer = _group getVariable ["AIC_Waypoints", [0, []]];
private _allWaypointsArray = _allWaypointsContainer select 1;

// Set waypoint index
private _wpIndex = count _allWaypointsArray; // the length of the array storing all waypoints is the index of the new waypoint
_waypointParams set [AIC_Waypoint_ArrayIndex_Index, _wpIndex];

// Add waypoint to the other waypoints (revision is NOT bumped for disabled waypoints;
// the caller must bump the revision separately when enabling the waypoint, e.g. on right-click)
_allWaypointsArray pushBack _waypointParams;
_group setVariable ["AIC_Waypoints", [_allWaypointsContainer select 0, _allWaypointsArray], true];

private _logMsg = "fn_addWaypoint added a waypoint: " + ([_waypointParams] call AIC_fnc_toStringWaypoint);
[AIC_LOGLEVEL_DEBUG, _logMsg] call AIC_fnc_log;

_waypointParams;
