class_name bullet extends Area2D

@export var speed: float = 400.0 
@export var max_distance: float = 200

@onready var sprite: Sprite2D = $Sprite2D
@onready var explosion_sprite: Sprite2D = $ExplosionSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var direction: Vector2 = Vector2.RIGHT
var start_position: Vector2  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = direction.angle()
	explosion_sprite.visible = false
	animation_player.animation_finished.connect(_on_explosion_finished)


func _process(delta):
	global_position += direction.normalized() * speed * delta
	
	if global_position.distance_to(start_position) >= max_distance:
		explode()

func explode():
	speed = 0 
	sprite.visible = false 
	explosion_sprite.visible = true
	animation_player.play("explosion")
	 

func _on_explosion_finished(anim_name: String) -> void:
	if anim_name == "explosion":
		queue_free()  # usuwa Bullet po zakończeniu animacji
