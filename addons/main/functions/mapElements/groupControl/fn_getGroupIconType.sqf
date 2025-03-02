#include "..\..\functions.h"

/*
	(FROM MARTA)
	Author: Karel Moricky, Modified by SA Duda

	Description:
	Get group's icon type.

	Parameter(s):
	_this: Group
*/
private ["_grp","_vehlist","_cars","_apcs","_tanks","_helis","_planes","_boats","_veh","_type"];

_grp = _this;

_vehlist = [];
_cars = 0;
_apcs = 0;
_tanks = 0;
_helis = 0;
_planes = 0;
_uavs = 0;
_boats = 0;
_artys = 0;
_mortars = 0;
_support_reammo = 0;
_support_repair = 0;
_support_refuel = 0;
_support_medic = 0;
_support = 0;
{
	if (!canStand vehicle _x && alive vehicle _x && !(vehicle _x in _vehlist)) then {
		_veh = vehicle _x;
		_vehlist = _vehlist + [_veh];

		//--- Vehicle is Car
		if (_veh isKindOf "car" || _veh isKindOf "wheeled_apc") then {_cars = _cars + 1};

		//--- Vehicle is Tank
		if (_veh isKindOf "tank") then {
			if (getNumber(configFile >> "cfgvehicles" >> typeOf _veh >> "artilleryScanner") > 0) then
			{
				//--- Self-propelled artillery
				_artys = _artys + 1;
			} else {

				//--- Armored tank
				_tanks = _tanks + 1;
			};
		};

		//--- Vehicle is APC
		if (_veh isKindOf "tracked_apc") then {_apcs = _apcs + 1};

		//--- Vehicle is Helicopter
		if (_veh isKindOf "helicopter") then {_helis = _helis + 1};

		//--- Vehicle is Plane
		if (_veh isKindOf "plane") then {
			if (_veh isKindOf "uav") then {

				//--- UAV
				_uavs = _uavs + 1
			} else {

				//--- Plane
				_planes = _planes + 1
			};
		};

		//--- Vehicle is Artillery
		if (_veh isKindOf "staticcanon") then {_artys = _artys + 1};

		//--- Vehicle is Mortar
		if (_veh isKindOf "staticmortar") then {_mortars = _mortars + 1};

		//--- Vehicle is Boat
		if (_veh isKindOf "boat") then {_boats = _boats + 1};

		//--- Vehicle is support
		_canHeal = getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "attendant") > 0;
		_canReammo = getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "transportAmmo") > 0;
		_canRefuel = getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "transportFuel") > 0;
		_canRepair = getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "transportRepair") > 0;
		if (_canHeal) then {_support_medic = _support_medic + 1};
		if (_canReammo) then {_support_reammo = _support_reammo + 1};
		if (_canRefuel) then {_support_refuel = _support_refuel + 1};
		if (_canRepair) then {_support_repair = _support_repair + 1};
	};
} forEach units _grp;

_type = "inf";
if (_cars >= 1) then {_type = "motor_inf"};
if (_apcs >= 1) then {_type = "mech_inf"};
if (_tanks >= 1) then {_type = "armor"};
if (_helis >= 1) then {_type = "air"};
if (_planes >= 1) then {_type = "plane"};
if (_uavs >= 1) then {_type = "uav"};
if (_artys >= 1) then {_type = "art"};
if (_mortars >= 1) then {_type = "mortar"};
if (_support_repair >= 1) then {_type = "maint"};
if (_support_medic >= 1) then {_type = "med"};
if ((_support_medic + _support_reammo + _support_refuel + _support_repair) > 1) then {_type = "support"};
if (_boats >= 1) then {_type = "boat"};
_type;