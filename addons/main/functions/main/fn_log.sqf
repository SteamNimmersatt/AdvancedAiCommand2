#include "functions.h"

/*
	Author: Nimmersatt

	Description:
	
	Logs the given message to the RPT file.

	Parameter(s):
	_this select 0: STRING - Message to log.
	
*/

private _logLevelNumeric = param [0];
private _msg = param [1];

// TODO CBA setting
private _logLevelSetting = 1;

if (_logLevelNumeric < _logLevelSetting) exitWith {}; // Don't log if the message is below our current log level setting.

private _logLevelText = switch (_logLevelNumeric) do {
	case AIC_LOGLEVEL_DEBUG: {"DEBUG"};
	case AIC_LOGLEVEL_INFO: {"INFO"};
	case AIC_LOGLEVEL_WARNING: {"WARNING"};
	case AIC_LOGLEVEL_ERROR: {"ERROR"};
	default {"INVALID LOG LEVEL"};
};

diag_log text format ["%1 - %2 - %3", "[AdvancedAiCommand2]", _logLevelText, _msg];