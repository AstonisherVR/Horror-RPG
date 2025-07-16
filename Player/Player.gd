class_name Player extends CharacterBody2D

@export var walk_speed: int = 1536 #768
@onready var player_sprites: AnimatedSprite2D = %"Player Sprites"

const TILE_SIZE: int = 512
const SPIDER_STRINGS: PackedScene = preload("res://spider_strings.tscn") 

enum State { IDLE, WALKING, TALKING }
var state: State = State.IDLE

var move_dir: Vector2
var target_position: Vector2
var prev_direction: Vector2

var facing: StringName = &"down"
var player_name: StringName = &"Ivy"

var is_moving: bool = false
var string_attached: bool = false

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
				target_position += move_dir * TILE_SIZE
				is_moving = true
	
				if string_attached:
					var new_string: Node2D = SPIDER_STRINGS.instantiate()
					var string_type = get_string_type(prev_direction, move_dir)
					new_string.lines[string_type].visible = true
					new_string.global_position = global_position + (move_dir * TILE_SIZE * 0.5)

					add_sibling(new_string)
					prev_direction = move_dir

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

func get_string_type(prev: Vector2, current: Vector2) -> StringName:
	if prev == current:
		if current.x != 0:
			return "String Horizontal"
		elif current.y != 0:
			return "String Vertical"
	else:
		if prev == Vector2.RIGHT and current == Vector2.UP: return "Edge Up Right"
		if prev == Vector2.LEFT and current == Vector2.UP: return "Edge Up Left"
		if prev == Vector2.RIGHT and current == Vector2.DOWN: return "Edge Down Right"
		if prev == Vector2.LEFT and current == Vector2.DOWN: return "Edge Down Left"
		if prev == Vector2.DOWN and current == Vector2.RIGHT: return "Edge Down Right"
		if prev == Vector2.UP and current == Vector2.RIGHT: return "Edge Up Right"
		if prev == Vector2.DOWN and current == Vector2.LEFT: return "Edge Down Left"
		if prev == Vector2.UP and current == Vector2.LEFT: return "Edge Up Left"

	return "String Horizontal"


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
