##Klasa Błyskawica obsługuje pułapki typu błyskawica w rozgrywce.
class_name Błyskawica extends Area2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

##Funkcja uruchamiana przy kolizji z innym obiektem.
##Jeśli obiektem jest gracz, funkcja odejmuje mu punkty hp.
##@param body - obiekt, z którym nastąpiło zderzenie.
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		animation.play("active")
		#tu trzeba odjąc hp graczowi
