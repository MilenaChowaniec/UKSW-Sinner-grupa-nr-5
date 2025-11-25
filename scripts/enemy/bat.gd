extends CharacterBody2D

# ==============================================================================
# KONFIGURACJA - wartości które możesz zmieniać w edytorze Godot
# ==============================================================================

@export var speed: float = 150.0        # Prędkość poruszania się nietoperza
@export var health: int = 3             # Ile uderzeń wytrzyma nietoperz
@export var damage: int = 1             # Obrażenia zadawane graczowi
@export var attack_cooldown: float = 1.0 # Czas między atakami (sekundy)

# ==============================================================================
# ZMIENNE - wewnętrzne zmienne skryptu
# ==============================================================================

var player: Node2D                      # Referencja do gracza
var is_active: bool = false             # Czy nietoperz ściga gracza?
var is_dead: bool = false               # Czy nietoperz nie żyje?
var can_attack: bool = true             # Czy może atakować (cooldown)
var attack_timer: Timer                 # Timer do cooldownu ataku

# ==============================================================================
# REFERENCJE DO WĘZŁÓW - pobierane automatycznie przy starcie
# ==============================================================================

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var collision_shape = $CollisionShape2D

# ==============================================================================
# FUNKCJE GODOT - uruchamiane automatycznie przez silnik
# ==============================================================================

func _ready():
	"""
	Funkcja uruchamiana gdy przeciwnik pojawi się na scenie.
	Inicjalizujemy tutaj wszystkie potrzebne elementy.
	"""
	
	# Szukamy gracza po grupie 'player' - upewnij się że gracz ma tę grupę!
	player = get_tree().get_first_node_in_group("player")
	
	# Uruchamiamy animację lotu
	if animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation("fly"):
			animated_sprite.play("fly")
		else:
			print("UWAGA: Brak animacji 'fly' dla AnimatedSprite2D")
	
	# Tworzymy timer do cooldownu ataków
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_cooldown_timeout)
	add_child(attack_timer)
	
	print("Bat gotowy! Szukam gracza...")

func _physics_process(delta):
	"""
	Funkcja uruchamiana co klatkę fizyki (60 razy na sekundę).
	Tutaj obsługujemy ruch i fizykę.
	"""
	
	# Jeśli nietoperz nie żyje - nic nie rób
	if is_dead:
		return
	
	# Jeśli nie ma gracza lub nietoperz nie jest aktywny - stoimy w miejscu
	if player == null or not is_active:
		velocity = Vector2.ZERO
		return
	
	# ==========================================================================
	# RUCH W KIERUNKU GRACZA
	# ==========================================================================
	
	# Obliczamy kierunek do gracza (wektor znormalizowany)
	var direction = (player.global_position - global_position).normalized()
	
	# Ustawiamy prędkość w kierunku gracza
	velocity = direction * speed
	
	# ==========================================================================
	# ANIMACJA I OBRÓT SPRITE'A
	# ==========================================================================
	
	# Obracamy sprite w kierunku ruchu
	if direction.x < 0:
		animated_sprite.flip_h = true   # Leci w lewo - odwracamy sprite
	elif direction.x > 0:
		animated_sprite.flip_h = false  # Leci w prawo - normalny sprite
	
	# Uruchamiamy fizykę ruchu
	move_and_slide()

# ==============================================================================
# FUNKCJE OBSŁUGI STANU - aktywacja, obrażenia, śmierć
# ==============================================================================

func activate():
	"""
	Funkcja aktywująca nietoperza - zaczyna ścigać gracza.
	Wywoływana gdy gracz wejdzie w obszar detekcji.
	"""
	if not is_active and not is_dead:
		is_active = true
		print("Bat aktywowany! Lecę do gracza!")
		
		# Możesz dodać tutaj dźwięk aktywacji lub efekt wizualny

func take_damage(amount: int):
	"""
	Funkcja wywoływana gdy nietoperz otrzyma obrażenia.
	"""
	
	# Jeśli już nie żyje, ignorujemy obrażenia
	if is_dead:
		return
	
	# Odejmujemy zdrowie
	health -= amount
	print("Bat otrzymał obrażenia! Pozostałe zdrowie: ", health)
	
	# Efekt wizualny obrażeń - sprite robi się czerwony na chwilę
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	# Sprawdzamy czy nietoperz umarł
	if health <= 0:
		die()

