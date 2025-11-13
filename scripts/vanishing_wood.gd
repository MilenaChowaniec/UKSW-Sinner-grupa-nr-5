extends StaticBody2D
@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

#to do testow bez gracza:
func _on_area_2d_mouse_entered() -> void:
	timer.start()
	#if body.name = timer.start()


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.3)
	collision_shape_2d.position = Vector2(-10000, 20000)
	
#to docelowo:
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		timer.start()
