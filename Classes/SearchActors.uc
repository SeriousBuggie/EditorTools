//=============================================================================
// SearchActors.
//=============================================================================
class SearchActors expands BrushBuilder;

var() LevelInfo LevelInfo;
var() string SearchInProperty;
var() string SearchText;
var() bool SearchInName;
var() bool SearchInEvent;
var() bool SearchInTag;
var() bool HideNotMatch;
var() const enum EMatch
{
	MATCH_Inside,
	MATCH_Exact,
	MATCH_Started,
	MATCH_Ended
} TypeMatch;
var() bool SearchIgnoreCase;
var() name OnlySubclassOf;
var() bool OnlyInVisible;

var() bool ShowHelp;

var int cnt;

function bool Find(coerce string haystack, string needle, int strlen) {
	if (SearchIgnoreCase) haystack = Caps(haystack);
	switch (TypeMatch) {
		case MATCH_Inside: return InStr(haystack, needle) >= 0;
		case MATCH_Exact: return haystack == needle;
		case MATCH_Started: return Left(haystack, strlen) == needle;
		case MATCH_Ended: return Right(haystack, strlen) == needle;
	}
}

event bool Build() {
	local Actor actor;
	local string str, Property, haystack, target;
	local name Subclass;
	local int i, strlen;
	local bool InName, InEvent, InTag, InProperty, InSubclass, InVisible;
	local CodeTrigger CodeTrigger;
	local Dispatcher Dispatcher;
	local FatnessTrigger FatnessTrigger;
	local RoundRobin RoundRobin;
	local StochasticTrigger StochasticTrigger;

	if (LevelInfo == None) {
		SetPropertyText("LevelInfo", "MyLevel.LevelInfo0");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo1");
		if (LevelInfo == None) SetPropertyText("LevelInfo", "MyLevel.LevelInfo2");
		if (LevelInfo == None) return BadParameters("Please specify LevelInfo");
	}
	
	// Local vars must be faster
	Property = SearchInProperty;
 	InProperty = Property != "" && Property != " " && Property != "None";
 	str = SearchText;
	InName = SearchInName;
	InEvent = SearchInEvent;
	InTag = SearchInTag;
	Subclass = OnlySubclassOf;
	InSubclass = Subclass != 'None' && Subclass != '';
	InVisible = OnlyInVisible;

	cnt = 0;
	
	if (ShowHelp || !(str != "" || (InProperty && TypeMatch == MATCH_Exact))) {
		str = "";
		if (!ShowHelp) {
			str = str$"Please specify SearchText in options (RMB click on button)"$Chr(13)$Chr(10);
			str = str$""$Chr(13)$Chr(10);
		}
		str = str$"usage:"$Chr(13)$Chr(10);
		str = str$"    - SearchInProperty empty - search over Event and Tag properties. Even if they specified not in standard fields, like OutEvents in Dispatcher. Supported only standard classes: Dispatcher, StochasticTrigger, RoundRobin, CodeTrigger, FatnessTrigger."$Chr(13)$Chr(10);
		str = str$""$Chr(13)$Chr(10);
		str = str$"    - SearchInProperty not empty - search desired text in specified property. SearchInName, SearchInEvent, SearchInTag - ignored. Search text can be empty if TypeMatch == MATCH_Exact."$Chr(13)$Chr(10);
		return BadParameters(str);
	}
	LevelInfo.ConsoleCommand("ShowLog");
	
	if (SearchIgnoreCase) str = Caps(str);
	strlen = Len(str);
	
	Log("");
	if (InProperty) target = Property$" = ";
	target = target$"'"$str$"'";
	if (InSubclass) target = target$" in "$Subclass;
	Log("------- Search for "$target$" started:");
	foreach LevelInfo.AllActors(class'Actor', actor) {
		if (InVisible && actor.bHiddenEd) continue;
		if (HideNotMatch) actor.bHiddenEd = true;
		if (InSubclass && !actor.isA(Subclass)) continue;
		if (InProperty) {
			haystack = actor.GetPropertyText(Property);
			if (Find(haystack, str, strlen)) {
				Found(actor, Property, haystack);
			}
			continue;
		}
		if (InName && Find(actor.Name, str, strlen)) {
			Found(actor, "Name"); continue;			
		}
		if (InEvent && Find(actor.Event, str, strlen)) {
			Found(actor, "Event", actor.Event); continue;
		}
		if (InTag && Find(actor.Tag, str, strlen)) {
			Found(actor, "Tag", actor.Tag); continue;
		}
		Dispatcher = Dispatcher(actor);
		if (Dispatcher != None) {
			for (i = 0; i < 8; i++) {
				if (Find(Dispatcher.OutEvents[i], str, strlen)) {
					Found(actor, "OutEvents["$i$"]", Dispatcher.OutEvents[i]); break;
				}
			}
			continue;
		}
		StochasticTrigger = StochasticTrigger(actor);
		if (StochasticTrigger != None) {
			for (i = 0; i < 6; i++) {
				if (Find(StochasticTrigger.Events[i], str, strlen)) {
					Found(actor, "Events["$i$"]", StochasticTrigger.Events[i]); break;
				}
			}
			continue;
		}
		RoundRobin = RoundRobin(actor);
		if (RoundRobin != None) {
			for (i = 0; i < 16; i++) {
				if (Find(RoundRobin.OutEvents[i], str, strlen)) {
					Found(actor, "OutEvents["$i$"]", RoundRobin.OutEvents[i]); break;	
				}
			}
			continue;
		}
		CodeTrigger = CodeTrigger(actor);
		if (CodeTrigger != None) {
			if (Find(CodeTrigger.CodeMasterTag, str, strlen)) {
				Found(actor, "CodeMasterTag", CodeTrigger.CodeMasterTag);
			}
			continue;			
		}
		FatnessTrigger = FatnessTrigger(actor);
		if (FatnessTrigger != None) {
			if (Find(FatnessTrigger.FatTag, str, strlen)) {
				Found(actor, "FatTag", FatnessTrigger.FatTag);
			}
			continue;
		}
	}
	log("------- Search for "$target$" ended. Found"@cnt@"results.");
	
	return false;
}

function Found(Actor actor, string where, optional coerce string value) {
	local string msg;
	local int i;
	
	msg = string(actor.Name);
	for (i = Len(msg); i < 21; i++) msg = msg$" ";
	msg = msg$" "$where;
	if (value != "") {
		for (i = Len(msg); i < 35; i++) msg = msg$" ";
		msg = msg$" '"$value$"'";
	}

	Log(msg);
	cnt++;
	
	if (HideNotMatch) actor.bHiddenEd = false;
}

defaultproperties {
	BitmapFilename="SearchActors"
	ToolTip="Search for Actors by Event or Tag even in custom fields"
	SearchInEvent=True
	SearchInTag=True
}
