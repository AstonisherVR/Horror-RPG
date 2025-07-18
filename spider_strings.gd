class_name Spider_Strings
extends Sprite2D


func setup(type: StringName, prev_dir: Vector2, current_dir: Vector2) -> void:
	if type == "String Line":
		frame = 1
		if current_dir.x != 0:
			rotation = 0
		else:
			rotation = deg_to_rad(90)

	elif type == "String Edge":
		frame = 0
		if prev_dir == Vector2.RIGHT and current_dir == Vector2.DOWN:
			rotation_degrees = 90
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
	
	# Run tween animation
	var t = create_tween()  # Ensure a Tween node is added in the scene

	scale = Vector2(0.5, 1.5)  # Initial squashed state

	# Squashed -> Stretched
	t.tween_property(self, "scale", Vector2(1.5, 0.5), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Stretched -> Normal
	t.tween_property(self, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
