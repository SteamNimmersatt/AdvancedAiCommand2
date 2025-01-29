class AICommand
{
	tag = "AIC";
	
	class Main
	{
		file = "\z\aicommand2\addons\main\functions\main";
		class initAICommand {description = "";};
		class initAICommandClient {description = "";};
		class log {description = "";};
		class msgSideChat {description = "";};
	};
	
	class MapIcon
	{
		file = "\z\aicommand2\addons\main\functions\mapIcon";	
		class createMapIcon {description = "";};
		class drawMapIcon {description = "";};
		class mapIconDefinitions {description = "";};
	};
	
	class GroupData
	{
		file = "\z\aicommand2\addons\main\functions\groupData";
		class addWaypoint {description = "";};	
		class getAllWaypoints {description = "";};
		class getWaypoint {description = "";};
		class setWaypoint {description = "";};
		class disableWaypoint {description = "";};
		class disableAllWaypoints {description = "";};
		class setGroupColor {description = "";};
		class getGroupColor {description = "";};
		class getAllActiveWaypoints {description = "";};
		class getGroupActions {description = "";};
		class setGroupActions {description = "";};
		class getGroupAssignedVehicles {description = "";};
		class setGroupAssignedVehicles {description = "";};
	};

	class CommandMenu
	{
		file = "\z\aicommand2\addons\main\functions\commandMenu";
		class commandMenuManager {description = "";};
		class showCommandMenu {description = "";};
		class showGroupCommandMenu {description = "";};
		class showGroupWpCommandMenu {description = "";};
		class addCommandMenuAction {description = "";};
		class executeCommandMenuAction {description = "";};
	};

	class EventHandler
	{
		file = "\z\aicommand2\addons\main\functions\eventHandler";
		class addManagedEventHandler {description = "";};
		class addEventHandler {description = "";};
		class removeEventHandler {description = "";};
		class eventHandlerManager {description = "";};
	};
	
	class Actions
	{
		file = "\z\aicommand2\addons\main\functions\actions";
		class commandMenuActionsInit {description = "";};
		class selectGroupControlGroup {description = "";};
		class selectGroupControlPosition {description = "";};
		class selectGroupControlVehicle {description = "";};
	};
	
	
	
	class RemoteCamera
	{
		file = "\z\aicommand2\addons\main\functions\remoteCamera";
		class disable3rdPersonCamera {description = "";};
		class enable3rdPersonCamera {description = "";};
		class cameraMouseMoveHandler {description = "";};
		class cameraMouseZoomHandler {description = "";};
		class cameraUpdatePosition {description = "";};
	};
	
	class VehicleIcon
	{
		file = "\z\aicommand2\addons\main\functions\vehicleIcon";
		class getVehicleIconPath {description = "";};
		class getVehicleMapIconSet {description = "";};
		class createVehicleInteractiveIcon {description = "";};
	};
		
	class MapElements
	{

		file = "\z\aicommand2\addons\main\functions\mapElements";
		class createMapElement {description = "";};
		class setMapElementEnabled {description = "";};
		class setMapElementVisible {description = "";};
		class setMapElementForeground {description = "";};
		class addMapElementChild {description = "";};
		class deleteMapElement {description = "";};
	};

	class InputControlMapElement
	{
		file = "\z\aicommand2\addons\main\functions\mapElements\inputControl";
		class inputControlEventHandler {description = "";};
		class createInputControl {description = "";};
		class drawInputControl {description = "";};
		class deleteInputControl {description = "";};
		class inputControlManager {description = "";};
	};
	
	class InteractiveIconMapElement
	{
		file = "\z\aicommand2\addons\main\functions\mapElements\interactiveIcon";
		class interactiveIconManager {description = "";};
		class createInteractiveIcon {description = "";};
		class drawInteractiveIcon {description = "";};
		class handleInteractiveIconEvent {description = "";};
		class interactiveIconEventHandler {description = "";};
		class getInteractiveIconsByMapPosition {description = "";};
		class removeInteractiveIcon {description = "";};
	};
	
	
	class GroupControlMapElement
	{
		file = "\z\aicommand2\addons\main\functions\mapElements\groupControl";
		class createGroupControl {description = "";};
		class drawGroupControl {description = "";};

		class getGroupControlGroup {description = "";};
		class getGroupControlIconSet {description = "";};
		class getGroupControlInteractiveIcon {description = "";};
		class getGroupControlWpIconSet {description = "";};
		class getGroupIconType {description = "";};
		
		class groupControlEventHandler {description = "";};
		class groupControlManager {description = "";};
		class groupControlWaypointEventHandler {description = "";};

		class removeGroupControl {description = "";};
		
		class setGroupControlGroup {description = "";};
		class removeGroupControlGroup {description = "";};
		
		class setGroupControlInteractiveIcon {description = "";};
		class removeGroupControlInteractiveIcon {description = "";};

		class showGroupReport {description = "";};
		class showGroupWaypointReport {description = "";};
	};
	
	class CommandControlMapElement
	{
		file = "\z\aicommand2\addons\main\functions\mapElements\commandControl";
		class commandControlManager {description = "";};
		class createCommandControl {description = "";};
		class drawCommandControl {description = "";};
		class commandControlAddGroup {description = "";};
		class commandControlRemoveGroup {description = "";};
		class commandControlEventHandler {description = "";};
		class showCommandControl {description = "";};
	};
	
	class Util
	{
		file = "\z\aicommand2\addons\main\functions\util";
		class getInVehicle {description = "";};
	};
	
};
