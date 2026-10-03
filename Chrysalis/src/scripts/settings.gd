extends Control

@onready var selectedTitle: Label = $MarginContainer/HBoxContainer/RightPanel/MarginContainer/VBoxContainer/SelectedTitle
@onready var audioButton: TextureButton = $MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxContainer/AudioButton
@onready var controlsButton: TextureButton = $MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxContainer/ControlsButton
@onready var difficultyButton: TextureButton = $MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxContainer/DifficultyButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	offButton()
	audioButton.button_pressed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_audio_button_pressed() -> void:
	selectedTitle.text = "AUDIO"
	offButton()
	audioButton.button_pressed = true

func _on_controls_button_pressed() -> void:
	selectedTitle.text = "CONTRÔLES"
	offButton()
	controlsButton.button_pressed = true

func _on_difficulty_button_pressed() -> void:
	selectedTitle.text = "DIFFICULTÉ"
	offButton()
	difficultyButton.button_pressed = true
	
	
func toggle_selected() -> void:
	pass
	
func offButton() -> void:
	audioButton.button_pressed = false
	controlsButton.button_pressed = false
	difficultyButton.button_pressed = false


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
