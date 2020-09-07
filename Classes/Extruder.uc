//=============================================================================
// Extruder.
//=============================================================================
class Extruder expands BrushBuilder;

var() LevelInfo LevelInfo;
var() bool bTesselate;

function int getDirection(int a, int b, vector v) {
	local int d;

	d = int(v dot (GetVertex(a) cross GetVertex(b)));
	d = d/Abs(d);
	return d;
}

event bool Build() {
	local ClipMarker marker, list[512];
	local int used, cnt, pivot, i, a, b, c, d, v, flags;
	local float s, k;
	local vector norm, center, move, next, prev, half, proj, plane[512];
	local rotator rhalf;

	if (LevelInfo == None) {
		SetPropertyText("LevelInfo", "MyLevel.LevelInfo0");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo1");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo2");
		if (LevelInfo == None) return BadParameters("Please specify LevelInfo");
	}
	
	a = 1024*1024*1024;
	b = Len(class'ClipMarker'.Name);
	foreach LevelInfo.AllActors(class'ClipMarker', marker) {
		i = int(Right(marker.Name, Len(marker.Name) - b));
		if (i < a) a = i;
	}
	foreach LevelInfo.AllActors(class'ClipMarker', marker) {
		i = int(Right(marker.Name, Len(marker.Name) - b)) - a;
		list[i] = marker;
		if (i > used) used = i;
	}
	for (i = 0; i <= used; i++) {
		if (list[i] == None) continue;
		if (i != 0 && list[0] != None && pivot == 0 && list[i].Location == list[0].Location) {
			pivot = cnt;
			continue;
		}
		if (i > cnt) {
			list[cnt] = list[i];
		}
		cnt++;
	}
	if (cnt < 4) return BadParameters("Need at least 5 ClipMarkers");
	if (pivot == 0) return BadParameters("Drag some ClipMarker to first ClipMarker");
	if (pivot == cnt) return BadParameters("Add ClipMarker for pivot point");
	if (pivot == 1) return BadParameters("Second ClipMarker can not be on same Location as first ClipMarker");
	if (pivot == cnt - 1) return BadParameters("Add ClipMarker for path points");
	
	if (pivot == 2) {
		flags = flags | 0x00000008; // PF_NotSolid = 0x00000008,	// Poly is not solid, doesn't block.
		flags = flags | 0x00000100; // PF_TwoSided = 0x00000100,	// Poly is visible from both sides.
	} else {
		norm = (list[1].Location - list[0].Location) cross (list[2].Location - list[0].Location);
		for (i = 3; i <= pivot; i++) {
			if (norm dot (list[i].Location - list[0].Location) != 0) {
				return BadParameters(list[i].Name@"not coplanar to first 3 ClipMarkers");
			}
		}
	}
	
	BeginBrush(false, 'Extruder');
	for (i = 0; i < pivot; i++) {
		plane[i] = list[i].Location - list[pivot].Location;
		Vertexv(plane[i]);
	}
	if (pivot == 2) {			
		d = 1;
	} else {
		d = getDirection(0, 1, list[pivot + 1].Location - list[pivot].Location);
		PolyBegin(-d, 'Start', flags); 
		for (i = 0; i < pivot; i++) Polyi(i); 
		PolyEnd();
	}
	
	for (i = pivot + 1; i < cnt; i++) {
		move = list[i].Location - list[i - 1].Location;
		if (i != cnt - 1) {
			next = list[i + 1].Location - list[i].Location;
		} else {
			next = move;
		}
		half = Normal(Normal(move) - Normal(next));
		rhalf = rotator(half);

		if (move == next) {
			k = 0;
		} else {
			proj = Normal(move cross (move cross next));

			k = (Normal(move) dot half)/(proj dot half);
		}

		for (a = 0; a < pivot; a++) {
			prev = plane[a] - center;
			s = k*(prev dot proj);
			prev += Normal(move)*s + center + move;			
			Vertexv(prev);
			plane[a] = prev + Normal(next)*s;
		}
		center += move;
	}
	
	cnt -= pivot + 1;
	for (i = 1; i <= cnt; i++) {
		b = i*pivot;
		for (a = 0; a < pivot; a++) {
			c = b + a + 1 - pivot;
			if (a == pivot - 1) c -= pivot;
			if (bTesselate) {
				Poly3i(d, c, b + a, b + a - pivot, 'Side', flags);
				Poly3i(d, c + pivot, b + a, c, 'Side', flags);
			} else {
				Poly4i(d, c, c + pivot, b + a, b + a - pivot, 'Side', flags);
			}
			if (pivot == 2) break;
		}
	}
	
	if (pivot > 2) {
		PolyBegin(d, 'End', flags);
		v = GetVertexCount() - pivot;
		for (i = 0; i < pivot; i++) Polyi(v + i);
		PolyEnd();
	}
	
	return EndBrush();
}

defaultproperties {
	BitmapFilename="Extruder"
	ToolTip="Extruder for build brush by ClipMarkers path"
}
