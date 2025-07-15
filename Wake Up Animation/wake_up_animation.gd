extends Node2D
signal wake_up

@onready var anim: AnimationPlayer = %AnimationPlayer

func start():
	anim.play("open")
	await anim.animation_finished
	wake_up.emit()
	queue_free()
