class_name Player
extends CharacterBody2D

@onready var _animation_player = $AnimationPlayer
@onready var _sprite = $Icon
@onready var _state_machine = $StateMachine
@onready var hitbox: Hitbox = $PlayerHitbox
@onready var hurtbox: Hurtbox = $PlayerHurtbox

@export var max_health: int = 100

signal hit_received(amount: int)

const unAppliedGravityState := ["PlayerFly", "PlayerAttack", "PlayerDashAttack"]

var health: int
var pending_damage: int = 0

func _ready() -> void:
	if not is_in_group("player"):
		add_to_group("player")
	
	health = max_health

	hurtbox.damage_received.connect(receive_hit)
	hit_received.connect(_on_hit_received)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and _state_machine.current_state.name not in unAppliedGravityState:
		velocity += get_gravity() * delta

	move_and_slide()
	

func get_animation_player() -> AnimationPlayer:
	return _animation_player

func receive_hit(amount: int) -> void:
	if health <= 0:
		return

	pending_damage += amount
	hit_received.emit(amount)


func _on_hit_received(amount: int) -> void:
	_state_machine.on_child_transition( _state_machine.current_state,"PlayerDamage")