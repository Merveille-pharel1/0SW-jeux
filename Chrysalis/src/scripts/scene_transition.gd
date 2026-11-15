extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

var is_transitioning := false
var teleport_arrival_pending := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_rect.modulate.a = 0.0
	fade_rect.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_scene(destination: PackedScene) -> void:
	if is_transitioning:
		return 

	if destination == null:
		push_warning("Aucune scène de destination assignée.")
		return
	
	is_transitioning = true
	fade_rect.show()

	await fade_to(1.0, 0.25)

	var error := get_tree().change_scene_to_packed(destination)
	if error != OK:
		push_error("Changement de scène impossible : " + error_string(error))
	
	await fade_to(0.0, 0.35)

	fade_rect.hide()
	is_transitioning = false

func teleport_to(destination: PackedScene, player: Node2D) -> void:
	if is_transitioning:
		return 

	if destination == null:
		push_warning("Aucune scène de destination assignée au portail.")
		return
	
	is_transitioning = true

	Audio.play_sfx("teleport")
	player.hide()

	await get_tree().create_timer(0.18).timeout

	teleport_arrival_pending = true

	var error := get_tree().change_scene_to_packed(destination)

	if error != OK:
		player.show()
		teleport_arrival_pending = false
		is_transitioning = false
		push_error("Téléportation impossible : " + error_string(error))


func finish_teleport(player: Node2D) -> void:
	teleport_arrival_pending = false
	player.hide()

	await get_tree().create_timer(0.12).timeout

	player.show()
	is_transitioning = false
	

func fade_to(alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect,"modulate:a", alpha, duration)
	await  tween.finished
