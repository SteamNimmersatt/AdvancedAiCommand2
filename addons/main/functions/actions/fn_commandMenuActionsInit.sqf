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

/*

	Helper functions

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

/*

	Add Waypoints

*/

AIC_fnc_addWaypointsActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	AIC_fnc_setGroupControlAddingWaypoints(_groupControlId,true);
};

["GROUP","Add Waypoints",[],AIC_fnc_addWaypointsActionHandler] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Add Waypoints",[],AIC_fnc_addWaypointsActionHandler] call AIC_fnc_addCommandMenuAction;


/*
	Clear all waypoints
*/

AIC_fnc_clearAllWaypointsActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	[_group] call AIC_fnc_disableAllWaypoints;	
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
	hint ("All waypoints cleared");
};
["GROUP","Confirm Cancel All",["Clear All Waypoints"],AIC_fnc_clearAllWaypointsActionHandler] call AIC_fnc_addCommandMenuAction;


/*

	Combat mode

*/

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

["GROUP","Forget all current targets",["Combat Mode"],AIC_fnc_forgetTargetsActionHandler] call AIC_fnc_addCommandMenuAction;
["GROUP","BLUE - Never Fire, Disengage",["Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["BLUE","Never Fire, Disengage"]] call AIC_fnc_addCommandMenuAction;
["GROUP","GREEN - Hold Fire, Disengage",["Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["GREEN","Hold Fire, Disengage"]] call AIC_fnc_addCommandMenuAction;
["GROUP","WHITE - Hold Fire, Engage At Will",["Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["WHITE","Hold Fire, Engage At Will"]] call AIC_fnc_addCommandMenuAction;
["GROUP","YELLOW - Fire At Will, Disengage (Default)",["Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["YELLOW","Fire At Will, Disengage"]] call AIC_fnc_addCommandMenuAction;
["GROUP","RED - Fire At Will, Engage At Will",["Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["RED","Fire At Will, Engage At Will"]] call AIC_fnc_addCommandMenuAction;


/*

	Behaviour

*/

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

["GROUP","Careless",["Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["CARELESS"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Safe",["Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["SAFE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Aware",["Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["AWARE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Combat",["Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["COMBAT"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Stealth",["Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["STEALTH"]] call AIC_fnc_addCommandMenuAction;
["GROUP","On",["Behaviour","Autonomous attacking (default=on)"],AIC_fnc_setGroupEnableAttackActionHandler,["On"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Off",["Behaviour","Autonomous attacking (default=on)"],AIC_fnc_setGroupEnableAttackActionHandler,["Off"]] call AIC_fnc_addCommandMenuAction;
["GROUP","On",["Behaviour","Auto Combat Mode (default=on)"],AIC_fnc_setGroupAutoCombatActionHandler,["On"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Off",["Behaviour","Auto Combat Mode (default=on)"],AIC_fnc_setGroupAutoCombatActionHandler,["Off"]] call AIC_fnc_addCommandMenuAction;


/*

	Formation & Speed

*/
	
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

["GROUP","Column",["Formation & Speed"],AIC_fnc_setGroupFormationActionHandler,["COLUMN"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Stag. Column",["Formation & Speed"],AIC_fnc_setGroupFormationActionHandler,["STAG COLUMN"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Wedge",["Formation & Speed"],AIC_fnc_setGroupFormationActionHandler,["WEDGE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Echelon Left",["Formation & Speed"],AIC_fnc_setGroupFormationActionHandler,["ECH LEFT"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Echelon Right",["Formation & Speed"],AIC_fnc_setGroupFormationActionHandler,["ECH RIGHT"]] call AIC_fnc_addCommandMenuAction;
["GROUP","V",["Formation & Speed"],AIC_fnc_setGroupFormationActionHandler,["VEE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Line",["Formation & Speed"],AIC_fnc_setGroupFormationActionHandler,["LINE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","File",["Formation & Speed"],AIC_fnc_setGroupFormationActionHandler,["FILE"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Diamond",["Formation & Speed"],AIC_fnc_setGroupFormationActionHandler,["DIAMOND"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Half Speed",["Formation & Speed"],AIC_fnc_setGroupSpeedActionHandler,["LIMITED", "Half Speed"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Full Speed (In Formation)",["Formation & Speed"],AIC_fnc_setGroupSpeedActionHandler,["NORMAL", "Full Speed (In Formation)"]] call AIC_fnc_addCommandMenuAction;
["GROUP","Full (No Formation)",["Formation & Speed"],AIC_fnc_setGroupSpeedActionHandler,["FULL", "Full (No Formation)"]] call AIC_fnc_addCommandMenuAction;


/*

	Fly in Height

*/

AIC_fnc_setFlyInHeightActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_actionParams params ["_height"];
	{
		if(_x isKindOf "Air") then {
			[_x,_height] remoteExec ["flyInHeight", _x]; 
		};
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	hint ("Fly in height set to " + (str _height) + " meters");
};

["GROUP","10 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[10],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","25 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[25],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","50 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[50],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","100 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[100],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","250 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[250],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","500 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[500],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","750 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[750],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","1000 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[1000],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","1500 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[1500],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","2000 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[2000],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;	
["GROUP","2500 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[2500],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["GROUP","3000 meters",["Set Fly in Height"],AIC_fnc_setFlyInHeightActionHandler,[3000],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;


/*

	Remote View & Control

*/

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

["GROUP","Remote View",["Remote"],AIC_fnc_remoteViewActionHandler,[],{
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

["GROUP","Remote Control",["Remote"],AIC_fnc_remoteControlActionHandler,[],{
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


/*

	Color

*/

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

["GROUP","Red",["Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_RED]] call AIC_fnc_addCommandMenuAction;
["GROUP","Green",["Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_GREEN]] call AIC_fnc_addCommandMenuAction;
["GROUP","Blue",["Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_BLUE]] call AIC_fnc_addCommandMenuAction;
["GROUP","Yellow",["Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_YELLOW]] call AIC_fnc_addCommandMenuAction;
["GROUP","Purple",["Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_PURPLE]] call AIC_fnc_addCommandMenuAction;
["GROUP","Pink",["Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_PINK]] call AIC_fnc_addCommandMenuAction;
["GROUP","Cyan",["Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_CYAN]] call AIC_fnc_addCommandMenuAction;
["GROUP","Black",["Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_BLACK]] call AIC_fnc_addCommandMenuAction;
["GROUP","White",["Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_WHITE]] call AIC_fnc_addCommandMenuAction;


/*

	Join / Split Group

*/

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
["GROUP","Join A Group",["Join / Split Group"],AIC_fnc_joinGroupActionHandler,[]] call AIC_fnc_addCommandMenuAction;

AIC_fnc_splitGroupHalfActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_group2 = createGroup (side _group);
	_joinNewGroup = false;
	{
		if(_joinNewGroup) then {
			[_x] joinSilent _group2;
			_joinNewGroup = false;
		} else {	
			_joinNewGroup = true;
		};
	} forEach (units _group);
	hint ("Group Split in Half");
};
["GROUP","In Half",["Join / Split Group","Split Group"],AIC_fnc_splitGroupHalfActionHandler,[],{
	params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	count units _group > 1;
}] call AIC_fnc_addCommandMenuAction;

AIC_fnc_splitGroupUnitsActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId"];
	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	
	// Find all command controls to update with new split groups
	_commandControlsToUpdate = [];
	_commandControls = AIC_fnc_getCommandControls();
	{
		_commandControlId = _x;
		_groups = AIC_fnc_getCommandControlGroups(_commandControlId);
		if(_group in _groups) then {
			_commandControlsToUpdate pushBack _commandControlId;
		};
	} forEach _commandControls;
	
	{
		_group = createGroup (side _x);
		[_x] joinSilent _group;
		{
			[_x,_group] call AIC_fnc_commandControlAddGroup;
		} forEach _commandControlsToUpdate;
	} forEach (units _group);
	
	hint ("Group Split into Individual Units");
	
};
["GROUP","Into Individual Units",["Join / Split Group","Split Group"],AIC_fnc_splitGroupUnitsActionHandler,[],{
	params ["_groupControlId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	count units _group > 1;
}] call AIC_fnc_addCommandMenuAction;


/*

	Assign Vehicle

*/

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
		_vehicleName = getText (configFile >> "CfgVehicles" >> typeOf _selectedVehicle >> "displayName");
		hint ("Vehicle assigned: " + _vehicleName);
	} else {
		hint ("No vehicle assigned");
	};
};

["GROUP","Assign Vehicle",[],AIC_fnc_assignVehicleActionHandler,[]] call AIC_fnc_addCommandMenuAction;		

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

["GROUP","Unassign All Vehicle(s)",[],AIC_fnc_unassignVehicleActionHandler,[],AIC_fnc_hasVehicleAssigned] call AIC_fnc_addCommandMenuAction;

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

["GROUP","Unload Other Group(s)",[],AIC_fnc_unloadOtherGroupsActionHandler,[],AIC_fnc_hasGroupCargo] call AIC_fnc_addCommandMenuAction;	


/*

	Land

*/

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
			[_group, [nil, _selectedPosition, false, "MOVE", landActionScript]] call AIC_fnc_addWaypoint;
			
			// Refresh/Redraw waypoints
			[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
		};
	};
};

["GROUP","Land nearby (search spot within 500m)",["Land now"],AIC_fnc_landNowNearbyActionHandler,[],AIC_fnc_isFlying] call AIC_fnc_addCommandMenuAction;

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
			[_group, [nil, _selectedPosition, false, "MOVE", landActionScript]] call AIC_fnc_addWaypoint;
			
			// Refresh/Redraw waypoints
			[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
		};
	};
};

["GROUP","Land precisely (as close as possible)",["Land now"],AIC_fnc_landNowPreciseActionHandler,[],AIC_fnc_isFlying] call AIC_fnc_addCommandMenuAction;


/*

	Rappel

*/

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

["GROUP","Rappel Other Group(s)",[],AIC_fnc_rappelActionHandler,[],{
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

	Waypoint Actions

*/

AIC_fnc_deleteWaypointHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];
	private ["_group"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	[_group,_waypointId] call AIC_fnc_disableWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
};

["WAYPOINT","Delete Waypoint",[],AIC_fnc_deleteWaypointHandler] call AIC_fnc_addCommandMenuAction;

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

["WAYPOINT","Column",["Formation & Speed"],AIC_fnc_setWaypointFormationActionHandler,["COLUMN"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Stag. Column",["Formation & Speed"],AIC_fnc_setWaypointFormationActionHandler,["STAG COLUMN"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Wedge",["Formation & Speed"],AIC_fnc_setWaypointFormationActionHandler,["WEDGE"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Echelon Left",["Formation & Speed"],AIC_fnc_setWaypointFormationActionHandler,["ECH LEFT"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Echelon Right",["Formation & Speed"],AIC_fnc_setWaypointFormationActionHandler,["ECH RIGHT"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","V",["Formation & Speed"],AIC_fnc_setWaypointFormationActionHandler,["VEE"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Line",["Formation & Speed"],AIC_fnc_setWaypointFormationActionHandler,["LINE"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","File",["Formation & Speed"],AIC_fnc_setWaypointFormationActionHandler,["FILE"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Diamond",["Formation & Speed"],AIC_fnc_setWaypointFormationActionHandler,["DIAMOND"]] call AIC_fnc_addCommandMenuAction;
								
AIC_fnc_setWaypointTypeActionHandler = {
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];

	private _group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	private _waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;

	// "_actionParams" contains "_type", "_label"
	_actionParams params ["_type",["_label", "ERROR LABEL UNDEFINED!"]];

	_waypoint set [AIC_Waypoint_ArrayIndex_Type,_type];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;

	hint ("Type set to '" + _label + "'.");
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

["WAYPOINT","Move (default)",["Set Waypoint Type"],AIC_fnc_setWaypointTypeActionHandler,["MOVE","'Move'"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Hold",["Set Waypoint Type"],AIC_fnc_setWaypointTypeActionHandler,["HOLD","'Hold'"]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","Seek & Destroy",["Set Waypoint Type"],AIC_fnc_setWaypointTypeActionHandler,["SAD","'Seek & Destroy'"]] call AIC_fnc_addCommandMenuAction;

/*
	WP Type "Unload"
*/

private _labelUnloadSubMenu = "Unload / Drop off";
private _labelUnloadSubSubMenuLandingNearby = "Land & Unload nearby (spot within 500m)";
private _labelUnloadSubSubMenuLandingPrecicely = "Land & Unload precicely";


private _labelUnloadGroupCrewAndPassenger = "Unload this groups crew & passengers";

// No aircraft
["WAYPOINT",_labelUnloadGroupCrewAndPassenger,["Set Waypoint Type", _labelUnloadSubMenu],AIC_fnc_setWaypointTypeUnloadActionHandler,["GETOUT",_labelUnloadGroupCrewAndPassenger],{(call AIC_fnc_hasVehicleAssigned) && !(call AIC_fnc_hasAircraftAssigned)}] call AIC_fnc_addCommandMenuAction;

// Is aircraft
["WAYPOINT",_labelUnloadGroupCrewAndPassenger,["Set Waypoint Type", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingNearby],AIC_fnc_setWaypointTypeUnloadActionHandler,["GETOUT",_labelUnloadGroupCrewAndPassenger],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelUnloadGroupCrewAndPassenger,["Set Waypoint Type", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingPrecicely],AIC_fnc_setWaypointTypeUnloadActionHandler,["GETOUT",_labelUnloadGroupCrewAndPassenger,true],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;


private _labelUnloadGroupPassengers = "Unload this groups passengers";

// No aircraft
["WAYPOINT",_labelUnloadGroupPassengers,["Set Waypoint Type", _labelUnloadSubMenu],AIC_fnc_setWaypointTypeUnloadActionHandler,["UNLOAD",_labelUnloadGroupPassengers],{call AIC_fnc_hasVehicleAssigned && !(call AIC_fnc_hasAircraftAssigned)}] call AIC_fnc_addCommandMenuAction;

// Is aircraft
["WAYPOINT",_labelUnloadGroupPassengers,["Set Waypoint Type", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingNearby],AIC_fnc_setWaypointTypeUnloadActionHandler,["UNLOAD",_labelUnloadGroupPassengers],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelUnloadGroupPassengers,["Set Waypoint Type", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingPrecicely],AIC_fnc_setWaypointTypeUnloadActionHandler,["UNLOAD",_labelUnloadGroupPassengers,true],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;


private _labelUnloadOtherGroupPassengers = "Unload other groups passengers (not crew positions)";

// No aircraft
["WAYPOINT",_labelUnloadOtherGroupPassengers,["Set Waypoint Type", _labelUnloadSubMenu],AIC_fnc_setWaypointTypeUnloadActionHandler,["TR UNLOAD",_labelUnloadOtherGroupPassengers],{call AIC_fnc_hasGroupCargo && !(call AIC_fnc_hasAircraftAssigned)}] call AIC_fnc_addCommandMenuAction;

// Is aircraft
["WAYPOINT",_labelUnloadOtherGroupPassengers,["Set Waypoint Type", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingNearby],AIC_fnc_setWaypointTypeUnloadActionHandler,["TR UNLOAD",_labelUnloadOtherGroupPassengers],{call AIC_fnc_hasGroupCargo && call AIC_fnc_hasAircraftAssigned}] call AIC_fnc_addCommandMenuAction;
["WAYPOINT",_labelUnloadOtherGroupPassengers,["Set Waypoint Type", _labelUnloadSubMenu, _labelUnloadSubSubMenuLandingPrecicely],AIC_fnc_setWaypointTypeUnloadActionHandler,["TR UNLOAD",_labelUnloadOtherGroupPassengers,true],{call AIC_fnc_hasGroupCargo && call AIC_fnc_hasAircraftAssigned}] call AIC_fnc_addCommandMenuAction;


/*
	WP Type "Land"
*/
private _labelLandNearby = "Land nearby (search spot within 500m)";
["WAYPOINT",_labelLandNearby,["Set Waypoint Type","Land"],AIC_fnc_setWaypointTypeLandNearbyActionHandler,[_labelLandNearby],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;

private _labelLandPrecise = "Land precisely (as close as possible)";
["WAYPOINT",_labelLandPrecise,["Set Waypoint Type","Land"],AIC_fnc_setWaypointTypeLandPreciseActionHandler,[_labelLandPrecise],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;


/*
	WP Type "Loiter"
*/
["WAYPOINT","10M Radius",["Set Waypoint Type","Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[10,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","100M Radius",["Set Waypoint Type","Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[100,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","250M Radius",["Set Waypoint Type","Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[250,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","500M Radius",["Set Waypoint Type","Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[500,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","1000M Radius",["Set Waypoint Type","Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[1000,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","2000M Radius",["Set Waypoint Type","Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[2000,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","3000M Radius",["Set Waypoint Type","Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[3000,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","4000M Radius",["Set Waypoint Type","Loiter (Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[4000,true]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","10M Radius",["Set Waypoint Type","Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[10,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","100M Radius",["Set Waypoint Type","Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[100,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","250M Radius",["Set Waypoint Type","Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[250,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","500M Radius",["Set Waypoint Type","Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[500,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","1000M Radius",["Set Waypoint Type","Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[1000,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","2000M Radius",["Set Waypoint Type","Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[2000,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","3000M Radius",["Set Waypoint Type","Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[3000,false]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","4000M Radius",["Set Waypoint Type","Loiter (C-Clockwise)"],AIC_fnc_setLoiterTypeActionHandler,[4000,false]] call AIC_fnc_addCommandMenuAction;


AIC_fnc_setWaypointFlyInHeightActionHandlerScript = {
	params ["_group","_height"]; 
  { 
  	if(_x isKindOf "Air") then { 
    	[_x,_height] remoteExec ["flyInHeight", _x];
    };
  } forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
};

AIC_fnc_setWaypointFlyInHeightActionHandler = {
	private ["_script"];
	params ["_menuParams","_actionParams"];
	_menuParams params ["_groupControlId","_waypointId"];
	_actionParams params ["_height"];
	private ["_group","_waypoint"];
	_group = [_groupControlId] call AIC_fnc_getGroupControlGroup;
	_waypoint = [_group, _waypointId] call AIC_fnc_getWaypoint;
	_waypoint set [AIC_Waypoint_ArrayIndex_FlyInHeight,_height];
	[_group, _waypoint] call AIC_fnc_setWaypoint;
	hint ("Waypoint fly in height set to " + (str _height) + " meters");
};

["WAYPOINT","10 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[10],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","25 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[25],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","50 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[50],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","100 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[100],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","250 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[250],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","500 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[500],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","750 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[750],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","1000 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[1000],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","1500 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[1500],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","2000 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[2000],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","2500 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[2500],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","3000 meters",["Set Fly in Height"],AIC_fnc_setWaypointFlyInHeightActionHandler,[3000],AIC_fnc_hasAircraftAssigned] call AIC_fnc_addCommandMenuAction;

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

["WAYPOINT","None",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[0]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","1 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[1]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","2 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[2]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","3 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[3]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","4 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[4]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","5 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[5]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","10 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[10]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","20 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[20]] call AIC_fnc_addCommandMenuAction;
["WAYPOINT","30 Min",["Set Duration"],AIC_fnc_setWaypointDurationActionHandler,[30]] call AIC_fnc_addCommandMenuAction;
