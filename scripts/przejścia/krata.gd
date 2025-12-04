
##Klasa Krata obsługuje obiekty krat w rozgrywce.
class_name Grid extends Area2D
@export var krata_animation: AnimatedSprite2D
var open = false

#to docelowo albo żeby dopiero jak zabijemy wroga się otwierało:
## Funkcja wywoływana gdy gracz wejdzie w obszar kolizji obiektu kraty.
## Funkcja uruchamia animację otwierania kraty.
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not open:
		open = true
		krata_animation.play("open")
		body.set_physics_process(false)
		await krata_animation.animation_finished
		body.set_physics_process(true)
		
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" and open:
		open = false
		krata_animation.play("close")
