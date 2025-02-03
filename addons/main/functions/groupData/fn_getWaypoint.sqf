#include "..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Get a waypoint for a group

	Parameter(s):
	_this select 0: GROUP - group to get waypoint
	_this select 1: NUMBER - waypoint index

	Returns: 
	ARRAY: [
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
*/

private ["_group","_waypointIndex"];

_group = param [0];
_waypointIndex = param [1];

private ["_waypointsArray"];

_waypointsArray = (_group getVariable ["AIC_Waypoints",[0,[]]]) select 1;
_waypointsArray select _waypointIndex;