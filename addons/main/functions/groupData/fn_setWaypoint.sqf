#include "..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Sets a waypoint for a group

	Parameter(s):
	_this select 0: GROUP - group to set waypoint
	_this select 1: ARRAY: [
		#0	NUMBER: waypoint index,
		#1	POSITION: waypoint world position,
		#2	BOOLEAN: waypoint disabled,
		#3	STRING: waypoint type,
		#4	STRING: waypoint action script ("waypoint statement expression"),
		#5	STRING: waypoint condition
		#6	NUMBER: waypoint timeout
		#7	STRING: waypoint formation
		#8	NUMBER: waypoint completion radius
		#9	NUMBER: waypoint duration
		#10	NUMBER: waypoint loiter waypointLoiterRadius
		#11	STRING: waypoint loiter direction"
	]

	Returns: 
	Nothing
	
*/

private ["_group","_waypoint","_waypointIndex"];

_group = param [0];
_waypoint = param [1];
_waypointIndex = _waypoint select 0;

private ["_waypoints","_revision","_waypointsArray"];

_waypoints = (_group getVariable ["AIC_Waypoints",[0,[]]]);
_revision = _waypoints select 0;
_waypointsArray = _waypoints select 1;

_waypointsArray set [_waypointIndex,_waypoint];
_revision = _revision + 1;
_group setVariable ["AIC_Waypoints",[_revision,_waypointsArray], true];