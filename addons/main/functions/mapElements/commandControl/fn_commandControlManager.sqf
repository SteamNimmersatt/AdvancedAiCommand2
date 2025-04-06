#include "\z\aicommand2\addons\main\functions\functions.h"

/*
	Author: [SA] Duda
	
	Description:
	Command Control Manager
	
	Parameter(s):
	None
	
	Returns: 
	Nothing
*/

["ALL_EAST"] call AIC_fnc_createCommandControl;
["ALL_WEST"] call AIC_fnc_createCommandControl;
["ALL_GUER"] call AIC_fnc_createCommandControl;
["ALL_CIV"] call AIC_fnc_createCommandControl;

private _isHumanPlayer = hasInterface;
if (_isHumanPlayer) then {
	AIC_fnc_commandControlDrawHandler = {
		private ["_commandControls", "_inputControls", "_actionControlShown"];

		_commandControls = AIC_fnc_getCommandControls();
		_inputControls = AIC_fnc_getInputControls();

		// Draw all visible input controls
		{
			if (AIC_fnc_getMapElementVisible(_x)) then {
				[_x] call AIC_fnc_drawInputControl;
			};
		} forEach _inputControls;

		// Draw command controls
		{
			[_x] call AIC_fnc_drawCommandControl;
		} forEach _commandControls;
	};

	// Setup UI event handlers
	["MAP_CONTROL", "Draw", "_this call AIC_fnc_commandControlDrawHandler"] spawn AIC_fnc_addManagedEventHandler;

	[] spawn {
		private ["_commandControls", "_groupsRevision", "_currentRevision"];
		while { true } do {
			_commandControls = AIC_fnc_getCommandControls();
			{
				_commandControlId = _x;
				_groupsRevision = AIC_fnc_getCommandControlGroupsRevision(_commandControlId);
				_currentRevision = AIC_fnc_getCommandControlGroupsControlsRevision(_commandControlId);

				// Check for command control group controls revision changes
				if (_groupsRevision != _currentRevision) then {
					[_commandControlId, "REFRESH_GROUP_CONTROLS", []] call AIC_fnc_commandControlEventHandler;
				};
			} forEach _commandControls;
			sleep 2;
		};
	};

	// Group casualty reporting
	// TODO: currently disabled because it also reports despawning units. Annoying e.g. for Antistasi.
	// TODO: move somewhere else
	[] spawn {

		// TODO: currently disabled because it also reports despawning units. Annoying e.g. for Antistasi.
		while { true } do {
			sleep 9999999;
		};


		// Array to track the number of units per group
		_groupTracking = [];

		// Update the unit count for a group, adding it if not already present
		UpdateUnitCount = {
			private _groupId = _this select 0;
			private _newCount = _this select 1;

			// Check if the group is already in _groupTracking
			private _index = -1;
			for "_i" from 0 to (count _groupTracking) - 1 do {
				private _groupTrackingEntry = _groupTracking select _i;
				private _groupTrackingEntryId = _groupTrackingEntry select 0;
				if (_groupTrackingEntryId isEqualTo _groupId) exitWith {
					_index = _i;
				};
			};

			if (_index != -1) then {
				private _groupTrackingEntry = _groupTracking select _index;
				_groupTrackingEntry set [1, _newCount]; // Update the count in the tracking entry (array of groupId, count)
				_groupTracking set [_index, _groupTrackingEntry];
			} else {
				private _groupTrackingEntry = [_groupId, _newCount];
				_groupTracking pushBack _groupTrackingEntry;
			};
		};

		// Get the unit count for a group
		GetUnitCount = {
			private _groupId = _this select 0;
			private _result = -1;
			{
				private _trackedGroupId = _x select 0;
				if (_trackedGroupId isEqualTo _groupId) exitWith {
					_result = _x select 1;
				};
			} forEach _groupTracking;
			_result
		};

		while { true } do {
			private _commandControls = AIC_fnc_getCommandControls();
			{
				private _commandControlId = _x;

				// Skip if not visible to the player
				if (!AIC_fnc_getMapElementVisible(_commandControlId)) then {
					continue;
				};

				private _groups = AIC_fnc_getCommandControlGroups(_commandControlId);
				{
					private _group = _x;
					private _groupId = groupId _group; // e.g. "Alpha 1-1"

					private _units = units _group;
					private _aliveUnitsCount = 0;
					{
						if (alive _x) then {
							_aliveUnitsCount = _aliveUnitsCount + 1;
						}
					} forEach _units;

					private _previousUnitCount = [_groupId] call GetUnitCount;
					if (_aliveUnitsCount != _previousUnitCount) then {
						[_groupId, _aliveUnitsCount] call UpdateUnitCount;
						if (_previousUnitCount > _aliveUnitsCount) then {
							private _unitsLostCount = _previousUnitCount - _aliveUnitsCount;
							[_group, format ["%1 casualties!", _unitsLostCount]] call AIC_fnc_msgSideChat;
						};
					}
				} forEach _groups;
			} forEach _commandControls;
			sleep 10;
		};
	}
};

