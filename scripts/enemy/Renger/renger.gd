extends CharacterBody2D

# Eksportowane zmienne
@export var hp: int = 3  # Punkty życia rangera
@export var move_speed: float = 40.0  # Prędkość poruszania się rangera

# Referencje do węzłów
@onready var animated_sprite = $AnimatedSprite2D  # Sprite z animacjami
@onready var player_detection_zone = $PlayerDetectionZone  # Area2D do wykrywania gracza

# Zmienne stanu
var player: Node2D = null  # Referencja do gracza
var player_detected: bool = false  # Czy gracz został wykryty
var is_awake: bool = false  # Czy ranger się obudził
var is_dead: bool = false  # Czy ranger nie żyje
var is_going_to_sleep: bool = false  # Czy ranger zasypia (animacja wake do tyłu)
var can_move: bool = false  # Czy ranger może się poruszać
var is_damaged: bool = false  # Czy ranger jest w trakcie animacji obrażeń
var is_aggroed: bool = false  # Czy ranger jest rozwścieczony (zawsze goni gracza)

func _ready():
	# Uruchom animację początkową - ranger śpi
	if animated_sprite:
		animated_sprite.play("static_idle")
	
	# Znajdź gracza w grupie "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	# Połącz sygnały z PlayerDetectionZone
	if player_detection_zone:
		player_detection_zone.body_entered.connect(_on_player_detection_zone_entered)
		player_detection_zone.body_exited.connect(_on_player_detection_zone_exited)
	
	# Połącz sygnał zakończenia animacji
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(_delta):
	# Jeśli ranger nie żyje, jest w animacji obrażeń lub nie może się ruszać, nie rób nic
	if is_dead or not can_move or is_damaged:
		return
	
	# Jeśli ranger jest rozwścieczony, ZAWSZE goni gracza (nawet poza detection zone)
	if is_aggroed and player:
		move_towards_player()
	# W przeciwnym razie tylko gdy gracz jest wykryty
	elif player and player_detected:
		move_towards_player()


# Funkcja poruszania się w stronę gracza
func move_towards_player():
	# Oblicz kierunek do gracza
	var direction = (player.global_position - global_position).normalized()
	
	# Obróć sprite w stronę gracza
	if direction.x < 0:
		animated_sprite.flip_h = true  # Gracz po lewej
	else:
		animated_sprite.flip_h = false  # Gracz po prawej
	
	# Ustaw prędkość w kierunku gracza
	velocity = direction * move_speed
	
	# Odtwórz animację ruchu
	if animated_sprite.animation != "move":
		animated_sprite.play("move")
	
	# Przesuń rangera
	move_and_slide()


# Funkcja wywoływana gdy coś wchodzi do PlayerDetectionZone
func _on_player_detection_zone_entered(body):
	# Sprawdź czy to gracz
	if body.is_in_group("player"):
		player_detected = true
		print("Gracz wykryty!")
		
		# Jeśli ranger jest w trakcie zasypiania, przerwij to i obudź go normalnie
		if is_going_to_sleep:
			is_going_to_sleep = false
		
		# Jeśli ranger jeszcze nie jest obudzony, obudź go
		if not is_awake and not is_dead:
			wake_up()


# Funkcja wywoływana gdy coś wychodzi z PlayerDetectionZone
func _on_player_detection_zone_exited(body):
	# Sprawdź czy to gracz
	if body.is_in_group("player"):
		player_detected = false
		print("Gracz wyszedł z zasięgu")
		
		# TYLKO jeśli ranger NIE jest rozwścieczony, może zasnąć
		if not is_aggroed:
			# Ranger przestaje się ruszać i wraca do snu
			can_move = false
			velocity = Vector2.ZERO
			
			if is_awake and not is_dead:
				go_to_sleep()
		else:
			print("Ranger jest rozwścieczony - nie zasypia mimo wyjścia gracza!")


