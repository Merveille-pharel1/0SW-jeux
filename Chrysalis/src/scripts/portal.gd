extends Node2D

@onready var sparks: GPUParticles2D = get_node_or_null("Sparks")
@onready var interaction_box = $InteractionBox

@export var next_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_box.set_label("Entrer dans le portail")
	interaction_box.interact.connect(_on_player_interact)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_proximity_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if sparks != null:
			sparks.emitting = true;


func _on_proximity_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if sparks != null:
			sparks.emitting = false;

func _on_player_interact() -> void :
	if next_scene == null:
		print("Pas de prochaine scène assignée")
		return

	var player := get_tree().get_first_node_in_group(&"player") as Node2D

	if player != null:
		SceneTransition.teleport_to(next_scene, player)
