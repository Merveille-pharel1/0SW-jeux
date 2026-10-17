class_name PlayerFly
extends BaseState

@export var player : Player
@export var	jump_velocity := -500
@export var fly_speed := 200.0
@export var time_out_delay := 4

enum State { JUMPING, FLYING_IDLE, FLYING_MOVE}

var current_state: State = State.JUMPING
var dir : Vector2 = Vector2.ZERO
var anim_player : AnimationPlayer
var firstime : bool = 1
var elapsedTime : float = 0.0


func enter():
	anim_player = player.get_animation_player()
	firstime = 1

	if player._state_machine.previous_state.name not in ["PlayerAttack", "PlayerDashAttack"]:
		elapsedTime = 0


func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	dir = Input.get_vector("move_left", "move_right", "fly_up", "fly_down")

	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("toggle_fly"):
		Transitioned.emit(self, "PlayerFall")

	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "PlayerAttack")

	if Input.is_action_just_pressed("dash_attack"):
		Transitioned.emit(self, "PlayerDashAttack")


func physics_update(delta: float) -> void:

	if not anim_player :
		anim_player = player.get_animation_player()

	manageFlyState(delta)

func manageFlyState(delta: float):

	match current_state:
		State.JUMPING:
			jumping(delta)
		State.FLYING_IDLE:
			flying_idle(delta)
		State.FLYING_MOVE:
			jumping_move(delta)
			

func jumping(delta: float) -> void:

	if firstime:
		firstime = 0
		player.velocity.y = jump_velocity

	player.velocity += player.get_gravity() * delta

	var transition := player.velocity.y > 0

	anim_player.play("Jump")

	if(transition):
		current_state = State.FLYING_IDLE 


func flying_idle(delta: float) -> void:

	elapsedTime += delta

	anim_player.play("FlyIdle")

	var transitionMove := dir != Vector2.ZERO

	if(transitionMove):
		current_state = State.FLYING_MOVE
	
	var transitionFall := elapsedTime > time_out_delay

	if(transitionFall):
		Transitioned.emit(self, "PlayerFall")
	

func jumping_move(delta: float) -> void:

	elapsedTime += delta

	if dir != Vector2.ZERO:
		player.velocity = dir * fly_speed
		player.change_direction(dir.x)

	else :
		player.velocity = player.velocity.lerp(Vector2.ZERO, 0.8)

	if not anim_player : return

	anim_player.play("FlyMove")

	var transitionMove := player.velocity.is_zero_approx()

	if(transitionMove):
		current_state = State.FLYING_IDLE
	
	var transitionFall := elapsedTime > time_out_delay

	if(transitionFall):
		current_state = State.JUMPING
		Transitioned.emit(self, "PlayerFall")

func exit() -> void:
	current_state = State.JUMPING
	firstime = 1
	
