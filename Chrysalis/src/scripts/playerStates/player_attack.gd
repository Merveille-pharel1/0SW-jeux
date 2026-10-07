class_name PlayerAttack
extends BaseState

@export var player : Player
@export var time_out_delay := 0.4


var anim_player : AnimationPlayer
var elapsedTime : float = 0.0

func enter():
	anim_player = player.get_animation_player()
	elapsedTime = 0
	player.velocity.x = 0


func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	pass


func physics_update(delta: float) -> void:
	if not anim_player :
		anim_player = player.get_animation_player()

	elapsedTime += delta

	if elapsedTime > time_out_delay:
		Transitioned.emit(self, "PlayerIdle")


	anim_player.play("Attack")

func exit() -> void:
	player.velocity.x = 0
