class_name Chest extends StaticBody2D
@export var skrzynia_animation: AnimatedSprite2D
@onready var serce: Area2D = $serce1
@onready var serce2: Area2D = $serce2

##Zmienna określająca czy skrzynia jest otwarta: true - skrzynia otwarta, false - skrzynia zamknięta. 
var open: bool = false 
##Funkcja ustawia parametry początkowe obiektów: serca na początku mają wyłączoną widoczność i wykrywanie obiektów.
func _ready() -> void:
	serce.visible = false
	serce.monitoring = false
	serce2.visible = false
	serce2.monitoring = false
	open = false
	serce.body_entered.connect(_on_serce_body_entered)
	serce2.body_entered.connect(_on_serce2_body_entered)

##Funkcja aktywowana przez wejście ciała na obiekt skrzyni.
##Funkcja uruchamia animację otwierania skrzyni.
func _on_collision_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not open:
		skrzynia_animation.play("open")
		open = true
		

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
func _on_serce_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.hp += 1
		print(body.hp)
		serce.queue_free()

##Funkcja aktywowana po dotknięciu drugiego serca przez inny obiekt.
##Funkcja dodaje punkty hp graczowi.		
func _on_serce2_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.hp += 1
		print(body.hp)
		serce2.queue_free()
