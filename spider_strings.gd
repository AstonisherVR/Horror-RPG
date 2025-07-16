class_name Spider_Strings extends Node2D

@onready var lines: Dictionary[StringName, Line2D] = {
	&"String Vertical": %"String Line Vertical",
	&"String Horizontal": %"String Line Horizontal"}

@onready var area_points: Dictionary[StringName, Area2D] = {
	&"Area Up": %"Area Up",
	&"Area Right": %"Area Right",
	&"Area Down": %"Area Down",
	&"Area Left": %"Area Left"}
