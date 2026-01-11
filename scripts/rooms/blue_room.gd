##Klasa BlueRoom obsługuje mechanizm odblokowywania drzwi w niebieskim pokoju.
class_name BlueRoom extends Node2D

## Referencja do drzwi wyjściowych z pokoju.
@onready var drzwi: Door = $drzwi

## Referencja do kraty (blokady wejścia / wyjścia).
@onready var krata: Grid = $krata

## Przeciwnik typu Bat znajdujący się w pokoju.
@onready var bat: CharacterBody2D = $Bat

## Przeciwnik typu Renger znajdujący się w pokoju.
@onready var renger: CharacterBody2D = $Renger

## Drugi przeciwnik typu Renger znajdujący się w pokoju.
@onready var renger_2: CharacterBody2D = $Renger2

## Licznik przeciwników pozostałych do pokonania w pokoju.
var enemies_left = 0


## Funkcja wywoływana przy wejściu pokoju do drzewa sceny.
func _ready() -> void:
	drzwi.lock()
	krata.unlock()
	
	var enemies := [bat, renger_2, renger]
	enemies = enemies.filter(func(e): return is_instance_valid(e))
	enemies_left = enemies.size()
	
	if enemies_left == 0:
		drzwi.unlock()
		return
	
	for e in enemies:
		e.tree_exited.connect(_on_enemy_removed)


## Funkcja wywoływana w momencie usunięcia przeciwnika ze sceny.
func _on_enemy_removed() -> void:
	enemies_left -= 1
	if enemies_left <= 0:
		drzwi.unlock()
