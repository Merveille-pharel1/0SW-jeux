class_name Player
extends CharacterBody2D

@onready var _animation_player = $AnimationPlayer
@onready var _sprite = $Icon

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	

func get_animation_player() -> AnimationPlayer:
	return _animation_player

