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
var camera_bounds_tween: Tween

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

	%ExitFloorSprite.visible = false
	
	player.reparent(initial_parent, true)
	player.global_position = floor_exit.global_position
	player.in_elevator = false

	cabin.get_node("ForegroundCabin").z_index = -1



func set_camera_bounds(zone: Node2D, immediate: bool = false) -> void:
	var top_left: Marker2D = zone.get_node("TopLeft")
	var bottom_right: Marker2D = zone.get_node("BottomRight")

	var top := floori(top_left.global_position.y)
	var bottom := ceili(bottom_right.global_position.y)

	if zone == $CameraBounds/Shaft:
		top = floori($CameraBounds/GroundFloor/TopLeft.global_position.y)
		bottom = ceili($CameraBounds/Basement/BottomRight.global_position.y)

	if camera_bounds_tween:
		camera_bounds_tween.kill()

	
	var target := Vector4(
		floori(top_left.global_position.x),
		top,
		floori(bottom_right.global_position.x),
		bottom
	)

	if immediate:
		apply_camera_bounds(target)
		return

	var current := Vector4(
		player_camera.limit_left, player_camera.limit_top,
		player_camera.limit_right, player_camera.limit_bottom
	)

	camera_bounds_tween = create_tween()
	camera_bounds_tween.set_trans(Tween.TRANS_SINE)
	camera_bounds_tween.set_ease(Tween.EASE_IN_OUT)
	camera_bounds_tween.tween_method(apply_camera_bounds, current, target, 0.5)


func apply_camera_bounds(bounds: Vector4) -> void:
	player_camera.limit_left = roundi(bounds.x)
	player_camera.limit_top = roundi(bounds.y)
	player_camera.limit_right = roundi(bounds.z)
	player_camera.limit_bottom = roundi(bounds.w)


func _on_upper_area_body_entered(body: Node2D) -> void:
	if body == player:
		set_camera_bounds($CameraBounds/UpperFloor)

func _on_down_basement_area_body_entered(body: Node2D) -> void:
	if body == player:
		var trigger: CollisionShape2D = %DownBasementArea.get_node("CollisionShape2D")

		if player.global_position.y <= trigger.global_position.y:
			set_camera_bounds($CameraBounds/Basement)
		else:
			set_camera_bounds($CameraBounds/Shaft)
	

func _on_shaft_area_body_entered(body: Node2D) -> void:
	if body == player:
		var trigger: CollisionShape2D = %ShaftArea.get_node("CollisionShape2D")

		if player.global_position.y <= trigger.global_position.y:
			set_camera_bounds($CameraBounds/Shaft)
		else:
			set_camera_bounds($CameraBounds/GroundFloor)


func _on_shaft_area_body_exited(body: Node2D) -> void:
	if body == player:
		var trigger: CollisionShape2D = %ShaftArea.get_node("CollisionShape2D")

		if player.global_position.y <= trigger.global_position.y:
			set_camera_bounds($CameraBounds/GroundFloor)
		else:
			set_camera_bounds($CameraBounds/Shaft)


func _on_down_basement_area_body_exited(body: Node2D) -> void:
	if body == player:
		var trigger: CollisionShape2D = %DownBasementArea.get_node("CollisionShape2D")

		if player.global_position.y <= trigger.global_position.y:
			set_camera_bounds($CameraBounds/Shaft)
		else:
			set_camera_bounds($CameraBounds/Basement)
