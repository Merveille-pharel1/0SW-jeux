extends Area2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var label: Label = %Label
@onready var panel: PanelContainer = %Panel

@export var collision_size: Vector2 = Vector2(50,50)

var player_inside := false
signal interact

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.visible = false
	set_label("Interagir")
	var rectangle := collision.shape as RectangleShape2D
	rectangle.size = collision_size


func set_label(text: String) -> void:
	label.text = text;


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		panel.visible = true
		player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		panel.visible = false
		player_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		interact.emit()