func die():
	"""
	Funkcja obsługująca śmierć nietoperza.
	"""
	if is_dead:
		return
	
	is_dead = true
	is_active = false
	print("Bat umiera!")
	
	# Wyłączamy fizykę - nietoperz przestaje się poruszać
	set_physics_process(false)
	
	# Wyłączamy kolizje - gracz może przejść przez martwego nietoperza
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	# Odtwarzamy animację śmierci jeśli istnieje
	if animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation("death"):
			animated_sprite.play("death")
			# Czekamy aż animacja śmierci się skończy
			await animated_sprite.animation_finished
		else:
			print("UWAGA: Brak animacji 'death' - używam domyślnej")
	
	# Usuwamy nietoperza ze sceny po krótkim czasie
	await get_tree().create_timer(0.5).timeout
	queue_free()

# ==============================================================================
# FUNKCJE ATAKU I COOLDOWN - POPRAWIONE!
# ==============================================================================

func attack_player():
	"""
	Funkcja atakująca gracza - wywołuje stan 'hit' w state machine gracza.
	"""
	if not can_attack or is_dead or player == null:
		return
	
	# Blokujemy możliwość ataku na czas cooldownu
	can_attack = false
	attack_timer.start()
	
	print("Bat atakuje gracza!")
	
	# ==========================================================================
	# POPRAWIONE: Przekazujemy WĘZEŁ stanu zamiast stringa
	# ==========================================================================
	
	var attack_success = false
	
	if player.has_node("StateMachine"):
		var state_machine = player.get_node("StateMachine")
		var hit_state_node = player.get_node("StateMachine/hit")
		
		# Metoda 1: change_state oczekuje WĘZŁA stanu, nie stringa
		if state_machine.has_method("change_state") and hit_state_node:
			state_machine.change_state(hit_state_node)
			attack_success = true
			print("Atak przez change_state z węzłem hit")
		
		# Metoda 2: set_state też może oczekiwać węzła
		elif state_machine.has_method("set_state") and hit_state_node:
			state_machine.set_state(hit_state_node)
			attack_success = true
			print("Atak przez set_state z węzłem hit")
		
		# Metoda 3: current_state jako właściwość
		elif state_machine.has_property("current_state") and hit_state_node:
			state_machine.current_state = hit_state_node
			attack_success = true
			print("Atak przez current_state z węzłem hit")
		
		# Metoda 4: transition_to z węzłem
		elif state_machine.has_method("transition_to") and hit_state_node:
			state_machine.transition_to(hit_state_node)
			attack_success = true
			print("Atak przez transition_to z węzłem hit")
	
	# Metoda 5: Bezpośrednie wywołanie stanu hit
	if not attack_success and player.has_node("StateMachine/hit"):
		var hit_state = player.get_node("StateMachine/hit")
		if hit_state.has_method("enter"):
			hit_state.enter()
			attack_success = true
			print("Atak przez bezpośrednie enter() na stanie hit")
		elif hit_state.has_method("_enter"):
			hit_state._enter()
			attack_success = true
			print("Atak przez bezpośrednie _enter() na stanie hit")
	
	# Metoda 6: Gracz ma bezpośrednią metodę hit()
	if not attack_success and player.has_method("hit"):
		player.hit()
		attack_success = true
		print("Atak przez metodę hit() gracza")
	
	# Jeśli żadna metoda nie zadziałała, debugujemy
	if not attack_success:
		print("UWAGA: Nie udało się zaatakować gracza!")
		debug_state_machine_methods()

