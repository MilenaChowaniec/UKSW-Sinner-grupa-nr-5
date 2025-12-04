##Klasa Ogienki obsługująca obiekty płomieni w rozgrywce.
class_name Fire extends Area2D

##Funkcja uruchamia się po zderzeniu z innym obiektem.
##Jeśli obiektem jest gracz, funkcja odejmuje graczowi hp.
##@param body - obiekt, z którym nastąpiła kolizja
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("odejmujemy hp")
		#tu trzeba odjac hp gracza
