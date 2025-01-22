#include "..\..\functions.h"

/*
	@title: Set Group Control Group
	@description: Sets the group associated with the specified group control.
	@params: 
		0: _controlId (STRING) - The ID of the group control.
		1: _controlGroup (GROUP) - The group to associate with the control.
*/

params ["_controlId", "_controlGroup"];
missionNamespace setVariable [format ["AIC_Group_Control_%1_Group", _controlId], _controlGroup];