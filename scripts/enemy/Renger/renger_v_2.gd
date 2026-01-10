extends CharacterBody2D

# ===== ZMIENNE DO EDYCJI =====
@export var hp: int = 3  # Punkty życia
@export var patrol_distance: float = 100.0  # Jak daleko idzie w jedną stronę (piksele)
@export var patrol_speed: float = 40.0  # Prędkość patrolu
@export var shoot_delay: float = 0.3  # Przerwa między strzałami (sekundy)

# Referencja do sceny pocisku
@export var bullet_scene: PackedScene

# ===== REFERENCJE DO WĘZŁÓW =====
@onready var animated_sprite = $AnimatedSprite2D
@onready var bullet_spawn_point = $BulletSpawnPoint
@onready var hit_box: Hit_Box = $HitBox

# ===== ZMIENNE STANU =====
var is_dead: bool = false
var is_damaged: bool = false

# ===== ZMIENNE PATROLU =====
enum PatrolState { MOVING, STANDING_AND_SHOOTING }
var patrol_state: PatrolState = PatrolState.MOVING
var patrol_start_position: Vector2
var current_patrol_direction: int = -1  # -1 = lewo, 1 = prawo

# ===== ZMIENNE STRZELANIA =====
var shots_fired: int = 0  # Ile strzałów już oddał (0-4)
var time_since_last_shot: float = 0.0
var shoot_directions: Array = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]  # Kolejność strzałów
var current_shot_index: int = 0


func _ready():
	# Połącz sygnał obrażeń
	$HitBox.damaged.connect(take_damage)
	
	# Połącz sygnał zakończenia animacji
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# Zapisz pozycję startową patrolu
	patrol_start_position = global_position
	
	# Zacznij od razu patrolować (w lewo)
	current_patrol_direction = -1
	patrol_state = PatrolState.MOVING
	animated_sprite.flip_h = true
	
	print("Ranger ready - starting patrol")


func _physics_process(delta):
	# Jeśli nie żyje lub w animacji obrażeń, nic nie rób
	if is_dead or is_damaged:
		return
	
	# Obsługa patrolu
	match patrol_state:
		PatrolState.MOVING:
			patrol_movement(delta)
		
		PatrolState.STANDING_AND_SHOOTING:
			shooting_sequence(delta)


# ===== PATROL - RUCH =====
func patrol_movement(delta):
	# Oblicz docelową pozycję
	var target_x = patrol_start_position.x + (patrol_distance * current_patrol_direction)
	
	# Sprawdź czy dotarł do celu
	var reached_target = false
	if current_patrol_direction == -1 and global_position.x <= target_x:
		reached_target = true
	elif current_patrol_direction == 1 and global_position.x >= target_x:
		reached_target = true
	
	if reached_target:
		# Dotarł - ZATRZYMAJ SIĘ i przygotuj strzelanie
		velocity = Vector2.ZERO
		patrol_state = PatrolState.STANDING_AND_SHOOTING
		shots_fired = 0
		current_shot_index = 0
		time_since_last_shot = 0.0
		
		# Ustaw pierwsze 2 kierunki strzałów (przód + góra)
		if animated_sprite.flip_h:  # Patrzy w lewo
			shoot_directions = [Vector2.LEFT, Vector2.UP]
		else:  # Patrzy w prawo
			shoot_directions = [Vector2.RIGHT, Vector2.UP]
		
		print("Ranger reached target - starting shooting sequence")
		return
	
	# Poruszaj się w kierunku celu
	velocity.x = current_patrol_direction * patrol_speed
	velocity.y = 0
	
	# Obróć sprite i marker
	if current_patrol_direction == -1:
		animated_sprite.flip_h = true
		update_bullet_spawn_point()
	else:
		animated_sprite.flip_h = false
		update_bullet_spawn_point()
	
	# Animacja ruchu
	if animated_sprite.animation != "move":
		animated_sprite.play("move")
	
	move_and_slide()


# ===== FUNKCJA OBRACAJĄCA MARKER =====
func update_bullet_spawn_point():
	if bullet_spawn_point:
		if animated_sprite.flip_h:
			# Patrzy w lewo - marker po lewej stronie
			bullet_spawn_point.position.x = -abs(bullet_spawn_point.position.x)
		else:
			# Patrzy w prawo - marker po prawej stronie
			bullet_spawn_point.position.x = abs(bullet_spawn_point.position.x)


# ===== STRZELANIE - SEKWENCJA =====
func shooting_sequence(delta):
	time_since_last_shot += delta
	
	# Czy czas na kolejny strzał?
	if time_since_last_shot >= shoot_delay:
		# Wystrzel!
		fire_bullet()
		
		shots_fired += 1
		time_since_last_shot = 0.0
		
		# Po 2 strzale (przód + góra) - OBRÓĆ SIĘ
		if shots_fired == 2:
			animated_sprite.flip_h = !animated_sprite.flip_h
			update_bullet_spawn_point()  # Obróć marker!
			# Zaktualizuj kierunki strzałów po obrocie
			if animated_sprite.flip_h:  # Teraz patrzy w lewo
				shoot_directions = [Vector2.LEFT, Vector2.DOWN]
			else:  # Teraz patrzy w prawo
				shoot_directions = [Vector2.RIGHT, Vector2.DOWN]
			current_shot_index = 0  # Reset indeksu dla nowych kierunków
		else:
			current_shot_index += 1
		
		print("Ranger fired shot #", shots_fired)
		
		# Czy skończył wszystkie 4 strzały?
		if shots_fired >= 4:
			# Zmień kierunek patrolu i wróć do ruchu
			current_patrol_direction *= -1
			patrol_state = PatrolState.MOVING
			
			print("Ranger finished shooting - changing direction and moving")


# ===== STRZELANIE - POJEDYNCZY STRZAŁ =====
func fire_bullet():
	if bullet_scene == null:
		print("ERROR: bullet_scene is null!")
		return
	
	# Animacja strzału
	if animated_sprite:
		animated_sprite.play("shoot")
	
	# Stwórz instancję pocisku
	var bullet = bullet_scene.instantiate()
	
	# Dodaj pocisk do sceny
	get_tree().root.add_child(bullet)
	
	# Ustaw pozycję pocisku
	if bullet_spawn_point:
		bullet.global_position = bullet_spawn_point.global_position
	else:
		bullet.global_position = global_position
	
	# Pobierz kierunek z tablicy
	var direction = shoot_directions[current_shot_index]
	
	# Ustaw kierunek pocisku
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction)
		print("Bullet fired in direction: ", direction)
	else:
		print("ERROR: Bullet doesn't have set_direction method!")


# ===== STARE FUNKCJE DO USUNIĘCIA =====


# ===== OBRAŻENIA I ŚMIERĆ =====
func take_damage(_damage: int) -> void:
	if is_dead:
		return
	
	hp -= _damage
	
	if hp <= 0:
		die()
	else:
		play_damaged_animation()


func play_damaged_animation():
	is_damaged = true
	velocity = Vector2.ZERO
	
	if animated_sprite:
		animated_sprite.play("damaged")


func die():
	is_dead = true
	velocity = Vector2.ZERO
	
	if animated_sprite:
		animated_sprite.play("death")


# ===== SYGNAŁY ANIMACJI =====
func _on_animation_finished():
	if animated_sprite.animation == "damaged":
		# Po obrażeniach wróć do patrolu
		is_damaged = false
	
	elif animated_sprite.animation == "death":
		queue_free()
