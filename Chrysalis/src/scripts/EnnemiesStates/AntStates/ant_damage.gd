class_name EnnemyDamage
extends BaseState

@export var ennemy : Ennemy
var anim_ennemy : AnimationPlayer

func enter():
	anim_ennemy = ennemy.get_animation_player()
	ennemy.health = max(ennemy.health - ennemy.pending_damage, 0)
	ennemy.pending_damage = 0

	print("EH: ", ennemy.health)

	if ennemy.health <= 0:
		Transitioned.emit(self, "EnnemyDeath")
		return
	
	anim_ennemy.play("Damage")

	if not ennemy._player_detector.is_colliding():
		ennemy.change_direction()
	
	Transitioned.emit(self, "EnnemyVigilance")


func _input(event: InputEvent) -> void:
	pass

func handle_inputs(input_event: InputEvent) -> void :	
	pass

func physics_update(delta: float) -> void:

	if not anim_ennemy :
		anim_ennemy = ennemy.get_animation_player()


func exit() -> void:
	pass