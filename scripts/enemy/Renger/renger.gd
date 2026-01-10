extends CharacterBody2D

# Eksportowane zmienne
@export var hp: int = 3  # Punkty życia rangera
@export var move_speed: float = 40.0  # Prędkość poruszania się rangera
@export var shoot_cooldown: float = 2.0  # Przerwa między strzałami (sekundy)

# Referencja do sceny pocisku
@export var bullet_scene: PackedScene  # Przeciągnij tutaj scenę pocisk_renger.tscn

# Referencje do węzłów
@onready var animated_sprite = $AnimatedSprite2D  # Sprite z animacjami
@onready var player_detection_zone = $PlayerDetectionZone  # Area2D do wykrywania gracza
@onready var shoot_range = $ShootRange  # Area2D zasięgu strzału
@onready var bullet_spawn_point = $BulletSpawnPoint  # Punkt spawnu pocisku

# Zmienne stanu
var player: Node2D = null  # Referencja do gracza
var player_detected: bool = false  # Czy gracz został wykryty
var is_awake: bool = false  # Czy ranger się obudził
var is_dead: bool = false  # Czy ranger nie żyje
var is_going_to_sleep: bool = false  # Czy ranger zasypia (animacja wake do tyłu)
var can_move: bool = false  # Czy ranger może się poruszać
var is_damaged: bool = false  # Czy ranger jest w trakcie animacji obrażeń
var is_aggroed: bool = false  # Czy ranger jest rozwścieczony (zawsze goni gracza)

# Zmienne do strzelania
var player_in_shoot_range: bool = false  # Czy gracz jest w zasięgu strzału
var is_shooting: bool = false  # Czy ranger aktualnie strzela
var can_shoot: bool = true  # Czy ranger może strzelać (cooldown)
var shoot_timer: float = 0.0  # Timer do cooldownu strzału

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
	
	# Połącz sygnały z ShootRange
	if shoot_range:
		shoot_range.body_entered.connect(_on_shoot_range_entered)
		shoot_range.body_exited.connect(_on_shoot_range_exited)
	
	# Połącz sygnał zakończenia animacji
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta):
	# Obsługa cooldownu strzału
	if not can_shoot:
		shoot_timer -= delta
		if shoot_timer <= 0:
			can_shoot = true
	
	# Jeśli ranger nie żyje, jest w animacji obrażeń lub strzela, nie ruszaj się
	if is_dead or is_damaged or is_shooting:
		return
	
	# Jeśli gracz jest w zasięgu strzału i ranger może strzelać, zacznij strzelać
	if player_in_shoot_range and can_shoot and is_awake and not is_dead:
		start_shooting()
		return
	
	# W przeciwnym razie poruszaj się (jeśli może)
	if not can_move:
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


# ===== FUNKCJE STRZELANIA =====

# Funkcja rozpoczynająca strzał
func start_shooting():
	is_shooting = true
	can_move = false
	velocity = Vector2.ZERO  # Zatrzymaj się
	
	# Obróć się w stronę gracza
	if player:
		if player.global_position.x < global_position.x:
			animated_sprite.flip_h = true
			# Przesuń marker na lewą stronę
			if bullet_spawn_point:
				bullet_spawn_point.position.x = -abs(bullet_spawn_point.position.x)
		else:
			animated_sprite.flip_h = false
			# Przesuń marker na prawą stronę
			if bullet_spawn_point:
				bullet_spawn_point.position.x = abs(bullet_spawn_point.position.x)
	
	# Odtwórz animację strzału
	if animated_sprite:
		animated_sprite.play("shoot")


# Funkcja wystrzeliwująca pocisk
func shoot_bullet():
	if bullet_scene == null:
		return

	if player == null:
		return

	# Stwórz instancję pocisku
	var bullet = bullet_scene.instantiate()

	# Dodaj pocisk do sceny (jako dziecko root node, nie rangera!)
	get_tree().root.add_child(bullet)

	# Ustaw pozycję pocisku NA POZYCJI MARKERA (zamiast rangera)
	if bullet_spawn_point:
		bullet.global_position = bullet_spawn_point.global_position
	else:
		# Fallback - jeśli nie ma markera, użyj pozycji rangera
		bullet.global_position = global_position

	# Oblicz kierunek do gracza
	var direction = (player.global_position - global_position).normalized()

	# Ustaw kierunek pocisku
	bullet.set_direction(direction)


# ===== SYGNAŁY SHOOT RANGE =====

func _on_shoot_range_entered(body):
	if body.is_in_group("player"):
		player_in_shoot_range = true


func _on_shoot_range_exited(body):
	if body.is_in_group("player"):
		player_in_shoot_range = false


# ===== POZOSTAŁE FUNKCJE =====

func _on_player_detection_zone_entered(body):
	if body.is_in_group("player"):
		player_detected = true
		
		if is_going_to_sleep:
			is_going_to_sleep = false
		
		if not is_awake and not is_dead:
			wake_up()


func _on_player_detection_zone_exited(body):
	if body.is_in_group("player"):
		player_detected = false
		
		if not is_aggroed:
			can_move = false
			velocity = Vector2.ZERO
			
			if is_awake and not is_dead:
				go_to_sleep()


func wake_up():
	is_awake = true
	can_move = false
	
	if animated_sprite:
		animated_sprite.play("wake")
		animated_sprite.speed_scale = 1.0


func go_to_sleep():
	is_going_to_sleep = true
	
	if animated_sprite:
		animated_sprite.play_backwards("wake")
		animated_sprite.speed_scale = 1.0


func take_damage(_damage: int) -> void:
	if is_dead:
		return
	
	if not is_aggroed:
		is_aggroed = true
		
		if not is_awake:
			wake_up()
	
	hp -= _damage
	
	if hp <= 0:
		die()
	else:
		play_damaged_animation()


func play_damaged_animation():
	is_damaged = true
	can_move = false
	velocity = Vector2.ZERO
	
	if animated_sprite:
		animated_sprite.play("damaged")


func die():
	is_dead = true
	can_move = false
	is_aggroed = false
	velocity = Vector2.ZERO
	
	if animated_sprite:
		animated_sprite.play("death")


func _on_animation_finished():
	if animated_sprite.animation == "wake":
		if is_going_to_sleep:
			is_awake = false
			is_going_to_sleep = false
			can_move = false
			animated_sprite.play("static_idle")
		else:
			can_move = true
			if player_detected or is_aggroed:
				# Sprawdź czy gracz jest w zasięgu strzału
				if not player_in_shoot_range:
					animated_sprite.play("move")
	
	elif animated_sprite.animation == "damaged":
		is_damaged = false
		
		if not is_dead and is_awake:
			can_move = true
			if player and not player_in_shoot_range:
				animated_sprite.play("move")
	
	elif animated_sprite.animation == "shoot":
		# Wystrzel pocisk na końcu animacji
		shoot_bullet()
		
		# Ustaw cooldown
		can_shoot = false
		shoot_timer = shoot_cooldown
		is_shooting = false
		
		# Jeśli gracz nadal jest w zasięgu strzału, ranger będzie czekał i strzelił ponownie
		# Jeśli gracz wyszedł, ranger zacznie go gonić
		if not player_in_shoot_range and is_awake:
			can_move = true
	
	elif animated_sprite.animation == "death":
		queue_free()
