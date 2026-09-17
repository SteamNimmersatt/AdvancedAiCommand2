#include "\z\aicommand2\addons\main\functions\functions.h"

/*
	Author: [SA] Duda

	Description:
	Initializes Command Menu Actions

	Parameter(s):
	None
		
	Returns: 
	Nothing
*/

AIC_fnc_hasVehicleAssigned = {
	params ["_groupControlId"];
	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _hasVehicleAssigned = (count ([_group] call AIC_fnc_getGroupAssignedVehicles) > 0);
	_hasVehicleAssigned;	
};

AIC_fnc_hasAircraftAssigned = {
	params ["_groupControlId"];
	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	
	private _hasAircraftAssigned = false;
	{
		if(_x isKindOf "Air") then {
			_hasAircraftAssigned = true;
		};
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);

	_hasAircraftAssigned;
};

AIC_fnc_isFlying = {
	params ["_groupControlId"];
	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	
	private _hasAircraftAssigned = call AIC_fnc_hasAircraftAssigned;
	
	if(!_hasAircraftAssigned) exitWith {
		false;
	};
	
	// Check if one one the units is above the ground
	private _isFlying = false;
	{
		private _isAboveGround = ((position _x) select 2) > 1;
		if(_isAboveGround) then {
			_isFlying = true;
		};
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	
	_isFlying;
};

AIC_fnc_hasGroupCargo = {
	params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_group getVariable ["AIC_Has_Group_Cargo",false];
};

AIC_fnc_isDefending = {
	params ["_groupControlId"];
	private "_group";
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	// Check both the group variable and missionNamespace (missionNamespace survives waypoint rebuilds)
	private _result = _group getVariable ["AIC_IsDefending", false] || { missionNamespace getVariable [format ["AIC_IsDefending_%1", groupId _group], false] };
	[AIC_LOGLEVEL_DEBUG, format ["isDefending check: group=%1, _groupControlId=%2, isDefending=%3", groupId _group, _groupControlId, _result]] call AIC_fnc_log;
	_result;
};

AIC_fnc_addWaypointsActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];

	// "_actionParams" optionally contains "_type" and "_label". When they are omitted
	// (the plain "Add Waypoints" entry) waypoints are placed as "MOVE", as before.
	// When they are given, every waypoint placed during this session gets that type
	// straight away, instead of having to re-open each waypoint to change it.
	_actionParams params [["_type","MOVE"],["_label","Move"]];

	AIC_fnc_setGroupControlAddWaypointType(_groupControlId,_type);
	AIC_fnc_setGroupControlAddingWaypoints(_groupControlId,true);

	if (_type != "MOVE") then {
		systemChat format ["[AAC2] - Placing '%1' waypoints. Every waypoint you add now uses this type. Right-click to finish.", _label];
	};
};

AIC_fnc_clearAllWaypointsActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	// Delete all waypoints (set state to "deleted") so they don't reappear when new waypoints are added
	private _waypoints = [_group] call AIC_fnc_getAllWaypoints;
	{
		[_group, _x select 0] call AIC_fnc_deleteWaypoint;
	} forEach (_waypoints select 1);
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
	hint ("All waypoints cleared");
};

AIC_fnc_setGroupCombatModeActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_actionParams params ["_mode","_modeLabel"];
	[_group,_mode] remoteExec ["setCombatMode", leader _group]; 
	hint ("Combat mode set to '" + _modeLabel + "'.");
};

AIC_fnc_forgetTargetsActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _leader = leader _group;
	private _targetsLeader = _leader targets []; // all targets the leader knows about
	
	// Forget all targets
	{
		_group forgetTarget _x;
	} forEach (_targetsLeader);
		
	hint ("Group forgot all targets!");
};

AIC_fnc_setGroupBehaviourActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_actionParams params ["_mode"];
	[_group,_mode] remoteExec ["setBehaviour", leader _group]; 
	hint ("Behaviour set to '" + _mode + "'.");
};

AIC_fnc_setGroupAutoCombatActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_actionParams params ["_mode"];
	if (_mode == "On") then {
		{_x enableAI "AUTOCOMBAT"} forEach (units _group);
	} else {
		{_x disableAI "AUTOCOMBAT"} forEach (units _group);
	};
	hint ("AutoCombat set to '" + _mode + "'.");
};

AIC_fnc_setGroupEnableAttackActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_actionParams params ["_mode"];
	if (_mode == "On") then {
		{_x enableAttack true} forEach (units _group);
	} else {
		{_x enableAttack false} forEach (units _group);
	};
	hint ("Autonomous attacking set to '" + _mode + "'.");
};
	
AIC_fnc_setGroupSpeedActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_actionParams params ["_speed","_label"];
	[_group,_speed] remoteExec ["setSpeedMode", leader _group]; 
	hint ("Speed set to " + _label);
};		

AIC_fnc_setGroupFormationActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_actionParams params ["_mode"];
	[_group,_mode] remoteExec ["setFormation", leader _group]; 
	hint ("Formation set to '" + _mode + "'.");
};

AIC_fnc_commandMenuIsAir = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_hasAir = false;
	{
		if(_x isKindOf "Air") then {
			_hasAir = true;
		};
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	_hasAir;
};

AIC_fnc_setFlyInHeightGroupActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	_actionParams params ["_mode"];
	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _title = ["Fly above ground (AGL)","Fly above sea (ASL)"] select (_mode == "ASL");

	// Show input dialog
	private _result = [_title] call AIC_fnc_showHeightInputDialog;
	if (_result < 0) exitWith {}; // cancelled

	{
		if(_x isKindOf "Air") then {
			[_x, _result, _mode] call AIC_fnc_applyFlyInHeight;
		};
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);

	private _unit = ["m AGL", "m ASL"] select (_mode == "ASL");
	hint ("Fly in height set to " + (str _result) + " " + _unit);
};

AIC_fnc_remoteViewActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_fromUnit","_rcUnit","_exitingRcUnit"];

	private _remoteControlActive = !isNull (missionNamespace getVariable ["AIC_Remote_Control_From_Unit",objNull]);
	if(_remoteControlActive) then {
		[] call AIC_fnc_terminateRemoteControl;
	};
	
	_fromUnit = missionNamespace getVariable ["AIC_Remote_View_From_Unit",objNull];
	if(isNull _fromUnit || !alive _fromUnit) then {
		_fromUnit = player;
		missionNamespace setVariable ["AIC_Remote_View_From_Unit",_fromUnit];
	};
	
	_rcUnit = leader _group;
	_exitingRcUnit = missionNamespace getVariable ["AIC_Remote_View_To_Unit",objNull];
	if(!isNull _exitingRcUnit) then {
		["MAIN_DISPLAY","KeyDown",(missionNamespace getVariable ["AIC_Remote_View_Delete_Handler",-1])] call AIC_fnc_removeEventHandler;
	};
	missionNamespace setVariable ["AIC_Remote_View_To_Unit",_rcUnit];

	AIC_Remote_View_From_Unit_Event_Handler = _fromUnit addEventHandler ["HandleDamage", "[] call AIC_fnc_terminateRemoteView; _this select 2;"];
	AIC_Remote_View_Delete_Handler = ["MAIN_DISPLAY","KeyDown", "if(_this select 1 == 211) then { [] call AIC_fnc_terminateRemoteView; }"] call AIC_fnc_addEventHandler;

	openMap false;
	
	[_rcUnit] call AIC_fnc_enable3rdPersonCamera;
	
	["RemoteControl",["","Press DELETE to Exit Remote View"]] call BIS_fnc_showNotification;
	
};

