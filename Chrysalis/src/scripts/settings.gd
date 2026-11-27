extends Control


@export var embedded_mode: bool = false
@export var game_difficulty: String = "Normal"

@onready var settingsContainer: VBoxContainer = %SettingsContainer
@onready var selectedSetting: VBoxContainer = %RightPanel/MarginContainer/SelectedSetting
@onready var selectedTitle: Label = selectedSetting.get_node("SelectedTitle")
@onready var controls_container = selectedSetting.get_node("ControlsContainer")
@onready var return_button: TextureButton = $ReturnButton

signal closed

const TABS := {
	"AudioButton": ["AUDIO", "AudioContainer"],
	"ControlsButton": ["CONTRÔLES", "ControlsContainer"],
	"DifficultyButton": ["DIFFICULTÉ", "DifficultyContainer"],
}

var selected_tab: String = "AudioButton"


func _ready() -> void:
	for button_name: String in TABS:
		var button: TextureButton = settingsContainer.get_node(button_name)

		button.focus_entered.connect(_on_tab_focused.bind(button_name))
		button.pressed.connect(_on_tab_pressed.bind(button_name))

	controls_container.controls_rebuilt.connect(_configure_binding_navigation)

	show_tab("AudioButton")

	_sync_difficulty()
	_configure_binding_navigation()

	if not embedded_mode:
		call_deferred("_focus_selected_tab")


func show_tab(button_name: String) -> void:
	if not TABS.has(button_name):
		return

	if selected_tab == "ControlsButton" and button_name != selected_tab:
		controls_container.cancel_rebinding()

	selected_tab = button_name

	# Un seul état de sélection pilote le titre, le panneau ET les boutons.
	for name_in_group: String in TABS:
		var button: TextureButton = settingsContainer.get_node(name_in_group)

		button.set_pressed_no_signal(name_in_group == selected_tab)
		selectedSetting.get_node(TABS[name_in_group][1]).visible = name_in_group == selected_tab

	selectedTitle.text = TABS[selected_tab][0]

	var active: Control = settingsContainer.get_node(selected_tab)

	return_button.focus_neighbor_right = return_button.get_path_to(_first_setting())
	return_button.focus_neighbor_top = return_button.get_path_to(active)


func _on_tab_focused(button_name: String) -> void:
	Audio.play_sfx(&"navigate")
	show_tab(button_name)


func _on_tab_pressed(button_name: String) -> void:
	Audio.play_sfx(&"click")
	show_tab(button_name)

	_first_setting().grab_focus()


func _first_setting() -> Control:
	match selected_tab:
		"ControlsButton":
			return controls_container.keyboardButtun
		"DifficultyButton":
			return selectedSetting.get_node("DifficultyContainer/EasyButton")

	return selectedSetting.get_node("AudioContainer/MasterContainer/Slider")


func _focus_selected_tab() -> void:
	if is_visible_in_tree():
		settingsContainer.get_node(selected_tab).grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or event.is_echo() or is_rebinding():
		return

	if not event.is_action_pressed("ui_cancel"):
		return
		
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null and selectedSetting.is_ancestor_of(focused):
		# Depuis un curseur, gauche/droite règlent le volume. Échap sort du panneau.
		_focus_selected_tab()
		get_viewport().set_input_as_handled()

	elif not embedded_mode:
		get_viewport().set_input_as_handled()
		_on_return_button_pressed()
	# En mode intégré, le menu pause gère le second Échap pour fermer les options.


func _configure_binding_navigation() -> void:
	var rows: Array = controls_container.get_binding_rows()
	var keyboard: Button = controls_container.keyboardButtun
	var gamepad: Button = controls_container.gamepadButtun
	var tab: Control = settingsContainer.get_node("ControlsButton")
	var first: Control = rows[0][0] if not rows.is_empty() else return_button

	keyboard.focus_neighbor_bottom = keyboard.get_path_to(first)
	gamepad.focus_neighbor_bottom = gamepad.get_path_to(first)
	keyboard.focus_next = keyboard.get_path_to(gamepad)
	gamepad.focus_next = gamepad.get_path_to(first)

	for row_index in range(rows.size()):
		var row: Array = rows[row_index]

		for column in range(row.size()):
			var button: Button = row[column]
			var left: Control = row[column - 1] if column > 0 else tab
			var right: Control = row[column + 1] if column + 1 < row.size() else button
			var up: Control = gamepad
			var down: Control = return_button

			if row_index > 0:
				var above: Array = rows[row_index - 1]
				up = above[mini(column, above.size() - 1)]
			if row_index + 1 < rows.size():
				var below: Array = rows[row_index + 1]
				down = below[mini(column, below.size() - 1)]

			button.focus_neighbor_left = button.get_path_to(left)
			button.focus_neighbor_right = button.get_path_to(right)
			button.focus_neighbor_top = button.get_path_to(up)
			button.focus_neighbor_bottom = button.get_path_to(down)

			button.focus_previous = button.get_path_to(row[column - 1] if column > 0 else up)
			button.focus_next = button.get_path_to(row[column + 1] if column + 1 < row.size() else down)


func _sync_difficulty() -> void:
	var names := {"EasyButton": "Easy", "NormalButton": "Normal", "DifficultButton": "Difficult"}
	if game_difficulty not in names.values():
		game_difficulty = "Normal"
		
	for button_name: String in names:
		var button: TextureButton = selectedSetting.get_node("DifficultyContainer/" + button_name)
		button.set_pressed_no_signal(names[button_name] == game_difficulty)


func _on_easy_button_pressed() -> void:
	game_difficulty = "Easy"
	_sync_difficulty()

func _on_normal_button_pressed() -> void:
	game_difficulty = "Normal"
	_sync_difficulty()

func _on_difficult_button_pressed() -> void:
	game_difficulty = "Difficult"
	_sync_difficulty()


func _on_return_button_pressed() -> void:
	if embedded_mode:
		close()
	else:
		Audio.save_volumes()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func open() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	show()
	show_tab("AudioButton")
	_focus_selected_tab()


func close() -> void:
	Audio.save_volumes()
	controls_container.cancel_rebinding()
	hide()
	if embedded_mode:
		process_mode = Node.PROCESS_MODE_DISABLED
	closed.emit()


func is_rebinding() -> bool:
	return controls_container.waiting_for_input
