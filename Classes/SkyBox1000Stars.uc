//=============================================================================
// SkyBox1000Stars.
//=============================================================================
class SkyBox1000Stars expands BrushBuilder;

#exec OBJ LOAD FILE=..\Textures\GenFX.utx

var() LevelInfo LevelInfo;
var() int CountStars;
var() bool FullSphere;
var() float SizeStars;

event bool Build() {
	local SkyZoneInfo skybox;
	local BlockMonsters star;
	local float phi, radius, theta, r, s;
	local int i, j;
	local vector D;

	if (LevelInfo == None) {
		SetPropertyText("LevelInfo", "MyLevel.LevelInfo0");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo1");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo2");
		if (LevelInfo == None) return BadParameters("Please specify LevelInfo");
	}

	// https://stackoverflow.com/a/26127012/1504248
	phi = PI*(3.0 - Sqrt(5.0)); // golden angle in radians
	foreach LevelInfo.AllActors(class'SkyZoneInfo', skybox) {		
		for (j = 0; j < CountStars; j++) {
			i = Rand(100*CountStars);
			D.z = 1 - (i/float(100*CountStars - 1))*2;  // z goes from 1 to -1
			if (!FullSphere && D.z < 0) D.z = -D.z;
			
			radius = Sqrt(1 - D.z*D.z);  // radius at z
			
			theta = phi*i;  // golden angle increment
			
			D.x = Cos(theta)*radius;
	        D.y = Sin(theta)*radius;
			
			r = Rand(156) + 100;

			star = LevelInfo.Spawn(class'BlockMonsters', LevelInfo, '', skybox.Location + r*D);
			star.bHidden = False;
			star.SetPropertyText("Style", "STY_Translucent");
			switch (rand(28)) {
				case 0: star.Texture = Texture'GenFX.LensFlar.dot_a'; s = 4.0; break;
				case 1: star.Texture = Texture'GenFX.LensFlar.dot_b'; s = 3.5; break;
				case 2: star.Texture = Texture'GenFX.LensFlar.dot_c'; s = 1.5; break;
				case 3: star.Texture = Texture'GenFX.LensFlar.dotblue'; s = 4.0; break;
				case 4: star.Texture = Texture'GenFX.LensFlar.dotgrn'; s = 4.0; break;
				case 5: star.Texture = Texture'GenFX.LensFlar.dotpink'; s = 4.0; break;
				case 6: star.Texture = Texture'GenFX.LensFlar.flare2'; s = 1.5; break;
				case 7: star.Texture = Texture'GenFX.LensFlar.flare3'; s = 2.0; break;
				case 8: star.Texture = Texture'GenFX.LensFlar.flare4'; s = 2.0; break;
				case 9: star.Texture = Texture'GenFX.LensFlar.flare5'; s = 2.5; break;
				case 10: star.Texture = Texture'GenFX.LensFlar.flare6'; s = 1.5; break;
				case 11: star.Texture = Texture'GenFX.LensFlar.flare7'; s = 1.0; break;
				case 12: star.Texture = Texture'GenFX.LensFlar.haze1'; s = 4.0; break;
				case 13: star.Texture = Texture'GenFX.LensFlar.haze2'; s = 4.0; break;
				case 14: star.Texture = Texture'GenFX.LensFlar.lens1'; s = 1.5; break;
				case 15: star.Texture = Texture'GenFX.LensFlar.lens2'; s = 2.0; break;
				case 16: star.Texture = Texture'GenFX.LensFlar.new1'; s = 4.0; break;
				case 17: star.Texture = Texture'GenFX.LensFlar.new2'; s = 4.0; break;
				case 18: star.Texture = Texture'GenFX.LensFlar.new3'; s = 2.0; break;
				case 19: star.Texture = Texture'GenFX.LensFlar.softlens'; s = 2.0; break;
				case 20: star.Texture = Texture'GenFX.LensFlar.softlens2'; s = 2.0; break;
				case 21: star.Texture = Texture(DynamicLoadObject("GenFX.LensFlar.lensgr~1", Class'Texture')); s = 1.5; break;
				case 22: star.Texture = Texture(DynamicLoadObject("GenFX.LensFlar.flarel~6", Class'Texture')); s = 1.0; break;
				case 23: star.Texture = Texture(DynamicLoadObject("GenFX.LensFlar.1", Class'Texture')); s = 1.5; break;
				case 24: star.Texture = Texture(DynamicLoadObject("GenFX.LensFlar.2", Class'Texture')); s = 1.5; break;
				case 25: star.Texture = Texture(DynamicLoadObject("GenFX.LensFlar.3", Class'Texture')); s = 1.5; break;
				case 26: star.Texture = Texture(DynamicLoadObject("GenFX.LensFlar.5", Class'Texture')); s = 2.0; break;
				case 27: star.Texture = Texture(DynamicLoadObject("GenFX.LensFlar.6", Class'Texture')); s = 1.5; break;
			}			
			star.DrawScale = 0.01*(RAND(2) + 1)/s;
			star.bUnlit = True;
			star.LightBrightness = 0;
			star.LightRadius = 0;
			star.Group = 'SkyBox1000Stars';
		}

		return BadParameters("Stars to skybox added!");
	}
	return BadParameters("First add SkyZoneInfo to the level.");
}

defaultproperties {
	BitmapFilename="SkyBox1000Stars"
	ToolTip="SkyBox 1000 stars"
	CountStars=1000
	SizeStars=1.0
}
