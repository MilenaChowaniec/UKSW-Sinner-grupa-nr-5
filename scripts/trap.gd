extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

@export var up_time: float = 1.0
@export var down_time: float = 2.0
var trap_up: bool = false 



func _ready() -> void:
	trap_up = false
	collision_shape.disabled = true
	sprite.play("start")  
	timer.start()

func _on_timer_timeout() -> void:
	if trap_up:
		trap_up = false
		sprite.play("trap_down")          
		collision_shape.disabled = true  #nie zadaja obrazen
		timer.wait_time = down_time   
		timer.start()
	else:
		trap_up = true
		sprite.play("trap_up")            
		collision_shape.disabled = false #zadaja obrazenia 
		timer.wait_time = up_time    
		timer.start()
