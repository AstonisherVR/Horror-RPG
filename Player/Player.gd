class_name Player extends CharacterBody2D
signal health_changed(current_hp)

@export var walk_speed: int = 1024 #768
@onready var player_sprites: AnimatedSprite2D = %"Player Sprites"

enum State { IDLE, WALKING, TALKING }

var state: State = State.IDLE
var facing: StringName = &"down"
var player_name: StringName = &"Ivy"
var move_dir: Vector2 = Vector2.ZERO
var target_position: Vector2
var is_moving: bool = false
const TILE_SIZE: int = 128

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
	var input_dir = _get_input_dir()
	if input_dir != Vector2.ZERO:
		# Start moving
		move_dir = input_dir.snapped(Vector2.ONE)  # Normalize to one axis
		_set_facing(move_dir)
		target_position = global_position + move_dir * TILE_SIZE
		is_moving = true
		state = State.WALKING

func _set_facing(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		facing = "left" if dir.x < 0 else "right"
	else:
		facing = "up" if dir.y < 0 else "down"

func process_walking_state() -> void:
	if is_moving:
		var to_target = target_position - global_position
		var step = move_dir * walk_speed * get_physics_process_delta_time()
		if step.length() >= to_target.length():
			global_position = target_position
			is_moving = false
			# Check input and continue walking if same direction is held
			var input_dir: Vector2 = _get_input_dir()
			if input_dir == move_dir:
				# Queue next tile
				target_position += move_dir * TILE_SIZE
				is_moving = true
			else:
				state = State.IDLE
		else:
			global_position += step

func process_talking_state() -> void:
	velocity = Vector2.ZERO

func update_animation() -> void:
	player_sprites.flip_h = (facing == "left")
	if is_moving:
		player_sprites.play("walk_" + facing)
	else:
		player_sprites.stop()
		player_sprites.frame = 1

func go_to_idle() -> void:
	velocity = Vector2.ZERO
	state = State.IDLE

func _get_input_dir() -> Vector2:
	var raw_input = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if abs(raw_input.x) > abs(raw_input.y):
		return Vector2(sign(raw_input.x), 0)
	elif abs(raw_input.y) > 0:
		return Vector2(0, sign(raw_input.y))
	return Vector2.ZERO

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

func _on_dialog_started() -> void:
	state = State.TALKING
	player_sprites.stop()

func _on_dialog_ended() -> void:
	state = State.IDLE
