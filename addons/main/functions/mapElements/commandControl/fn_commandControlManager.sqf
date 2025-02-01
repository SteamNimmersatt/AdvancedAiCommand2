#include "..\..\functions.h"

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
if(_isHumanPlayer) then {
		
	AIC_fnc_commandControlDrawHandler = {	
		private ["_commandControls","_inputControls","_actionControlShown"];
		
		_commandControls = AIC_fnc_getCommandControls();
		_inputControls = AIC_fnc_getInputControls();
		
		// Draw all visible input controls
		{
			if(AIC_fnc_getMapElementVisible(_x)) then {
				[_x] call AIC_fnc_drawInputControl;
			};
		} forEach _inputControls;
		
		// Draw command controls
		{	
			[_x] call AIC_fnc_drawCommandControl;
		} forEach _commandControls;
	};

	// Setup UI event handlers
	["MAP_CONTROL","Draw", "_this call AIC_fnc_commandControlDrawHandler"] spawn AIC_fnc_addManagedEventHandler;
	
	
	[] spawn {
		private ["_commandControls","_groupsRevision","_currentRevision"];
		while {true} do {
			_commandControls = AIC_fnc_getCommandControls();
			{
				_commandControlId = _x;
				_groupsRevision = AIC_fnc_getCommandControlGroupsRevision(_commandControlId);
				_currentRevision = AIC_fnc_getCommandControlGroupsControlsRevision(_commandControlId);

				// Check for command control group controls revision changes
				if(_groupsRevision != _currentRevision) then {
					[_commandControlId,"REFRESH_GROUP_CONTROLS",[]] call AIC_fnc_commandControlEventHandler;
				};

			} forEach _commandControls;
			sleep 2;
		};
	};
	
};

