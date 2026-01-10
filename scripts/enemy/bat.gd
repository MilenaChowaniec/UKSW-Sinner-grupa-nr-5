extends CharacterBody2D

# Eksportowane zmienne (możesz je edytować w inspektorze)
@export var speed: float = 50.0  # Prędkość poruszania się bata
@export var patrol_radius: float = 100.0  # Promień okręgu patrolowego
@export var patrol_speed: float = 2.0  # Prędkość obracania się po okręgu
@export var hp: int = 3  # Punkty życia bata
@export var knockback_force: float = 300.0  # Siła odrzutu
@export var knockback_duration: float = 0.4  # Czas trwania odrzutu

# Referencje do węzłów
@onready var animated_sprite = $AnimatedSprite2D  # Referencja do AnimatedSprite2D
@onready var detection_area = $DetectionArea  # Referencja do Area2D wykrywającej gracza
var player: Node2D = null  # Przechowuje referencję do gracza
var player_in_detection_area: bool = false  # Czy gracz jest w zasięgu wykrywania
@onready var hit_box: Hit_Box = $HitBox


# Zmienne do patrolowania
var patrol_center: Vector2  # Środek okręgu patrolowego (startowa pozycja)
var patrol_angle: float = 0.0  # Aktualny kąt na okręgu

# Zmienne do HP i stanu
var is_dead: bool = false  # Czy bat jest martwy
var got_hit: bool = false  # Czy bat został trafiony

# Zmienne do knockback
var is_knockback: bool = false  # Czy bat jest w trakcie odrzutu
var knockback_velocity: Vector2 = Vector2.ZERO  # Prędkość odrzutu
var knockback_timer: float = 0.0  # Timer odrzutu


func _ready():
	# Zapisz startową pozycję jako środek okręgu patrolowego
	patrol_center = global_position
	$HitBox.damaged.connect(take_damage)
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
	
	# Połącz sygnał zakończenia animacji
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta):
	# Jeśli bat jest martwy, nie wykonuj żadnej logiki ruchu
	if is_dead:
		return
	
	# Jeśli bat jest w trakcie knockback
	if is_knockback:
		handle_knockback(delta)
		return
	
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
	
	# Sprawdź kolizję z graczem
	check_collision_with_player()


func check_collision_with_player():
	# Sprawdź czy bat zderzył się z graczem
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("player"):
			apply_knockback_from_player()
			break


func apply_knockback_from_player():
	if player == null:
		return
	
	# Oblicz kierunek odrzutu (od gracza)
	var knockback_direction = (global_position - player.global_position).normalized()
	
	# Ustaw prędkość odrzutu
	knockback_velocity = knockback_direction * knockback_force
	
	# Włącz stan knockback
	is_knockback = true
	knockback_timer = knockback_duration


func handle_knockback(delta):
	# Zmniejsz timer
	knockback_timer -= delta
	
	# Jeśli timer się skończył, wyłącz knockback
	if knockback_timer <= 0:
		is_knockback = false
		knockback_velocity = Vector2.ZERO
		return
	
	# Zastosuj prędkość knockback
	velocity = knockback_velocity
	
	# Stopniowo zmniejszaj prędkość odrzutu (opcjonalne)
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, delta * 5)
	
	# Przesuń bata
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


# Funkcja do zadawania obrażeń batowi
func take_damage(_damage: int) -> void:
	got_hit = true  # Oznacz że bat został trafiony
	hp -= 1  # Odejmij 1 HP
	
	# Sprawdź czy bat powinien umrzeć
	check_death()


# Funkcja sprawdzająca czy bat powinien umrzeć
func check_death():
	if hp <= 0 and not is_dead:
		die()


# Funkcja śmierci bata
func die():
	is_dead = true  # Oznacz bata jako martwego
	velocity = Vector2.ZERO  # Zatrzymaj ruch
	
	# Odtwórz animację śmierci
	if animated_sprite:
		animated_sprite.play("die")


# Wywoływane gdy animacja się kończy
func _on_animation_finished():
	# Jeśli zakończyła się animacja śmierci, usuń bata
	if is_dead and animated_sprite.animation == "die":
		queue_free()  # Usuń bata ze sceny
