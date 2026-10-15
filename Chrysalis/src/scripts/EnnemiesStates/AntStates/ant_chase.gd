class_name EnnemyChase
extends BaseState

@export var ennemy : Ennemy
@export var chase_speed : float = 250
@export var chase_distance : float = 100  

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

	var direction := ennemy.get_direction_to_player() 

	if not is_zero_approx(direction.x):
		var new_direction := signf(direction.x)
		if new_direction != ennemy.direction:
			ennemy.change_direction()

	if ennemy.get_type() == "Aerian":
		ennemy.velocity = direction * chase_speed 
	else:	
		ennemy.velocity.x = direction.x * chase_speed


	anim_ennemy.play("Patrol")

	if not ennemy._floor_detector.is_colliding() or ennemy.is_on_wall_only():
		ennemy.change_direction()
		Transitioned.emit(self, "EnnemyVigilance")

	var distance = ennemy.get_distance_to_player()
	
	var transition := distance < chase_distance or distance > 300
	if transition:
		Transitioned.emit(self, "EnnemyVigilance")

func exit() -> void:
	ennemy.velocity = Vector2.ZERO
