## Player state: attacking
class_name State_Attack extends State

var attacking : bool = false

## Reference to AnimationPlayer to detect when the attack animation finishes
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

## Reference to the other states so we can transition
@onready var walk: State = $"../walk"
@onready var idle: State = $"../idle"


## Start attacking animation when entering this state
func enter() -> void:
	player.update_animation("attack")
	# Connect the callback so we know when the animation ends
	animation_player.animation_finished.connect(end_attack) 
	attacking = true
	
	spawn_bullet()


## Called when leaving state - disconnect signal and allow transition to other states
func exit() -> void:
	animation_player.animation_finished.disconnect(end_attack)
	attacking = false
	pass


## Player cant move while attacking (for now)
func process(_delta : float) -> State:
	# Stop player movement if no input
	if player.direction == Vector2.ZERO:
		player.velocity = Vector2.ZERO
	
	# Once the animation is finished, switch the transition
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null


## Not required in this state
func physics(_delta : float) -> State:
	return null

## Spawn a bullet in the direction of the mouse
func spawn_bullet():
	var bullet_scene = preload("res://scenes/bullet.tscn")
	var bullet_ = bullet_scene.instantiate()
	
	# Set bullet start position at player
	bullet_.global_position = player.global_position
	bullet_.start_position = player.global_position
	
	# Calculate direction towards mouse
	var mouse_pos = player.get_global_mouse_position()
	bullet_.direction = (mouse_pos - player.global_position).normalized()
	
	# Add bullet to current scene
	get_tree().current_scene.add_child(bullet_)


## Not required in this state
func handle_input(_event: InputEvent) -> State:
	return null


## Callback triggered when AnimationPlayer finishes the attack animation
func end_attack(_new_anim_state : String) -> void:
	attacking = false