# Dodaj tę funkcję do debugowania
func debug_state_machine_methods():
	"""
	Funkcja do debugowania StateMachine.
	"""
	if player and player.has_node("StateMachine"):
		var state_machine = player.get_node("StateMachine")
		print("=== DEBUG StateMachine ===")
		print("Metody StateMachine:")
		for method in state_machine.get_method_list():
			print(" - ", method.name)
		
		print("Dzieci StateMachine (dostępne stany):")
		for child in state_machine.get_children():
			print(" - ", child.name, " (", child.get_class(), ")")
			
		# Sprawdzamy czy stan hit istnieje
		if state_machine.has_node("hit"):
			print("Stan 'hit' znaleziony!")
			var hit_state = state_machine.get_node("hit")
			print("Metody stanu hit:")
			for method in hit_state.get_method_list():
				print("   - ", method.name)
		else:
			print("Stan 'hit' NIE znaleziony!")
	"""
	Funkcja atakująca gracza - wywołuje stan 'hit' w state machine gracza.
	"""
	if not can_attack or is_dead or player == null:
		return
	
	# Blokujemy możliwość ataku na czas cooldownu
	can_attack = false
	attack_timer.start()
	
	print("Bat atakuje gracza!")
	
	# ==========================================================================
	# POPRAWIONE: RÓŻNE SPOSOBY ATAKU NA GRACZA
	# ==========================================================================
	
	var attack_success = false
	
	# Metoda 1: Sprawdzamy czy StateMachine ma właściwość current_state
	if player.has_node("StateMachine"):
		var state_machine = player.get_node("StateMachine")
		
		# Sprawdzamy różne możliwe metody zmiany stanu
		if state_machine.has_method("change_state"):
			state_machine.change_state("hit")
			attack_success = true
			print("Atak przez change_state('hit')")
		
		elif state_machine.has_method("set_state"):
			state_machine.set_state("hit")
			attack_success = true
			print("Atak przez set_state('hit')")
		
		elif state_machine.has_property("current_state"):
			state_machine.current_state = "hit"
			attack_success = true
			print("Atak przez current_state = 'hit'")
		
		elif state_machine.has_method("transition_to"):
			state_machine.transition_to("hit")
			attack_success = true
			print("Atak przez transition_to('hit')")
	
	# Metoda 2: Sprawdzamy czy gracz ma bezpośrednią metodę hit()
	if not attack_success and player.has_method("hit"):
		player.hit()
		attack_success = true
		print("Atak przez metodę hit()")
	
	# Metoda 3: Sprawdzamy czy gracz ma metodę take_damage()
	if not attack_success and player.has_method("take_damage"):
		player.take_damage(damage)
		attack_success = true
		print("Atak przez take_damage()")
	
	# Metoda 4: Sprawdzamy czy StateMachine ma bezpośrednie stany jako węzły
	if not attack_success and player.has_node("StateMachine/hit"):
		# Jeśli stan 'hit' jest bezpośrednim dzieckiem StateMachine
		var hit_state = player.get_node("StateMachine/hit")
		if hit_state.has_method("enter"):
			hit_state.enter()
			attack_success = true
			print("Atak przez bezpośrednie wejście do stanu hit")
	
	# Jeśli żadna metoda nie zadziałała, wypisujemy ostrzeżenie
	if not attack_success:
		print("UWAGA: Nie udało się zaatakować gracza! Sprawdź State Machine.")
		print("Dostępne metody StateMachine:")
		var state_machine = player.get_node("StateMachine")
		for method in state_machine.get_method_list():
			print(" - ", method.name)

func _on_attack_cooldown_timeout():
	"""
	Funkcja wywoływana gdy skończy się cooldown ataku.
	"""
	can_attack = true
	#print("Bat może znowu atakować!") # Możesz odkomentować do debugowania

# ==============================================================================
# OBSŁUGA SYGNAŁÓW AREA2D - podłącz w edytorze Godot!
# ==============================================================================

func _on_detection_area_body_entered(body):
	"""
	Funkcja wywoływana gdy jakieś ciało wejdzie w obszar detekcji.
	Podłącz do DetectionArea → body_entered w edytorze!
	"""
	if body.is_in_group("player") and not is_dead:
		activate()

func _on_attack_area_body_entered(body):
	"""
	Funkcja wywoływana gdy jakieś ciało wejdzie w obszar ataku.
	Podłącz do AttackArea → body_entered w edytorze!
	"""
	if body.is_in_group("player") and not is_dead and can_attack:
		attack_player()

func _on_attack_area_body_exited(body):
	"""
	Funkcja wywoływana gdy jakieś ciało wyjdzie z obszaru ataku.
	Podłącz do AttackArea → body_exited w edytorze!
	"""
	if body.is_in_group("player"):
		#print("Gracz wyszedł z obszaru ataku") # Możesz odkomentować
		pass
