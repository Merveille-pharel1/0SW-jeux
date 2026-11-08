extends Control

@onready var settingsContainer:  = %SettingsContainer
@onready var selectedSetting: VBoxContainer = %RightPanel/MarginContainer/SelectedSetting
@onready var selectedTitle: Label = selectedSetting.get_node("SelectedTitle")

@export var game_difficulty: String = "Normal"

const TABS := {
	"AudioButton": ["AUDIO", "AudioContainer"],
	"ControlsButton": ["CONTRÔLES", "ControlsContainer"],
	"DifficultyButton": ["DIFFICULTÉ", "DifficultyContainer"],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_tab("AudioButton")
	settingsContainer.get_node("AudioButton").grab_focus()

	for button_name in TABS:
		var button: TextureButton = settingsContainer.get_node(button_name)
		button.focus_entered.connect(_on_tab_focused.bind(button_name))
		button.pressed.connect(Audio.play_sfx.bind(&"click"))
		button.focus_exited.connect(_on_tab_focus_exited.bind(button_name))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_tab_focused(button_name: String) -> void:
	Audio.play_sfx(&"navigate")
	show_tab(button_name)

func _on_tab_focus_exited(button_name: String) -> void:
	var button := settingsContainer.get_node(button_name)
	button.release_focus()

func show_tab(button_name: String) -> void:
	var info: Array = TABS[button_name]
	selectedTitle.text = info[0]
	for tab in TABS.values():
		selectedSetting.get_node(tab[1]).visible = (tab[1] == info[1])

func _on_return_button_pressed() -> void:
	Audio.save_volumes()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


#region DifficultySetting

func _on_easy_button_pressed() -> void:
	game_difficulty = "Easy"
	
func _on_normal_button_pressed() -> void:
	game_difficulty = "Normal"

func _on_difficult_button_pressed() -> void:
	game_difficulty = "Difficult"

#endregion
