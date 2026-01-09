class_name Renger extends CharacterBody2D

@export var move_speed: float = 150.0
@export var health: int = 4
@onready var animated_sprite = $AnimatedSprite2D
@onready var player_detection_zone = $PlayerDetectionZone

var direction: Vector2 = Vector2.ZERO
var state : String = "idle"
var cardinal_direction : Vector2 = Vector2.LEFT

func _ready():
	pass


func _process(delta):
	
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	velocity = direction * move_speed
	
	if SetState() == true:
		UpdateAnimation()
	
	pass


func _physics_process(delta):
	move_and_slide()
	return
	

func SetDirection() -> bool:
	return true

func SetState() -> bool:
	var new_state : String = "idle" if direction == Vector2.ZERO else "walk"
	if new_state == state:
		return false
	state = new_state
	return true


func UpdateAnimation() -> void:
	animated_sprite.play("static_idle")
	pass
	
	
func AnimDirection() -> String:
	if cardinal_direction == Vector2.LEFT:
		return "left"
	else:
		return "right"
		
