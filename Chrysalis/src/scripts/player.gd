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
var hitbox_offset_x: float
var facing_direction: float = 1.0
var in_elevator := false

var hit_material: ShaderMaterial
var hit_tween: Tween

func _ready() -> void:
	if not is_in_group("player"):
		add_to_group("player")
	
	health = max_health

	hit_material = _sprite.material as ShaderMaterial

	hitbox_offset_x = absf(hitbox.position.x)
	change_direction(-1.0 if _sprite.flip_h else 1.0)

	hurtbox.damage_received.connect(receive_hit)

	if SceneTransition.teleport_arrival_pending:
		SceneTransition.finish_teleport(self)


func _physics_process(delta: float) -> void:
	
	if in_elevator:
		return
	
	# Add the gravity.
	if not is_on_floor() and _state_machine.current_state.name not in unAppliedGravityState:
		velocity += get_gravity() * delta

	move_and_slide()
	

func get_animation_player() -> AnimationPlayer:
	return _animation_player

func receive_hit(amount: int) -> void:
	if health <= 0 or amount <= 0:
		return

	health = maxi(health - amount, 0)

	if health == 0:
		if hit_tween:
			hit_tween.kill()

		hit_material.set_shader_parameter("hit_strength", 0.0)
		_state_machine.on_child_transition(_state_machine.current_state, "PlayerDeath")
	else:
		play_damage_flash()

	hit_received.emit(amount)


func play_damage_flash() -> void:
	if hit_tween:
		hit_tween.kill()

	hit_material.set_shader_parameter("hit_strength", 0.85)

	hit_tween = create_tween()
	hit_tween.tween_interval(0.04)
	hit_tween.tween_property(hit_material, "shader_parameter/hit_strength", 0.0, 0.11)


func change_direction(direction: float) -> void:
	if is_zero_approx(direction):
		return

	facing_direction = signf(direction)
	_sprite.flip_h = facing_direction < 0.0
	hitbox.position.x = hitbox_offset_x * facing_direction
