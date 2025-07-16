extends Node2D

var lines: Dictionary[StringName, Line2D] = {
&"String Vertical": %"String Line Vertical",
&"String Horizontal": %"String Line Horizontal",
&"Edge Up Right": %"Edge Line",
&"Edge Down Right": %"Edge Line 2",
&"Edge Down Left": %"Edge Line 3",
&"Edge Up Left": %"Edge Line 4"}

var area_points: Dictionary[StringName, Line2D] = {
&"Area Up": %"Area Up",
&"Area Right": %"Area RIght",
&"Area Down": %"Area Down",
&"Area Left": %"Area Left",}
