extends Area2D
var Player_Is_In:bool
@export var drzwi_animation: AnimatedSprite2D
#to docelowo:
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		drzwi_animation.play("open")
		
	

#to do testow bez gracza:
func _on_mouse_entered() -> void:
	drzwi_animation.play("open")


func _on_mouse_exited() -> void:
	drzwi_animation.play("close")
