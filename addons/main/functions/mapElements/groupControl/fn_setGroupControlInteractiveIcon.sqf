#include "..\..\functions.h"

/*
	@title: Set Group Control Interactive Icon
	@description: Sets the interactive icon associated with the specified group control.
	@params: 
		0: _controlId (STRING) - The ID of the group control.
		1: _interactiveGroupIcon (STRING) - The interactive icon id to set.
*/

params ["_controlId", "_interactiveGroupIcon"];
missionNamespace setVariable [format ["AIC_Group_Control_%1_Icon", _controlId], _interactiveGroupIcon];