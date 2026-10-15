class_name EnnemyAttack
extends BaseState

@export var ennemy : Ennemy
@export var time_out_delay := 1
@export var attack_damage: int = 10

var anim_ennemy : AnimationPlayer
var elapsedTime : float = 0.0

func enter():
	anim_ennemy = ennemy.get_animation_player()
	elapsedTime = 0

	ennemy.hitbox.start_attack(attack_damage)
	anim_ennemy.play("Attack")

func _input(event: InputEvent) -> void:
	pass

func handle_inputs(input_event: InputEvent) -> void :	
	pass

func physics_update(delta: float) -> void:

	if not anim_ennemy :
		anim_ennemy = ennemy.get_animation_player()

	elapsedTime += delta

	if elapsedTime > time_out_delay:
		Transitioned.emit(self, "EnnemyVigilance")

func exit() -> void:
	ennemy.hitbox.stop_attack()