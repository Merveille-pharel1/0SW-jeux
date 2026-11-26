extends Node2D

@onready var health_bar: TextureProgressBar = $HealthBar

@export var auto_position: bool = true
@export var sprite_path: NodePath = NodePath("../Icon")
@export var collision_path: NodePath = NodePath("../CollisionShape2D")
@export_range(0.0, 100.0, 1.0) var gap: float = 12.0
@export var extra_offset := Vector2.ZERO

func _ready() -> void:
	_update_position()
	set_process(auto_position)


func _process(_delta: float) -> void:
	_update_position()


func _update_position() -> void:
	health_bar.position = -health_bar.size * health_bar.scale / 2.0

	if not auto_position:
		return

	var parent_2d := get_parent() as Node2D
	if parent_2d == null:
		return

	var source: Node2D
	var rect: Rect2
	var sprite := get_node_or_null(sprite_path) as Sprite2D
	var collision := get_node_or_null(collision_path) as CollisionShape2D
	
	if sprite != null and sprite.texture != null:
		source = sprite
		rect = sprite.get_rect()
	elif collision != null and collision.shape != null:
		source = collision
		rect = collision.shape.get_rect()
	else:
		return # position manuelle si aucune dimension n'est disponible.

	var transform_to_parent := parent_2d.global_transform.affine_inverse() * source.global_transform
	var bounds := transform_to_parent * rect
	var half_height := health_bar.size.y * absf(health_bar.scale.y * scale.y) / 2.0
	
	position = Vector2(bounds.get_center().x, bounds.position.y - gap - half_height) + extra_offset
