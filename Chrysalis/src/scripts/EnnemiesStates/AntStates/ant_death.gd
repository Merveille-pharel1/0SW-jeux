class_name EnnemyDeath
extends BaseState

@export var ennemy : Ennemy
var anim_ennemy : AnimationPlayer

func enter():
	anim_ennemy = ennemy.get_animation_player()

	ennemy.velocity = Vector2.ZERO

	anim_ennemy.play("Death")

	await anim_ennemy.animation_finished

	if is_instance_valid(ennemy):
		ennemy.queue_free()


func _input(event: InputEvent) -> void:
	pass

func handle_inputs(input_event: InputEvent) -> void :	
	pass

func physics_update(delta: float) -> void:
	pass

	# if not anim_ennemy :
	# 	anim_ennemy = ennemy.get_animation_player()

	# anim_ennemy.play("Death")

func exit() -> void:
	pass