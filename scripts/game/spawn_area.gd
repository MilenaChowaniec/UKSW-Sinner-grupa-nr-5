class_name Spawn extends Node2D
@onready var spawn_purple: Marker2D = $purple_room/spawn_purple
@onready var spawn_blue: Marker2D = $blue_room/spawn_blue
@onready var spawn_red: Marker2D = $red_room/spawn_red

@onready var player: Player = $Player

@onready var purple_room = $purple_room
@onready var blue_room = $blue_room
@onready var red_room = $red_room

var current_room: Node2D

func _ready() -> void:
	player.global_position = spawn_purple.global_position
	set_camera_bounds(550,100,300,400)


func _on_spawn_area_purple_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.global_position = spawn_blue.global_position
		set_camera_bounds(3150,0,300,600)

func _on_spawn_area_blue_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.global_position = spawn_red.global_position
		set_camera_bounds(5250,300,600,300)

func _on_spawn_area_red_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().quit()

func set_camera_bounds(left : int, top : int, right: int, bottom: int) -> void:
	player.camera_2d.limit_left = left
	player.camera_2d.limit_top = top
	player.camera_2d.limit_right = right
	player.camera_2d.limit_bottom = bottom
