# RoomBounds.gd - Skrypt podpięty do każdego węzła Area2D/RoomBounds

extends Area2D

# Eksportowane zmienne, które ustawisz w Inspektorze dla każdego pokoju
@export var limit_left: int = 0
@export var limit_top: int = 0
@export var limit_right: int = 1024
@export var limit_bottom: int = 600

# Sygnał, który zostanie wyemitowany, gdy gracz wejdzie do pokoju
signal camera_limits_set(left_limit, top_limit, right_limit, bottom_limit)

func _ready():
	# Połącz sygnał body_entered z funkcją
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Zakładamy, że tylko gracz (Player) ma ciało, które może wejść do tego obszaru.
	# Warto dodać sprawdzenie, np. if body.name == "Player":
	if body.name != "Player":
		return
	# Emituj sygnał z danymi o granicach, które zostaną odebrane przez kamerę.
	camera_limits_set.emit(limit_left, limit_top, limit_right, limit_bottom)
