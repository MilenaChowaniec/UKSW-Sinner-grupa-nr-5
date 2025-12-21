##Klasa reprezentująca platformę, która znika po wejściu gracza i odradza się po określonym czasie.
class_name VanishingPlatform extends Area2D
##Referencja do obiektu Timer - steruje cyklem znikania i pojawiania się platformy.
@onready var timer: Timer = $Timer
##Referencja do obszaru kolizji platformy.
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
##Referencja do obszaru wykrywania wejścia gracza na platformę.
@onready var collision_area: CollisionShape2D = $Area2D/CollisionShape2D

##zmienna określająca czas po którym po wejściu gracza na platformę zaczyna ona znikać.
@export var disappear_delay := 0.6
##zmienna określająca czas po którym platfroma znów się pojawia po zniknięciu.
@export var respawn_delay := 10.0
##zmienna określająca czy platforma jest aktualnie aktywna: false - nieaktywna, true - aktywna.
var is_active: bool = true
##zmienna określająca czy gracz znajduje się na konkretnej platformie: false - gracz poza platformą, true - gracz na platformie.
var player_on_this_wood: bool = false

##Funkcja sprawdza czy na ppowierzchni platformy znajdują się jakieś obiekty i czy wśród nich jest gracz.
##Ustawia zmienną player_on_this_wood w zależności od wyniku.
func _physics_process(_delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if b.name == "Player":
			player_on_this_wood = true
		else:
			player_on_this_wood = false
	


##Funkcja uruchamiana przy inicjalizacji obiektu.
##Funkcja określa parametry początkowe obiektu.
func _ready() -> void:
	add_to_group("wood_platforms") 
	modulate.a = 1.0
	collision_shape_2d.disabled = false
	collision_area.disabled = false

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

##Funkcja wywoływana, gdy dowolne ciało wejdzie do Area2D platformy.
##Funkcja sprawdza czy obiekt to gracz i ustawia czas odliczania na disappear_delay oraz uruchamia timer.
##@param body - obiekt, z którym nastąpiła kolizja
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		timer.wait_time = disappear_delay
		timer.start()
		
##Funkcja wywoływana, gdy dowolne ciało wyjdzie z Area2D platformy.
##Funkcja sprawdza czy obiekt to gracz i przestawia wartość zmiennej player_on_this_wood.
##@param body - obiekt, który opuścił obszar platformy
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_on_this_wood = false
