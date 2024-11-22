#include "..\functions.h"

/*
	Author: [SA] Duda
	
	Description:
	get vehicles a group is assigned to 
	
	Parameter(s):
	_this select 0: group - group
	
	Returns: 
	ARRAY - [
		OBJECT - vehicle, 
		...
	]
	
*/
private ["_group", "_assignedVehicles"];
_group = param [0];
_assignedVehicles = _group getVariable ["AIC_Assigned_Vehicles", []];
{
	private _isVehicle = !isNull objectParent _x;
	if (_isVehicle) then {
		_assignedVehicles = _assignedVehicles + [vehicle _x];
	};
} forEach (units _group);
_assignedVehicles;