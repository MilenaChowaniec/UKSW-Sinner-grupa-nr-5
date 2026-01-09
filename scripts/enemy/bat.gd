extends CharacterBody2D

# Eksportowane zmienne (możesz je edytować w inspektorze)
@export var speed: float = 50.0  # Prędkość poruszania się bata
@export var patrol_radius: float = 100.0  # Promień okręgu patrolowego
@export var patrol_speed: float = 2.0  # Prędkość obracania się po okręgu

# Referencje do węzłów
@onready var animated_sprite = $AnimatedSprite2D  # Referencja do AnimatedSprite2D
@onready var detection_area = $DetectionArea  # Referencja do Area2D wykrywającej gracza
var player: Node2D = null  # Przechowuje referencję do gracza
var player_in_detection_area: bool = false  # Czy gracz jest w zasięgu wykrywania

# Zmienne do patrolowania
var patrol_center: Vector2  # Środek okręgu patrolowego (startowa pozycja)
var patrol_angle: float = 0.0  # Aktualny kąt na okręgu


func _ready():
	# Zapisz startową pozycję jako środek okręgu patrolowego
	patrol_center = global_position
	
	# Znajdź gracza w grupie "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]  # Pobierz pierwszego gracza z grupy
	
	# Uruchom animację lotu
	if animated_sprite:
		animated_sprite.play("fly")
	
	# Połącz sygnały z DetectionArea
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)


func _physics_process(delta):
	# Sprawdź czy gracz istnieje i czy jest w zasięgu wykrywania
	if player == null or not player_in_detection_area:
		# Gracz nie jest w zasięgu - wykonaj patrol w kółko
		patrol_in_circle(delta)
		return
	
	# Gracz jest w zasięgu - ścigaj gracza
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


func patrol_in_circle(delta):
	# Zwiększ kąt obrotu (obraca się w czasie)
	patrol_angle += patrol_speed * delta
	
	# Oblicz nową pozycję na okręgu używając sin i cos
	var offset = Vector2(
		cos(patrol_angle) * patrol_radius,  # Pozycja X na okręgu
		sin(patrol_angle) * patrol_radius   # Pozycja Y na okręgu
	)
	
	# Docelowa pozycja = środek okręgu + offset
	var target_position = patrol_center + offset
	
	# Oblicz kierunek do docelowej pozycji
	var direction = (target_position - global_position).normalized()
	
	# Obróć sprite w kierunku ruchu
	if direction.x < 0:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false
	
	# Ustaw prędkość
	velocity = direction * speed
	
	# Przesuń bata
	move_and_slide()


# Sygnały z DetectionArea
func _on_detection_area_body_entered(body):
	# Sprawdź czy ciało które weszło to gracz
	if body.is_in_group("player"):
		player_in_detection_area = true  # Gracz wszedł w zasięg


func _on_detection_area_body_exited(body):
	# Sprawdź czy ciało które wyszło to gracz
	if body.is_in_group("player"):
		player_in_detection_area = false  # Gracz wyszedł z zasięgu
