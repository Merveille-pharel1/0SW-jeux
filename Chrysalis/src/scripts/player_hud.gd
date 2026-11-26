extends CanvasLayer

@onready var hud: Control = $HUD
@onready var health_bar: TextureProgressBar = $HUD/PlayerHealthBar
@onready var portrait: TextureRect = $HUD/Portrait
@onready var percentage: Label = $HUD/HealthPercentage

@export var player_path: NodePath = NodePath("..")
@export var screen_margin := Vector2(24.0, 20.0)
@export_range(0.25, 2.0, 0.05) var hud_scale: float = 1.0
@export var portrait_texture: Texture2D
@export var portrait_frame := Vector2i(0, 0)
var _player: Node


func _ready() -> void:
	hud.position = screen_margin
	hud.scale = Vector2.ONE * hud_scale

	_layout_percentage()

	health_bar.resized.connect(_layout_percentage)
	portrait.resized.connect(_update_portrait_size)

	_update_portrait_size()

	_player = get_node_or_null(player_path)
	if _player == null or not _player.has_signal("health_changed"):
		push_warning("PlayerHUD : le joueur doit exposer le signal health_changed.")
		return

	_player.connect("health_changed", _on_health_changed)

	_setup_portrait()
	call_deferred("_refresh_health")


func _refresh_health() -> void:
	if is_instance_valid(_player):
		_on_health_changed(int(_player.get("health")), int(_player.get("max_health")))


func _on_health_changed(current_health: int, maximum_health: int) -> void:
	var maximum := maxi(maximum_health, 1)
	var current := clampi(current_health, 0, maxi(maximum_health, 0))

	health_bar.max_value = maximum
	health_bar.value = current
	percentage.text = "%d %%" % roundi(100.0 * float(current) / float(maximum))


func _setup_portrait() -> void:
	if portrait_texture != null:
		portrait.texture = portrait_texture
		return

	var sprite := _player.get_node_or_null("Icon") as Sprite2D
	if sprite == null or sprite.texture == null:
		push_warning("PlayerHUD : assigne Portrait Texture ou une texture au Sprite2D Icon.")
		return

	var source_rect := Rect2(Vector2.ZERO, sprite.texture.get_size())
	if sprite.region_enabled:
		source_rect = sprite.region_rect

	var cell_size := source_rect.size / Vector2(sprite.hframes, sprite.vframes)
	var cell := Vector2i(
		clampi(portrait_frame.x, 0, sprite.hframes - 1),
		clampi(portrait_frame.y, 0, sprite.vframes - 1)
	)

	var atlas := AtlasTexture.new()

	atlas.atlas = sprite.texture
	atlas.region = Rect2(source_rect.position + Vector2(cell) * cell_size, cell_size)
	atlas.filter_clip = true
	portrait.texture = atlas


func _update_portrait_size() -> void:
	var material := portrait.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("portrait_size", portrait.size)



func _layout_percentage() -> void:
	# Centre le label dans la barre
	if health_bar.texture_progress == null:
		return
		
	var fill_size := health_bar.texture_progress.get_size() * health_bar.scale
	var fill_position := health_bar.position + health_bar.texture_progress_offset * health_bar.scale
	percentage.size = fill_size
	percentage.position = fill_position + (fill_size - percentage.size) / 2.0
