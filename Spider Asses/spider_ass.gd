class_name Ass_Spider extends Area2D

@export var msssax_strings: int = 1
var in_use: bool = false
var player_in: bool = false
var player: Player
@onready var above_text: Label = %"Above Text"

func _ready() -> void:
	hide()
	apear()
	above_text.hide()

func _unhandled_input(event: InputEvent) -> void:
	if player == null: return
	if event.is_action_pressed("interact"):
		if player_in and !player.string_attached and !player.is_moving and in_use == false:
			in_use = true
			player.connect_to_spider(self)
			print("player holding string")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player_in = true
		if in_use == false and !player.string_attached:
			above_text.show()
		else:
			above_text.hide()
		
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		player_in = false
		above_text.hide()

func apear():
	var show_time = .5
	var distance = 512
	show()
	var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	if self.is_in_group("Down"):
		t.tween_property(self, "global_position:y", global_position.y - distance, show_time)
	elif self.is_in_group("Up"):
		t.tween_property(self, "global_position:y", global_position.y + distance, show_time)
	elif self.is_in_group("Right"):
		t.tween_property(self, "global_position:x", global_position.x + distance, show_time)
	elif self.is_in_group("Left"):
		t.tween_property(self, "global_position:x", global_position.x - distance, show_time)

func disconnect_player():
	in_use = false
	player = null
	player_in = false

func follow_string_path(path: Array[Vector2]) -> void:
	if path.is_empty():
		print("No path to follow.")
		return

	print("Spider following path:", path)
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT_IN)

	var duration_per_step := 0.25 # seconds per string step
	var delay := 0.0

	for point in path:
		tween.tween_property(self, "global_position", point, duration_per_step).set_delay(delay)
		delay += duration_per_step

	tween.tween_callback(func():
		print("Spider finished moving.")
		in_use = false)
