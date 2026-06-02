// Apply fly-in-height ASL to a single vehicle on the machine that owns it.
// The vehicle owner machine is where flyInHeightASL actually has effect —
// the script must run there, not on the menu-clicker's machine.
//
// ASL is set first (dominant), then AGL subordinate (100m) as a safety floor.
// Arma uses max(flyInHeight, flyInHeightASL) for the effective climb altitude,
// so any ASL > 100m wins. The 100m floor prevents fatal-dive on uneven
// terrain if the ASL application is delayed by a frame.
params ["_vehicle", "_height"];
if (isNull _vehicle) exitWith {};
if !(_vehicle isKindOf "Air") exitWith {};
_vehicle flyInHeightASL [_height, _height, _height];
_vehicle flyInHeight 100;
