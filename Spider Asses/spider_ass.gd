extends Area2D

@export var max_strings: int = 1
var in_use: bool = false
var player_in: bool = false
var player: Player

func _unhandled_input(event: InputEvent) -> void:
	if player == null: return
	if event.is_action_pressed("interact"):
		if player_in and !player.string_attached:
			in_use = true
			player.connect_to_spider(self)
			print("player holding string")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player_in = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		player_in = false
