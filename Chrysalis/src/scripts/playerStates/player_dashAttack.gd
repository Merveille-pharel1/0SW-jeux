class_name PlayerDashAttack
extends BaseState

@export var player : Player
@export var time_out_delay := 0.4
@export var dash_speed := 600.0

var anim_player : AnimationPlayer
var elapsedTime : float = 0.0

func enter():
	anim_player = player.get_animation_player()
	elapsedTime = 0


func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	pass

	
func physics_update(delta: float) -> void:
	var dir = -1 if player._sprite.flip_h else 1

	if not anim_player :
		anim_player = player.get_animation_player()

	elapsedTime += delta

	if elapsedTime > time_out_delay:

		player.velocity.x = lerp(player.velocity.x, 0.0, 0.9)

		if player.is_on_floor() and is_zero_approx(player.velocity.x):
			Transitioned.emit(self, "PlayerIdle")

		else:
			Transitioned.emit(self, "PlayerFall")

	player.velocity.x = dir * dash_speed
	anim_player.play("DashAttack")

func exit() -> void:
	pass
