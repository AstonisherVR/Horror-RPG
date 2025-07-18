class_name Bedroom extends Node2D

@onready var girl: Player = %Girl
@onready var wake_up_animation: Node = %"Wake up Animation"
@onready var girl_name = girl.player_name
var remember_girl_speed: float = 0
var pinki_interaction_one_activated: bool = false
static var total_full_string_line_placed: int = 0
@onready var key: Sprite2D = $Key

func _ready() -> void:
	wake_up_sequence()
	pass

func _process(delta: float) -> void:
	if total_full_string_line_placed >= 2:
		key.show()

func wake_up_sequence() -> void:
	key.hide()
	girl_talking()
	#print("Start wake up sequence")
	wake_up_animation.show()
	wake_up_animation.start()
	await wake_up_animation.wake_up
	await get_tree().create_timer(.75).timeout

	Dialogs.show_dialog("Wha...", girl_name)
	await wait_for_dialog_to_end()
	#print("Line 1 finished")
	Dialogs.update_text_only("M-Mom? Dad?")
	await wait_for_dialog_to_end()
	#print("Line 2 finished")
	Dialogs.update_text_only("My room! It's different...")
	await wait_for_dialog_to_end()
	Dialogs.update_text_only("Why is my room different?")
	await wait_for_dialog_to_end()
	Dialogs.update_text_only("What's going on?")
	await wait_for_dialog_to_end()
	girl_idle()

func wait_for_dialog_to_end() -> void:
	if not Dialogs.active:
		await Dialogs.dialog_started
	await Dialogs.dialog_ended

func girl_talking():
	girl.state = girl.State.TALKING

func girl_idle():
	girl.state = girl.State.IDLE
