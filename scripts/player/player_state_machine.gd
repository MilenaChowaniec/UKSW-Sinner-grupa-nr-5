## Handles swtiching between different player state (idle, walk etc)
class_name PlayerStateMachine extends Node

var states : Array[State] ## All states 
var prev_state : State
var curr_state : State


## Disable processing until a state is set during initialization
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


## Let the active state run its logic each frame and check if it requests a state change
func _process(delta: float) -> void:
	change_state(curr_state.process(delta))


## Same as above, but for physics-based state behavior
func _physics_process(delta: float) -> void:
	change_state(curr_state.physics(delta))


## Pass input to the active state
func _unhandled_input(event: InputEvent) -> void:
	change_state(curr_state.handle_input(event))


## Find state nodes, attach player references, and set the default starting state
func initialize(_player : Player) -> void:
	states = []
	
	## Collect all children (nodes) that are valid states
	for c in get_children(): # get_children returns an array of nodes
		if c is State:
			states.append(c)
	
	## Activate the first state as the initial one
	if states.size() > 0:
		states[0].player = _player
		change_state(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT ## Enable processing again once the initial state is set


## Switch state to a new state if its different and valid
func change_state(new_state : State) -> void:
	if new_state == null || new_state == curr_state:
		return
	
	if curr_state:
		curr_state.exit()
	
	prev_state = curr_state
	curr_state = new_state
	
	curr_state.enter()
