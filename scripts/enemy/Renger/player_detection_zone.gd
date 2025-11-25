extends Area2D

@export var detection_range: float = 300.0
var player: Node2D = null

func _ready():
	var collision_shape = $CollisionShape2D
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = detection_range

func can_see_player() -> bool:
	return player != null

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_body_exited(body):
	if body == player:
		player = null
