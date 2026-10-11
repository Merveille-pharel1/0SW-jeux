extends VBoxContainer

@onready var actionsControl: VBoxContainer = $ScrollContainer/MarginContainer/ActionsControl
@onready var keyboardButtun: Button = $ModeControls/KeyboardButton
@onready var gamepadButtun: Button = $ModeControls/GamePadButton

const INPUT_CONFIG_PATH = "user://controls.cfg"
var modeControl := "keyboard"
var action_to_rebind: StringName = &""
var old_event: InputEvent = null
var current_button: Button = null
var waiting_for_input := false
var controls : Array
var buttons_group : ButtonGroup


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_controls()
	controls = getControls()
	showControls(controls, modeControl)

	update_font_weight(keyboardButtun)
	keyboardButtun.toggled.connect(func(_pressed): update_font_weight(keyboardButtun))
	gamepadButtun.toggled.connect(func(_pressed): update_font_weight(gamepadButtun))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if not waiting_for_input:
		return

	if modeControl == "keyboard" and not keyboardFilter(event):
		return

	if modeControl == "gamepad" and not gamepadFilter(event):
		return

	if not is_valid_input(event):
		return

	var new_event : InputEvent = event.duplicate()
	
	if new_event is InputEventKey:
		new_event.keycode = 0
		new_event.physical_keycode = event.physical_keycode

	if old_event != null:
		InputMap.action_erase_event(action_to_rebind, old_event)
	
	InputMap.action_add_event(action_to_rebind, new_event)

	print(new_event)
	print(new_event.as_text())
	print(current_button)
	current_button.text = new_event.as_text()
	current_button.set_meta("input_event", new_event)

	save_controls()

	current_button.button_pressed = false
	waiting_for_input = false
	get_viewport().set_input_as_handled()

	for button in buttons_group.get_buttons():
		button.disabled = false

func getControls() -> Array:
	var results := []

	var actions = InputMap.get_actions()

	for action in actions:
		if not action.begins_with("ui_") and not action.begins_with("debug_"):
			var events = InputMap.action_get_events(action)
			
			var keyboard_mouse_events = events.filter(keyboardFilter)

			var gamepad_events = events.filter(gamepadFilter)

			results.append({action: {"keyboard": keyboard_mouse_events, "gamepad": gamepad_events}})

	return results

func showControls(arrayControls: Array, type: String) -> void:

	buttons_group = ButtonGroup.new() 

	for control in arrayControls:
		var action = control.keys()[0]
		var events = control[action][type]

		var controlContainer = HBoxContainer.new()
		controlContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var label = Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = str(action)
		controlContainer.add_child(label)

		var eventsContainer = HBoxContainer.new()
		eventsContainer.size_flags_horizontal = Control.SIZE_SHRINK_END
		eventsContainer.add_theme_constant_override("separation", 10)
		
		if events.is_empty():
			var button := createButton(action, null)
			eventsContainer.add_child(button)

		for e in events:
			var button := createButton(action, e)
			eventsContainer.add_child(button)
		
		controlContainer.add_child(eventsContainer)

		var separator = HSeparator.new()

		var separatorStyle = StyleBoxLine.new()
		separatorStyle.color = Color("#65757D80")
		separatorStyle.thickness = 1
		separatorStyle.grow_begin = 0
		separatorStyle.grow_end = 0

		separator.add_theme_stylebox_override("separator", separatorStyle)
		separator.add_theme_constant_override("separation", 6)

		actionsControl.add_child(controlContainer)
		actionsControl.add_child(separator)



func start_rebinding(action: StringName, button: Button):

	if waiting_for_input:
		return

	for other_button in buttons_group.get_buttons():
		other_button.disabled = other_button != button

	action_to_rebind = action
	old_event = button.get_meta("input_event") if button.has_meta("input_event") else null
	current_button = button
	waiting_for_input = true

	button.text = "Appuyez une touche..."

func _on_keyboard_button_pressed() -> void:
	modeControl = "keyboard"
	reinitialize()
	showControls(controls, modeControl)


func _on_game_pad_button_pressed() -> void:
	modeControl = "gamepad"	
	reinitialize()
	showControls(controls, modeControl)


#region Helpers

func keyboardFilter(event: InputEvent) -> bool:
	return event is InputEventKey or event is InputEventMouseButton

func gamepadFilter(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion

func createButton(action: String, event: InputEvent) -> Button:
	var button = Button.new()

	button.toggle_mode = true
	button.button_group = buttons_group

	button.text = event.as_text() if event != null else "[vide]"
	
	if event != null:
		button.set_meta("input_event", event)
	
	styleInputButton(button)

	button.pressed.connect(start_rebinding.bind(action, button))
	return button


func styleInputButton(button: Button) -> void:
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color("#263941")
	normal.border_color = Color("#45636B")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(8)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6

	var hover = normal.duplicate()
	hover.bg_color = Color("#345C65")
	hover.border_color = Color("#68B8B9")

	var pressed = normal.duplicate()
	pressed.bg_color = Color("#167B78")
	pressed.border_color = Color("#7CE5D3")
	pressed.set_border_width_all(2)

	var disabled = normal.duplicate()
	disabled.bg_color = Color("#202A30")
	disabled.border_color = Color("#36434A")

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)

	button.add_theme_color_override("font_color", Color("#DCE8EB"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("#78868C"))

	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func is_valid_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo

	if event is InputEventMouseButton or event is InputEventJoypadButton:
		return event.pressed

	if event is InputEventJoypadMotion:
		return abs(event.axis_value) > 0.5

	return false

func clearAllControls() -> void:
	for child in actionsControl.get_children():
		actionsControl.remove_child(child)
		child.queue_free()


func reinitialize() -> void:
	clearAllControls()
	action_to_rebind= &""
	old_event = null
	current_button = null
	waiting_for_input = false


func update_font_weight(button: Button) -> void:
	var font = button.get_theme_font("font")

	font.variation_embolden = 0.8 if button.button_pressed else 0.0
	button.add_theme_font_override("font", font)

#endregion

#region Config

func save_controls() -> void:
	var config = ConfigFile.new()

	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue

		var events = InputMap.action_get_events(action)
		config.set_value("controls", action, events)
	
	var error = config.save(INPUT_CONFIG_PATH)

	if error != OK:
		push_error("Erreur lors de la sauvegarde des contrôles")

func load_controls() -> void:
	var config = ConfigFile.new()

	if config.load(INPUT_CONFIG_PATH) != OK:
		return

	for action in config.get_section_keys("controls"):
		if not InputMap.has_action(action):
			continue

		InputMap.action_erase_events(action)

		var events = config.get_value("controls", action)

		for event in events:
			InputMap.action_add_event(action, event)
#endregion