# Funkcja budzenia rangera
func wake_up():
	print("Ranger się budzi!")
	is_awake = true
	can_move = false  # Nie może się ruszać podczas budzenia
	
	# Odtwórz animację budzenia normalnie (do przodu)
	if animated_sprite:
		animated_sprite.play("wake")
		animated_sprite.speed_scale = 1.0  # Normalna prędkość


# Funkcja usypiania rangera
func go_to_sleep():
	print("Ranger wraca do snu!")
	is_going_to_sleep = true  # Oznacz że zasypia
	
	# Odtwórz animację wake od tyłu
	if animated_sprite:
		animated_sprite.play_backwards("wake")  # Odtwórz animację od tyłu
		animated_sprite.speed_scale = 1.0  # Możesz zmienić prędkość np. na 1.5 dla szybszego zasypiania


# Funkcja zadawania obrażeń rangerowi
func take_damage(_damage: int) -> void:
	# Jeśli ranger jest martwy, ignoruj obrażenia
	if is_dead:
		return
	
	print("Ranger otrzymał obrażenia! HP przed: ", hp)
	
	# WAŻNE: Ranger staje się rozwścieczony!
	if not is_aggroed:
		is_aggroed = true
		print("Ranger jest teraz rozwścieczony! Będzie gonić gracza wszędzie!")
		
		# Jeśli ranger śpi, obudź go natychmiast
		if not is_awake:
			wake_up()
	
	# Odejmij HP
	hp -= _damage
	
	print("HP po obrażeniach: ", hp)
	
	# Sprawdź czy ranger powinien umrzeć
	if hp <= 0:
		die()
	else:
		# Ranger jeszcze żyje - odtwórz animację obrażeń
		play_damaged_animation()


# Funkcja odtwarzająca animację obrażeń
func play_damaged_animation():
	print("Odtwarzanie animacji 'damaged'")
	is_damaged = true  # Zablokuj ruch podczas animacji
	can_move = false
	velocity = Vector2.ZERO  # Zatrzymaj ruch
	
	# Odtwórz animację obrażeń
	if animated_sprite:
		animated_sprite.play("damaged")


# Funkcja śmierci rangera
func die():
	print("Ranger umiera!")
	is_dead = true  # Oznacz rangera jako martwego
	can_move = false
	is_aggroed = false  # Nie jest już rozwścieczony
	velocity = Vector2.ZERO  # Zatrzymaj ruch
	
	# Odtwórz animację śmierci
	if animated_sprite:
		animated_sprite.play("death")


# Funkcja wywoływana gdy animacja się kończy
func _on_animation_finished():
	# Sprawdź która animacja się skończyła
	if animated_sprite.animation == "wake":
		# Jeśli ranger zasypial (animacja od tyłu)
		if is_going_to_sleep:
			print("Ranger zasnął - animacja 'wake' od tyłu zakończona")
			is_awake = false
			is_going_to_sleep = false
			can_move = false
			# Przejdź do static_idle
			animated_sprite.play("static_idle")
		else:
			# Jeśli ranger się budził (animacja do przodu)
			print("Animacja 'wake' zakończona - ranger może się teraz ruszać")
			can_move = true  # Teraz może się ruszać
			# Jeśli gracz nadal jest w zasięgu LUB ranger jest rozwścieczony, zacznij iść
			if player_detected or is_aggroed:
				animated_sprite.play("move")
	
	elif animated_sprite.animation == "damaged":
		# Po animacji obrażeń, wróć do normalnego stanu
		print("Animacja 'damaged' zakończona")
		is_damaged = false
		
		# Po obrażeniach ranger ZAWSZE wraca do gonienia gracza (bo jest aggroed)
		if not is_dead and is_awake:
			can_move = true
			if player:
				animated_sprite.play("move")
	
	elif animated_sprite.animation == "death":
		# Po animacji śmierci, usuń rangera
		print("Animacja 'death' zakończona - usuwanie rangera")
		queue_free()  # Usuń rangera ze sceny

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		take_damage(1)
		print("Test obrażeń!")
