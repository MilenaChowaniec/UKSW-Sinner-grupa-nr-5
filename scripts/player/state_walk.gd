## Player state: moving while input direction is active
class_name State_Walk extends State

@export var move_speed : float = 100.0

## Reference to the other states
@onready var idle: State = $"../idle"
@onready var attack: State = $"../attack"
@onready var hit: State = $"../hit"
@onready var death: State = $"../death"


## Start walking animation when entering this state
func enter() -> void:
	player.update_animation("walk")
	pass


## Not required in this state
func exit() -> void:
	pass


## Move the player if theres input, otherwise return to idle state
## Update facing direction and animation when direction changes
func process(_delta : float) -> State:
	#if player.got_hit == true:
		#if player.hp == 0:
			#return death
		#player.got_hit = false
		#player.update_animation("hit")
		
	if player.direction == Vector2.ZERO:
		return idle
	
	player.velocity = player.direction.normalized() * move_speed
	
	if player.set_direction():
		player.update_animation("walk")
	
	return null


## Not required in this state
func physics(_delta : float) -> State:
	return null


## Check if the player starts a new attack
func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null
