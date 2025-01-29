#include "..\..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Remove interactive icon

	Parameter(s):
	_this select 0: STRING - Interactive Icon ID
		
	Returns: 
	Nothing
*/

private ["_interactiveIconId","_interactiveIcons"];

_interactiveIconId = param [0];
if(isNil "_interactiveIconId") exitWith {};

[_interactiveIconId] call AIC_fnc_deleteMapElement;

AIC_fnc_removeInteractiveIconIconSet(_interactiveIconId);
AIC_fnc_removeInteractiveIconPosition(_interactiveIconId);
AIC_fnc_removeInteractiveIconState(_interactiveIconId);
AIC_fnc_removeInteractiveIconDimensions(_interactiveIconId);
AIC_fnc_removeInteractiveIconEventHandlerScript(_interactiveIconId);
AIC_fnc_removeInteractiveIconEventHandlerScriptParams(_interactiveIconId);

_interactiveIcons = AIC_fnc_getInteractiveIcons();
_interactiveIcons = _interactiveIcons - [_interactiveIconId];
AIC_fnc_setInteractiveIcons(_interactiveIcons);