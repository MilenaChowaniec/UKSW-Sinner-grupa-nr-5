extends Area2D
var Player_Is_In:bool
@export var krata_animation: AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		krata_animation.play("open_krata")
		
	
