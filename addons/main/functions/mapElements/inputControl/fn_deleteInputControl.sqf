#include "..\..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Deletes an input control

	Parameter(s):
	_this select 0: STRING - Input Control ID
		
	Returns: 
	Nothing
*/

private ["_inputControlId"];

_inputControlId = param [0];

[_inputControlId] call AIC_fnc_deleteMapElement;

{
	[_x select 0] call AIC_fnc_removeInteractiveIcon;
} forEach ((AIC_fnc_getInputControlData(_inputControlId)) select 0);

AIC_fnc_removeInputControlType(_inputControlId);
AIC_fnc_removeInputControlParameters(_inputControlId);
AIC_fnc_removeInputControlData(_inputControlId);
AIC_fnc_removeInputControlOutput(_inputControlId);

_inputControls = AIC_fnc_getInputControls();
_inputControls = _inputControls - [_inputControlId];
AIC_fnc_setInputControls(_inputControls);