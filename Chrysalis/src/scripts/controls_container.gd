extends VBoxContainer

@onready var actionsControl: VBoxContainer = $ScrollContainer/MarginContainer/ActionsControl

var modeControl := "keyboard"
var action_to_rebind: StringName = &""
var old_event: InputEvent = null
var current_button: Button = null
var waiting_for_input := false
var controls : Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	controls = getControls()
	showControls(controls, modeControl)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not waiting_for_input:
		return

	if modeControl == "keyboard" and not keyboardFilter(event):
		return

	if modeControl == "gamepad" and gamepadFilter(event):
		return

	if not is_valid_input(event):
		return

	var new_event : InputEvent = event.duplicate()
	new_event.physical_keycode = event.physical_keycode

	InputMap.action_erase_event(action_to_rebind, old_event)
	InputMap.action_add_event(action_to_rebind, new_event)

	current_button.text = new_event.as_text()
	current_button.set_meta("input_event", new_event)

	waiting_for_input = false
	get_viewport().set_input_as_handled()

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
	# var actionsControl = get_node("ScrollContainer/MarginContainer/ActionsControl")

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
		
		for e in events:
			var button = Button.new()

			button.text = e.as_text()
			button.set_meta("input_event", e)
			
			styleInputButton(button)

			button.pressed.connect(start_rebinding.bind(action, button))

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


func keyboardFilter(event: InputEvent) -> bool:
	return event is InputEventKey or event is InputEventMouseButton

func gamepadFilter(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion

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

	# var disabled = normal.duplicate()
	# disabled.bg_color = Color("#202A30")
	# disabled.border_color = Color("#36434A")

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	# button.add_theme_stylebox_override("disabled", disabled)

	button.add_theme_color_override("font_color", Color("#DCE8EB"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("#78868C"))

	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func start_rebinding(action: StringName, button: Button):
	action_to_rebind = action
	old_event = button.get_meta("input_event")
	current_button = button
	waiting_for_input = true

	button.text = "Appuyez une touche..."

func is_valid_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo

	if event is InputEventMouseButton or event is InputEventJoypadButton:
		return event.pressed

	if event is InputEventJoypadMotion:
		return abs(event.axis_value) > 0.5

	return false


func _on_keyboard_button_pressed() -> void:
	modeControl = "keyboard"	
	showControls(controls, modeControl)



func _on_game_pad_button_pressed() -> void:
	modeControl = "gamepad"	
	showControls(controls, modeControl)
