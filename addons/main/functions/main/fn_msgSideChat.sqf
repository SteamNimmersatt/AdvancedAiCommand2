#include "functions.h"

/*
	Author: Nimmersatt
	
	Description:
	
	Writes the given message into the side chat, visible to all players.
	
	Parameter(s):
	_this select 0: OBJECT - Either a group or a player transmitting the message.
	_this select 1: STRING - Message to write into the chat.
*/

private ["_entity", "_msg", "_msgSender"];
_entity = param [0];
_msg = param [1];

// Check given entity param
private _typeName = typeName _entity;

if (_typeName == "OBJECT") then {
	if (isPlayer _entity) then {
		_msgSender = _entity;
	}
} else {
	if (_typeName == "GROUP") then {
		private _leader = leader _entity;
		_msgSender = _leader;
	}
};
if (isNil "_msgSender") exitWith {
	format ["Invalid entity of type '%1' passed to fn_msgSideChat for side chat message '%2'.", typeName _entity, _msg] call AIC_fnc_log;
};

// Give radio if not present
private _hasRadio = "ItemRadio" in assignedItems _msgSender;
if (!_hasRadio) then {
	_msgSender addItem "ItemRadio";
	_msgSender assignItem "ItemRadio";
};

// Send message
_msgFormatted = format["%1 %2", "[AAC2] - ", _msg];
_msgSender sideChat _msgFormatted;

// Remove radio again if it was not present before
if (!_hasRadio) then {
	_msgSender unassignItem "ItemRadio";
	_msgSender removeItem "ItemRadio";
};