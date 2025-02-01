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

// Check if the given entity is a valid player
if (isPlayer _entity) then {
	_msgSender = _entity;
}
// Check if the given entity is a valid group
else if (_entity isKindOf "Group") then {
	private _leader = leader _entity;
	_msgSender = _leader;
} else {
	format ["Invalid entity of type '%1' passed to fn_msgSideChat for side chat message '%2'.", typeOf _entity, _msg] call AIC_fnc_log;
	exitWith {};
};

// Give radio if not present
private _hasRadio = "ItemRadio" in assignedItems _msgSender;
if (!_hasRadio) then {
	_entity addItem "ItemRadio";
	_entity assignItem "ItemRadio";
};

// Send message
_msgFormatted = format["%1 %2", "[AAC2]", _msg];
_entity sideChat _msgFormatted;

// Remove radio again if it was not present before
if (!_hasRadio) then {
	_entity unassignItem "ItemRadio";
	_entity removeItem "ItemRadio";
};