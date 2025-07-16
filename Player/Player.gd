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
	if input_dir == Vector2.ZERO:
		return

	var next_pos = global_position + input_dir * TILE_SIZE
	var can_move = true

	# Wall check (example - use your own check here)
	if is_tile_blocked(next_pos):
		can_move = false

	# String check
	if string_attached:
		var is_backtracking = input_dir == -move_dir and string_positions.size() > 0 and next_pos == string_positions[-1]
		var is_forward = input_dir == move_dir

		if not is_backtracking and not is_forward:
			can_move = false
		elif not is_backtracking and strings_used >= string_limit:
			can_move = false

	if can_move:
		prev_direction = move_dir
		move_dir = input_dir
		target_position = next_pos
		is_moving = true
		_set_facing(move_dir)
		state = State.WALKING

func _set_facing(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		facing = "left" if dir.x < 0 else "right"
	else:
		facing = "up" if dir.y < 0 else "down"

func process_walking_state() -> void:
	if not is_moving:
		return

	var to_target = target_position - global_position
	var step = move_dir * walk_speed * get_physics_process_delta_time()

	if step.length() >= to_target.length():
		global_position = target_position
		is_moving = false

		# Handle string backtracking
		if string_attached and string_positions.size() > 0 and global_position == string_positions[-1]:
			var last_pos = string_positions.pop_back()
			remove_string_at(last_pos)
			strings_used -= 1
			print("Backtracked, string removed")

		# Handle forward string placing
		elif string_attached and prev_direction != Vector2.ZERO and strings_used < string_limit:
			var new_string_pos = global_position - (move_dir * TILE_SIZE * 0.5)
			create_string_at_position(new_string_pos)

		state = State.IDLE
	else:
		global_position += step

func is_tile_blocked(pos: Vector2) -> bool:
	var tilemap = get_parent().get_node("TileMap") # Adjust path as needed
	var cell = tilemap.local_to_map(pos)
	return tilemap.get_cell_source_id(0, cell) != -1 and tilemap.get_cell_tile_data(0, cell).get_custom_data("is_wall") == true

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
