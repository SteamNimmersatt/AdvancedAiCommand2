#include "..\..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Gets interactive icons based on a map position. Only returns up to 1 icon at position.

	Parameter(s):
	_this select 0: NUMBER -  Map x position
	_this select 1: NUMBER - Map y position
		
	Returns: 
	ARRAY - [
		ARRAY - Interactive icon ids at position
		ARRAY - Interactive icon ids not at position
	]
*/

private _mapPositionX = param [0];
private _mapPositionY = param [1];

private _interactiveIcons = AIC_fnc_getInteractiveIcons();
private _mapControl = findDisplay 12 displayCtrl 51;

// First pass: of all the icons under the cursor, remember the one whose centre is
// nearest to it. Icons overlap regularly — most obviously right after a group is
// split, when both halves are still standing on the same spot — and picking the
// first match in list order made every icon behind the front one unreachable.
// Choosing the nearest centre instead keeps stacked icons selectable: nudging the
// mouse a few pixels towards the icon you want is enough to reach it.
private _closestIcon = "";
private _closestDistance = -1;

{
	if((AIC_fnc_getMapElementVisible(_x)) && (AIC_fnc_getMapElementEnabled(_x))) then {
		private _iconWorldPosition = AIC_fnc_getInteractiveIconPosition(_x);
		private _iconMapPosition = _mapControl ctrlMapWorldToScreen _iconWorldPosition;
		private _iconMapPositionX = _iconMapPosition select 0;
		private _iconMapPositionY = _iconMapPosition select 1;
		private _iconMapDimensions = AIC_fnc_getInteractiveIconDimensions(_x);
		private _iconMapWidth = _iconMapDimensions select 0;
		private _iconMapHeight = _iconMapDimensions select 1;

		if( (_mapPositionX < _iconMapPositionX + (_iconMapWidth/2)) && (_mapPositionX > _iconMapPositionX - (_iconMapWidth/2)) && (_mapPositionY < _iconMapPositionY + (_iconMapHeight/2)) && (_mapPositionY > _iconMapPositionY - (_iconMapHeight/2)) ) then {
			private _deltaX = _mapPositionX - _iconMapPositionX;
			private _deltaY = _mapPositionY - _iconMapPositionY;
			private _distance = sqrt ((_deltaX * _deltaX) + (_deltaY * _deltaY));
			if(_closestDistance < 0 || {_distance < _closestDistance}) then {
				_closestDistance = _distance;
				_closestIcon = _x;
			};
		};
	};
} forEach _interactiveIcons;

// Second pass: split the icons into the (at most one) icon at the cursor and the rest.
// Icons that are hidden or disabled stay out of both lists, as before.
private _iconsAtPosition = [];
private _iconsNotAtPosition = [];

{
	if((AIC_fnc_getMapElementVisible(_x)) && (AIC_fnc_getMapElementEnabled(_x))) then {
		if(_x isEqualTo _closestIcon) then {
			_iconsAtPosition pushBack _x;
		} else {
			_iconsNotAtPosition pushBack _x;
		};
	};
} forEach _interactiveIcons;

[_iconsAtPosition,_iconsNotAtPosition];

