#include "..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Gets the icon path for a specified vehicle class name

	Parameter(s):
	_this select 0: String - Vehicle class name

	Returns: 
	STRING: The icon path
*/
private ["_vehicleClassName"];
_vehicleClassName = param [0];
getText (configFile >> "CfgVehicles" >> _vehicleClassName >> "Icon")