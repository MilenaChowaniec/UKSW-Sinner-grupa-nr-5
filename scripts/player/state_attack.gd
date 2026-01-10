## Player state: attacking
class_name State_Attack extends State

var attacking : bool = false

@export_range(1,20,0.5) var decelerate_speed : float = 5.0

## Reference to AnimationPlayer to detect when the attack animation finishes
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

## Reference gun point 
@onready var gun_point_right: Node2D = $"../../GunPointRight"
@onready var gun_point_left: Node2D = $"../../GunPointLeft"


## Reference to the other states so we can transition
@onready var walk: State = $"../walk"
@onready var idle: State = $"../idle"
@onready var hit: State = $"../hit"


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


## Player cant move while attacking (for now)
func process(_delta : float) -> State:
	if player.got_hit == true:
		player.got_hit = false
		return hit
	
	player.velocity -= player.velocity * decelerate_speed * _delta
	
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
	var bullet_scene = preload("res://scenes/player/bullet.tscn")
	var bullet_ = bullet_scene.instantiate()
	
	# Set bullet start position at player
	if player.cardinal_direction == Vector2.RIGHT:
		bullet_.global_position = gun_point_right.global_position
	else:
		bullet_.global_position = gun_point_left.global_position
	
	bullet_.start_position = bullet_.global_position
	
	# Calculate direction towards mouse
	var mouse_pos = player.get_global_mouse_position()
	bullet_.direction = (mouse_pos - bullet_.global_position).normalized()
	
	bullet_.scale = player.scale
	
	# Add bullet to current scene
	get_tree().current_scene.add_child(bullet_)


## Not required in this state
func handle_input(_event: InputEvent) -> State:
	return null


## Callback triggered when AnimationPlayer finishes the attack animation
func end_attack(_new_anim_state : String) -> void:
	attacking = false
