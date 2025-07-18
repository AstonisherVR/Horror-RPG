extends Control

@onready var start_sfx: AudioStreamPlayer = %start_sfx
@onready var overlay_black: ColorRect = %"Overlay Black"

func _on_new_game_button_pressed() -> void:
	var t = create_tween().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_ELASTIC).parallel()
	t.tween_property(overlay_black, "color:a", 1.0, 2)
	start_sfx.play()
	%MenuContainer.hide()
	await start_sfx.finished
	await get_tree().create_timer(.5).timeout
	get_tree().change_scene_to_file("res://Levels/bedroom.tscn")

@export var options_packed_scene : PackedScene

func _juice_button(button: Button) -> void:
	var t = get_tree().create_tween()
	t.tween_property(button, "scale", Vector2(1.1, 1.2), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(button, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

var options_scene
var sub_menu

func _open_sub_menu(menu : Control) -> void:
	sub_menu = menu
	sub_menu.show()
	%BackButton.show()
	%MenuContainer.hide()

func _close_sub_menu() -> void:
	if sub_menu == null:
		return
	sub_menu.hide()
	sub_menu = null
	%BackButton.hide()
	%MenuContainer.show()

func _event_is_mouse_button_released(event : InputEvent) -> bool:
	return event is InputEventMouseButton and not event.is_pressed()

func _input(event : InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
		else:
			get_tree().quit()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		%MenuButtonsBoxContainer.focus_first()

func _hide_exit_for_web() -> void:
	if OS.has_feature("web"):
		%ExitButton.hide()

func _add_or_hide_options() -> void:
	if options_packed_scene == null:
		%OptionsButton.hide()
	else:
		options_scene = options_packed_scene.instantiate()
		options_scene.hide()
		%OptionsContainer.call_deferred("add_child", options_scene)

func _ready() -> void:
	_hide_exit_for_web()
	_add_or_hide_options()

func _on_options_button_pressed() -> void:
	_open_sub_menu(options_scene)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	_close_sub_menu()


func _on_exit_button_mouse_entered() -> void:
	_juice_button(%ExitButton)


func _on_options_button_mouse_entered() -> void:
	_juice_button(%OptionsButton)

func _on_new_game_button_mouse_entered() -> void:
	_juice_button(%NewGameButton)
