#include "..\..\functions.h"

/*
	@title: Get Group Control Group
	@description: Retrieves the group associated with the specified group control.
	@params: 
		0: _controlId (STRING) - The ID of the group control.
	@return: GROUP or nil if no group is found.
*/

params ["_controlId"];
missionNamespace getVariable [format ["AIC_Group_Control_%1_Group", _controlId], nil];