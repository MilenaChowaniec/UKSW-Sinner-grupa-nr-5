## Klasa Drzwi obsługuje obiekty drzwi w rozgrywce.
class_name Door
extends Area2D

## Zmienna określająca czy drzwi są otwarte: false – zamknięte, true – otwarte.
var open = false

## Zmienna określająca czy możliwe jest otworzenie drzwi.
var locked = true

## Referencja do animacji drzwi.
@export var drzwi_animation: AnimatedSprite2D

## Fizyczna blokada uniemożliwiająca przejście przez drzwi.
@onready var blocker: StaticBody2D = $Blocker

## Kształt kolizji blokady drzwi.
@onready var blocker_shape: CollisionShape2D = $Blocker/CollisionShape2D


## Funkcja wywoływana po wejściu obiektu drzwi do drzewa sceny.
func _ready() -> void:
	blocker_shape.disabled = not locked


## Funkcja odblokowująca drzwi i umożliwiająca przejście gracza.
func unlock() -> void:
	locked = false
	blocker_shape.disabled = true


## Funkcja blokująca drzwi i uniemożliwiająca przejście gracza.
func lock() -> void:
	locked = true
	blocker_shape.disabled = false


## Funkcja wywoływana gdy gracz wejdzie w obszar kolizji obiektu drzwi.
## Funkcja uruchamia animację otwierania drzwi.
func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	if locked:
		return
	if not open:
		open = true
		drzwi_animation.play("open")
		body.set_physics_process(false)
		await drzwi_animation.animation_finished
		body.set_physics_process(true)


## Funkcja wywoływana gdy gracz wyjdzie z obszaru kolizji obiektu drzwi.
## Funkcja uruchamia animację zamykania drzwi.
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" and open:
		open = false
		drzwi_animation.play("close")