AIC_fnc_terminateRemoteView = {
	["MAIN_DISPLAY","KeyDown",(missionNamespace getVariable ["AIC_Remote_View_Delete_Handler",-1])] call AIC_fnc_removeEventHandler;
	(missionNamespace getVariable ["AIC_Remote_View_From_Unit",objNull]) removeEventHandler ["HandleDamage", (missionNamespace getVariable ["AIC_Remote_View_From_Unit_Event_Handler",-1])];
	missionNamespace setVariable ["AIC_Remote_View_To_Unit",nil];
	missionNamespace setVariable ["AIC_Remote_View_From_Unit",nil];
	[] call AIC_fnc_disable3rdPersonCamera;
	["RemoteControl",["","Remote View Terminated"]] call BIS_fnc_showNotification;
};

AIC_fnc_remoteControlActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_fromUnit","_rcUnit","_exitingRcUnit"];

	private _remoteViewActive = !isNull (missionNamespace getVariable ["AIC_Remote_View_From_Unit",objNull]);
	if(_remoteViewActive) then {
		[] call AIC_fnc_terminateRemoteView;
	};

	_fromUnit = missionNamespace getVariable ["AIC_Remote_Control_From_Unit",objNull];
	if(isNull _fromUnit || !alive _fromUnit) then {
		_fromUnit = player;
		missionNamespace setVariable ["AIC_Remote_Control_From_Unit",_fromUnit];
	};
	
	_rcUnit = leader _group;
	if(!alive _rcUnit) exitWith {
		["RemoteControl",["","Remote Control Failed: Not Alive"]] call BIS_fnc_showNotification;
	};
	_exitingRcUnit = missionNamespace getVariable ["AIC_Remote_Control_To_Unit",objNull];
	if(!isNull _exitingRcUnit) then {
		_exitingRcUnit removeEventHandler ["HandleDamage", (missionNamespace getVariable ["AIC_Remote_Control_To_Unit_Event_Handler",-1])];
		["MAIN_DISPLAY","KeyDown",(missionNamespace getVariable ["AIC_Remote_Control_Delete_Handler",-1])] call AIC_fnc_removeEventHandler;
	};
	missionNamespace setVariable ["AIC_Remote_Control_To_Unit",_rcUnit];

	AIC_Remote_Control_From_Unit_Event_Handler = _fromUnit addEventHandler ["HandleDamage", "[] call AIC_fnc_terminateRemoteControl; _this select 2;"];
	AIC_Remote_Control_To_Unit_Event_Handler = _rcUnit addEventHandler ["HandleDamage", "[] call AIC_fnc_terminateRemoteControl; _this select 2;"];
	AIC_Remote_Control_Delete_Handler = ["MAIN_DISPLAY","KeyDown", "if(_this select 1 == 211) then { [] call AIC_fnc_terminateRemoteControl; }"] call AIC_fnc_addEventHandler;
	
	// Disable effects (which might be active for the player at the time)
	// DISABLED_BIS_fnc_feedback_allowPP = false; // TODO causes a warning, disabled for now
	
	selectPlayer _rcUnit;
	(vehicle _rcUnit) switchCamera "External";
	openMap false;
	
	["RemoteControl",["","Press DELETE to Exit Remote Control"]] call BIS_fnc_showNotification;
};

AIC_fnc_terminateRemoteControl = {
	["MAIN_DISPLAY","KeyDown",(missionNamespace getVariable ["AIC_Remote_Control_Delete_Handler",-1])] call AIC_fnc_removeEventHandler;
	(missionNamespace getVariable ["AIC_Remote_Control_From_Unit",objNull]) removeEventHandler ["HandleDamage", (missionNamespace getVariable ["AIC_Remote_Control_From_Unit_Event_Handler",-1])];
	(missionNamespace getVariable ["AIC_Remote_Control_To_Unit",objNull]) removeEventHandler ["HandleDamage", (missionNamespace getVariable ["AIC_Remote_Control_To_Unit_Event_Handler",-1])];
	missionNamespace setVariable ["AIC_Remote_Control_To_Unit",nil];
	selectPlayer (missionNamespace getVariable ["AIC_Remote_Control_From_Unit",player]);
	missionNamespace setVariable ["AIC_Remote_Control_From_Unit",nil];
	(vehicle player) switchCamera cameraView;

	// Enable effects again
	// DISABLED_BIS_fnc_feedback_allowPP = true; // TODO causes a warning, disabled for now

	["RemoteControl",["","Remote Control Terminated"]] call BIS_fnc_showNotification;
};

AIC_fnc_setGroupColorActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_actionParams params ["_color"];
	[_group,_color] call AIC_fnc_setGroupColor;
	AIC_fnc_setGroupControlColor(_groupControlId,_color);
	[_groupControlId,"REFRESH_GROUP_ICON",[]] call AIC_fnc_groupControlEventHandler;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
	[_groupControlId,"REFRESH_ACTIONS",[]] call AIC_fnc_groupControlEventHandler;
	hint ("Color set to '" + (_color select 0) + "'.");
};

AIC_fnc_renameGroupActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	[_group] spawn AIC_fnc_showRenameGroupDialog;
};

AIC_fnc_joinGroupActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_selectedGroup"];
	_selectedGroup = [_groupControlId] call AIC_fnc_selectGroupControlGroup;
	if(!isNull _selectedGroup) then {
		(units _group) joinSilent _selectedGroup;
		hint ("Selected Group Joined");
	} else {
		hint ("No Group Selected");
	};
};

