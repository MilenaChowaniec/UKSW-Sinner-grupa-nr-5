##Klasa RedRoom obsługuje mechanizm odblokowywania drzwi w czerwonym pokoju.
class_name RedRoom extends Node2D

## Przeciwnik typu Bat znajdujący się w pokoju.
@onready var bat: CharacterBody2D = $Bat

## Przeciwnik typu Renger w wersji v2 znajdujący się w pokoju.
@onready var renger_v_2: CharacterBody2D = $Renger_v2

## Przeciwnik typu Renger znajdujący się w pokoju.
@onready var renger: CharacterBody2D = $Renger

## Referencja do drzwi w pokoju.
@onready var drzwi: Door = $drzwi

## Referencja do kraty blokującej przejście w pokoju.
@onready var krata: Grid = $krata

## Licznik przeciwników pozostałych do pokonania w pokoju.
var enemies_left = 0


## Funkcja wywoływana przy wejściu pokoju do drzewa sceny.
func _ready() -> void:
	drzwi.unlock()
	krata.lock()
	
	var enemies := [bat, renger_v_2, renger]
	enemies = enemies.filter(func(e): return is_instance_valid(e))
	enemies_left = enemies.size()
	
	if enemies_left == 0:
		krata.unlock()
		return
	
	for e in enemies:
		e.tree_exited.connect(_on_enemy_removed)


## Funkcja wywoływana w momencie usunięcia przeciwnika ze sceny.
func _on_enemy_removed() -> void:
	enemies_left -= 1
	if enemies_left <= 0:
		krata.unlock()
