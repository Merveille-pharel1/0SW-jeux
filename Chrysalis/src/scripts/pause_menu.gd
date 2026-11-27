class_name PauseMenu
extends CanvasLayer

@export var pause_action: StringName = &"pause"
@export_file("*.tscn") var main_menu_path := "res://scenes/main_menu.tscn"

@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton
@onready var center: CenterContainer = $Root/CenterContainer
@onready var options_host: Control = $Root/OptionsHost
@onready var status_label: Label = %Status
@onready var options_menu: Control = $Root/OptionsHost/OptionsMenu

var _owns_pause := false
var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:

	for button: Button in [resume_button, options_button, main_menu_button, quit_button]:
		button.mouse_entered.connect(button.grab_focus)
		button.focus_entered.connect(Audio.play_sfx.bind(&"navigate"))
		button.pressed.connect(Audio.play_sfx.bind(&"click"))

	resume_button.pressed.connect(resume)
	options_button.pressed.connect(_open_options)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	options_menu.closed.connect(_on_options_closed)



func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	if options_menu != null and options_menu.visible and options_menu.has_method("is_rebinding"):
		if options_menu.call("is_rebinding"):
			return
	
	var wants_pause := event.is_action_pressed(pause_action)
	var wants_back := visible and event.is_action_pressed("ui_cancel")
	if not wants_pause and not wants_back:
		return

	get_viewport().set_input_as_handled()

	if options_menu != null and options_menu.visible:
		options_menu.call("close")
	elif visible:
		resume()
	else:
		pause()


func pause() -> void:
	if visible or get_tree().paused:
		return

	_owns_pause = true
	_previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	get_tree().paused = true

	status_label.text = "Reprendre l’aventure"

	center.show()
	show()

	resume_button.grab_focus()


func resume() -> void:
	if options_menu != null and options_menu.visible:
		options_menu.call("close")

	_release_focus()

	hide()

	if _owns_pause:
		get_tree().paused = false

	_owns_pause = false
	Input.mouse_mode = _previous_mouse_mode


func _open_options() -> void:
	center.hide()
	options_host.show()
	options_menu.call("open")


func _on_options_closed() -> void:
	options_host.hide()
	center.show()

	if visible:
		options_button.grab_focus()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false

	_owns_pause = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var error := get_tree().change_scene_to_file(main_menu_path)

	if error != OK:
		get_tree().paused = true
		_owns_pause = true
		status_label.text = "Impossible d’ouvrir le menu principal."
		push_error("PauseMenu : chemin incorrect : " + main_menu_path)


func _on_quit_pressed() -> void:
	get_tree().paused = false
	_owns_pause = false
	get_tree().quit()


func _release_focus() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null and is_ancestor_of(focused):
		focused.release_focus()


func _exit_tree() -> void:
	if _owns_pause:
		get_tree().paused = false
		Input.mouse_mode = _previous_mouse_mode
