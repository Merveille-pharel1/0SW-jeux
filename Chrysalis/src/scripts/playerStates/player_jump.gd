class_name PlayerJump
extends BaseState

@export var player : Player
@export var	jump_velocity := -500
@export var move_speed := 200.0

var anim_player : AnimationPlayer
var dir :float = 0

func enter():
	anim_player = player.get_animation_player()
	player.velocity.y = jump_velocity


func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	dir = Input.get_axis("move_left", "move_right")

	if dir != 0:
		if player.is_on_floor():
			Transitioned.emit(self, "PlayerRun")
	
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "PlayerAttack")

	if Input.is_action_just_pressed("dash_attack"):
		Transitioned.emit(self, "PlayerDashAttack")

	if Input.is_action_just_pressed("toggle_fly"):
		Transitioned.emit(self, "PlayerFly")
	

func physics_update(delta: float) -> void:
	if not anim_player :
		anim_player = player.get_animation_player()

	if dir != 0:
		player.velocity.x = dir * move_speed
		player._sprite.flip_h = dir < 0
	elif player.is_on_floor():
		Transitioned.emit(self, "PlayerIdle")
	
	if player.velocity.y > 0:
		Transitioned.emit(self, "PlayerFall")

	anim_player.play("Jump")

	

func exit() -> void:
	player.velocity.x = 0
