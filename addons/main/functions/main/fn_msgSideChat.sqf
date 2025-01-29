#include "functions.h"

/*
	Author: Nimmersatt

	Description:
	
	Writes the given message into the chat, visible to all players.

	Parameter(s):
	_this select 0: STRING - Message to write into the chat.
	_this select 1: OBJECT - The group transmitting the message
	
*/

private ["_group","_msg"];
_group = param [0];
_msg = param [1];

private _leader = leader _group;
private _hasRadio = "ItemRadio" in assignedItems _leader;

// Give radio if not present
if (!_hasRadio) then {
	_leader addItem "ItemRadio";
	_leader assignItem "ItemRadio";
};

// Send message
_msgFormatted=format["%1 %2", "[AAC2]", _msg];
_leader sideChat _msgFormatted;

// Remove radio again if it was not present before
if (!_hasRadio) then {
	_leader unassignItem "ItemRadio";
	_leader removeItem "ItemRadio";
};