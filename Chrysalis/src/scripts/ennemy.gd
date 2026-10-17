class_name Ennemy
extends CharacterBody2D

@onready var _animation_player = $AnimationPlayer
@onready var _sprite = $Icon
@onready var _state_machine = $StateMachine
@onready var _floor_detector = $FloorDectector
@onready var _player_detector = $PlayerDetector
@onready var hitbox: Hitbox = $EnnemyHitbox
@onready var hurtbox: Hurtbox = $EnnemyHurtbox

@export var ennemy_type : StringName
@export var max_health: int = 100

signal hit_received(amount: int)

var player: Player
var direction := 1 
var health: int
var pending_damage: int = 0
var hitbox_offset_x: float

func _ready() -> void:
	health = max_health

	hurtbox.damage_received.connect(receive_hit)
	hit_received.connect(_on_hit_received)

	player = get_tree().get_first_node_in_group("player") as Player

	hitbox_offset_x = absf(hitbox.position.x)


func _physics_process(delta: float) -> void:
	move_and_slide()
	

func get_animation_player() -> AnimationPlayer:
	return _animation_player


func get_player() -> Player:
	return player


func get_distance_to_player() -> float:
	if not is_instance_valid(player):
		return INF

	return global_position.distance_to(player.global_position)


func get_direction_to_player() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO

	return global_position.direction_to(player.global_position)


func change_direction() -> void:
	direction *= -1
	_sprite.flip_h = !_sprite.flip_h 
	_floor_detector.target_position.x *= -1
	_player_detector.target_position.x *= -1
	hitbox.position.x = hitbox_offset_x * direction


func get_type() -> StringName:
	return ennemy_type

func receive_hit(amount: int) -> void:
	if health <= 0:
		return

	pending_damage += amount
	hit_received.emit(amount)


func _on_hit_received(amount: int) -> void:
	_state_machine.on_child_transition( _state_machine.current_state,"EnnemyDamage")
