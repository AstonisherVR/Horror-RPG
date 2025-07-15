class_name Player extends CharacterBody2D
signal health_changed(current_hp)

@export var walk_speed: int = 500
@export var hitpoints: int = 3
@onready var player_sprites: AnimatedSprite2D = %"Player Sprites"

enum State { BLOCKED, IDLE, WALKING }

var state: State = State.IDLE
var facing: String = "down"
var my_name: StringName = "Ivy"

func _ready() -> void:
	_move_to_spawnpoint()
	_connect_to_dialog_system()

func _physics_process(_delta: float) -> void:
	_process_state()
	_update_animation()

func _process_state() -> void:
	match state:
		State.IDLE:
			if _get_input_dir() != Vector2.ZERO:
				state = State.WALKING
		State.WALKING:
			_handle_movement()

func _update_animation() -> void:
	player_sprites.flip_h = (facing == "left")
	if velocity != Vector2.ZERO:
		player_sprites.play("walk_" + (facing if facing != "left" else "right"))
	else:
		player_sprites.stop()
		player_sprites.frame = 1

func _handle_movement() -> void:
	var direction = _get_input_dir()
	if direction != Vector2.ZERO:
		velocity = direction * walk_speed
		_update_facing(direction)
	else:
		_go_to_idle()
	move_and_slide()

func _update_facing(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		facing = "left" if direction.x < 0 else "right"
	else:
		facing = "up" if direction.y < 0 else "down"

func _go_to_idle() -> void:
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
	state = State.BLOCKED

func _on_dialog_ended() -> void:
	state = State.IDLE
