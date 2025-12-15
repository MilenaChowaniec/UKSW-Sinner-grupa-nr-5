##Klasa Spawn odpowiadająca za początkowe ustawienie pozycji gracza przy zmianie pokoju.
class_name Spawn extends Node2D
##Referencja do obiektu Marker2D oznaczającego miejsce początkowej pozycji gracza w pokoju fioletowym.
@onready var spawn_purple: Marker2D = $purple_room/spawn_purple
##Referencja do obiektu Marker2D oznaczającego miejsce początkowej pozycji gracza w pokoju niebieskim.
@onready var spawn_blue: Marker2D = $blue_room/spawn_blue
##Referencja do obiektu Marker2D oznaczającego miejsce początkowej pozycji gracza w pokoju czerwonym.
@onready var spawn_red: Marker2D = $red_room/spawn_red
##Referencja do obiektu gracza.
@onready var player: Player = $Player

##Funkcja wywoływana przy inicjalizacji.
##Funkcja ustawia pozycję gracza w pierwszym pokoju przy użyciu znacznika spawn_purple.
func _ready() -> void:
	player.global_position = spawn_purple.global_position
	
##Funkcja wywoływana przy wejściu w miejsce przeniesienia gracza do kolejnego pokoju.
##Funkcja ustawia pozycję gracza w drugim pokoju przy użyciu znacznika spawn_blue.	
func _on_spawn_area_purple_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.global_position = spawn_blue.global_position
		

##Funkcja wywoływana przy wejściu w miejsce przeniesienia gracza do kolejnego pokoju.
##Funkcja ustawia pozycję gracza w trzecim pokoju przy użyciu znacznika spawn_red.
func _on_spawn_area_blue_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.global_position = spawn_red.global_position

##Funkcja wywoływana przy wejściu w miejsce przeniesienia gracza do kolejnego pokoju.
##Funkcja kończy rozgrywkę.
func _on_spawn_area_red_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().quit()