if (isServer) then {
	// Add new groups to command control
	[] spawn {
		_isAntistasiActive = isClass(configFile >> "CfgPatches" >> "A3A_core");
		if (_isAntistasiActive) then {
			[AIC_LOGLEVEL_INFO, "Antistasi mod is loaded. Will not show civilian groups."] call AIC_fnc_log;
		};

		while { true } do {
			{
				if (side _x == east) then {
					["ALL_EAST", _x] call AIC_fnc_commandControlAddGroup;
				};
				if (side _x == west) then {
					["ALL_WEST", _x] call AIC_fnc_commandControlAddGroup;
				};
				if (side _x == resistance) then {
					["ALL_GUER", _x] call AIC_fnc_commandControlAddGroup;
				};
				if (side _x == civilian) then {
					// Antistasi: Hide civilian groups (do not allow to control them)
					if (!_isAntistasiActive) then {
						["ALL_CIV", _x] call AIC_fnc_commandControlAddGroup;
					}
				};
			} forEach allGroups;
			sleep 5;
		};
	};

	// Check for empty groups associated with command controls and remove them
	[] spawn {
		private ["_commandControls", "_commandControlId", "_groups", "_group", "_units"];
		while { true } do {
			_commandControls = AIC_fnc_getCommandControls();
			{
				_commandControlId = _x;
				_groups = AIC_fnc_getCommandControlGroups(_commandControlId);
				{
					_group = _x;
					_units = [];
					{
						if (alive _x) then {
							_units = _units + [_x]
						}
					} forEach (units _group);
					if (count _units == 0) then {
						[_group, '<Communication lost>'] call AIC_fnc_msgSideChat;
						[_commandControlId, _group] call AIC_fnc_commandControlRemoveGroup;
					};
				} forEach _groups;
			} forEach _commandControls;
			sleep 10;
		};
	};

	// Manage group waypoints
	[] spawn {
		while { true } do {
			{
				private _group = _x;
				private _lastWpRevision = _group getVariable ["AIC_Server_Last_Wp_Revision", 0];
				private _groupWaypoints = waypoints _group;
				private _groupControlWaypoints = [_group] call AIC_fnc_getAllActiveWaypoints;
				private _currentWpRevision = _groupControlWaypoints select 0;
				private _groupControlWaypointArray = _groupControlWaypoints select 1;

				if (_currentWpRevision != _lastWpRevision) then {
					while { (count (waypoints _group)) > 0 } do {
						deleteWaypoint ((waypoints _group) select 0);
					};

					private _priorWaypointDurationEnabled = false;

					// Loop over the waypoints
					{
						if (!_priorWaypointDurationEnabled) then {
							// _x is an array of waypoint properties (see waypoint.h)
							private _waypoint = _x;

							private _wpIndex = _waypoint select AIC_Waypoint_ArrayIndex_Index;
							private _wpPosition = _waypoint select AIC_Waypoint_ArrayIndex_Position;
							private _wpDisabled = _waypoint select AIC_Waypoint_ArrayIndex_Disabled;
							private _wpType = _waypoint select AIC_Waypoint_ArrayIndex_Type;
							private _wpStatement = _waypoint select AIC_Waypoint_ArrayIndex_Statement;
							private _wpCondition = _waypoint select AIC_Waypoint_ArrayIndex_Condition;
							private _wpTimeout = _waypoint select AIC_Waypoint_ArrayIndex_Timeout;
							private _wpFormation = _waypoint select AIC_Waypoint_ArrayIndex_Formation;
							private _wpCompletionRadius = _waypoint select AIC_Waypoint_ArrayIndex_CompletionRadius;
							private _wpDuration = _waypoint select AIC_Waypoint_ArrayIndex_Duration;
							private _wpLoiterRadius = _waypoint select AIC_Waypoint_ArrayIndex_LoiterRadius;
							private _wpLoiterDirection = _waypoint select AIC_Waypoint_ArrayIndex_LoiterDirection;
							private _wpFlyInHeight = _waypoint select AIC_Waypoint_ArrayIndex_FlyInHeight;

							if (_wpDuration > 0) then {
								_priorWaypointDurationEnabled = true;
							};

							// Add waypoint object to group
							private _wpExactPlacement = -1;
							private _wpObject = _group addWaypoint [_wpPosition, _wpExactPlacement];

							// Set waypoint type
							_wpObject setWaypointType _wpType;

							// The "_wpStatement" is the expression which will be executed when the "_wpStatementCondition" becomes true
							private _wpStatementOriginal = _wpStatement; // we will append the given original statement at the end of this block
							_wpStatement = "";
							private _wpStatementCondition = format ["true && ((group this) getVariable ['AIC_WP_DURATION_REMANING', 0]) <= 0 && {
								%1
							}", _wpCondition];

							// Disable the waypoint internally in AAC2 as soon as it has been fulfilled
							private _disableWaypointStatement = format["[group this, %1] call AIC_fnc_disableWaypoint;
							", _wpIndex];
							_wpStatement = _wpStatement + _disableWaypointStatement;

							if (!isNil "_wpFlyInHeight") then {
								private _flyInHeightStatement = format ["[group this, %1] call AIC_fnc_setWaypointFlyInHeightActionHandlerScript;
								", _wpFlyInHeight];
								_wpStatement = _wpStatement + _flyInHeightStatement;
							};
							if (!isNil "_wpTimeout") then {
								_wpObject setWaypointTimeout [_wpTimeout, _wpTimeout, _wpTimeout];
							};
							if (!isNil "_wpFormation") then {
								_wpObject setWaypointFormation _wpFormation;
							};
							if (!isNil "_wpCompletionRadius") then {
								_wpObject setWaypointCompletionRadius _wpCompletionRadius;
							};

							if (_wpType == "LOITER") then {
								[AIC_LOGLEVEL_DEBUG, format["Setting up loiter waypoint. _wpLoiterRadius=%1, _wpLoiterDirection=%2.", _wpLoiterRadius, _wpLoiterDirection]] call AIC_fnc_log;
								if (!isNil "_wpLoiterRadius") then {
									_wpObject setWaypointLoiterRadius _wpLoiterRadius;
								};
								if (!isNil "_wpLoiterDirection") then {
									_wpObject setWaypointLoiterType _wpLoiterDirection;
								};
							};

							// Wp statement - do this at the end to ensure the statement includes everything.
							_wpStatement = _wpStatement + _wpStatementOriginal;
							[AIC_LOGLEVEL_DEBUG, format["Waypoint of type '%1' has condition '%2' and statement: '%3'.", _wpType, _wpStatementCondition, _wpStatement]] call AIC_fnc_log;
							_wpObject setWaypointStatements [_wpStatementCondition, _wpStatement];
						};
					} forEach _groupControlWaypointArray;

					if (count (waypoints _group)==0) then {
						_group addWaypoint [position leader _group, 0];
					};
					_group setVariable ["AIC_Server_Last_Wp_Revision", _currentWpRevision];
				};

				if (count _groupControlWaypointArray > 0) then {
					private _nextActiveWaypoint = _groupControlWaypointArray select 0;
					private _wpDuration = _nextActiveWaypoint select AIC_Waypoint_ArrayIndex_Duration;

					if (_wpDuration > 0 && _group getVariable ["AIC_WP_DURATION_REMANING", 0] <= 0) then {
						_group setVariable ["AIC_WP_DURATION_REMANING", _wpDuration];
					};
					if (_wpDuration <= 0 && _group getVariable ["AIC_WP_DURATION_REMANING", 0] > 0) then {
						_group setVariable ["AIC_WP_DURATION_REMANING", 0, true];
					};
					_group setVariable ["AIC_WP_DURATION_REMANING", (_group getVariable ["AIC_WP_DURATION_REMANING", 0]) - 2, true];
					if (_wpDuration > 0 && _group getVariable ["AIC_WP_DURATION_REMANING", 0] <= 0) then {
						_nextActiveWaypoint set [AIC_Waypoint_ArrayIndex_Duration, 0];
						[_group, _nextActiveWaypoint] call AIC_fnc_setWaypoint;
					};
				};
			} forEach allGroups;

			sleep 2;
		};
	};
};