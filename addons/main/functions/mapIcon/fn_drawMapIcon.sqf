#include "..\functions.h"

/*
	Author: [SA] Duda
	
	Description:
	Draws the specified map icon on the map
	
	Parameter(s):
	_this select 0: STRING - Icon ID
	_this select 1: position - Icon world position ([X, Y])
	_this select 2: BOOLEAN - Is in foreground (alpha will be reduced by 50% if in background)
	_this select 2: GROUP - the group associated with the icon
	
	Returns: 
	Nothing
*/
private _iconId = param [0];
private _iconPosition = param [1]; // World position of icon ([X, Y])
private _isInForeground = param [2];
private _group = param [3];

private _groupId = groupId _group;

private _iconProperties = AIC_fnc_getMapIconProperties(_iconId);
private _iconImage = _iconProperties select 0;
private _iconWidth = _iconProperties select 1;
private _iconHeight = _iconProperties select 2;
private _iconMapWidth = _iconProperties select 3;
private _iconMapHeight = _iconProperties select 4;
private _iconShadow = _iconProperties select 5;
private _iconColor = _iconProperties select 6;

private _iconTextFont = "PuristaLight";
private _iconTextSize = 0.05;
private _iconTextAlignment = "right";


// If the icon is a group selector icon ("circle around nato icon"), draw the name of the group next to it.
private _iconText = "";
private _isGroupSelectorIcon = "group_selector" in (str _iconImage);
if (_isGroupSelectorIcon) then {
	_iconText = _groupId;
};

// _iconId contains "GROUP_ICON" ?

if (_isInForeground) then {
	AIC_MAP_CONTROL drawIcon [
		_iconImage,
		_iconColor,
		_iconPosition,
		_iconWidth,
		_iconHeight,
		0, // angle
		_iconText,
		_iconShadow,
		_iconTextSize,
		_iconTextFont,
		_iconTextAlignment
	];
} else {
	private _iconColorMod = [_iconColor select 0, _iconColor select 1, _iconColor select 2, (_iconColor select 3) * 0.5];
	AIC_MAP_CONTROL drawIcon [
		_iconImage,
		_iconColorMod,
		_iconPosition,
		_iconWidth,
		_iconHeight,
		0, // angle
		_iconText,
		_iconShadow,
		_iconTextSize,
		_iconTextFont,
		_iconTextAlignment
	];
};