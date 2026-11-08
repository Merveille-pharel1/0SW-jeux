extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play_music(&"MenuAudio")
	var playButton := get_node("UI/MenuButtons/PlayButton")

	var buttons := get_node("UI/MenuButtons").get_children()

	for node in buttons:
		if node is TextureButton:
			var button := node as TextureButton
			var normal_texture := button.texture_normal

			button.mouse_entered.connect(buttonSelected.bind(button))
			button.focus_entered.connect(buttonSelected.bind(button))
			button.mouse_exited.connect(buttonUnselected.bind(button, normal_texture))
			button.focus_exited.connect(buttonUnselected.bind(button, normal_texture))

	playButton.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func buttonSelected(button: TextureButton):
	button.texture_normal = button.texture_hover
	
	var label := button.get_node("Label") as Label
	set_style(label, Color("FFFFFF"), Color("#4FC3FF"), 4)

func buttonUnselected(button: TextureButton, normal_texture):
	button.texture_normal = normal_texture

	var label := button.get_node("Label") as Label
	set_style(label, Color("#EAF4FF"), Color("#244D8F"), 2)


func set_style(label: Label, font_color: Color, outline_color: Color, outline_size: int) -> void:
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", outline_color)
	label.add_theme_constant_override("outline_size", outline_size)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/forest_level.tscn")

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
