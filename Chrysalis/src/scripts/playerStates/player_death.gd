class_name PlayerDeath
extends BaseState

@export var player : Player
@export var respawn_delay: float = 0.6
var anim_player : AnimationPlayer


func enter():
	anim_player = player.get_animation_player()

	player.velocity = Vector2.ZERO

	anim_player.play("Death")

	await anim_player.animation_finished

	await get_tree().create_timer(respawn_delay).timeout

	if is_instance_valid(player):
		get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	pass


func physics_update(delta: float) -> void:
	pass

func exit() -> void:
	pass
