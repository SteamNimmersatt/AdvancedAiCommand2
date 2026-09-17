#include "..\..\functions.h"

params ["_groupControlId","_waypointId"];
_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
_waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
_waypoint params ["_wpIndex","_wpPosition","_wpState",["_wpType","MOVE"],["_wpActionScript",""],["_wpCondition","true"],"_wpTimeout","_wpFormation","_wpCompletionRadius",["_wpDuration",0],"_wpLoiterRadius","_wpLoiterDirection","_wpFlyInHeight","_wpFlyInHeightAsl"];
							
_sizeLarge = 1.0;
_sizeSmall = 0.9;
_textLarge = "<t size='%3' color='#ffffff'><t align='left'>%1:</t><t align='right'>%2</t></t><br />";
_textSmall = "<t size='%3' color='#cccccc'><t align='left'> - %1:</t><t align='right'>%2</t></t><br />";

_wpInfo = format [_textLarge,"Waypoint",_wpType,_sizeLarge];

if(!isNil "_wpFormation") then {
	_wpInfo = _wpInfo + format [_textSmall,"Formation",_wpFormation,_sizeSmall];
};

// Loiter waypoints are placed as either clockwise or counter-clockwise, but the report
// showed only "LOITER", leaving the direction and radius guessable solely from watching
// the aircraft fly.
if(!isNil "_wpLoiterRadius") then {
	_wpInfo = _wpInfo + format [_textSmall,"Loiter radius (m)",_wpLoiterRadius,_sizeSmall];
};

if(!isNil "_wpLoiterDirection") then {
	private _loiterDirectionLabel = if (_wpLoiterDirection isEqualTo "CIRCLE_L") then {
		"Counter-clockwise"
	} else {
		"Clockwise"
	};
	_wpInfo = _wpInfo + format [_textSmall,"Loiter direction",_loiterDirectionLabel,_sizeSmall];
};

if(_wpDuration > 0) then {
	_wpInfo = _wpInfo + format [_textSmall,"Duration (mins)", (str floor (_wpDuration/60)) ,_sizeSmall];
};

if(!isNil "_wpFlyInHeightAsl") then {
	_wpInfo = _wpInfo + format [_textSmall,"Height (m ASL)", _wpFlyInHeightAsl,_sizeSmall];
};

if(!isNil "_wpFlyInHeight") then {
	_wpInfo = _wpInfo + format [_textSmall,"Height (m AGL)", _wpFlyInHeight,_sizeSmall];
};

_text = parseText (
	"<t size='1.3' color='#ffffff' font='PuristaMedium' underline='true' align='left'>SITREP</t>" + 
	format ["<t size='0.9' align='right'>%1</t><br /><br />",[dayTime] call bis_fnc_timetostring] + 
	format ["<t>%1</t>",_wpInfo] + 
	""
);
hint _text;
