extends Area2D
@export var skrzynia_animation: AnimatedSprite2D
@onready var serce: Area2D = $Area2D
@onready var serce2: Area2D = $Area2D2

##Funkcja ustawia parametry początkowe obiektów: serca na początku mają wyłączoną widoczność i wykrywanie obiektów.
func _ready() -> void:
	serce.visible = false
	serce.monitoring = false
	serce2.visible = false
	serce2.monitoring = false
	

func _on_mouse_entered() -> void:
	skrzynia_animation.play("open")

##Funkcja aktywowana przez wejście ciała na obiekt skrzyni.
##Funkcja uruchamia animację otwierania skrzyni.
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		skrzynia_animation.play("open")

##Funkcja aktywowana po zakończeniu animacji otwarcia skrzyni.
##Funkcja przełącza widoczność serc na włączoną i wykrywanie obiektów na aktywne.
func _on_animated_sprite_2d_animation_finished() -> void:
	if skrzynia_animation.animation == "open":
		serce.visible = true
		serce.monitoring = true
		serce2.visible = true
		serce2.monitoring = true
		
##Funkcja aktywowana po dotknięciu pierwszego serca przez inny obiekt.
##Funkcja dodaje punkty hp graczowi.		
func _on_serce_mouse_entered(body: Node2D) -> void:
	if body.name == "PLayer":
		print("Zebrałes przedmiot")
		serce.queue_free()
		
##Funkcja aktywowana po dotknięciu drugiego serca przez inny obiekt.
##Funkcja dodaje punkty hp graczowi.		
func _on_serce2_mouse_entered(body: Node2D) -> void:
	if body.name == "PLayer":
		print("Zebrałes przedmiot")
		serce.queue_free()
