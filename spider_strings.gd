class_name Spider_Strings extends Sprite2D

func setup(type: StringName, prev_dir: Vector2, current_dir: Vector2) -> void:
	if type == "String Line":
		frame = 0
		if current_dir.x != 0:
			rotation = 0
		else:
			rotation = deg_to_rad(90)

	elif type == "String Edge":
		frame = 1
		# Determine correct rotation based on the corner direction
		if prev_dir == Vector2.RIGHT and current_dir == Vector2.DOWN:
			rotation_degrees = 90
			#flip_h = true
		elif prev_dir == Vector2.RIGHT and current_dir == Vector2.UP:
			rotation_degrees = 180
		elif prev_dir == Vector2.DOWN and current_dir == Vector2.LEFT:
			rotation_degrees = 180
		elif prev_dir == Vector2.DOWN and current_dir == Vector2.RIGHT:
			rotation_degrees = -90
		elif prev_dir == Vector2.LEFT and current_dir == Vector2.UP:
			rotation_degrees = 270
		elif prev_dir == Vector2.UP and current_dir == Vector2.RIGHT:
			rotation_degrees = 270
			flip_h = true
		elif prev_dir == Vector2.UP and current_dir == Vector2.LEFT:
			flip_h = true
