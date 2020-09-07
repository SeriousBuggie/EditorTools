//=============================================================================
// BrushToCamera.
//=============================================================================
class BrushToCamera expands BrushBuilder;

var() LevelInfo LevelInfo;
var(hidden) vector GridSize;

event bool Build() {
	local Brush brush, b;
	local Actor actor;
	local Camera camera;

	if (LevelInfo == None) {
		SetPropertyText("LevelInfo", "MyLevel.LevelInfo0");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo1");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo2");
		if (LevelInfo == None) return BadParameters("Please specify LevelInfo");
	}
	
	foreach LevelInfo.AllActors(class'Brush', brush) {
		if (brush.CsgOper != 0) continue;
		b = brush;
		break;
	}
	if (b == None) return BadParameters("Builder brush not found");
	
	foreach LevelInfo.AllActors(class'Actor', actor) {
		if (!actor.bSelected) continue;
		return MoveSnapped(b, actor.Location);
	}
	foreach LevelInfo.AllActors(class'Camera', camera) {
		return MoveSnapped(b, camera.Location + 64*vector(camera.Rotation));
	}
	return false;
}

function bool MoveSnapped(Actor a, vector loc) {
	SetPropertyText("GridSize", LevelInfo.ConsoleCommand("get ini:Engine.Engine.EditorEngine GridSize"));
	loc -= a.Location;
	if (GridSize.x != 0) loc.x = int(int((loc.x/GridSize.x) + 0.5)*GridSize.x);
	if (GridSize.y != 0) loc.y = int(int((loc.y/GridSize.y) + 0.5)*GridSize.y);
	if (GridSize.z != 0) loc.z = int(int((loc.z/GridSize.z) + 0.5)*GridSize.z);
	loc += a.Location;
	LevelInfo.ConsoleCommand("BRUSH MOVETO X="$loc.x@"Y="$loc.y@"Z="$loc.z);
	
	return false;
}



defaultproperties {
	BitmapFilename="BrushToCamera"
	ToolTip="Move builder Brush to first selected actor or in front of first Camera"
}