if(isServer) then {
	
	[] spawn {

		_isAntistasiActive = isClass(configFile >> "CfgPatches" >> "A3A_core");
		"Antistasi mod is loaded. Will not show civilian groups." call AIC_fnc_log;

		while {true} do {
			{
				if(side _x == east) then {
					["ALL_EAST",_x] call AIC_fnc_commandControlAddGroup;
				};
				if(side _x == west) then {
					["ALL_WEST",_x] call AIC_fnc_commandControlAddGroup;
				};
				if(side _x == resistance) then {
					["ALL_GUER",_x] call AIC_fnc_commandControlAddGroup;
				};
				if(side _x == civilian) then {
					// Antistasi: Hide civilian groups (do not allow to control them)
					if(!_isAntistasiActive) then {
						["ALL_CIV",_x] call AIC_fnc_commandControlAddGroup;
					}
				};
			} forEach allGroups;
			sleep 5;
		};
		
	};

	// Check for empty groups associated with command controls and remove them
	[] spawn {
		private ["_commandControls","_commandControlId","_groups","_groupControls","_group","_units"];
		while {true} do {
			_commandControls = AIC_fnc_getCommandControls();
			{
				_commandControlId = _x;
				_groups = AIC_fnc_getCommandControlGroups(_commandControlId);
				{
					_group = _x;
					_units = [];
					{if (alive _x) then {_units = _units + [_x]}} forEach (units _group);
					if(count _units == 0) then {
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
		while {true} do {
			private ["_group","_groupControl","_lastWpRevision","_groupWaypoints","_groupControlWaypoints","_currentWpRevision","_groupControlWaypointArray","_wp","_wpType","_waitForCode","_wpActionScript","_wpCondition","_wpTimeout","_wpStatementCondition","_wpStatementExpression"];
			{
				_group = _x;
				_lastWpRevision = _group getVariable ["AIC_Server_Last_Wp_Revision",0];
				_groupWaypoints = waypoints _group;
				_groupControlWaypoints = [_group] call AIC_fnc_getAllActiveWaypoints;
				_currentWpRevision = _groupControlWaypoints select 0;
				_groupControlWaypointArray = _groupControlWaypoints select 1;
				if( _currentWpRevision != _lastWpRevision) then {
					while {(count (waypoints _group)) > 0} do { 
						deleteWaypoint ((waypoints _group) select 0); 
					};
					private ["_priorWaypointDurationEnabled"];
					_priorWaypointDurationEnabled = false;
					{		
						if(!_priorWaypointDurationEnabled) then {
							_x params ["_wpIndex","_wpPosition","_wpDisabled",["_wpType","MOVE"],["_wpActionScript",""],["_wpCondition","true"],"_wpTimeout","_wpFormation","_wpCompletionRadius",["_wpDuration",0],"_wpLoiterRadius","_wpLoiterDirection"];
							if(_wpDuration > 0) then {
								_priorWaypointDurationEnabled = true;
							};
							_wp = _group addWaypoint [_x select 1, 0];
							
							_wpStatementCondition = format ["true && ((group this) getVariable ['AIC_WP_DURATION_REMANING',0]) <= 0 && {%1}",_wpCondition];
							_wpStatementExpression = "[group this, "+str (_x select 0)+"] call AIC_fnc_disableWaypoint;";
							
							if(_wpType == "SCRIPTED") then {
								// In case of a wp of type "SCRIPTED" the "wpActionScript" is the path of the waypoint script to use.
								_wp setWaypointScript _wpActionScript;
							} else {
								// For other wp types the "wpActionScript" is the waypoint statement expression.
								_wpStatementExpression = _wpStatementExpression + _wpActionScript;
							};
														
							_wp setWaypointStatements [_wpStatementCondition, _wpStatementExpression];
							
							_wp setWaypointType _wpType;
							if(!isNil "_wpTimeout") then {
								_wp setWaypointTimeout [_wpTimeout,_wpTimeout,_wpTimeout];
							}; 
							if(!isNil "_wpFormation") then {
								_wp setWaypointFormation _wpFormation;
							};
							if(!isNil "_wpCompletionRadius") then {
								_wp setWaypointCompletionRadius _wpCompletionRadius;
							};  
							if(!isNil "_wpLoiterRadius") then {
								_wp setWaypointLoiterRadius _wpLoiterRadius;
							};  
							if(!isNil "_wpLoiterDirection") then {
								_wp setWaypointLoiterType _wpLoiterDirection;
							};  
							
						};
					} forEach _groupControlWaypointArray;
					if(count (waypoints _group)==0) then {
						_group addWaypoint [position leader _group, 0];
					};
					_group setVariable ["AIC_Server_Last_Wp_Revision",_currentWpRevision];
				};
				
				private ["_nextActiveWaypoint"];
				if( count _groupControlWaypointArray > 0 ) then {
					_nextActiveWaypoint = _groupControlWaypointArray select 0;
					_nextActiveWaypoint params ["_wpIndex","_wpPosition","_wpDisabled",["_wpType","MOVE"],["_wpActionScript",""],["_wpCondition","true"],"_wpTimeout","_wpFormation","_wpCompletionRadius",["_wpDuration",0],"_wpLoiterRadius","_wpLoiterDirection"];
					if(_wpDuration > 0 && _group getVariable ["AIC_WP_DURATION_REMANING",0] <= 0) then {
						_group setVariable ["AIC_WP_DURATION_REMANING",_wpDuration];
					};
					if(_wpDuration <= 0 && _group getVariable ["AIC_WP_DURATION_REMANING",0] > 0) then {
						_group setVariable ["AIC_WP_DURATION_REMANING",0,true];
					};
					_group setVariable ["AIC_WP_DURATION_REMANING",(_group getVariable ["AIC_WP_DURATION_REMANING",0]) - 2,true];
					if(_wpDuration > 0 && _group getVariable ["AIC_WP_DURATION_REMANING",0] <= 0) then {
						_nextActiveWaypoint set [9,0];
						[_group, _nextActiveWaypoint] call AIC_fnc_setWaypoint;
					};
				};
				
			} forEach allGroups;
			sleep 2;
		};
	};
};

