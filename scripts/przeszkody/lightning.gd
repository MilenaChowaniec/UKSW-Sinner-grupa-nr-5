extends Area2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D



func _on_mouse_entered() -> void:
	animation.play("active")
