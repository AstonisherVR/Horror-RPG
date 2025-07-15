extends StaticBody2D

@export var to_scene = "" # (String, FILE, "*.tscn")
@export var spawnpoint: String = ""

func _ready():
	$to_inside.to_scene = to_scene
	$to_inside.spawnpoint = spawnpoint
