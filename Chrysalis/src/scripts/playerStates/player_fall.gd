class_name PlayerFall
extends BaseState

@export var player : Player
@export var move_speed := 200.0

var anim_player : AnimationPlayer
var dir :float = 0

func enter():
	anim_player = player.get_animation_player()


func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	dir = Input.get_axis("move_left", "move_right")


func physics_update(delta: float) -> void:
	if not anim_player :
		anim_player = player.get_animation_player()

	if dir != 0:
		player.velocity.x = dir * move_speed
		player._sprite.flip_h = dir < 0

	if player.is_on_floor():
		Transitioned.emit(self, "PlayerIdle")

	anim_player.play("Fall")

func exit() -> void:
	player.velocity.x = 0
