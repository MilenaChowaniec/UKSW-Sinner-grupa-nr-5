extends StaticBody2D
##Klasa Trap obsługuje obiekty pułapki w rozgrywce - kolce wysuwające się z podłoża.
class_name Trap

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

##zmienna opisująca czas przez który kolce są wysunięte z podłoża. 
@export var up_time: float = 1.0
##zmienna opisująca czas przez który kolce są schowane. 
@export var down_time: float = 2.0
##zmienna określająca czy kolce są wysunięte: wartość false - kolce nie są wysunięte, wartość true - kolce są wysunięte. 
var trap_up: bool = false 


##Funkcja przygotowująca obiekt, urchamiana przy inicjalizacji.
##Funkcja ustawia parametry początkowe obiektu.
func _ready() -> void:
	trap_up = false
	collision_shape.disabled = true
	sprite.play("start")  
	timer.start()

## Funkcja wywoływana automatycznie po upłynięciu czasu timera.
## Steruje stanem pułapki – naprzemiennie podnosi ją i opuszcza.
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