AIC_fnc_splitGroupHalfActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];

	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _units = units _group;

	if (count _units < 2) exitWith {
		hint "This group is too small to be split.";
	};

	private _newGroup = createGroup [side _group, true];
	if (isNull _newGroup) exitWith {
		hint "Could not create a new group. The group limit for this side has been reached.";
		[AIC_LOGLEVEL_ERROR, "AIC_fnc_splitGroupHalfActionHandler - createGroup returned grpNull."] call AIC_fnc_log;
	};

	// Collect the command controls the original group belongs to, so the new half can
	// be registered with them right away (same as when splitting into individual units).
	// Without this the new group only becomes commandable once the server's polling loop
	// happens to pick it up, which is why half the squad appeared to be lost.
	private _commandControls = AIC_fnc_getCommandControls();
	private _commandControlsToUpdate = [];
	{
		private _commandControlId = _x;
		private _groups = AIC_fnc_getCommandControlGroups(_commandControlId);
		if (_group in _groups) then {
			_commandControlsToUpdate pushBack _commandControlId;
		};
	} forEach _commandControls;

	// Move every second unit into the new group. Index 0 is the group leader, so the
	// original group keeps its leader and both halves end up roughly the same size.
	private _unitsToMove = [];
	{
		if (_forEachIndex mod 2 == 1) then {
			_unitsToMove pushBack _x;
		};
	} forEach _units;
	_unitsToMove joinSilent _newGroup;

	// Carry over the parent group's AAC2 colour and stance so the new half keeps
	// behaving the same way until it is given orders of its own.
	[_newGroup, [_group] call AIC_fnc_getGroupColor] call AIC_fnc_setGroupColor;
	_newGroup setBehaviour (behaviour (leader _group));
	_newGroup setCombatMode (combatMode _group);

	{
		[_x, _newGroup] call AIC_fnc_commandControlAddGroup;
	} forEach _commandControlsToUpdate;

	hint format ["Group split in half. New group: %1", groupId _newGroup];
};

AIC_fnc_splitGroupUnitsActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _groupColor = [_group] call AIC_fnc_getGroupColor;
	private _groupBehaviour = behaviour (leader _group);
	private _groupCombatMode = combatMode _group;

	// Find all command controls to update with new split groups
	private _commandControlsToUpdate = [];
	private _commandControls = AIC_fnc_getCommandControls();
	{
		private _commandControlId = _x;
		private _groups = AIC_fnc_getCommandControlGroups(_commandControlId);
		if(_group in _groups) then {
			_commandControlsToUpdate pushBack _commandControlId;
		};
	} forEach _commandControls;

	{
		private _unit = _x;
		private _newGroup = createGroup [side _unit, true];
		if (isNull _newGroup) exitWith {
			hint "Could not create a new group. The group limit for this side has been reached.";
			[AIC_LOGLEVEL_ERROR, "AIC_fnc_splitGroupUnitsActionHandler - createGroup returned grpNull."] call AIC_fnc_log;
		};
		[_unit] joinSilent _newGroup;

		// Carry over the parent group's AAC2 colour and stance.
		[_newGroup, _groupColor] call AIC_fnc_setGroupColor;
		_newGroup setBehaviour _groupBehaviour;
		_newGroup setCombatMode _groupCombatMode;

		{
			[_x,_newGroup] call AIC_fnc_commandControlAddGroup;
		} forEach _commandControlsToUpdate;
	} forEach (units _group);

	hint ("Group Split into Individual Units");

};

AIC_fnc_assignVehicleActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_selectedVehicle"];
	_selectedVehicle = [_groupControlId] call AIC_fnc_selectGroupControlVehicle;
	if(!isNull _selectedVehicle) then {
		private ["_vehicleName","_assignedVehicles","_vehicleSlotsToAssign","_maxSlots","_vehicleRoles"];
		private ["_unitIndex","_countOfSlots","_vehicleToAssign"];
		[_group,_selectedVehicle] remoteExec ["addVehicle", leader _group];
		_assignedVehicles = [_group] call AIC_fnc_getGroupAssignedVehicles;
		_assignedVehicles pushBack _selectedVehicle;
		[_group,_assignedVehicles] call AIC_fnc_setGroupAssignedVehicles;
		_vehicleSlotsToAssign = [];
		_maxSlots = 0;
		{
			_vehicleRoles = [_x] call BIS_fnc_vehicleRoles;
			if(count _vehicleRoles > _maxSlots) then {
				_maxSlots = count _vehicleRoles;
			};
		} forEach _assignedVehicles;
		if(_maxSlots > 0) then {
			for "_i" from 0 to (_maxSlots-1) do {
				{
					_vehicleRoles = [_x] call BIS_fnc_vehicleRoles;
					if(count _vehicleRoles > _i) then {
						_vehicleSlotsToAssign pushBack [_x,_vehicleRoles select _i];
					};
				} forEach _assignedVehicles;
			};
		};
		_unitIndex = 0;
		_countOfSlots = count _vehicleSlotsToAssign;
		{
			if(_countOfSlots > _unitIndex) then {
				_vehicleToAssign = (_vehicleSlotsToAssign select _unitIndex) select 0;
				_role = (_vehicleSlotsToAssign select _unitIndex) select 1;
				[_x,_vehicleToAssign,_role] remoteExec ["AIC_fnc_getInVehicle", _x];
			};
			_unitIndex = _unitIndex + 1;
		} forEach (units _group);
		if(_selectedVehicle isKindOf "Air") then {
			[_selectedVehicle,100] remoteExec ["flyInHeight", _selectedVehicle]; 
		};
	_vehicleName = getText (configOf _selectedVehicle >> "displayName");
		hint ("Vehicle assigned: " + _vehicleName);
	} else {
		hint ("No vehicle assigned");
	};
};

AIC_fnc_unassignVehicleActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	{
		[_group,_x] remoteExec ["leaveVehicle", leader _group];
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	[_group,nil] call AIC_fnc_setGroupAssignedVehicles;
	hint ("All vehicles unassigned");
};

AIC_fnc_unloadOtherGroupsActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_vehicle","_unloadedGroups","_assignedVehicles"];
	_unloadedGroups = [];
	{
		_vehicle = _x;
		{
			if(group _x != _group) then {
				if!(group _x in _unloadedGroups) then {
					[group _x, _vehicle] remoteExec ["leaveVehicle", leader group _x];
					_unloadedGroups pushBack (group _x);
					_assignedVehicles = [group _x] call AIC_fnc_getGroupAssignedVehicles;
					_assignedVehicles = _assignedVehicles - [_vehicle];
					[group _x,_assignedVehicles] call AIC_fnc_setGroupAssignedVehicles;
				};
			};
		} forEach (crew _vehicle);
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	hint ((str count _unloadedGroups) + " other group(s) unloaded");
};

landActionScript = "
private _msgSent = false;
{
    private _vehicle = vehicle _x;
	if (_vehicle isKindOf 'Air') then {
        if (!_msgSent) then {
            [(group this), 'Landing now.'] call AIC_fnc_msgSideChat;
            _msgSent = true;
        };
        _vehicle land 'LAND';
    };
} forEach (units (group this));
";

