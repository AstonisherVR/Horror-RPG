extends Area2D

var in_use: bool = false
var player_in: bool = false
var player: Player

func _input(event):
	if player == null: return
	if event.is_action_pressed("interact"):
		if player_in and player.string_attached:
			in_use = true
			print("player_placed string")
			player.string_attached = false
			Bedroom.total_strings_placed += 1
			print("bedroom total strings ", Bedroom.total_strings_placed)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player_in = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		player_in = false
