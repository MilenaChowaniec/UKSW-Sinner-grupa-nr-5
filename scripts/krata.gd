extends Area2D
##Klasa Krata obsługuje obiekty krat w rozgrywce.
class_name Krata
@export var krata_animation: AnimatedSprite2D

#to docelowo albo żeby dopiero jak zabijemy wroga się otwierało:
## Funkcja wywoływana gdy gracz wejdzie w obszar kolizji obiektu kraty.
## Funkcja uruchamia animację otwierania kraty.
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		krata_animation.play("open")
		

#to do testow bez gracza:
func _on_mouse_entered() -> void:
	krata_animation.play("open")