AIC_fnc_landNowNearbyActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_selectedPosition"];
	_selectedPosition = [_groupControlId] call AIC_fnc_selectGroupControlPosition;
	if(count _selectedPosition > 0) then {
		_hasAir = false;
		{
			if(_x isKindOf "Air") then {
				_hasAir = true;
			};
		} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
		if(_hasAir) then {
		
			// Remove all waypoints
			[_group] call AIC_fnc_disableAllWaypoints;
			
			// Forget targets (we want to land now!)
			private _leader = leader _group;
			private _targetsLeader = _leader targets [];

			{
				_group forgetTarget _x;
			} forEach (_targetsLeader);
			
			[_group, 'Moving to landing zone.'] call AIC_fnc_msgSideChat;
			// The state must be a state constant, not the boolean the old scheme used -
			// downstream code compares it against strings and throws on a boolean.
			private _landWaypoint = [_group, [nil, _selectedPosition, AIC_Waypoint_State_Active, "MOVE", landActionScript]] call AIC_fnc_addWaypoint;
			// fn_addWaypoint deliberately leaves the revision alone, so bump it here: the
			// disableAllWaypoints call above only bumps when the group had waypoints to
			// disable, and without a bump the server never rebuilds and never lands.
			[_group, _landWaypoint] call AIC_fnc_setWaypoint;
			
			// Refresh/Redraw waypoints
			[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
		};
	};
};

AIC_fnc_landNowPreciseActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_selectedPosition"];
	_selectedPosition = [_groupControlId] call AIC_fnc_selectGroupControlPosition;
	if(count _selectedPosition > 0) then {
		_hasAir = false;
		{
			if(_x isKindOf "Air") then {
				_hasAir = true;
			};
		} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
		if(_hasAir) then {
		
			// Remove all waypoints
			[_group] call AIC_fnc_disableAllWaypoints;
			
			// Forget targets (we want to land now!)
			private _leader = leader _group;
			private _targetsLeader = _leader targets [];
			{
				_group forgetTarget _x;
			} forEach (_targetsLeader);
			
			// Create invisible landing pad
			private _pad = "Land_HelipadEmpty_F" createVehicle _selectedPosition;
			
			[_group, 'Moving to landing zone.'] call AIC_fnc_msgSideChat;
			// The state must be a state constant, not the boolean the old scheme used -
			// downstream code compares it against strings and throws on a boolean.
			private _landWaypoint = [_group, [nil, _selectedPosition, AIC_Waypoint_State_Active, "MOVE", landActionScript]] call AIC_fnc_addWaypoint;
			// fn_addWaypoint deliberately leaves the revision alone, so bump it here: the
			// disableAllWaypoints call above only bumps when the group had waypoints to
			// disable, and without a bump the server never rebuilds and never lands.
			[_group, _landWaypoint] call AIC_fnc_setWaypoint;
			
			// Refresh/Redraw waypoints
			[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
		};
	};
};

AIC_fnc_rappelActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_selectedPosition"];
	_selectedPosition = [_groupControlId] call AIC_fnc_selectGroupControlPosition;
	if(count _selectedPosition > 0) then {
		{
			if(_x isKindOf "Helicopter") then {
				[_x,25,AGLToASL [_selectedPosition select 0, _selectedPosition select 1, 0]] call AR_Rappel_All_Cargo;
			};
		} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
		[_group] spawn {
			params ["_groupRappelling"];
			_unitsInVehicle = true;
			while {_unitsInVehicle} do {
				_unitsInVehicle = false;
				{
					private _isVehicle = !isNull objectParent _x;
					if(_isVehicle) then {
						_unitsInVehicle = true;
					};
				} forEach (units _groupRappelling);
				sleep 1;
			};
			[_groupRappelling] call AIC_fnc_unassignVehicleActionHandler;
		};
	};
};

AIC_fnc_deleteWaypointHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	[_group,_waypointId] call AIC_fnc_deleteWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
};

AIC_fnc_setWaypointFormationActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];
	private ["_group","_waypoint"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	_actionParams params ["_mode"];
	_waypoint set [AIC_Waypoint_ArrayIndex_Formation,_mode];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
	hint ("Formation set to '" + _mode + "'.");
};
								
AIC_fnc_setWaypointTypeActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];

	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;

	// "_actionParams" contains "_type", "_label" and optionally "_note" (an extra
	// explanation shown in side chat for waypoint types whose behaviour is not obvious)
	_actionParams params ["_type",["_label", "ERROR LABEL UNDEFINED!"],["_note",""]];

	_waypoint set [AIC_Waypoint_ArrayIndex_Type,_type];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;

	hint ("Type set to '" + _label + "'.");

	if (_note != "") then {
		systemChat ("[AAC2] - " + _note);
	};
};

/*
	Sets a waypoint to "CYCLE", which turns the group's waypoints into an endless patrol.

	AAC2 normally disables each waypoint once the group has reached it. That would take
	the loop apart after a single pass, so fn_commandControlManager keeps every waypoint
	of a group active for as long as one of them is a cycle waypoint. The patrol then
	runs until the player issues new orders, which rebuilds the waypoint list as usual.
*/
AIC_fnc_setWaypointTypeCycleActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];

	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;

	_waypoint set [AIC_Waypoint_ArrayIndex_Type, "CYCLE"];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;

	hint "Type set to 'Cycle'.";

	// Count every waypoint that still exists — waypoints being placed right now are
	// "drafted" rather than "active", so getAllActiveWaypoints would under-count here.
	private _waypointCount = count ((([_group] call AIC_fnc_getAllWaypoints) select 1) select {
		(_x select AIC_Waypoint_ArrayIndex_State) != AIC_Waypoint_State_Deleted
	});
	if (_waypointCount < 2) then {
		systemChat "[AAC2] - A cycle waypoint needs at least one other waypoint to loop back to. Place it next to the waypoint the patrol should return to.";
	} else {
		systemChat "[AAC2] - Cycle waypoint set. The group patrols its waypoints until you give it new orders.";
	};
};

AIC_fnc_setDefendWpTypeActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];

	_actionParams params [["_type", "DEFEND"], ["_label", "Defend / Garrison"]];
	
	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	_waypoint set [AIC_Waypoint_ArrayIndex_Type, _type];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId, "REFRESH_WAYPOINTS", []] call AIC_fnc_groupControlEventHandler;
	
	// Show the defend dialog, then finalize the waypoint parameters in the callback
	private _callback = {
		params ["_radius", "_threshold", "_patrolChance", "_holdChance"];
		
		private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
		private _waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
		
		// Store defend parameters in the waypoint's statement field as a parseable string
		// Format: "DEFEND_PARAMS:radius:threshold:patrol:hold"
		// This is read by fn_commandControlManager when building the Arma waypoint
		_waypoint set [AIC_Waypoint_ArrayIndex_Statement, format ["DEFEND_PARAMS:%1:%2:%3:%4", _radius, _threshold, _patrolChance, _holdChance]];
		_waypoint set [AIC_Waypoint_ArrayIndex_Type, _type];
		[_group, _waypoint] call AIC_fnc_setWaypoint;
		[_groupControlId, "REFRESH_WAYPOINTS", []] call AIC_fnc_groupControlEventHandler;
		
		hint format ["Type set to '%1' (Radius: %2m, Threshold: %3, Patrol: %4%%, Hold: %5%%)", _label, _radius, _threshold, _patrolChance, _holdChance];
	};
	
	[_callback] call AIC_fnc_showDefendDialog;
};

AIC_fnc_setWaypointTypeUnloadActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];

	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;

	// "_actionParams" contains "_wpType", "_label" and optionally "_createHeliPad"
	_actionParams params ["_wpType",["_label", "ERROR LABEL UNDEFINED!"], ["_createHeliPad", false]];

	if (_createHeliPad) then {
		[AIC_LOGLEVEL_DEBUG, "AIC_fnc_setWaypointTypeActionHandler - Creating helipad at waypoint position."] call AIC_fnc_log;
		private _wpPosition = _waypoint select AIC_Waypoint_ArrayIndex_Position;
		private _pad = "Land_HelipadEmpty_F" createVehicle _wpPosition;
	};

	// TODO
	switch (_wpType) do {
		case "GETOUT": {  
			// TODO: Unassign vehicles
		};
		case "UNLOAD": { hint "two"; };
		default { };
	};



	_waypoint set [AIC_Waypoint_ArrayIndex_Type,_wpType];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;

	hint ("Waypoint type set to '" + _label + "'.");
};

AIC_fnc_setWaypointTypeLandNearbyActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];
	private ["_group","_waypoint"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	_actionParams params ["_label"];
	_waypoint set [AIC_Waypoint_ArrayIndex_Type,"MOVE"];
	_waypoint set [AIC_Waypoint_ArrayIndex_Statement,landActionScript];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
	hint ("Type set to '" + _label + "'.");
};

AIC_fnc_setWaypointTypeLandPreciseActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];
	private ["_group","_waypoint"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	_actionParams params ["_label"];
	_waypoint set [AIC_Waypoint_ArrayIndex_Type, "MOVE"];
	_waypoint set [AIC_Waypoint_ArrayIndex_Statement, landActionScript];
	
	// Create invisible landing pad
	private _waypointPosition = _waypoint select 1;
	_pad = "Land_HelipadEmpty_F" createVehicle _waypointPosition;
	
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
	hint ("Type set to '" + _label + "'.");
};

AIC_fnc_setWaypointAttackActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];

	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	_waypoint set [AIC_Waypoint_ArrayIndex_Type, "ATTACK"];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId, "REFRESH_WAYPOINTS", []] call AIC_fnc_groupControlEventHandler;

	// Show radius dialog (blocks until user confirms or cancels)
	private _radius = ["Enter Attack Radius"] call AIC_fnc_showRadiusInputDialog;
	if (_radius <= 0) exitWith {
		// User cancelled — waypoint remains disabled (was never enabled).
		// The waypoint type stays ATTACK but won't execute because it's still disabled.
		[AIC_LOGLEVEL_DEBUG, "AIC_fnc_setWaypointAttackActionHandler - User cancelled radius input."] call AIC_fnc_log;
	};

	// User confirmed — finalize the waypoint with the chosen radius
	_waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	_waypoint set [AIC_Waypoint_ArrayIndex_Type, "ATTACK"];
	_waypoint set [AIC_Waypoint_ArrayIndex_CompletionRadius, _radius];
	_waypoint set [AIC_Waypoint_ArrayIndex_Statement, ""];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;

	hint ("Type set to 'Attack' at " + str _radius + " meter radius");
};

AIC_fnc_setLoiterTypeActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];
	_actionParams params ["_radius","_clockwise"];
	private ["_group","_waypoint"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	_waypoint set [AIC_Waypoint_ArrayIndex_Type, "LOITER"];
	_waypoint set [AIC_Waypoint_ArrayIndex_LoiterRadius,_radius];
	if(_clockwise) then {
		_waypoint set [AIC_Waypoint_ArrayIndex_LoiterDirection,"CIRCLE"];
	} else {
		_waypoint set [AIC_Waypoint_ArrayIndex_LoiterDirection,"CIRCLE_L"];
	};
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
	private _loiterTypeLabel = "loiter clockwise";
	if(!_clockwise) then {
		_loiterTypeLabel = "loiter counter clockwise";
	};
	hint ("Type set to " + _loiterTypeLabel + " at " + str _radius + " meter radius");
};



/*
	WP Type "Unload"
*/

private _labelUnloadSubMenu = "Unload / Drop off";
private _labelUnloadSubSubMenuLandingNearby = "Land & Unload nearby (spot within 500m)";
private _labelUnloadSubSubMenuLandingPrecicely = "Land & Unload precicely";
private _labelUnloadGroupCrewAndPassenger = "Unload this groups crew & passengers";
private _labelUnloadGroupPassengers = "Unload this groups passengers";
private _labelUnloadOtherGroupPassengers = "Unload other groups passengers (not crew positions)";


/*
	WP Type "Land"
*/
private _labelLandNearby = "Land nearby (search spot within 500m)";
private _labelLandPrecise = "Land precisely (as close as possible)";


/*
	Labels and side-chat explanations for the additional waypoint types.
	See https://community.bistudio.com/wiki/Waypoint_types
*/
private _labelWpSentry = "Sentry (wait, then engage on contact)";
private _noteWpSentry = "Sentry: the group holds at the waypoint until it identifies an enemy, then engages and continues.";
private _labelWpGuard = "Guard (take over a guard point)";
private _noteWpGuard = "Guard: the group takes over the nearest free guard point, otherwise it holds this position.";
private _labelWpDismiss = "Dismiss (stand down, react on contact)";
private _noteWpDismiss = "Dismiss: the group relaxes and wanders around the waypoint, but forms up again as soon as it makes contact.";
private _labelWpCycle = "Cycle (loop waypoints as a patrol)";


/*
	WP Type "Loiter"
*/

// Wrapper for both AGL and ASL fly-in height — used as completion-statement snippet
// in fn_commandControlManager.sqf (which embeds this function name as a string).
// Internally calls AIC_fnc_applyFlyInHeight, which runs on the vehicle's owning machine.
AIC_fnc_setWaypointFlyInHeightActionHandlerScript = {
	params ["_group","_height",["_mode","ASL"]];
	{
		if(_x isKindOf "Air") then {
			[_x, _height, _mode] call AIC_fnc_applyFlyInHeight;
		};
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
};

AIC_fnc_setWaypointFlyInHeightActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];
	_actionParams params ["_mode"];
	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	private _title = ["Fly above ground (AGL)","Fly above sea (ASL)"] select (_mode == "ASL");

	// Show input dialog
	private _result = [_title] call AIC_fnc_showHeightInputDialog;
	if (_result < 0) exitWith {}; // cancelled

	if (_mode == "AGL") then {
		_waypoint set [AIC_Waypoint_ArrayIndex_FlyInHeightAsl, nil];
		_waypoint set [AIC_Waypoint_ArrayIndex_FlyInHeight, _result];
	} else {
		_waypoint set [AIC_Waypoint_ArrayIndex_FlyInHeight, nil];
		_waypoint set [AIC_Waypoint_ArrayIndex_FlyInHeightAsl, _result];
	};
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;

	// Apply altitude to aircraft immediately
	[_group, _result, _mode] call AIC_fnc_setWaypointFlyInHeightActionHandlerScript;

	private _unit = ["m AGL", "m ASL"] select (_mode == "ASL");
	hint ("Waypoint fly in height set to " + (str _result) + " " + _unit);
};

