class_name PlayerRun
extends BaseState


@export var player : Player
var anim_player : AnimationPlayer

@export var move_speed := 200.0

var dir : float = 0.0

func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	dir = Input.get_axis("move_left", "move_right")

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
	
	if dir != 0:
		player.velocity.x = dir * move_speed
		player._sprite.flip_h = dir < 0
	else :
		player.velocity.x = lerp(player.velocity.x, 0.0, 0.8)

	if not anim_player : return

	anim_player.play("Run")

	if is_zero_approx(player.velocity.x) :
		Transitioned.emit(self, "PlayerIdle")
	

func enter() -> void:
	# Called when entering this state
	pass

func exit() -> void:
	# Called when exiting this state
	pass
