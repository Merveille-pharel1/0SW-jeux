extends Node2D

@onready var health_bar: TextureProgressBar = $HealthBar


func _ready() -> void:
	health_bar.position = -health_bar.size * health_bar.scale / 2.0
