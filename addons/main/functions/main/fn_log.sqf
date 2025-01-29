#include "functions.h"

/*
	Author: Nimmersatt

	Description:
	
	Logs the given message to the RPT file.

	Parameter(s):
	_this select 0: STRING - Message to log.
	
*/

private ["_msg"];
_msg = param [0];

diag_log format ["%1: %2", "AdvancedAiCommand2", _msg];