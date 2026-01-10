extends Area2D

# Eksportowane zmienne
@export var speed: float = 150.0  # Prędkość pocisku
@export var damage: int = 1  # Obrażenia zadawane graczowi
@export var lifetime: float = 1.0  # Czas życia pocisku (sekundy)

# Zmienne wewnętrzne
var direction: Vector2 = Vector2.ZERO  # Kierunek lotu pocisku
var lifetime_timer: float = 0.0  # Timer czasu życia

func _ready():
	# Połącz sygnał kolizji
	body_entered.connect(_on_body_entered)
	
	print("Pocisk rangera utworzony!")


func _physics_process(delta):
	# Poruszaj pociskiem w kierunku
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta
	
	# Zliczaj czas życia
	lifetime_timer += delta
	if lifetime_timer >= lifetime:
		print("Pocisk znikł (koniec czasu życia)")
		queue_free()  # Usuń pocisk po określonym czasie


# Funkcja ustawiająca kierunek i rotację pocisku
func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	
	# Obróć pocisk w kierunku lotu
	rotation = direction.angle()


# Funkcja wywoływana gdy pocisk koliduje z czymś
func _on_body_entered(body):
	print("Pocisk trafił w: ", body.name)
