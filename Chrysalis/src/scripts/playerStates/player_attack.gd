class_name PlayerAttack
extends BaseState

@export var player : Player
@export var attack_damage: int = 25
@export var respawn_delay: float = 0.3


var anim_player : AnimationPlayer
var elapsedTime : float = 0.0
var previous_state: BaseState

func enter():
	anim_player = player.get_animation_player()
	elapsedTime = 0
	player.velocity.x = 0

	player.hitbox.start_attack(attack_damage)
	anim_player.play("Attack")

	if not anim_player.animation_finished.is_connected(_on_animation_finished):
		anim_player.animation_finished.connect(_on_animation_finished)


func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	pass


func physics_update(delta: float) -> void:
	if not anim_player :
		anim_player = player.get_animation_player()

	elapsedTime += delta

	previous_state = player._state_machine.previous_state
	if previous_state.name == "PlayerFly":
		previous_state.elapsedTime += delta


func _on_animation_finished(_anim_name: StringName) -> void:
	await get_tree().create_timer(respawn_delay).timeout

	if previous_state.name == "PlayerJump":
		Transitioned.emit(self, "PlayerFall")
	elif previous_state.name == "PlayerFly":
		previous_state.current_state = previous_state.State.FLYING_IDLE
		Transitioned.emit(self, "PlayerFly")
	else:
		Transitioned.emit(self, "PlayerIdle")

func exit() -> void:
	player.velocity.x = 0
	player.hitbox.stop_attack()

	if anim_player.animation_finished.is_connected(_on_animation_finished):
		anim_player.animation_finished.disconnect(_on_animation_finished)

