class_name State_Hit extends State

var being_hit : bool = false

## Reference to AnimationPlayer to detect when the attack animation finishes
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

## Reference to the other states so we can transition
@onready var walk: State = $"../walk"
@onready var idle: State = $"../idle"
@onready var death: State_Death = $"../death"


## Reduce player HP by 1 and check if the player is alive
func enter() -> void:
	player.hp -=1
	
	# If player is still alive, play hit animation and connect callback
	if player.hp > 0:
		player.update_animation("hit")
		animation_player.animation_finished.connect(end_hit)
	being_hit = true


## What happens when player exits this state?
func exit() -> void:
	animation_player.animation_finished.disconnect(end_hit)
	being_hit = false


## If player has 0 HP, call death, otherwise idle or walk
func process(_delta : float) -> State:
	player.velocity = Vector2.ZERO
	if player.hp == 0:
		return death
		
	if being_hit == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null


## Marks player as no longer being hit
func end_hit(_new_anim : String) -> void:
	being_hit = false


## Not required in this state
func physics(_delta : float) -> State:
	return null


## Not required in this state
func handle_input(_event: InputEvent) -> State:
	return null
