class_name Player extends CharacterBody2D
signal health_changed(current_hp)

@export var walk_speed: int = 768
@onready var player_sprites: AnimatedSprite2D = %"Player Sprites"

enum State { IDLE, WALKING, TALKING }

var state: State = State.IDLE
var facing: StringName = &"down"
var player_name: StringName = &"Ivy"

func _ready() -> void:
	_move_to_spawnpoint()
	_connect_to_dialog_system()

func _physics_process(_delta: float) -> void:
	match state:
		State.IDLE:
			process_idle_state()
		State.WALKING:
			process_walking_state()
		State.TALKING:
			process_talking_state()
	update_animation()

func process_idle_state() -> void:
	if _get_input_dir() != Vector2.ZERO:
		state = State.WALKING

func process_walking_state() -> void:
	var dir: Vector2 = _get_input_dir()
	if dir != Vector2.ZERO:
		velocity = dir * walk_speed
		if abs(dir.x) >= abs(dir.y):
			facing = "left" if dir.x < 0 else "right"
		else:
			facing = "up" if dir.y < 0 else "down"
	else:
		velocity = Vector2.ZERO
		state = State.IDLE
	move_and_slide()

func process_talking_state() -> void:
	velocity = Vector2.ZERO

func update_animation() -> void:
	player_sprites.flip_h = (facing == "left")
	if velocity == Vector2.ZERO:
		player_sprites.stop()
		player_sprites.frame = 1
	else:
		player_sprites.play("walk_" + facing)

func go_to_idle() -> void:
	velocity = Vector2.ZERO
	state = State.IDLE

func _get_input_dir() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

# Setup functions
func _move_to_spawnpoint() -> void:
	var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	for spawnpoint in spawnpoints:
		if spawnpoint.name == Globals.spawnpoint:
			global_position = spawnpoint.global_position
			break

func _connect_to_dialog_system() -> void:
	var connection_result = (
		Dialogs.dialog_started.connect(_on_dialog_started) == OK and
		Dialogs.dialog_ended.connect(_on_dialog_ended) == OK)
	if not connection_result:
		push_error("Failed to connect to dialog system")

# Signal handlers
func _on_dialog_started() -> void:
	state = State.TALKING
	player_sprites.stop()

func _on_dialog_ended() -> void:
	state = State.IDLE
