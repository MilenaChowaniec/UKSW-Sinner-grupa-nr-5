## Player state: stanind still
class_name State_Idle extends State

## Reference to the others states for quick transition
@onready var walk: State = $"../walk"
@onready var attack: State = $"../attack"
@onready var hit: State = $"../hit"
@onready var death: State = $"../death"


## Start idle animation when entering this state
func enter() -> void:
	player.update_animation("idle")


## Not required in this state
func exit() -> void:
	pass


## If the player presses movement, switch to walk state
func process(_delta : float) -> State:
	if player.got_hit == true:
		if player.hp == 0:
			return death
		player.got_hit = false
		player.update_animation("hit")
		player.velocity = Vector2.ZERO
	
	if player.direction != Vector2.ZERO:
		return walk
		
	player.velocity = Vector2.ZERO
	return null


## Not required in this state
func physics(_delta : float) -> State:
	return null


## Check if the player starts a new attack
func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null
