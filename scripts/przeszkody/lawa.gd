class_name Lava extends Area2D
@onready var timer: Timer = $Timer
var player_inside = false
@onready var player: Player = $"../../Player"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("zderzenie z lawa")
		player_inside = true
		$Timer.start()
		
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("wyszedles z lawa")
		player_inside = false
		$Timer.stop()
		
func _on_timer_timeout() -> void:
	if not player_inside:
		return
		
	var player_on_any_wood := false
	for wood in get_tree().get_nodes_in_group("wood_platforms"):
			if wood.player_on_this_wood:
				player_on_any_wood = true
				break
				
	if player_on_any_wood:
		return
	else:
		print("odejmuje HP")
