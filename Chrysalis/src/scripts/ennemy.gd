class_name Ennemy
extends CharacterBody2D

@onready var _animation_player = $AnimationPlayer
@onready var _sprite = $Icon
@onready var _state_machine = $StateMachine
@onready var _floor_detector = $FloorDectector
@onready var _player_detector = $PlayerDetector
@onready var hitbox: Hitbox = $EnnemyHitbox
@onready var hurtbox: Hurtbox = $EnnemyHurtbox

@export_enum("Ground", "Aerial") var ennemy_type : String = "Ground"
@export var max_health: int = 100
@export var attack_range: float = 100.0
@export var lose_player_distance: float = 350.0
@export_enum("Gauche:-1", "Droite:1") var direction := -1 

signal hit_received(amount: int)

var player: Player
var health: int
var pending_damage: int = 0
var hitbox_offset_x: float
var hit_material: ShaderMaterial
var hit_tween: Tween
var patrol_origin: Vector2

func _ready() -> void:
	health = max_health

	hitbox_offset_x = absf(hitbox.position.x)

	hit_material = _sprite.material as ShaderMaterial

	hurtbox.damage_received.connect(receive_hit)
	player = get_tree().get_first_node_in_group("player") as Player

	if _floor_detector != null:
		_floor_detector.enabled = not is_aerial()


func _physics_process(delta: float) -> void:

	if not is_aerial() and not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	

func get_animation_player() -> AnimationPlayer:
	return _animation_player


func get_player() -> Player:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Player

	return player


func get_distance_to_player() -> float:
	if not is_instance_valid(player):
		return INF

	return global_position.distance_to(player.global_position)


func get_direction_to_player() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO

	return global_position.direction_to(player.global_position)


func is_aerial() -> bool:
	return ennemy_type == "Aerial"

func sees_player() -> bool:
	var target := get_player()
	if target == null:
		return false

	var collider := _player_detector.get_collider() as Node
	if collider == null:
		return false

	return collider == target or target.is_ancestor_of(collider)


func can_attack_player() -> bool:
	var target := get_player()
	if target == null:
		return false

	var offset := target.global_position - global_position
	var player_is_in_front := offset.x * direction >= 0.0

	return (
		player_is_in_front
		and offset.length() <= attack_range
		and sees_player()
	)


func face_player() -> void:
	var target := get_player()
	if target == null:
		return

	var offset_x := target.global_position.x - global_position.x

	if not is_zero_approx(offset_x) and signf(offset_x) != direction:
		change_direction()


func has_ground_ahead() -> bool:
	if is_aerial():
		return true

	if _floor_detector == null:
		return true

	return _floor_detector.is_colliding()


func change_direction() -> void:
	direction *= -1
	_sprite.flip_h = !_sprite.flip_h 

	hitbox.position.x = hitbox_offset_x * direction

	_player_detector.target_position.x *= -1
	_player_detector.force_raycast_update()

	if _floor_detector != null and _floor_detector.enabled:
		_floor_detector.target_position.x *= -1
		_floor_detector.force_raycast_update()



func get_type() -> StringName:
	return ennemy_type

func receive_hit(amount: int) -> void:
	if health <= 0 or amount <= 0:
		return

	health = maxi(health - amount, 0)

	if health == 0:
		if hit_tween:
			hit_tween.kill()

		if hit_material:
			hit_material.set_shader_parameter("hit_strength", 0.0)

		_state_machine.on_child_transition(_state_machine.current_state, "EnnemyDeath")
	else:
		play_damage_flash()

	if not sees_player():
		change_direction()

	hit_received.emit(amount)


func play_damage_flash() -> void:
	if hit_material == null:
		push_warning("Flash impossible : hit_material est null sur " + str(name))
		return

	if hit_tween:
		hit_tween.kill()

	hit_material.set_shader_parameter("hit_strength", 0.85)

	hit_tween = create_tween()
	hit_tween.tween_interval(0.04)
	hit_tween.tween_property(hit_material, "shader_parameter/hit_strength", 0.0, 0.11)
