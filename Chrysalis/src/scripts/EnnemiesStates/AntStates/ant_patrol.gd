class_name EnnemyPatrol
extends BaseState

@export var ennemy : Ennemy
@export var move_speed := 80.0

var anim_ennemy : AnimationPlayer

func enter():
	anim_ennemy = ennemy.get_animation_player()

func _input(event: InputEvent) -> void:
	pass

func handle_inputs(input_event: InputEvent) -> void :	
	pass

func physics_update(delta: float) -> void:

	if not anim_ennemy :
		anim_ennemy = ennemy.get_animation_player()

	if not ennemy._floor_detector.is_colliding() or ennemy.is_on_wall_only():
		ennemy.change_direction()

	ennemy.velocity.x = ennemy.direction * move_speed

	anim_ennemy.play("Patrol")

	if ennemy._player_detector.is_colliding():
		Transitioned.emit(self, "EnnemyVigilance")

func exit() -> void:
	ennemy.velocity.x = 0.0
