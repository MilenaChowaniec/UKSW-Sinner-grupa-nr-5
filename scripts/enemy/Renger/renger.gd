extends CharacterBody2D

@export var detection_range: float = 300.0
@export var attack_range: float = 150.0
@export var move_speed: float = 50.0
@export var attack_cooldown: float = 2.0
@export var health: int = 100
@export var bullet_damage: int = 10

@onready var animated_sprite = $AnimatedSprite2D
@onready var player_detection_zone = $PlayerDetectionZone

var player: Node2D = null
var current_state: String = "static_idle"
var is_dead: bool = false
var time_since_last_attack: float = 0.0
var can_attack: bool = true

func _ready():
	set_state("static_idle")
	print("Renger gotowy! Szuka gracza...")

func _physics_process(delta):
	if is_dead:
		return
	
	# Aktualizuj timer ataku
	if current_state == "shoot" and can_attack:
		time_since_last_attack += delta
		if time_since_last_attack >= attack_cooldown:
			shoot_at_player()
			time_since_last_attack = 0.0
	
	match current_state:
		"static_idle":
			handle_static_idle_state()
		"wake":
			handle_wake_state()
		"move":
			handle_move_state(delta)
		"shoot":
			handle_shoot_state()
		"damaged":
			handle_damaged_state()

func set_state(new_state: String):
	if current_state != new_state and not is_dead:
		print("Renger zmienia stan z ", current_state, " na ", new_state)
		current_state = new_state
		play_animation(new_state)
		
		# Resetuj timer przy zmianie stanu na shoot
		if new_state == "shoot":
			time_since_last_attack = attack_cooldown  # Strzel od razu
			can_attack = true

func play_animation(anim_name: String):
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)

func handle_static_idle_state():
	# Stój w miejscu i czekaj na gracza
	velocity = Vector2.ZERO
	
	if player_detection_zone and player_detection_zone.can_see_player():
		player = player_detection_zone.player
		print("Renger wykrył gracza! Budzenie...")
		set_state("wake")

func handle_wake_state():
	# Zatrzymaj się podczas animacji budzenia
	velocity = Vector2.ZERO
	
	# Czekaj aż animacja wake się skończy
	if not animated_sprite.is_playing():
		set_state("move")

func handle_move_state(delta):
	if player == null or (player_detection_zone and not player_detection_zone.can_see_player()):
		print("Renger stracił gracza z oczu")
		set_state("static_idle")
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= attack_range:
		print("Renger w zasięgu ataku! Odległość: ", distance_to_player)
		set_state("shoot")
	else:
		# Porusz się w kierunku gracza
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
		
		# Odwróć sprite w kierunku ruchu
		if direction.x != 0:
			animated_sprite.flip_h = direction.x < 0
		
		print("Renger goni gracza. Odległość: ", distance_to_player)

func handle_shoot_state():
	if player == null or (player_detection_zone and not player_detection_zone.can_see_player()):
		print("Renger stracił gracza podczas strzelania")
		set_state("static_idle")
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > attack_range * 1.2:  # Dodaj margines
		print("Gracz uciekł z zasięgu, powrót do gonienia")
		set_state("move")
		return
	
	# Odwróć się w stronę gracza
	var direction_to_player = (player.global_position - global_position).normalized()
	if direction_to_player.x != 0:
		animated_sprite.flip_h = direction_to_player.x < 0
	
	# Zatrzymaj ruch podczas strzelania
	velocity = Vector2.ZERO

func handle_damaged_state():
	# Zatrzymaj się podczas otrzymywania obrażeń
	velocity = Vector2.ZERO
	
	# Po animacji damaged wróć do poprzedniego stanu
	if not animated_sprite.is_playing():
		if player and player_detection_zone and player_detection_zone.can_see_player():
			var distance_to_player = global_position.distance_to(player.global_position)
			if distance_to_player <= attack_range:
				set_state("shoot")
			else:
				set_state("move")
		else:
			set_state("static_idle")

func take_damage(damage: int):
	if is_dead:
		return
	
	health -= damage
	print("Renger otrzymał ", damage, " obrażeń. Pozostałe zdrowie: ", health)
	
	if health <= 0:
		die()
	else:
		set_state("damaged")

func die():
	is_dead = true
	set_state("death")
	velocity = Vector2.ZERO
	can_attack = false
	
	# Wyłącz kolizje po śmierci
	var collision = $CollisionShape2D
	if collision:
		collision.set_deferred("disabled", true)
	
	print("Renger zginął!")
	
	# Usuń przeciwnika po animacji śmierci
	await animated_sprite.animation_finished
	queue_free()

func shoot_at_player():
	if player and player_detection_zone and player_detection_zone.can_see_player() and can_attack:
		print("Renger strzela do gracza!")
		
		# Odtwórz animację strzału
		if animated_sprite.animation != "shoot":
			play_animation("shoot")
		
		# Utwórz pocisk
		create_bullet()

# Funkcja do tworzenia pocisku 
func create_bullet():
	var bullet_scene = preload("res://scenes/enemy/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	bullet.damage = bullet_damage
	get_parent().add_child(bullet)

# Sygnały dla PlayerDetectionZone
func _on_player_detection_zone_body_entered(body):
	if body.is_in_group("player"):
		player = body
		print("Renger: Gracz wszedł w strefę wykrywania")

func _on_player_detection_zone_body_exited(body):
	if body == player:
		player = null
		print("Renger: Gracz opuścił strefę wykrywania")
