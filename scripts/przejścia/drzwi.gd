##Klasa Drzwi obsługuje obiekty drzwi w rozgrywce.
class_name Door extends Area2D
##Zmienna określająca czy drzwi są otwarte: false - zamknięte, true - otwarte.
var open = false
##Referencja do animacji drzwi.
@export var drzwi_animation: AnimatedSprite2D

## Funkcja wywoływana gdy gracz wejdzie w obszar kolizji obiektu drzwi.
## Funkcja uruchamia animację otwierania drzwi.
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not open:
		open = true
		drzwi_animation.play("open")
		body.set_physics_process(false)
		await drzwi_animation.animation_finished
		body.set_physics_process(true)
		
##Funkcja wywoływana gdy gracz wyjdzie z obszaru kolizji obiektu drzwi.
##Funkcja uruchamia animację zamykania drzwi.
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" and open:
		open = false
		drzwi_animation.play("close")
