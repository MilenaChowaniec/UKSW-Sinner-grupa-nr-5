class_name State_Death extends State

var dying : bool = false

## Reference to AnimationPlayer to detect when the attack animation finishes
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"


## Start death animation when entering this state
func enter() -> void:
	dying = true
	player.update_animation("death")
	print("death")
	animation_player.animation_finished.connect(end_death)


## Disconnects animation signal
func exit() -> void:
	# tu musi byc ze koniec gry, odnosienie do menu po smierci
	pass


## Not required in this state
func process(_delta : float) -> State:
	player.velocity = Vector2.ZERO
	return null

## Callback triggered when death animation finishes
func end_death(_new_anim : String) -> void:
	dying = false


## Not required in this state
func physics(_delta : float) -> State:
	return null

## Not required in this state
func handle_input(_event: InputEvent) -> State:
	return null
