#include "..\..\functions.h"

/*
	@title: Get Group Control Interactive Icon
	@description: Retrieves the interactive icon associated with the specified group control.
	@params: 
		0: _controlId (STRING) - The ID of the group control.
	@return: STRING or nil if no interactive icon is found.
*/

params ["_controlId"];
missionNamespace getVariable [format ["AIC_Group_Control_%1_Icon", _controlId], nil];