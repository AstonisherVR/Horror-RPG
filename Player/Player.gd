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

var string_limit: int = 0
var strings_used: int = 0

var string_positions: Array[Vector2] = []

var facing: StringName = &"down"
var player_name: StringName = &"Ivy"

var is_holding_cancel: bool = false
var is_moving: bool = false
var string_attached: bool = false

func _ready() -> void:
	_move_to_spawnpoint()
	_connect_to_dialog_system()

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			process_idle_state()
		State.WALKING:
			process_walking_state()
		State.TALKING:
			process_talking_state()
	update_animation()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_string"):
		cancel_current_string()

func cancel_current_string() -> void:
	string_attached = false
	for pos in string_positions:
		remove_string_at(pos)
	string_positions.clear()
	strings_used = 0
	print("String canceled.")

func process_idle_state() -> void:
	var input_dir = _get_input_dir()
	if input_dir != Vector2.ZERO:
		# Start moving
		prev_direction = move_dir  # Store previous direction before updating
		move_dir = input_dir.snapped(Vector2.ONE)
		target_position = global_position + move_dir * TILE_SIZE
		is_moving = true
		_set_facing(move_dir)
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
			# Snap to target position
			global_position = target_position
			is_moving = false

			var input_dir: Vector2 = _get_input_dir().snapped(Vector2.ONE)

			# Handle backtracking (remove last string)
			if input_dir == -move_dir and string_positions.size() > 0:
				var last_pos = string_positions.pop_back()
				remove_string_at(last_pos)
				strings_used -= 1
				print("Backtracked, string removed")

			# Handle forward movement (place new string)
			elif string_attached and prev_direction != Vector2.ZERO:
				var new_string_pos = global_position - (move_dir * TILE_SIZE * 0.5)
				create_string_at_position(new_string_pos)
				string_positions.append(new_string_pos)
				strings_used += 1

			# Decide next action
			if input_dir == move_dir:
				# Continue moving
				prev_direction = move_dir
				target_position += move_dir * TILE_SIZE
				is_moving = true
			else:
				state = State.IDLE
		else:
			global_position += step

func process_talking_state() -> void:
	velocity = Vector2.ZERO

func remove_string_at(pos: Vector2) -> void:
	for child in get_parent().get_children():
		if child is Spider_Strings and child.global_position == pos:
			child.queue_free()
			break

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

func create_string_at_position(pos: Vector2) -> void:
	if strings_used >= string_limit:
		print("Reached string limit.")
		return

	strings_used += 1
	var new_string: Spider_Strings = SPIDER_STRINGS.instantiate()
	var string_type: StringName = get_string_type(prev_direction, move_dir)
	new_string.global_position = pos
	string_positions.append(new_string.global_position)
	add_sibling(new_string)
	new_string.lines[string_type].visible = true
	print("String placed: ", string_type)

func get_string_type(prev: Vector2, current: Vector2) -> StringName:
	var string_type: StringName
	if current.x != 0:
		string_type = &"String Horizontal"
	elif current.y != 0:
		string_type = &"String Vertical"
	else:
		string_type = &"String Horizontal"
	return string_type

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

func connect_to_spider(spider: Node):
	string_attached = true
	string_limit = spider.max_strings
	strings_used = 0

func _on_dialog_started() -> void:
	state = State.TALKING
	player_sprites.stop()

func _on_dialog_ended() -> void:
	state = State.IDLE
