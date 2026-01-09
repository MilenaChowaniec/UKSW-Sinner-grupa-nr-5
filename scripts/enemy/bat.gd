extends CharacterBody2D

# Eksportowane zmienne (możesz je edytować w inspektorze)
@export var speed: float = 50.0  # Prędkość poruszania się bata

# Referencje do węzłów
@onready var animated_sprite = $AnimatedSprite2D  # Referencja do AnimatedSprite2D
var player: Node2D = null  # Przechowuje referencję do gracza


func _ready():
	# Znajdź gracza w grupie "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]  # Pobierz pierwszego gracza z grupy
	
	# Uruchom animację lotu
	if animated_sprite:
		animated_sprite.play("fly")


func _physics_process(delta):
	# Sprawdź czy gracz istnieje
	if player == null:
		return
	
	# Oblicz kierunek do gracza
	var direction = (player.global_position - global_position).normalized()
	
	# Obróć bata w stronę gracza
	flip_sprite_towards_player()
	
	# Ustaw prędkość w kierunku gracza
	velocity = direction * speed
	
	# Przesuń bata używając wbudowanej funkcji
	move_and_slide()


func flip_sprite_towards_player():
	# Sprawdź czy gracz jest po lewej stronie bata
	if player.global_position.x < global_position.x:
		animated_sprite.flip_h = true  # Odwróć sprite w lewo
	else:
		animated_sprite.flip_h = false  # Sprite patrzy w prawo (domyślnie)
