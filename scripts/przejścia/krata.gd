## Klasa Krata obsługuje obiekty krat w rozgrywce.
class_name Grid
extends Area2D

## Referencja do animacji kraty.
@export var krata_animation: AnimatedSprite2D

## Zmienna określająca czy krata jest otwarta: false – zamknięta, true – otwarta.
var open = false

## Zmienna określająca czy możliwe jest otworzenie kraty.
var locked = true

## Fizyczna blokada uniemożliwiająca przejście przez kratę.
@onready var blocker: StaticBody2D = $Blocker

## Kształt kolizji blokady kraty.
@onready var blocker_shape: CollisionShape2D = $Blocker/CollisionShape2D


## Funkcja wywoływana po wejściu obiektu kraty do drzewa sceny.
func _ready() -> void:
	blocker_shape.disabled = not locked


## Funkcja odblokowująca kratę i umożliwiająca przejście gracza.
func unlock() -> void:
	locked = false
	blocker_shape.disabled = true
	

## Funkcja blokująca kratę i uniemożliwiająca przejście gracza.
func lock() -> void:
	locked = true
	blocker_shape.disabled = false
	

## Funkcja wywoływana gdy gracz wejdzie w obszar kolizji obiektu kraty.
## Funkcja uruchamia animację otwierania kraty.
func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	if locked:
		return
	if not open:
		open = true
		krata_animation.play("open")
		body.set_physics_process(false)
		await krata_animation.animation_finished
		body.set_physics_process(true)
	

## Funkcja wywoływana gdy gracz wyjdzie z obszaru kolizji obiektu kraty.
## Funkcja uruchamia animację zamykania kraty.
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" and open:
		open = false
		krata_animation.play("close")
