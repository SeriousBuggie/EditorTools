//=============================================================================
// Distance.
//=============================================================================
class Distance expands BrushBuilder;

var() LevelInfo LevelInfo;

event bool Build() {
	local ClipMarker marker;
	local Actor actor, A[2];
	local Camera camera;
	local float best, dist;
	local int i;
	local vector D;
	local string msg;

	if (LevelInfo == None) {
		SetPropertyText("LevelInfo", "MyLevel.LevelInfo0");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo1");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo2");
		if (LevelInfo == None) return BadParameters("Please specify LevelInfo");
	}
	
	i = 0;
	foreach LevelInfo.AllActors(class'ClipMarker', marker) {
		if (i >= 2) return BadParameters("Error: more than 2 clip markers on the map");
		A[i++] = marker;
	}
	if (i == 1) return BadParameters("Error: need 2 clip markers on the map");
	
	if (i == 0) {
		foreach LevelInfo.AllActors(class'Actor', actor) {
			if (!actor.bSelected) continue;
			if (i >= 2) return BadParameters("Error: more than 2 actors selected");
			A[i++] = actor;
		}
		if (i == 0) return BadParameters("Error: please select 1 or 2 actors on the map");
		if (i == 1) {
			foreach LevelInfo.AllActors(class'Camera', camera) {
				dist = VSize(A[0].Location - camera.Location);
				if (A[1] == None || dist < best) {
					A[1] = camera;
					best = dist;
				}
			}
			if (A[1] == None) return BadParameters("Error: Camera actor not found, please select second actor");
		}
	}
	D = A[0].Location - A[1].Location;
	msg = "Distance between"@A[0].name@"and"@A[1].Name$Chr(13)$Chr(10)$Chr(13)$Chr(10)$"dXYZ:"@Vsize(D)$Chr(13)$Chr(10)$"dX:"@abs(D.X)$Chr(13)$Chr(10)$"dY:"@abs(D.Y)$Chr(13)$Chr(10)$"dZ:"@abs(D.Z);
	D.Z = 0;
	msg = msg$Chr(13)$Chr(10)$"dXY:"@Vsize(D);
	
	Log(msg); // for allow copy from log
	return BadParameters(msg);
}

defaultproperties {
	BitmapFilename="Distance"
	ToolTip="Measure distance"
}
