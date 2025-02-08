#include "\z\aicommand2\addons\main\functions\functions.h"

/*

	Description:
	Returns a string representation of a waypoint (for logging).

	Parameter(s):
	_this select 0: ARRAY - the waypoint

	Returns: 
	The string representation of the waypoint.
	
*/

private _waypoint = param [0];

private _arrayLength = count _waypoint;
private _logString = "";
for "_fieldIndex" from 0 to (_arrayLength - 1) do {
	private _fieldName = switch (_fieldIndex) do {
		case AIC_Waypoint_ArrayIndex_Index: {"Index"};
		case AIC_Waypoint_ArrayIndex_Position: {"Position"};
		case AIC_Waypoint_ArrayIndex_Disabled: {"Disabled"};
		case AIC_Waypoint_ArrayIndex_Type: {"Type"};
		case AIC_Waypoint_ArrayIndex_Statement: {"Statement"};
		case AIC_Waypoint_ArrayIndex_Condition: {"Condition"};
		case AIC_Waypoint_ArrayIndex_Timeout: {"Timeout"};
		case AIC_Waypoint_ArrayIndex_Formation: {"Formation"};
		case AIC_Waypoint_ArrayIndex_CompletionRadius: {"CompletionRadius"};
		case AIC_Waypoint_ArrayIndex_Duration: {"Duration"};
		case AIC_Waypoint_ArrayIndex_LoiterRadius: {"LoiterRadius"};
		case AIC_Waypoint_ArrayIndex_LoiterDirection: {"LoiterDirection"};
		case AIC_Waypoint_ArrayIndex_FlyInHeight: {"FlyInHeight"};
		default {""};
	};
	_logString = _logString + format ["%1='%2'. ", _fieldName, _waypoint select _fieldIndex];
};

_logString;