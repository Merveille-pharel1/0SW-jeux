extends Sprite2D

@export_enum("Cover", "Fit Width") var fit_mode: int = 0
@export var depth_scale: Vector2 = Vector2.ONE
@export var repeat_horizontal: bool = false
@export var repeat_vertical: bool = false

func _ready() -> void:
	get_viewport().size_changed.connect(resize_background)
	resize_background()


func resize_background() -> void:
	if texture == null:
		return

	var viewport_size = get_viewport_rect().size
	var texture_size = texture.get_size()

	var factor: float

	if fit_mode == 0:
		factor = maxf(
			viewport_size.x / texture_size.x,
			viewport_size.y / texture_size.y
		)
	else:
		factor = viewport_size.x / texture_size.x

	scale = factor * depth_scale
	centered = false
	update_repetition(texture_size)

func update_repetition(texture_size: Vector2) -> void:
	var parallax := get_parent() as Parallax2D

	if parallax == null:
		return

	var repeat_x := 0.0
	var repeat_y := 0.0

	if repeat_horizontal:
		repeat_x = texture_size.x * absf(scale.x)

	if repeat_vertical:
		repeat_y = texture_size.y * absf(scale.y)

	parallax.repeat_size = Vector2(repeat_x, repeat_y)


	
