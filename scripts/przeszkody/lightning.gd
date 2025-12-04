##Klasa Błyskawica obsługuje pułapki typu błyskawica w rozgrywce.
class_name Lightning extends Area2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

func freeze_player(player: Node2D, duration: float) -> void:
	player.set_physics_process(false)
	await get_tree().create_timer(duration).timeout
	player.set_physics_process(true)

##Funkcja uruchamiana przy kolizji z innym obiektem.
##Jeśli obiektem jest gracz, funkcja odejmuje mu punkty hp.
##@param body - obiekt, z którym nastąpiło zderzenie.
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		animation.play("active")
		body.set_physics_process(false)
		await animation.animation_finished
		body.set_physics_process(true)
		#tu trzeba odjąc hp graczowi