AIC_fnc_setWaypointDurationActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];
  _actionParams params ["_duration"];
	private ["_group","_waypoint"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	_waypoint set [AIC_Waypoint_ArrayIndex_Duration, _duration * 60];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	hint ("Waypoint duration set to " + (str _duration) + " mins");
};

/* 
    Menu "GROUP" (which opens when a user clicks on a group icon)
*/

["GROUP","Cancel Defend / Garrison",[],AIC_fnc_cancelDefendActionHandler,[],AIC_fnc_isDefending] call AIC_fnc_addCommandMenuAction;

// Add Waypoints
["GROUP","Add Waypoints",[],AIC_fnc_addWaypointsActionHandler] call AIC_fnc_addCommandMenuAction;

// Add Waypoints of a given type directly, without having to re-open every waypoint
// afterwards to change its type ("Add Advanced WP", requested in issue #27).
["GROUP","Move",["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["MOVE","Move"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Seek & Destroy",["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["SAD","Seek & Destroy"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Hold",["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["HOLD","Hold"]] call AIC_fnc_addCommandMenuAction;
["GROUP",_labelWpSentry,["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["SENTRY","Sentry"]] call AIC_fnc_addCommandMenuAction;
["GROUP",_labelWpGuard,["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["GUARD","Guard"]] call AIC_fnc_addCommandMenuAction;
["GROUP",_labelWpDismiss,["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["DISMISS","Dismiss"]] call AIC_fnc_addCommandMenuAction;
["GROUP",_labelWpCycle,["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["CYCLE","Cycle"]] call AIC_fnc_addCommandMenuAction;

// Clear all waypoints
["GROUP","Confirm Clear All",["Clear All Waypoints"],AIC_fnc_clearAllWaypointsActionHandler] call AIC_fnc_addCommandMenuAction;

//
// "Tactical" Submenu
//

["GROUP","Forget all current targets",["Tactical"],AIC_fnc_forgetTargetsActionHandler] call AIC_fnc_addCommandMenuAction;

// Combat Mode
["GROUP","BLUE - Never Fire, Disengage",["Tactical","Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["BLUE","Never Fire, Disengage"]] call AIC_fnc_addCommandMenuAction;
["GROUP","GREEN - Hold Fire, Disengage",["Tactical","Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["GREEN","Hold Fire, Disengage"]] call AIC_fnc_addCommandMenuAction;
["GROUP","WHITE - Hold Fire, Engage At Will",["Tactical","Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["WHITE","Hold Fire, Engage At Will"]] call AIC_fnc_addCommandMenuAction;
["GROUP","YELLOW - Fire At Will, Disengage (Default)",["Tactical","Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["YELLOW","Fire At Will, Disengage"]] call AIC_fnc_addCommandMenuAction;
["GROUP","RED - Fire At Will, Engage At Will",["Tactical","Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["RED","Fire At Will, Engage At Will"]] call AIC_fnc_addCommandMenuAction;

// Behaviour
["GROUP","Careless",["Tactical","Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["CARELESS"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Safe",["Tactical","Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["SAFE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Aware",["Tactical","Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["AWARE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Combat",["Tactical","Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["COMBAT"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Stealth",["Tactical","Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["STEALTH"]] call AIC_fnc_addCommandMenuAction;
["GROUP","On",["Tactical","Behaviour","Leader can issue attack (default=on)"],AIC_fnc_setGroupEnableAttackActionHandler,["On"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Off",["Tactical","Behaviour","Leader can issue attack (default=on)"],AIC_fnc_setGroupEnableAttackActionHandler,["Off"]] call AIC_fnc_addCommandMenuAction;
["GROUP","On",["Tactical","Behaviour","Auto switch to Combat Mode (default=on)"],AIC_fnc_setGroupAutoCombatActionHandler,["On"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Off",["Tactical","Behaviour","Auto switch to Combat Mode (default=on)"],AIC_fnc_setGroupAutoCombatActionHandler,["Off"]] call AIC_fnc_addCommandMenuAction;

// Formation
["GROUP","Column",["Tactical","Formation"],AIC_fnc_setGroupFormationActionHandler,["COLUMN"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Stag. Column",["Tactical","Formation"],AIC_fnc_setGroupFormationActionHandler,["STAG COLUMN"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Wedge",["Tactical","Formation"],AIC_fnc_setGroupFormationActionHandler,["WEDGE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Echelon Left",["Tactical","Formation"],AIC_fnc_setGroupFormationActionHandler,["ECH LEFT"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Echelon Right",["Tactical","Formation"],AIC_fnc_setGroupFormationActionHandler,["ECH RIGHT"]] call AIC_fnc_addCommandMenuAction;
["GROUP","V",["Tactical","Formation"],AIC_fnc_setGroupFormationActionHandler,["VEE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Line",["Tactical","Formation"],AIC_fnc_setGroupFormationActionHandler,["LINE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","File",["Tactical","Formation"],AIC_fnc_setGroupFormationActionHandler,["FILE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Diamond",["Tactical","Formation"],AIC_fnc_setGroupFormationActionHandler,["DIAMOND"]] call AIC_fnc_addCommandMenuAction;

// Speed
["GROUP","Half Speed",["Tactical","Speed"],AIC_fnc_setGroupSpeedActionHandler,["LIMITED", "Half Speed"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Full Speed (In Formation)",["Tactical","Speed"],AIC_fnc_setGroupSpeedActionHandler,["NORMAL", "Full Speed (In Formation)"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Full (No Formation)",["Tactical","Speed"],AIC_fnc_setGroupSpeedActionHandler,["FULL", "Full (No Formation)"]] call AIC_fnc_addCommandMenuAction;

//
// "Group" Submenu
//

// Remote View & Control
["GROUP","Remote View",["Group","Remote"],AIC_fnc_remoteViewActionHandler,[],{
	params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_canControl"];
	_canControl = false;
	if(player != leader _group) then {
		_canControl = true;
	};
	_canControl;
}] call AIC_fnc_addCommandMenuAction;

["GROUP","Remote Control",["Group","Remote"],AIC_fnc_remoteControlActionHandler,[],{
	params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private ["_canControl"];
	_canControl = true;
	if(!alive leader _group) then {
		_canControl = false;
	};
	if(isPlayer leader _group) then {
		_canControl = false;
	};
	_canControl;
}] call AIC_fnc_addCommandMenuAction;

// Color
["GROUP","Red",["Group","Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_RED]] call AIC_fnc_addCommandMenuAction;
["GROUP","Green",["Group","Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_GREEN]] call AIC_fnc_addCommandMenuAction;
["GROUP","Blue",["Group","Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_BLUE]] call AIC_fnc_addCommandMenuAction;
["GROUP","Yellow",["Group","Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_YELLOW]] call AIC_fnc_addCommandMenuAction;
["GROUP","Purple",["Group","Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_PURPLE]] call AIC_fnc_addCommandMenuAction;
["GROUP","Pink",["Group","Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_PINK]] call AIC_fnc_addCommandMenuAction;
["GROUP","Cyan",["Group","Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_CYAN]] call AIC_fnc_addCommandMenuAction;
["GROUP","Black",["Group","Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_BLACK]] call AIC_fnc_addCommandMenuAction;
["GROUP","White",["Group","Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_WHITE]] call AIC_fnc_addCommandMenuAction;

// Rename Group
["GROUP","Rename Group",["Group"],AIC_fnc_renameGroupActionHandler] call AIC_fnc_addCommandMenuAction;

// Join / Split Group
["GROUP","Join A Group",["Group","Join / Split Group"],AIC_fnc_joinGroupActionHandler,[]] call AIC_fnc_addCommandMenuAction;
["GROUP","In Half",["Group","Join / Split Group","Split Group"],AIC_fnc_splitGroupHalfActionHandler,[],{
	params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	count units _group > 1;
}] call AIC_fnc_addCommandMenuAction;
["GROUP","Into Individual Units",["Group","Join / Split Group","Split Group"],AIC_fnc_splitGroupUnitsActionHandler,[],{
	params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	count units _group > 1;
}] call AIC_fnc_addCommandMenuAction;

//
// "Vehicle" Submenu
//

// Assign Vehicle
["GROUP","Assign Vehicle",["Vehicle Actions"],AIC_fnc_assignVehicleActionHandler,[]] call AIC_fnc_addCommandMenuAction;
["GROUP","Unassign All Vehicle(s)",["Vehicle Actions"],AIC_fnc_unassignVehicleActionHandler,[],AIC_fnc_hasVehicleAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","Unload Other Group(s)",["Vehicle Actions"],AIC_fnc_unloadOtherGroupsActionHandler,[],AIC_fnc_hasGroupCargo] call AIC_fnc_addCommandMenuAction;

// Fly in Height
["GROUP","Fly above ground (AGL)...",["Vehicle Actions", "Fly in Height"],AIC_fnc_setFlyInHeightGroupActionHandler,["AGL"],AIC_fnc_commandMenuIsAir] call AIC_fnc_addCommandMenuAction;
["GROUP","Fly above sea (ASL)...",["Vehicle Actions", "Fly in Height"],AIC_fnc_setFlyInHeightGroupActionHandler,["ASL"],AIC_fnc_commandMenuIsAir] call AIC_fnc_addCommandMenuAction;

// Land
["GROUP","Land nearby (search spot within 500m)",["Vehicles","Land now"],AIC_fnc_landNowNearbyActionHandler,[],AIC_fnc_isFlying] call AIC_fnc_addCommandMenuAction;
["GROUP","Land precisely (as close as possible)",["Vehicles","Land now"],AIC_fnc_landNowPreciseActionHandler,[],AIC_fnc_isFlying] call AIC_fnc_addCommandMenuAction;

// Rappel
["GROUP","Rappel Other Group(s)",["Vehicle Actions"],AIC_fnc_rappelActionHandler,[],{
	params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_hasAir = false;
	{
		if(_x isKindOf "Helicopter") then {
			if(((position _x) select 2) > 1) then {
				_hasAir = true;
			};
		};
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	_hasAir && (_group getVariable ["AIC_Has_Group_Cargo",false]) && !isNil "AR_RAPPELLING_INIT";	
}] call AIC_fnc_addCommandMenuAction;


/*
	Menu "WAYPOINT" (which opens when a user clicks on a waypoint icon)
*/

// Add more Waypoints
["WAYPOINT","Add Waypoints",[],AIC_fnc_addWaypointsActionHandler] call AIC_fnc_addCommandMenuAction;

// Add more Waypoints of a given type (see the identical GROUP menu entries above)
["WAYPOINT","Move",["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["MOVE","Move"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Seek & Destroy",["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["SAD","Seek & Destroy"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Hold",["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["HOLD","Hold"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelWpSentry,["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["SENTRY","Sentry"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelWpGuard,["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["GUARD","Guard"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelWpDismiss,["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["DISMISS","Dismiss"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelWpCycle,["Add Waypoints (Advanced)"],AIC_fnc_addWaypointsActionHandler,["CYCLE","Cycle"]] call AIC_fnc_addCommandMenuAction;

// Set WP Type (General)
["WAYPOINT","Move (default)",["Set Waypoint Type"],AIC_fnc_setWaypointTypeActionHandler,["MOVE","'Move'"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Attack (CBA)",["Set Waypoint Type","Offensive WP Types"],AIC_fnc_setWaypointAttackActionHandler,[]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Seek & Destroy",["Set Waypoint Type","Offensive WP Types"],AIC_fnc_setWaypointTypeActionHandler,["SAD","'Seek & Destroy'"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelWpSentry,["Set Waypoint Type","Offensive WP Types"],AIC_fnc_setWaypointTypeActionHandler,["SENTRY","'Sentry'",_noteWpSentry]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Defend - Garrison / Patrol (CBA)",["Set Waypoint Type","Defensive WP Types"],AIC_fnc_setDefendWpTypeActionHandler,["DEFEND","'Defend - Garrison / Patrol (CBA)'"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Hold",["Set Waypoint Type","Defensive WP Types"],AIC_fnc_setWaypointTypeActionHandler,["HOLD","'Hold'"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelWpGuard,["Set Waypoint Type","Defensive WP Types"],AIC_fnc_setWaypointTypeActionHandler,["GUARD","'Guard'",_noteWpGuard]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelWpDismiss,["Set Waypoint Type","Defensive WP Types"],AIC_fnc_setWaypointTypeActionHandler,["DISMISS","'Dismiss'",_noteWpDismiss]] call AIC_fnc_addCommandMenuAction;

// Set WP Type "Cycle" - turns the group's waypoints into an endless patrol
["WAYPOINT",_labelWpCycle,["Set Waypoint Type","Special WP Types"],AIC_fnc_setWaypointTypeCycleActionHandler,[]] call AIC_fnc_addCommandMenuAction;

// Deliberately not offered: "GETIN" / "GETIN NEAREST" duplicate (and get in the way of)
// the existing "Assign Vehicle" action, and "SUPPORT" is unreliable in Arma 3 itself.
// See the pull request description for the details.

// Delete WP
["WAYPOINT","Delete Waypoint",[],AIC_fnc_deleteWaypointHandler] call AIC_fnc_addCommandMenuAction;

// Set WP Formation
["WAYPOINT","Column",["Formation"],AIC_fnc_setWaypointFormationActionHandler,["COLUMN"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Stag. Column",["Formation"],AIC_fnc_setWaypointFormationActionHandler,["STAG COLUMN"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Wedge",["Formation"],AIC_fnc_setWaypointFormationActionHandler,["WEDGE"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Echelon Left",["Formation"],AIC_fnc_setWaypointFormationActionHandler,["ECH LEFT"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Echelon Right",["Formation"],AIC_fnc_setWaypointFormationActionHandler,["ECH RIGHT"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","V",["Formation"],AIC_fnc_setWaypointFormationActionHandler,["VEE"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Line",["Formation"],AIC_fnc_setWaypointFormationActionHandler,["LINE"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","File",["Formation"],AIC_fnc_setWaypointFormationActionHandler,["FILE"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Diamond",["Formation"],AIC_fnc_setWaypointFormationActionHandler,["DIAMOND"]] call AIC_fnc_addCommandMenuAction;

// Set WP Type "Land" - Aircraft
["WAYPOINT",_labelLandPrecise,["Set Waypoint Type", "Special WP Types", "Land"],AIC_fnc_setWaypointTypeLandPreciseActionHandler,[_labelLandPrecise],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelLandNearby,["Set Waypoint Type", "Special WP Types", "Land"],AIC_fnc_setWaypointTypeLandNearbyActionHandler,[_labelLandNearby],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;

// Set WP Type "Unload Group, Crew, Passengers" - Vehicles (no aircraft)
["WAYPOINT",_labelUnloadGroupCrewAndPassenger,["Set Waypoint Type", "Special WP Types", _labelUnloadSubMenu],AIC_fnc_setWaypointTypeUnloadActionHandler,["GETOUT",_labelUnloadGroupCrewAndPassenger],{(call AIC_fnc_hasVehicleAssigned) && !(call AIC_fnc_hasAircraftAssigned)}] call AIC_fnc_addCommandMenuAction;

// Set WP Type "Unload Group, Crew, Passengers" - Aircraft
["WAYPOINT",_labelUnloadGroupCrewAndPassenger,["Set Waypoint Type", "Special WP Types", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingNearby],AIC_fnc_setWaypointTypeUnloadActionHandler,["GETOUT",_labelUnloadGroupCrewAndPassenger],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelUnloadGroupCrewAndPassenger,["Set Waypoint Type", "Special WP Types", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingPrecicely],AIC_fnc_setWaypointTypeUnloadActionHandler,["GETOUT",_labelUnloadGroupCrewAndPassenger,true],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;

// Set WP Type "Unload Group" - Vehicles (no aircraft)
["WAYPOINT",_labelUnloadGroupPassengers,["Set Waypoint Type", "Special WP Types", _labelUnloadSubMenu],AIC_fnc_setWaypointTypeUnloadActionHandler,["UNLOAD",_labelUnloadGroupPassengers],{call AIC_fnc_hasVehicleAssigned && !(call AIC_fnc_hasAircraftAssigned)}] call AIC_fnc_addCommandMenuAction;

// Set WP Type "Unload Group" - Aircraft
["WAYPOINT",_labelUnloadGroupPassengers,["Set Waypoint Type", "Special WP Types", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingNearby],AIC_fnc_setWaypointTypeUnloadActionHandler,["UNLOAD",_labelUnloadGroupPassengers],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelUnloadGroupPassengers,["Set Waypoint Type", "Special WP Types", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingPrecicely],AIC_fnc_setWaypointTypeUnloadActionHandler,["UNLOAD",_labelUnloadGroupPassengers,true],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;

// Set WP Type "Unload Other Groups" - Vehicles (no aircraft)
["WAYPOINT",_labelUnloadOtherGroupPassengers,["Set Waypoint Type", "Special WP Types", _labelUnloadSubMenu],AIC_fnc_setWaypointTypeUnloadActionHandler,["TR UNLOAD",_labelUnloadOtherGroupPassengers],{call AIC_fnc_hasGroupCargo && !(call AIC_fnc_hasAircraftAssigned)}] call AIC_fnc_addCommandMenuAction;

// Set WP Type "Unload Other Groups" - Vehicles (no aircraft)
["WAYPOINT",_labelUnloadOtherGroupPassengers,["Set Waypoint Type", "Special WP Types", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingNearby],AIC_fnc_setWaypointTypeUnloadActionHandler,["TR UNLOAD",_labelUnloadOtherGroupPassengers],{call AIC_fnc_hasGroupCargo && call AIC_fnc_hasAircraftAssigned}] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelUnloadOtherGroupPassengers,["Set Waypoint Type", "Special WP Types", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingPrecicely],AIC_fnc_setWaypointTypeUnloadActionHandler,["TR UNLOAD",_labelUnloadOtherGroupPassengers,true],{call AIC_fnc_hasGroupCargo && call AIC_fnc_hasAircraftAssigned}] call AIC_fnc_addCommandMenuAction;

// Set WP Fly in Height
["WAYPOINT","Fly above ground (AGL)...",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,["AGL"],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Fly above sea (ASL)...",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,["ASL"],{params ["_groupControlId","_waypointId"]; (_groupControlId != "") && {!isNil{_waypointId}} && {([_groupControlId call AIC_fnc_getGroupControlGroup,_waypointId] call AIC_fnc_getWaypoint) param [3,""] != "LOITER"} && {[([_groupControlId] call AIC_fnc_getGroupControlGroup)] call AIC_fnc_getGroupAssignedVehicles findIf {_x isKindOf "Air"} >= 0}}] call AIC_fnc_addCommandMenuAction;


// Set WP Duration
["WAYPOINT","None",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[0]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","1 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[1]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","2 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[2]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","3 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[3]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","4 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[4]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","5 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[5]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","10 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[10]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","20 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[20]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","30 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[30]] call AIC_fnc_addCommandMenuAction;

// Set Loiter Radius
["WAYPOINT","10M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[10,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","100M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[100,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","250M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[250,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","500M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[500,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","1000M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[1000,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","2000M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[2000,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","3000M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[3000,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","4000M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[4000,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","10M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[10,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","100M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[100,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","250M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[250,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","500M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[500,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","1000M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[1000,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","2000M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[2000,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","3000M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[3000,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","4000M Radius",["Set Waypoint Type", "Special WP Types", "Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[4000,false]] call AIC_fnc_addCommandMenuAction;
