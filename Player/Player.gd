class_name Player
extends CharacterBody2D

@export var walk_speed: int = 1536
@onready var player_sprites: AnimatedSprite2D = $"Player Sprites"

const TILE_SIZE: int = 512
const SPIDER_STRINGS: PackedScene = preload("res://spider_strings.tscn")

enum State { IDLE, WALKING, TALKING }
var state: State = State.IDLE

var move_dir: Vector2 = Vector2.ZERO
var prev_direction: Vector2 = Vector2.ZERO

var target_position: Vector2 = Vector2.ZERO
var string_start_dir: Vector2 = Vector2.ZERO

var string_limit: int = 0
var strings_used: int = 0

var string_positions: Array[Vector2] = []

var facing: StringName = "down"
var player_name: StringName = "Ivy"

var is_holding_cancel: bool = false
static var is_moving: bool = false
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
		if state == State.IDLE and string_attached and not is_moving:
			cancel_current_string()

	if event.is_action_pressed("interact"):
		if is_moving: return
		if string_attached and is_web_tile(global_position):
			print("Placed string via interaction")
			string_attached = false
			Bedroom.total_strings_placed += 1

func cancel_current_string() -> void:
	if not string_attached:
		return
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

	if is_tile_blocked(next_pos):
		print("Blocked by wall at:", next_pos)
		can_move = false

	if string_attached:
		var is_backtracking = string_positions.size() > 0 and next_pos == string_positions[-1]
		var is_in_path = _is_string_at_position(next_pos)

		if is_backtracking:
			can_move = true
		elif is_in_path or strings_used >= string_limit:
			can_move = false
			print("Blocked: in path or limit reached.")

	if can_move:
		#print("Moving from", global_position, "to", next_pos)
		prev_direction = move_dir
		move_dir = input_dir
		target_position = next_pos
		is_moving = true
		_set_facing(move_dir)
		state = State.WALKING

func process_walking_state() -> void:
	if not is_moving:
		return

	var to_target = target_position - global_position
	var step = move_dir * walk_speed * get_physics_process_delta_time()

	if step.length() >= to_target.length():
		global_position = target_position
		is_moving = false

		if string_attached:
			var backtracked = string_positions.size() > 0 and global_position == string_positions[-1]
			if backtracked:
				var last_pos = string_positions.pop_back()
				remove_string_at(last_pos)
				strings_used -= 1
				print("Backtracked, removed string at:", last_pos)
			elif strings_used < string_limit:
				var last_pos = global_position - move_dir * TILE_SIZE
				create_string_at_position(last_pos)

		state = State.IDLE
	else:
		global_position += step

func _set_facing(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		facing = "left" if dir.x < 0 else "right"
	else:
		facing = "up" if dir.y < 0 else "down"

func _is_string_at_position(pos: Vector2) -> bool:
	return pos in string_positions

func is_tile_blocked(pos: Vector2) -> bool:
	var tilemap = $"../Ground"
	var cell = tilemap.local_to_map(pos)
	if tilemap.get_cell_source_id(cell) == -1:
		return false
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data:
		return tile_data.get_custom_data("is_wall") == true
	return false

func process_talking_state() -> void:
	pass

func remove_string_at(pos: Vector2) -> void:
	for child in get_parent().get_children():
		if child is Spider_Strings and child.global_position == pos:
			child.queue_free()
			break

func is_web_tile(pos: Vector2) -> bool:
	var tilemap = $"../Ground"
	var cell = tilemap.local_to_map(pos)
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data:
		return tile_data.get_custom_data("web_tile") == true
	return false

func update_animation() -> void:
	player_sprites.flip_h = (facing == "left")
	if is_moving:
		player_sprites.play("walk_" + facing)
	else:
		player_sprites.stop()
		player_sprites.frame = 1

func _get_input_dir() -> Vector2:
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
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
	string_positions.append(pos)

	var new_string: Spider_Strings = SPIDER_STRINGS.instantiate()
	new_string.global_position = pos
	get_parent().add_child(new_string)

	# FIX: Calculate direction from *actual last string* to current pos
	var actual_prev_direction := Vector2.ZERO
	if string_positions.size() > 1:
		var prev_pos = string_positions[-2]
		actual_prev_direction = (pos - prev_pos).normalized()
	elif string_positions.size() == 1:
		actual_prev_direction = string_start_dir
	else:
		actual_prev_direction = move_dir


	var string_type: StringName = get_string_type(actual_prev_direction, move_dir)
	new_string.setup(string_type, actual_prev_direction, move_dir)

	print("String placed at", pos, "Type:", string_type)

func get_string_type(prev_dir: Vector2, current_dir: Vector2) -> StringName:
	return "String Line" if prev_dir == current_dir else "String Edge"

func _move_to_spawnpoint() -> void:
	var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	for spawnpoint in spawnpoints:
		if spawnpoint.name == Globals.spawnpoint:
			global_position = spawnpoint.global_position
			break

func _connect_to_dialog_system() -> void:
	Dialogs.dialog_started.connect(_on_dialog_started)
	Dialogs.dialog_ended.connect(_on_dialog_ended)

func connect_to_spider(spider: Node) -> void:
	string_attached = true
	string_limit = spider.max_strings
	strings_used = 0
	string_positions.clear()
	# Detect direction based on wall side (example assumes right wall)
	string_start_dir = (global_position - spider.global_position).normalized()
	print("Connected to spider. Limit:", string_limit, " Start Dir:", string_start_dir)

func snap_dir(dir: Vector2) -> Vector2:
	if abs(dir.x) > abs(dir.y):
		return Vector2(sign(dir.x), 0)
	else:
		return Vector2(0, sign(dir.y))

func _on_dialog_started() -> void:
	state = State.TALKING
	player_sprites.stop()

func _on_dialog_ended() -> void:
	state = State.IDLE
