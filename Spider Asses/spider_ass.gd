class_name Ass_Spider extends Area2D

@export var max_strings: int = 1
var in_use: bool = false
var player_in: bool = false
var player: Player

func _ready() -> void:
	hide()

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

func apear():
	var show_time = .5
	var distance = 512
	show()
	var t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	if self.is_in_group("Down"):
		t.tween_property(self, "global_position:y", global_position.y + distance, show_time)
	elif self.is_in_group("Up"):
		t.tween_property(self, "global_position:y", global_position.y - distance, show_time)
	elif self.is_in_group("Right"):
		t.tween_property(self, "global_position:x", global_position.x + distance, show_time)
	elif self.is_in_group("Left"):
		t.tween_property(self, "global_position:x", global_position.x - distance, show_time)
