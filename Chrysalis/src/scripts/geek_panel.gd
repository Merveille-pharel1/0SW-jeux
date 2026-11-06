extends CanvasLayer

@onready var fps : HBoxContainer = %FPS
@onready var current_memory: HBoxContainer = %CurrentMemory
@onready var min_memory: HBoxContainer = %MinMemory
@onready var max_memory: HBoxContainer = %MaxMemory
# @onready var timer: Timer = $Timer

const BYTES_TO_MB := 1024 * 1024

var min_value: float = INF
var max_value: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("geek_mode") and not event.is_echo():
		visible = !visible
		
func _on_timer_timeout() -> void:
	if visible:
		var fps_value: float = Engine.get_frames_per_second()

		var ram: float = (
			Performance.get_monitor(Performance.MEMORY_STATIC)
			/ BYTES_TO_MB
		)

		min_value = minf(min_value, ram)
		max_value = maxf(max_value, ram)

		fps.get_node("Value").text = "%d" % fps_value
		current_memory.get_node("Value").text = "%dMB" % ram
		min_memory.get_node("Value").text = "%dMB" % min_value
		max_memory.get_node("Value").text = "%dMB" % max_value
