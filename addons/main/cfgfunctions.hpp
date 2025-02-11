/*
	 recompile = 1 - Allows to edit code while Arma3 is running. Restart the mission to see changes. This is useful for debugging and development.
*/
class AICommand
{
	tag = "AIC";
	
	class Main
	{
		file = "\z\aicommand2\addons\main\functions\main";
		class initAICommand {description = ""; recompile = 1};
		class initAICommandClient {description = ""; recompile = 1};
		class log {description = ""; recompile = 1};
		class msgSideChat {description = ""; recompile = 1};
	};
	
	class MapIcon
	{
		file = "\z\aicommand2\addons\main\functions\mapIcon";	
		class createMapIcon {description = ""; recompile = 1};
		class drawMapIcon {description = ""; recompile = 1};
		class mapIconDefinitions {description = ""; recompile = 1};
	};
	
	class GroupData
	{
		file = "\z\aicommand2\addons\main\functions\groupData";
		class addWaypoint {description = ""; recompile = 1};	
		class getAllWaypoints {description = ""; recompile = 1};
		class getWaypoint {description = ""; recompile = 1};
		class setWaypoint {description = ""; recompile = 1};
		class toStringWaypoint {description = ""; recompile = 1};
		class disableWaypoint {description = ""; recompile = 1};
		class disableAllWaypoints {description = ""; recompile = 1};
		class setGroupColor {description = ""; recompile = 1};
		class getGroupColor {description = ""; recompile = 1};
		class getAllActiveWaypoints {description = ""; recompile = 1};
		class getGroupActions {description = ""; recompile = 1};
		class setGroupActions {description = ""; recompile = 1};
		class getGroupAssignedVehicles {description = ""; recompile = 1};
		class setGroupAssignedVehicles {description = ""; recompile = 1};
	};

	class CommandMenu
	{
		file = "\z\aicommand2\addons\main\functions\commandMenu";
		class commandMenuManager {description = ""; recompile = 1};
		class showCommandMenu {description = ""; recompile = 1};
		class showGroupCommandMenu {description = ""; recompile = 1};
		class showGroupWpCommandMenu {description = ""; recompile = 1};
		class addCommandMenuAction {description = ""; recompile = 1};
		class executeCommandMenuAction {description = ""; recompile = 1};
	};

	class EventHandler
	{
		file = "\z\aicommand2\addons\main\functions\eventHandler";
		class addManagedEventHandler {description = ""; recompile = 1};
		class addEventHandler {description = ""; recompile = 1};
		class removeEventHandler {description = ""; recompile = 1};
		class eventHandlerManager {description = ""; recompile = 1};
	};
	
	class Actions
	{
		file = "\z\aicommand2\addons\main\functions\actions";
		class commandMenuActionsInit {description = ""; recompile = 1};
		class selectGroupControlGroup {description = ""; recompile = 1};
		class selectGroupControlPosition {description = ""; recompile = 1};
		class selectGroupControlVehicle {description = ""; recompile = 1};
	};
	
	
	
	class RemoteCamera
	{
		file = "\z\aicommand2\addons\main\functions\remoteCamera";
		class disable3rdPersonCamera {description = ""; recompile = 1};
		class enable3rdPersonCamera {description = ""; recompile = 1};
		class cameraMouseMoveHandler {description = ""; recompile = 1};
		class cameraMouseZoomHandler {description = ""; recompile = 1};
		class cameraUpdatePosition {description = ""; recompile = 1};
	};
	
	class VehicleIcon
	{
		file = "\z\aicommand2\addons\main\functions\vehicleIcon";
		class getVehicleIconPath {description = ""; recompile = 1};
		class getVehicleMapIconSet {description = ""; recompile = 1};
		class createVehicleInteractiveIcon {description = ""; recompile = 1};
	};
		
	class MapElements
	{

		file = "\z\aicommand2\addons\main\functions\mapElements";
		class createMapElement {description = ""; recompile = 1};
		class setMapElementEnabled {description = ""; recompile = 1};
		class setMapElementVisible {description = ""; recompile = 1};
		class setMapElementForeground {description = ""; recompile = 1};
		class addMapElementChild {description = ""; recompile = 1};
		class deleteMapElement {description = ""; recompile = 1};
	};

	class InputControlMapElement
	{
		file = "\z\aicommand2\addons\main\functions\mapElements\inputControl";
		class inputControlEventHandler {description = ""; recompile = 1};
		class createInputControl {description = ""; recompile = 1};
		class drawInputControl {description = ""; recompile = 1};
		class deleteInputControl {description = ""; recompile = 1};
		class inputControlManager {description = ""; recompile = 1};
	};
	
	class InteractiveIconMapElement
	{
		file = "\z\aicommand2\addons\main\functions\mapElements\interactiveIcon";
		class interactiveIconManager {description = ""; recompile = 1};
		class createInteractiveIcon {description = ""; recompile = 1};
		class drawInteractiveIcon {description = ""; recompile = 1};
		class handleInteractiveIconEvent {description = ""; recompile = 1};
		class interactiveIconEventHandler {description = ""; recompile = 1};
		class getInteractiveIconsByMapPosition {description = ""; recompile = 1};
		class removeInteractiveIcon {description = ""; recompile = 1};
	};
	
	
	class GroupControlMapElement
	{
		file = "\z\aicommand2\addons\main\functions\mapElements\groupControl";
		class createGroupControl {description = ""; recompile = 1};
		class drawGroupControl {description = ""; recompile = 1};

		class getGroupControlGroup {description = ""; recompile = 1};
		class getGroupControlIconSet {description = ""; recompile = 1};
		class getGroupControlInteractiveIcon {description = ""; recompile = 1};
		class getGroupControlWpIconSet {description = ""; recompile = 1};
		class getGroupIconType {description = ""; recompile = 1};
		
		class groupControlEventHandler {description = ""; recompile = 1};
		class groupControlManager {description = ""; recompile = 1};
		class groupControlWaypointEventHandler {description = ""; recompile = 1};

		class removeGroupControl {description = ""; recompile = 1};
		
		class setGroupControlGroup {description = ""; recompile = 1};
		class removeGroupControlGroup {description = ""; recompile = 1};
		
		class setGroupControlInteractiveIcon {description = ""; recompile = 1};
		class removeGroupControlInteractiveIcon {description = ""; recompile = 1};

		class showGroupReport {description = ""; recompile = 1};
		class showGroupWaypointReport {description = ""; recompile = 1};
	};
	
	class CommandControlMapElement
	{
		file = "\z\aicommand2\addons\main\functions\mapElements\commandControl";
		class commandControlManager {description = ""; recompile = 1};
		class createCommandControl {description = ""; recompile = 1};
		class drawCommandControl {description = ""; recompile = 1};
		class commandControlAddGroup {description = ""; recompile = 1};
		class commandControlRemoveGroup {description = ""; recompile = 1};
		class commandControlEventHandler {description = ""; recompile = 1};
		class showCommandControl {description = ""; recompile = 1};
	};
	
	class Util
	{
		file = "\z\aicommand2\addons\main\functions\util";
		class getInVehicle {description = ""; recompile = 1};
	};
	
};
