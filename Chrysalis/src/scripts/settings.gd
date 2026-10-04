extends Control

@onready var audioButton: TextureButton = $MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxContainer/AudioButton
@onready var controlsButton: TextureButton = $MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxContainer/ControlsButton
@onready var difficultyButton: TextureButton = $MarginContainer/HBoxContainer/LeftPanel/MarginContainer/VBoxContainer/DifficultyButton
@onready var selectedSettingContainer: VBoxContainer = $MarginContainer/HBoxContainer/RightPanel/MarginContainer/SelectedSetting
@onready var audioContainer: VBoxContainer = $MarginContainer/HBoxContainer/RightPanel/MarginContainer/SelectedSetting/AudioContainer

@export var game_difficulty: String = "Normal"
@export var music_value: int = 0
@export var effect_value: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_audio_button_pressed() -> void:
	toggle_selected("AUDIO")

func _on_controls_button_pressed() -> void:
	toggle_selected("CONTRÔLES")

func _on_difficulty_button_pressed() -> void:
	toggle_selected("DIFFICULTÉ")

func toggle_selected(selectedSetting: String) -> void:
	var selectedTitle = get_node("MarginContainer/HBoxContainer/RightPanel/MarginContainer/SelectedSetting/SelectedTitle") as Label
	selectedTitle.text = selectedSetting
	
	match selectedSetting:
		"AUDIO" : 
			offSettingsVisibility()
			selectedSettingContainer.get_node("AudioContainer").visible = true
			
		"CONTRÔLES" : 
			offSettingsVisibility()
			selectedSettingContainer.get_node("ControlsContainer").visible = true
			
		"DIFFICULTÉ" : 
			offSettingsVisibility()
			selectedSettingContainer.get_node("DifficultyContainer").visible = true

func offSettingsVisibility() -> void:
	selectedSettingContainer.get_node("AudioContainer").visible = false
	selectedSettingContainer.get_node("DifficultyContainer").visible = false
	selectedSettingContainer.get_node("ControlsContainer").visible = false

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_effect_slider_value_changed(value: float) -> void:
	var effectContainer = audioContainer.get_node("EffectContainer")
	var effectValue: int  = effectContainer.get_node("EffectSlider").value 
	effectContainer.get_node("Value").text = str(effectValue) + " %"
	effect_value = effectValue 

func _on_music_slider_value_changed(value: float) -> void:
	var musicContainer = audioContainer.get_node("MusicContainer")
	var musicValue: int = musicContainer.get_node("MusicSlider").value
	musicContainer.get_node("Value").text = str(musicValue) + " %"
	music_value = musicValue

func _on_easy_button_pressed() -> void:
	game_difficulty = "Easy"
	
func _on_normal_button_pressed() -> void:
	game_difficulty = "Normal"

func _on_difficult_button_pressed() -> void:
	game_difficulty = "Difficult"
