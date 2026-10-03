extends Control
@onready var play_label: Label = $UI/MenuButtons/PlayButton/Label
@onready var settings_label: Label = $UI/MenuButtons/SettingsButton/Label
@onready var info_label: Label = $UI/MenuButtons/InfoButton/Label
@onready var exit_label: Label = $UI/MenuButtons/ExitButton/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_play_button_mouse_entered() -> void:
	set_style(play_label, Color("FFFFFF"), Color("#4FC3FF"), 4)

func _on_play_button_mouse_exited() -> void:
	set_style(play_label, Color("#EAF4FF"), Color("#244D8F"), 2)
	
func _on_settings_button_mouse_entered() -> void:
	set_style(settings_label, Color("FFFFFF"), Color("#4FC3FF"), 4)

func _on_settings_button_mouse_exited() -> void:
	set_style(settings_label, Color("#EAF4FF"), Color("#244D8F"), 2)

func _on_info_button_mouse_entered() -> void:
	set_style(info_label, Color("FFFFFF"), Color("#4FC3FF"), 4)

func _on_info_button_mouse_exited() -> void:
	set_style(info_label, Color("#EAF4FF"), Color("#244D8F"), 2)

func _on_exit_button_mouse_entered() -> void:
	set_style(exit_label, Color("FFFFFF"), Color("#4FC3FF"), 4)

func _on_exit_button_mouse_exited() -> void:
	set_style(exit_label, Color("#EAF4FF"), Color("#244D8F"), 2)
	
func set_style(label: Label, font_color: Color, outline_color: Color, outline_size: int) -> void:
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", outline_color)
	label.add_theme_constant_override("outline_size", outline_size)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/forest_level.tscn")
