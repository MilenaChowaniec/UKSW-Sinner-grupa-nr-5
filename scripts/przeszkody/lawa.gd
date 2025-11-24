class_name Lawa extends Area2D
@onready var timer: Timer = $Timer
var player_inside = false

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
	if player_inside:
		print("odejmuje HP")
