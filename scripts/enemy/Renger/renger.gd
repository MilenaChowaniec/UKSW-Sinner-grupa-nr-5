class_name Renger extends CharacterBody2D

@export var move_speed: float = 50.0
@export var health: int = 100

@onready var animated_sprite = $AnimatedSprite2D
@onready var player_detection_zone = $PlayerDetectionZone

var player: Node2D = null
var current_state: String = "static_idle"
var is_dead: bool = false
var time_since_last_attack: float = 0.0
var can_attack: bool = true

func _ready():
	pass


func _process(delta):
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	velocity = direction * move_speed
	
	pass


func _physics_process(delta):
	move_and_slide()
	if is_dead:
		return
	
