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

	if ennemy.sees_player():
		Transitioned.emit(self, "EnnemyChase")
		return

	var reaches_left := ennemy.global_position.x <= ennemy.left_limit and ennemy.direction < 0

	var reaches_right := ennemy.global_position.x >= ennemy.right_limit and ennemy.direction > 0

	var obstacle_ahead := ennemy.is_on_wall() or not ennemy.has_ground_ahead()
	
	if reaches_left or reaches_right or obstacle_ahead:
		ennemy.change_direction()

	if not ennemy.has_ground_ahead():
		ennemy.velocity.x = 0.0
		return

	ennemy.velocity.x = ennemy.direction * move_speed

	anim_ennemy.play("Patrol")

	if ennemy.is_aerial():
		ennemy.velocity.y = 0.0

func exit() -> void:
	ennemy.velocity.x = 0.0
