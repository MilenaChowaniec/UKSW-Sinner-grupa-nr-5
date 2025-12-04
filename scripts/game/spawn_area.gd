class_name Spawn extends Node2D
@onready var spawn_purple: Marker2D = $purple_room/spawn_purple
@onready var spawn_blue: Marker2D = $blue_room/spawn_blue
@onready var spawn_red: Marker2D = $red_room/spawn_red

@onready var player: Player = $Player

func _ready() -> void:
	player.global_position = spawn_purple.global_position
	
func _on_spawn_area_purple_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.global_position = spawn_blue.global_position
		


func _on_spawn_area_blue_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.global_position = spawn_red.global_position

func _on_spawn_area_red_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().quit()
