class_name Bedroom extends Node2D

@onready var girl: Player = %Girl
@onready var wake_up_animation: Node = %"Wake up Animation"
@onready var girl_name = girl.player_name
var remember_girl_speed: float = 0
var pinki_interaction_one_activated: bool = false
static var total_strings_placed: int = 0

func _ready() -> void:
	wake_up_sequence()
	pass

func wake_up_sequence() -> void:
	disable_speed()
	#print("Start wake up sequence")
	
	#wake_up_animation.show()
	#wake_up_animation.start()
	#await wake_up_animation.wake_up
	#await get_tree().create_timer(.5).timeout
	Dialogs.show_dialog("...", girl_name)
	await wait_for_dialog_to_end()
	#print("Line 1 finished")
	Dialogs.update_text_only("Something has changed here...")
	await wait_for_dialog_to_end()
	#print("Line 2 finished")
	Dialogs.update_text_only("I need to understand what's going on.")
	await wait_for_dialog_to_end()
	enable_speed()

func wait_for_dialog_to_end() -> void:
	if not Dialogs.active:
		await Dialogs.dialog_started
	await Dialogs.dialog_ended

func disable_speed():
	remember_girl_speed = girl.walk_speed
	girl.walk_speed = 0

func enable_speed():
	girl.walk_speed = remember_girl_speed
	remember_girl_speed = 0
