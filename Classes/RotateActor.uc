//=============================================================================
// RotateActor.
//=============================================================================
class RotateActor expands BrushBuilder;

var() LevelInfo LevelInfo;
var() const enum EChange
{
	Yaw,
	Pitch,
	Roll
} Change;
var() int StepDegrees;

event bool Build() {
	local Actor actor;
	local int step;
	local rotator rstep;

	if (LevelInfo == None) {
		SetPropertyText("LevelInfo", "MyLevel.LevelInfo0");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo1");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo2");
		if (LevelInfo == None) return BadParameters("Please specify LevelInfo");
	}
	
	step = int(StepDegrees*65536/360 + 0.5);
	switch (Change) {
		case Yaw: rstep.Yaw = step; break;
		case Pitch: rstep.Pitch = step; break;
		case Roll: rstep.Roll = step; break;
	}	
	
	foreach LevelInfo.AllActors(class'Actor', actor) {
		if (!actor.bSelected) continue;
		actor.bDirectional = true;
		actor.SetRotation(actor.Rotation + rstep);
	}
	return false;
}

defaultproperties {
	BitmapFilename="RotateActor"
	ToolTip="Rotate selected actor to fixed step on specified axis"
	StepDegrees=90
}
