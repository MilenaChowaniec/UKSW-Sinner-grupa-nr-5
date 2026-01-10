# Handles displaying player's HP as hearts on the HUD
# Each heart represents 2 HP: full = 2, half = 1, empty = 0
class_name Hearts extends CanvasLayer

@export var max_hp := 6
var player

## Get the player node from the current scene and initialize hearts
func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	#update_hearts()


## Continuously update hearts every frame based on player's current HP
func _process(_delta: float) -> void:
	if player:
		update_hearts()


## Loop through all heart sprites in this container and update their state
func update_hearts():
	var current_hp = player.hp
	var hearts_container = get_child(0)  # zakładamy, że pierwsze dziecko to Control
	for i in range(hearts_container.get_child_count()):
		var heart = hearts_container.get_child(i) as Sprite2D
		if heart == null:
			continue
		
		var heart_index = (hearts_container.get_child_count() - 1 - i) * 2
		if current_hp >= heart_index + 2:
			heart.frame = 0
		elif current_hp == heart_index + 1:
			heart.frame = 1
		else:
			heart.frame = 2
