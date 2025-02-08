#include "..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Get a waypoint for a group

	Parameter(s):
	_this select 0: GROUP - group to get waypoint
	_this select 1: NUMBER - waypoint index

	Returns: 
	ARRAY: see waypoint.h
*/

private _group = param [0];
private _waypointIndex = param [1];
private _waypointsArray = (_group getVariable ["AIC_Waypoints",[0,[]]]) select 1;
_waypointsArray select _waypointIndex;