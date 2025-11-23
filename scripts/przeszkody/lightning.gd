extends Area2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D



func _on_mouse_entered() -> void:
	animation.play("active")


func _on_body_entered(body: Node2D) -> void:
	animation.play("active")
