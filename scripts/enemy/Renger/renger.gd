extends CharacterBody2D

# Eksportowane zmienne
@export var hp: int = 3  # Punkty życia rangera

# Referencje do węzłów
@onready var animated_sprite = $AnimatedSprite2D  # Sprite z animacjami
@onready var player_detection_zone = $PlayerDetectionZone  # Area2D do wykrywania gracza

# Zmienne stanu
var player: Node2D = null  # Referencja do gracza
var player_detected: bool = false  # Czy gracz został wykryty
var is_awake: bool = false  # Czy ranger się obudził
var is_dead: bool = false  # Czy ranger nie żyje
var is_going_to_sleep: bool = false  # Czy ranger zasypia (animacja wake do tyłu)

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
	# Na razie pusta - dodamy logikę w kolejnych krokach
	pass


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
		
		# Ranger wraca do snu
		if is_awake and not is_dead:
			go_to_sleep()


# Funkcja budzenia rangera
func wake_up():
	print("Ranger się budzi!")
	is_awake = true
	
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


# Funkcja wywoływana gdy animacja się kończy
func _on_animation_finished():
	# Sprawdź która animacja się skończyła
	if animated_sprite.animation == "wake":
		# Jeśli ranger zasypial (animacja od tyłu)
		if is_going_to_sleep:
			print("Ranger zasnął - animacja 'wake' od tyłu zakończona")
			is_awake = false
			is_going_to_sleep = false
			# Przejdź do static_idle
			animated_sprite.play("static_idle")
		else:
			# Jeśli ranger się budził (animacja do przodu)
			print("Animacja 'wake' zakończona - ranger obudzony")
			# Tutaj później dodamy przejście do idle lub ataku
