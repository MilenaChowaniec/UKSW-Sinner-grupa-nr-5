extends Area2D
var Player_Is_In:bool
@export var drzwi_animation: AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		drzwi_animation.play("open_drzwi")
		
	
