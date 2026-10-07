class_name PlayerFly
extends BaseState

@export var player : Player
@export var	jump_velocity := -500
@export var fly_speed := 200.0
@export var time_out_delay := 5
# @export var margeForce := Vector2(0, 0.1)

enum State { JUMPING, FLYING_IDLE, FLYING_MOVE}

var current_state: State = State.JUMPING
var dir : float = 0.0
var anim_player : AnimationPlayer
var firstime : bool = 1
var elapsedTime : float = 0.0
var  margeForce :Vector2


func enter():
	anim_player = player.get_animation_player()
	firstime = 1


func _input(event: InputEvent) -> void:
	handle_inputs(event)

func handle_inputs(input_event: InputEvent) -> void :
	dir = Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("toggle_fly"):
		Transitioned.emit(self, "Fall")

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

	var transition := player.velocity.y > 0

	anim_player.play("Jump")

	if(transition):
		current_state = State.FLYING_IDLE 





func flying_idle(delta: float) -> void:
	
	margeForce = Vector2(0, randf_range(0, 0.5))

	elapsedTime += delta

	player.velocity -= player.get_gravity() * delta + margeForce

	anim_player.play("FlyIdle")

	var transitionMove := dir != 0

	if(transitionMove):
		current_state = State.FLYING_MOVE
	
	var transitionFall := elapsedTime > time_out_delay

	if(transitionFall):
		Transitioned.emit(self, "PlayerFall")
	
	

func jumping_move(delta: float) -> void:

	elapsedTime += delta

	margeForce = Vector2(0, randf_range(0, 0.5))
	player.velocity -= player.get_gravity() * delta + margeForce

	if dir != 0:
		player.velocity.x = dir * fly_speed
		player._sprite.flip_h = dir < 0
	else :
		player.velocity.x = lerp(player.velocity.x, 0.0, 0.8)

	if not anim_player : return

	anim_player.play("FlyMove")

	var transitionMove := is_zero_approx(player.velocity.x)

	if(transitionMove):
		current_state = State.FLYING_IDLE
	
	var transitionFall := elapsedTime > time_out_delay

	if(transitionFall):
		current_state = State.JUMPING
		Transitioned.emit(self, "PlayerFall")

func exit() -> void:
	current_state = State.JUMPING
	elapsedTime = 0
	firstime = 1
	

