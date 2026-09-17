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

				// Skip waypoint management for groups actively defending (CBA handles patrol/garrision waypoints)
				if (_group getVariable ["AIC_IsDefending", false]) then {
					continue;
				};

				private _lastWpRevision = _group getVariable ["AIC_Server_Last_Wp_Revision", 0];
				private _groupWaypoints = waypoints _group;
				private _groupControlWaypoints = [_group] call AIC_fnc_getAllActiveWaypoints;
				private _currentWpRevision = _groupControlWaypoints select 0;
				private _groupControlWaypointArray = _groupControlWaypoints select 1;

				if (_currentWpRevision != _lastWpRevision) then {
					// Clear defending state when waypoints are rebuilt (unless actively defending)
					if !(missionNamespace getVariable [format ["AIC_IsDefending_%1", groupId _group], false]) then {
						_group setVariable ["AIC_IsDefending", false, true];
					};
				while { (waypoints _group) isNotEqualTo [] } do {
						deleteWaypoint ((waypoints _group) select 0);
					};

					private _priorWaypointDurationEnabled = false;

					// A "CYCLE" waypoint turns the group's waypoints into an endless patrol.
					// AAC2 normally disables each waypoint once the group reaches it, which
					// would take the loop apart after a single pass, so while a cycle waypoint
					// is present every waypoint of this group stays active. The patrol then
					// runs until the player issues new orders, which bumps the revision and
					// rebuilds the waypoint list from scratch as usual.
					private _hasCycleWaypoint = (_groupControlWaypointArray findIf {
						(_x select AIC_Waypoint_ArrayIndex_Type) == "CYCLE"
					}) >= 0;

					// Arma jumps to the nearest waypoint the moment a cycle waypoint is
					// reached, so anything sequenced after it is never visited. New waypoints
					// are appended to the end of the group's list, which would put them behind
					// an existing cycle, so the cycle waypoints are built last and everything
					// else keeps the order the player placed it in. The player's own ordering
					// is left untouched - only the order the Arma waypoints are created in
					// changes, and each waypoint still carries its original index.
					private _waypointsToBuild = _groupControlWaypointArray;
					if (_hasCycleWaypoint) then {
						private _cycleWaypoints = [];
						private _otherWaypoints = [];
						{
							if ((_x select AIC_Waypoint_ArrayIndex_Type) == "CYCLE") then {
								_cycleWaypoints pushBack _x;
							} else {
								_otherWaypoints pushBack _x;
							};
						} forEach _groupControlWaypointArray;
						_waypointsToBuild = _otherWaypoints + _cycleWaypoints;
					};

					// Loop over the waypoints
					{
						if (!_priorWaypointDurationEnabled) then {
							// _x is an array of waypoint properties (see waypoint.h)
							private _waypoint = _x;

							private _wpIndex = _waypoint select AIC_Waypoint_ArrayIndex_Index;
							private _wpPosition = _waypoint select AIC_Waypoint_ArrayIndex_Position;
							private _wpState = _waypoint select AIC_Waypoint_ArrayIndex_State;
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
							private _wpFlyInHeightAsl = _waypoint select AIC_Waypoint_ArrayIndex_FlyInHeightAsl;

							if (_wpDuration > 0) then {
								_priorWaypointDurationEnabled = true;
							};

							// Add waypoint object to group
							private _wpExactPlacement = -1;
							private _wpObject = _group addWaypoint [_wpPosition, _wpExactPlacement];

							// DEFEND type: replace with MOVE waypoint + CBA_fnc_taskDefend as completion statement
							// Must be handled BEFORE setWaypointType since "DEFEND" is not a valid Arma enum value
							private _wpDefendStatement = "";
							if (_wpType == "DEFEND") then {
								_wpType = "MOVE";
								private _defendRadius = 50;
								private _defendThreshold = 3;
								private _defendPatrol = 10;
								private _defendHold = 0;

								// Parse defend parameters from the waypoint statement if it contains DEFEND_PARAMS
								if (!isNil "_wpStatement") then {
									if (_wpStatement select [0, 14] == "DEFEND_PARAMS:") then {
										private _parts = _wpStatement splitString ":";
										if (count _parts >= 5) then {
											_defendRadius = parseNumber (_parts select 1);
											_defendThreshold = parseNumber (_parts select 2);
											_defendPatrol = parseNumber (_parts select 3);
											_defendHold = parseNumber (_parts select 4);
										};
										_wpStatement = "";
									};
								};

							_wpDefendStatement = format ["[group this, %1, %2, %3, %4] call AIC_fnc_setDefendActive;", _defendRadius, _defendThreshold, _defendPatrol, _defendHold];
							[AIC_LOGLEVEL_DEBUG, format["Setting up defend/garrison waypoint with CBA_fnc_taskDefend. _defendRadius=%1, _defendThreshold=%2, _defendPatrol=%3, _defendHold=%4.", _defendRadius, _defendThreshold, _defendPatrol, _defendHold]] call AIC_fnc_log;
							};

							// ATTACK type: replace with SAD waypoint + CBA_fnc_taskAttack as completion statement
							// Must be handled BEFORE setWaypointType since "ATTACK" is not a valid Arma enum value
							private _wpAttackStatement = "";
							if (_wpType == "ATTACK") then {
								_wpType = "SAD";
								private _attackRadius = 100;
								if (!isNil "_wpCompletionRadius") then {
									_attackRadius = _wpCompletionRadius;
								};
								_wpAttackStatement = format ["[group this, group this, %1] call CBA_fnc_taskAttack; [group this, 'Attacking at waypoint.'] call AIC_fnc_msgSideChat;", _attackRadius];
								[AIC_LOGLEVEL_DEBUG, format["Setting up attack waypoint with CBA_fnc_taskAttack. _attackRadius=%1.", _attackRadius]] call AIC_fnc_log;
							};

							// Set waypoint type
							_wpObject setWaypointType _wpType;

							// The "_wpStatement" is the expression which will be executed when the "_wpStatementCondition" becomes true
							private _wpStatementOriginal = _wpStatement; // we will append the given original statement at the end of this block
							_wpStatement = "";
							private _wpStatementCondition = format ["true && ((group this) getVariable ['AIC_WP_DURATION_REMANING', 0]) <= 0 && {
								%1
							}", _wpCondition];

							// Disable the waypoint internally in AAC2 as soon as it has been fulfilled.
							// Skipped while the group is patrolling a cycle, so the loop survives.
							if (!_hasCycleWaypoint) then {
								private _disableWaypointStatement = format["[group this, %1] call AIC_fnc_disableWaypoint;
							", _wpIndex];
								_wpStatement = _wpStatement + _disableWaypointStatement;
							};

						// Apply fly-in height at waypoint arrival
							if (!isNil "_wpFlyInHeightAsl") then {
								_wpObject setWaypointLoiterAltitude _wpFlyInHeightAsl;
								private _flyInHeightStatement = format ["[group this, %1, 'ASL'] call AIC_fnc_setWaypointFlyInHeightActionHandlerScript;
						", _wpFlyInHeightAsl];
								_wpStatement = _wpStatement + _flyInHeightStatement;
							};
							if (!isNil "_wpFlyInHeight") then {
								_wpObject setWaypointLoiterAltitude _wpFlyInHeight;
								private _flyInHeightStatement = format ["[group this, %1, 'AGL'] call AIC_fnc_setWaypointFlyInHeightActionHandlerScript;
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

							// Prepend the defend statement (runs before the disable and original statement)
							if (_wpDefendStatement != "") then {
								_wpStatement = _wpDefendStatement + _wpStatement;
							};
							// Prepend the attack statement (runs before the disable and original statement)
							if (_wpAttackStatement != "") then {
								_wpStatement = _wpAttackStatement + _wpStatement;
							};

							// Wp statement - do this at the end to ensure the statement includes everything.
							_wpStatement = _wpStatement + _wpStatementOriginal;
							[AIC_LOGLEVEL_DEBUG, format["Waypoint of type '%1' has condition '%2' and statement: '%3'.", _wpType, _wpStatementCondition, _wpStatement]] call AIC_fnc_log;
							_wpObject setWaypointStatements [_wpStatementCondition, _wpStatement];
						};
					} forEach _waypointsToBuild;

				if ((waypoints _group) isEqualTo []) then {
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

					// Store altitude for fallback (both ASL and AGL)
											private _wpFlyInHeightAsl = _nextActiveWaypoint select AIC_Waypoint_ArrayIndex_FlyInHeightAsl;
											private _wpFlyInHeight = _nextActiveWaypoint select AIC_Waypoint_ArrayIndex_FlyInHeight;
											if (!isNil "_wpFlyInHeightAsl") then {
												_group setVariable ["AIC_Last_FlyInHeightAsl", _wpFlyInHeightAsl];
												_group setVariable ["AIC_Last_FlyInHeightMode", "ASL"];
											};
											if (!isNil "_wpFlyInHeight") then {
												_group setVariable ["AIC_Last_FlyInHeight", _wpFlyInHeight];
												_group setVariable ["AIC_Last_FlyInHeightMode", "AGL"];
											};
										} else {
											// No waypoints: apply last stored altitude if available
											private _lastFlyInHeightMode = _group getVariable ["AIC_Last_FlyInHeightMode", nil];
											if (!isNil "_lastFlyInHeightMode") then {
												if (_lastFlyInHeightMode == "ASL") then {
													private _lastFlyInHeightAsl = _group getVariable ["AIC_Last_FlyInHeightAsl", nil];
													if (!isNil "_lastFlyInHeightAsl") then {
														[_group, _lastFlyInHeightAsl, "ASL"] call AIC_fnc_setWaypointFlyInHeightActionHandlerScript;
													};
												} else {
													private _lastFlyInHeight = _group getVariable ["AIC_Last_FlyInHeight", nil];
													if (!isNil "_lastFlyInHeight") then {
														[_group, _lastFlyInHeight, "AGL"] call AIC_fnc_setWaypointFlyInHeightActionHandlerScript;
													};
												};
											};
				};
			} forEach allGroups;

			sleep 2;
		};
	};
};
