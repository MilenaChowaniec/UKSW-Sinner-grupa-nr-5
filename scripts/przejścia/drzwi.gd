
##Klasa Drzwi obsługuje obiekty drzwi w rozgrywce.
class_name Drzwi extends Area2D

var open = false

@export var drzwi_animation: AnimatedSprite2D
#to docelowo:
## Funkcja wywoływana gdy gracz wejdzie w obszar kolizji obiektu drzwi.
## Funkcja uruchamia animację otwierania drzwi.
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not open:
		open = true
		drzwi_animation.play("open")
		

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" and open:
		open = false
		drzwi_animation.play("close")
