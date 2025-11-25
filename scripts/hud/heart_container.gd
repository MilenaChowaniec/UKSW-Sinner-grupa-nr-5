# Handles displaying player's HP as hearts on the HUD
# Each heart represents 2 HP: full = 2, half = 1, empty = 0
class_name Hearts extends HBoxContainer

@export var max_hp := 6
var player

## Get the player node from the current scene and initialize hearts
func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	update_hearts()


## Continuously update hearts every frame based on player's current HP
func _process(_delta: float) -> void:
	if player:
		update_hearts()


## Loop through all heart sprites in this container and update their state
func update_hearts():
	var current_hp = player.hp
	
	for i in range(get_child_count()):
		var heart = get_child(i) as Sprite2D
		var heart_index = (get_child_count() - 1 - i) * 2  # right to left
		if current_hp >= heart_index + 2:
			heart.frame = 0  # full heart
		elif current_hp == heart_index + 1:
			heart.frame = 1  # half heart
		else:
			heart.frame = 2  # empty heart
