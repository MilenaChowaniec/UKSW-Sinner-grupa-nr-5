## Player state: stanind still
class_name State_Idle extends State

## Reference to the walk state for quick transition
@onready var walk: State = $"../walk"


## Start idle animation when entering this state
func enter() -> void:
	player.update_animation("idle")


## Not required in this state
func exit() -> void:
	pass


## If the player presses movement, switch to walk state
func process(_delta : float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
		
	player.velocity = Vector2.ZERO
	return null


## Not required in this state
func physics(_delta : float) -> State:
	return null


## Not required in this state
func handle_input(_event: InputEvent) -> State:
	return null
