class_name bullet extends Area2D

@export var speed: float = 400.0 
@export var max_distance: float = 200
var direction: Vector2 = Vector2.RIGHT
var start_position: Vector2  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = direction.angle()


func _process(delta):
	global_position += direction.normalized() * speed * delta
	if global_position.distance_to(start_position) >= max_distance:
		queue_free()
