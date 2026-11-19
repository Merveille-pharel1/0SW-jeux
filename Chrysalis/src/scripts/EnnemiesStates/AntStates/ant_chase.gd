class_name EnnemyChase
extends BaseState

@export var ennemy : Ennemy
@export var chase_speed : float = 250
@export var lose_sight_delay: float = 0.4 

var anim_ennemy : AnimationPlayer
var time_without_sight: float = 0.0

func enter():
	time_without_sight = 0.0
	ennemy.get_animation_player().play("Patrol")

func _input(event: InputEvent) -> void:
	pass

func handle_inputs(input_event: InputEvent) -> void :	
	pass

func physics_update(delta: float) -> void:

	var target := ennemy.get_player()

	if target == null:
		Transitioned.emit(self, "EnnemyPatrol")
		return

	var offset := target.global_position - ennemy.global_position

	if offset.length() > ennemy.lose_player_distance:
		Transitioned.emit(self, "EnnemyPatrol")
		return

	ennemy.face_player()

	if ennemy.can_attack_player():
		Transitioned.emit(self, "EnnemyAttack")
		return

	if ennemy.sees_player():
		time_without_sight = 0.0
	else:
		time_without_sight += delta

	if time_without_sight >= lose_sight_delay:
		Transitioned.emit(self, "EnnemyPatrol")
		return

	if not ennemy.has_ground_ahead() or ennemy.is_on_wall():
		ennemy.change_direction()
		Transitioned.emit(self, "EnnemyPatrol")
		return

	if ennemy.is_aerial():
		ennemy.velocity = offset.normalized() * chase_speed
	else:
		ennemy.velocity.x = signf(offset.x) * chase_speed

func exit() -> void:
	ennemy.velocity = Vector2.ZERO
