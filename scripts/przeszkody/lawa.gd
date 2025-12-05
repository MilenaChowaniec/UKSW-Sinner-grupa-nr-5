##Klasa Lava obsługuje działanie pułapki lawy w grze.
class_name Lava extends Area2D
##Referencja do obiektu Timera służącego do odliczania czasu co który odejmowane jest HP gracza podczas gdy znajduje się on w lawie.
@onready var timer: Timer = $Timer
##Zmienna określająca czy gracz znajduje się w lawie: false - gracz poza lawą, true - gracz w lawie.
var player_inside = false

##Funkcja uruchamiana gdy obiekt wejdzie w obszar kolizji obiektu lawa.
##Jeśli obiektem jest gracz, funkcja uruchamia timer.
##@param body - obiekt, który wszedł w obszar kolizji
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = true
		$Timer.start()
	
##Funkcja uruchamiana gdy obiekt wyjdzie z obszaru kolizji obiektu lawa.
##Jeśli obiektem jest gracz, funkcja zatrzymuje timer.
##@param body - obiekt, który wszedł w obszar kolizji	
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false
		$Timer.stop()
	
##Funkcja sprawdza czy gracz znajduje się w obszarze kolizji lawy. 
##Następnie sprawdza czy gracz znajduje się również na którejś z platform znajdujących się nad lawą.
##Jeśli gracz znajduje się w obszarze kolizji lawy i nie znajduje się na żadnej z platform funkcja odejmuje HP gracza. 	
func _on_timer_timeout() -> void:
	if not player_inside:
		return
		
	var player_on_any_wood := false
	for wood in get_tree().get_nodes_in_group("wood_platforms"):
			if wood.player_on_this_wood:
				player_on_any_wood = true
				break
				
	if player_on_any_wood:
		return
	else:
		#tu trzeba odjąc hp gracza
		print("odejmuje HP")
