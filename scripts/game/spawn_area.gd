## Klasa Spawn odpowiadająca za początkowe ustawienie pozycji gracza przy zmianie pokoju.
class_name Spawn
extends Node2D

## Referencja do obiektu Marker2D oznaczającego miejsce początkowej pozycji gracza w pokoju fioletowym.
@onready var spawn_purple: Marker2D = $purple_room/spawn_purple

## Referencja do obiektu Marker2D oznaczającego miejsce początkowej pozycji gracza w pokoju niebieskim.
@onready var spawn_blue: Marker2D = $blue_room/spawn_blue

## Referencja do obiektu Marker2D oznaczającego miejsce początkowej pozycji gracza w pokoju czerwonym.
@onready var spawn_red: Marker2D = $red_room/spawn_red

## Referencja do obiektu gracza.
@onready var player: Player = $Player

## Referencja do pokoju fioletowego.
@onready var purple_room = $purple_room

## Referencja do pokoju niebieskiego.
@onready var blue_room = $blue_room

## Referencja do pokoju czerwonego.
@onready var red_room = $red_room

## Zmienna przechowująca aktualny pokój, w którym znajduje się gracz.
var current_room: Node2D


## Funkcja wywoływana przy inicjalizacji sceny.
## Funkcja ustawia początkową pozycję gracza oraz granice kamery dla pierwszego pokoju.
func _ready() -> void:
	player.global_position = spawn_purple.global_position
	set_camera_bounds(550, 100, 300, 400)


## Funkcja wywoływana przy wejściu gracza w obszar przejścia z pokoju fioletowego do niebieskiego.
## Funkcja ustawia nową pozycję gracza oraz granice kamery dla pokoju niebieskiego.
func _on_spawn_area_purple_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.global_position = spawn_blue.global_position
		set_camera_bounds(3150, 0, 300, 600)


## Funkcja wywoływana przy wejściu gracza w obszar przejścia z pokoju niebieskiego do czerwonego.
## Funkcja ustawia nową pozycję gracza oraz granice kamery dla pokoju czerwonego.
func _on_spawn_area_blue_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.global_position = spawn_red.global_position
		set_camera_bounds(5250, 300, 600, 300)


## Funkcja wywoływana przy wejściu gracza w obszar zakończenia gry.
## Funkcja przełącza scenę na ekran końca gry.
func _on_spawn_area_red_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().change_scene_to_file("res://scenes/game/gameover.tscn")


## Funkcja ustawiająca granice kamery gracza.
## Parametry określają maksymalne granice ruchu kamery w aktualnym pokoju.
func set_camera_bounds(left: int, top: int, right: int, bottom: int) -> void:
	player.camera_2d.limit_left = left
	player.camera_2d.limit_top = top
	player.camera_2d.limit_right = right
	player.camera_2d.limit_bottom = bottom
