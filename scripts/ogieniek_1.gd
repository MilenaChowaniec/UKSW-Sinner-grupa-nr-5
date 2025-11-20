##Klasa Ogieniek obsługuje przeszkody w postaci płomieni w rozgrywce. 
class_name Ogieniek
extends Area2D

## Funkcja uruchamia się po zderzeniu obiektu klasy Ogieniek z innym obiektem w grze.
## Jeśli obiekt był graczem, funkcja odejmuje mu HP.
## @param body - obiekt, z ktorym nastapilo zderzenie
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("odejmujemy HP")
