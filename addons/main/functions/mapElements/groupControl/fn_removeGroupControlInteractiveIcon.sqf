#include "..\..\functions.h"

/*
	@title: Remove Group Control Interactive Icon
	@description: Removes the interactive icon associated with the specified group control.
	@params: 
		0: _controlId (STRING) - The ID of the group control.
*/

params ["_controlId"];
missionNamespace setVariable [format ["AIC_Group_Control_%1_Icon", _controlId], nil];