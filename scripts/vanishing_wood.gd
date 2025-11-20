extends StaticBody2D
##Klasa reprezentująca platformę, która znika po wejściu gracza i odradza się po określonym czasie.
class_name VanishingPlatform
##steruje cyklem znikania i pojawiania się
@onready var timer: Timer = $Timer
##obszar kolizji platformy
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
##obszar wykrywania wejścia gracza na platformę
@onready var collision_area: CollisionShape2D = $Area2D/CollisionShape2D

##zmienna określająca czas po którym po wejściu gracza na platformę zaczyna ona znikać.
@export var disappear_delay := 1.0
##zmienna określająca czas po którym platfroma znów się pojawia po zniknięciu.
@export var respawn_delay := 10.0
##zmienna określająca czy platforma jest aktualnie aktywna: false - nieaktywna, true - aktywna.
var is_active: bool = true

##Funkcja uruchamiana przy inicjalizacji obiektu.
##Funkcja określa parametry początkowe obiektu.
func _ready() -> void:
	modulate.a = 1.0
	collision_shape_2d.disabled = false
	collision_area.disabled = false

#to do testow bez gracza:
func _on_area_2d_mouse_entered() -> void:
	timer.wait_time = disappear_delay
	timer.start()
	#if body.name = timer.start()

## Funkcja wywoływana automatycznie po upłynięciu czasu timera.
## Steruje cyklem działania platformy -> zniknięcie -> odrodzenie -> zniknięcie -> ...
func _on_timer_timeout() -> void:
	if is_active:
		is_active = false
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.3)
		
		collision_shape_2d.disabled = true
		collision_area.disabled = true
		
		timer.wait_time = respawn_delay
		timer.start()
	else:
		is_active = true
		
		collision_shape_2d.disabled = false
		collision_area.disabled = false
		
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
#to docelowo:
##Funkcja wywoływana, gdy dowolne ciało wejdzie do Area2D platformy.
##Funkcja sprawdza czy obiekt to gracz i ustawia czas odliczania na disappear_delay oraz uruchamia timer.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		timer.wait_time = disappear_delay
		timer.start()
