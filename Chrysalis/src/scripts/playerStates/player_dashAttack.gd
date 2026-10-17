class_name PlayerDashAttack
extends BaseState

@export var player : Player
@export var dash_speed := 600.0
@export var attack_damage: int = 35

var anim_player : AnimationPlayer
var elapsedTime : float = 0.0
var previous_state: BaseState


func enter():
	anim_player = player.get_animation_player()
	elapsedTime = 0

	if not anim_player.animation_finished.is_connected(_on_animation_finished):
		anim_player.animation_finished.connect(_on_animation_finished)

	player.hitbox.start_attack(attack_damage)


func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	pass

	
func physics_update(delta: float) -> void:
	var dir = -1 if player._sprite.flip_h else 1

	if not anim_player :
		anim_player = player.get_animation_player()

	elapsedTime += delta

	previous_state = player._state_machine.previous_state
	if previous_state.name == "PlayerFly":
		previous_state.elapsedTime += delta

	player.velocity.x = dir * dash_speed
	anim_player.play("DashAttack")


func _on_animation_finished(_anim_name: StringName) -> void:
	player.velocity.x = 0

	if is_zero_approx(player.velocity.x):

		if previous_state.name == "PlayerJump":
			Transitioned.emit(self, "PlayerFall")
		elif previous_state.name == "PlayerFly":
			previous_state.current_state = previous_state.State.FLYING_IDLE
			Transitioned.emit(self, "PlayerFly")
		else:
			Transitioned.emit(self, "PlayerIdle")


func exit() -> void:
	player.hitbox.stop_attack()

	if not anim_player.animation_finished.is_connected(_on_animation_finished):
		anim_player.animation_finished.disconnect(_on_animation_finished)
	
	


	

