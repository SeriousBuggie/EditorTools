//=============================================================================
// EditActor.
//=============================================================================
class EditActor expands BrushBuilder;

var() LevelInfo LevelInfo;
var() string SetProperty;
var() string ToValue;

event bool Build() {
	local Actor actor, a;
	local string prop, val;
	local bool setValue;
	local int cnt, good;

	if (LevelInfo == None) {
		SetPropertyText("LevelInfo", "MyLevel.LevelInfo0");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo1");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo2");
		if (LevelInfo == None) return BadParameters("Please specify LevelInfo");
	}
	
	prop = SetProperty;
	val = ToValue;
	setValue = prop != "" && prop != " " && prop != "None";
	
	foreach LevelInfo.AllActors(class'Actor', actor) {
		if (!actor.bSelected) continue;
		if (setValue) {
			cnt++;
			actor.SetPropertyText(prop, val);
			if (actor.GetPropertyText(prop) == val) good++;
			continue;
		}
		if (a != None) return BadParameters("Error: more than 1 actor selected");
		a = actor;
	}
	if (setValue) {
		if (cnt == 0) {
			val = "Error: need select 1 or more actors";
		} else {
			val = "Set values for"@cnt@"actors."@good@"actors accepted value.";
		}
		return BadParameters(val);
	}
	if (a == None) return BadParameters("Error: please select 1 actor");
	LevelInfo.ConsoleCommand("EDITACTOR NAME="$a.Name);
	return false;
}

defaultproperties {
	BitmapFilename="EditActor"
	ToolTip="Call EditActor command for selected actor"
}
