extends CharacterBody2D

@export var speed: float = 100.0
@export var health: int = 3
@export var damage: int = 1

var player: Node2D
var is_active: bool = false

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# PODPIĘCIE ANIMACJI
	animated_sprite.play("fly")
	
	# Znajdź gracza
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_active or not player:
		return
	
	# Ruch w kierunku gracza
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	# Obrót sprite
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
	
	move_and_slide()

func activate():
	is_active = true

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	animated_sprite.play("death")
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	queue_free()

# Obsługa obszarów detekcji
func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		activate()

func _on_attack_area_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _on_detection_area_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_attack_area_area_d_2_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
