class_name PlayerIdle
extends BaseState

@export var player : Player
var anim_player : AnimationPlayer

func enter():
	anim_player = player.get_animation_player()


func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	var dir : float = Input.get_axis("move_left", "move_right")

	if (dir != 0):
		Transitioned.emit(self, "PlayerRun")

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		Transitioned.emit(self, "PlayerJump")
	
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "PlayerAttack")

	if Input.is_action_just_pressed("dash_attack"):
		Transitioned.emit(self, "PlayerDashAttack")

	if Input.is_action_just_pressed("toggle_fly"):
		Transitioned.emit(self, "PlayerFly")


func physics_update(delta: float) -> void:

	if not anim_player :
		anim_player = player.get_animation_player()

	anim_player.play("Idle")

func exit() -> void:
	pass
