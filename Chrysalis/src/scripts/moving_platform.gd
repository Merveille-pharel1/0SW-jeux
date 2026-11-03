extends Node2D

@export var offset = Vector2(350, 0)
@export var duration = 6.0

@onready var anim_body : AnimatableBody2D = $AnimatableBody2D

func _ready() -> void:
    start_tween()

func start_tween():
    var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS) as Tween
    tween.set_loops().set_parallel(false)
    tween.tween_property(anim_body, "position", offset, duration / 2)
    tween.tween_property(anim_body, "position", Vector2.ZERO, duration)
