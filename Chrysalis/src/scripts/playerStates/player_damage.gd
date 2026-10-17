class_name PlayerDamage
extends BaseState

@export var player : Player
var anim_player : AnimationPlayer

func enter():
	anim_player = player.get_animation_player()
	player.health = max(player.health - player.pending_damage, 0)
	player.pending_damage = 0

	if player.health <= 0:
		Transitioned.emit(self, "PlayerDeath")
		return

	anim_player.play("Damage")

	await anim_player.animation_finished

	Transitioned.emit(self, "PlayerIdle")


func _input(event: InputEvent) -> void:
	pass

func handle_inputs(input_event: InputEvent) -> void :
	pass


func physics_update(delta: float) -> void:
	pass 


func exit() -> void:
	pass
