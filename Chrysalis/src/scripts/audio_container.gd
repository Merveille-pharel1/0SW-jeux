extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var audioSettings := get_children()

	for audioSetting in audioSettings:
		var slider := audioSetting.get_node_or_null("Slider") as HSlider
		if slider == null:
			continue
		
		var bus := StringName(String(audioSetting.name).trim_suffix("Container"))
		var busVolume = Audio.get_volume(bus)

		slider.value = busVolume
		audioSetting.get_node("Value").text = str(int(busVolume * 100)) + " %"

		slider.value_changed.connect(func(value: float): _on_value_changed(bus, value, audioSetting))
		slider.drag_ended.connect(func(value_changed: bool): _on_drag_ended(value_changed))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_value_changed(bus: StringName, value: float, settingContainer: HBoxContainer) -> void:
	Audio.set_volume(bus, value)
	print(int(value * 100))
	settingContainer.get_node("Value").text = str(int(value * 100)) + " %"

func _on_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Audio.save_volumes()