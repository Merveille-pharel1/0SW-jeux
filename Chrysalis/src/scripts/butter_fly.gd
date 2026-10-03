extends Node2D

@export var speed: float = 70.0
@export var direction_change_time: float = 1.2
@export var turn_speed: float = 2.0
@onready var animated_sprite :AnimatedSprite2D = $AnimatedSprite2D

var direction := Vector2.RIGHT
var target_direction := Vector2.RIGHT
var timer := 0.0
var screen_size := Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	choose_new_direction()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta

	if timer <= 0:
		choose_new_direction()
		
	# Turn progressively
	direction = direction.lerp(target_direction, turn_speed * delta).normalized()
	position += direction * speed * delta
	
	
	if position.x > screen_size.x:
		direction = Vector2.LEFT
		animated_sprite.flip_h = true
	
	if position.x <= 0:
		direction = Vector2.RIGHT
		animated_sprite.flip_h = false
		
	
func choose_new_direction() -> void:
	target_direction = Vector2(randf_range(direction.y, direction.x), randf_range(-0.7, 0.7)).normalized()

	timer = randf_range(direction_change_time * 0.5, direction_change_time * 1.5)
