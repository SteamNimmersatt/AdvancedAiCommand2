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



[AIC_LOGLEVEL_INFO, format["drawMapIcon - _iconText='%1', _isInForeground='%2', _isGroupSelectorIcon='%3', _iconImage='%4'", str _iconText, str _isInForeground, str _isGroupSelectorIcon, str _iconImage]] call AIC_fnc_log;

// Draw icons softer?
if (!_isInForeground ) then {
	_iconColor = [_iconColor select 0, _iconColor select 1, _iconColor select 2, (_iconColor select 3) * 0.5];
};

// Draw the icon
AIC_MAP_CONTROL drawIcon [
	_iconImage,
	_iconColor,
	_iconPosition,
	_iconWidth,
	_iconHeight,
	0, // angle
	"", // text next to the icon
	_iconShadow
];

// Draw the name of the group next to the icon
private _isGroupSelectorIcon = "group_selector" in (str _iconImage); // "group selector icon" = circle around nato icon
private _isMarkerIcon = "marker" in (str _iconImage); // nato style marker icon
if (_isMarkerIcon) then {
	private _text = _groupId;
	private _font = "PuristaLight";
	private _textSize = 0.05;
	private _textAlignment = "right";
	//private _positionX = (_iconPosition select 0) + (_iconWidth / 2);
	private _positionX = (_iconPosition select 0) + 10;
	private _positionY = (_iconPosition select 1);
	private _position = [_positionX, _positionY];
	private _color = [_iconColor select 0, _iconColor select 1, _iconColor select 2, 1]; // Same color as icon but fully opaque.
	private _shadow = 2; // outline around text

	AIC_MAP_CONTROL drawIcon [
			"#(rgb,1,1,1)color(1,1,1,1)",
			_color, // green: [0,1,0,1],
			_position,
			0,
			0,
			0,
			_text,
			2, // shadow. 2=outline around text
			_textSize,
			_font,
			_textAlignment
		]
}