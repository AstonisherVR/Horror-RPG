extends TextureRect
class_name DialogBox

"""
Exposes the show_dialog function to the Dialogs singleton.
Will show a dialog box with the name of the character and
dialog text, two lines at a time.
"""

@onready var dialog_text = $dialog_text

# warning-ignore:unused_signal
signal dialog_started
# warning-ignore:unused_signal
signal dialog_ended

var lines_to_skip = 0

func _ready():
	Dialogs.dialog_box = self
	hide()

func show_dialog(new_text, speaker):
	print("DialogBox.show_dialog() -> ", new_text, speaker)
	dialog_text.text = new_text
	$nametag/label.text = speaker
	lines_to_skip = 0
	dialog_text.lines_skipped = lines_to_skip
	$anims.play("appear")
	emit_signal("dialog_started")

func _input(event):
	if event.is_action_pressed("interact"):
		match $anims.assigned_animation:
			"show_text":
				$anims.play("wait")
			"wait":
				lines_to_skip += 2
				if lines_to_skip < dialog_text.get_line_count():
					dialog_text.lines_skipped = lines_to_skip
					$anims.play("show_text")
				else:
					$anims.play("disappear")

func update_dialog_text(new_text: String):
	if dialog_text.text == new_text:
		return
	dialog_text.text = new_text
	lines_to_skip = 0
	dialog_text.lines_skipped = 0
	$anims.play("show_text")
	emit_signal("dialog_started")
