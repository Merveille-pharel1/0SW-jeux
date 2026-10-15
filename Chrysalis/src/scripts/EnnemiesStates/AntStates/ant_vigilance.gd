class_name EnnemyVigilance
extends BaseState

@export var ennemy : Ennemy
@export var distance_chase: float = 300.0

var anim_ennemy : AnimationPlayer

func enter():
	anim_ennemy = ennemy.get_animation_player()

func _input(_event: InputEvent) -> void:
	pass

func handle_inputs(_input_event: InputEvent) -> void :	
	pass

func physics_update(_delta: float) -> void:

	if not anim_ennemy :
		anim_ennemy = ennemy.get_animation_player()	

	anim_ennemy.play("Idle")

	var distance := ennemy.get_distance_to_player()

	var transitionAttack : bool = distance < 100 and ennemy._player_detector.is_colliding()
	if transitionAttack:
		Transitioned.emit(self, "EnnemyAttack")

	var transitionChase := distance < distance_chase
	if transitionChase:
		Transitioned.emit(self, "EnnemyChase")

	var transitionPatrol : bool = distance > 300 and !ennemy._player_detector.is_colliding()
	if transitionPatrol:
		Transitioned.emit(self, "EnnemyPatrol")


func exit() -> void:
	print("sortie")
