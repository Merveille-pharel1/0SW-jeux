extends Node2D

@onready var boss_sprite2D: Sprite2D = $Parallax/Salle11Parallax/Icon
@onready var interaction_box: Area2D = $InteractiveElements/InteractionBox
@onready var cabin: Node2D = %Elevator/Cabin
@onready var place_noe: Marker2D = %Elevator/Cabin/PlacePlayer
@onready var arrival_cabin: Marker2D = %Elevator/ArrivalCabin
@onready var floor_exit: Marker2D = %Elevator/FloorExit
@onready var player: Player = $Player

@export var decor_boss_close: Texture2D
@export var decor_boss_open: Texture2D
@export var player_camera: Camera2D

var elevator_openned := false
var road_launch := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss_sprite2D.texture = decor_boss_close
	interaction_box.set_label("Ouvrir")
	set_camera_bounds($CameraBounds/GroundFloor)
	cabin.get_node("ForegroundCabin").z_index = -1
	%Elevator/ElevatorLintel.z_index = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interaction_box_interact() -> void:
	boss_sprite2D.texture = decor_boss_open
	interaction_box.visible = false
	elevator_openned = true
	cabin.get_node("ForegroundCabin").visible = false



func _on_boarding_zone_body_entered(body: Node2D) -> void:
	if body != player or not elevator_openned or road_launch:
		return
	
	road_launch = true
	player.in_elevator = true
	player.velocity = Vector2.ZERO
	AscendPlayer.call_deferred()


func AscendPlayer() -> void :
	var initial_parent: Node = player.get_parent()

	var boarding := create_tween()
	boarding.tween_property(player, "global_position", place_noe.global_position, 1.0)

	await boarding.finished

	cabin.get_node("ForegroundCabin").z_index = 1
	%Elevator/ElevatorLintel.z_index = 2
	cabin.get_node("ForegroundCabin").visible = true

	player.reparent(cabin, true)

	var ascendTween := create_tween()
	ascendTween.set_trans(Tween.TRANS_SINE)
	ascendTween.set_ease(Tween.EASE_IN_OUT)
	ascendTween.tween_property(cabin, "global_position", arrival_cabin.global_position, 3.0)

	await ascendTween.finished

	player.reparent(initial_parent, true)
	player.global_position = floor_exit.global_position
	player.in_elevator = false

	cabin.get_node("ForegroundCabin").z_index = -1

func set_camera_bounds(zone: Node2D) -> void:
	var top_left: Marker2D = zone.get_node("TopLeft")
	var bottom_right: Marker2D = zone.get_node("BottomRight")

	player_camera.limit_left = floori(top_left.global_position.x)
	player_camera.limit_top = floori(top_left.global_position.y)
	player_camera.limit_right = floori(bottom_right.global_position.x)
	player_camera.limit_bottom = floori(bottom_right.global_position.y)


func _on_basement_area_body_entered(body: Node2D) -> void:
	if body == player:
		if player.global_position.y <= %BasementArea.get_node("CollisionShape2D").global_position.y:
			set_camera_bounds($CameraBounds/Basement)
		else:
			set_camera_bounds($CameraBounds/Shaft)


func _on_upper_area_body_entered(body: Node2D) -> void:
	if body == player:
		set_camera_bounds($CameraBounds/UpperFloor)
	

func _on_shaft_area_body_entered(body: Node2D) -> void:
	if body == player:
		if player.global_position.y <= %ShaftArea.get_node("CollisionShape2D").global_position.y:
			set_camera_bounds($CameraBounds/Shaft)
		else:
			set_camera_bounds($CameraBounds/GroundFloor)
