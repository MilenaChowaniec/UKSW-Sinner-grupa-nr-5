class_name Player extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.RIGHT ## Direction of player (for animations)
var direction : Vector2 = Vector2.ZERO ## Input direction from keyboard
var hp = 6
var got_hit = false

## References to key child nodes
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine


## Initialize the state machine and pass this player to it
func _ready() -> void:
	state_machine.initialize(self)
	$Interactions/HitBox.damaged.connect(take_damage)

func take_damage(_damage : int) -> void:
	got_hit = true
	
## Check input each frame and update movement direction
func _process(_delta: float) -> void:
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")


## Handle physics (built-in function)
func _physics_process(_delta: float) -> void:
	move_and_slide()


## Decide if the facing direction should change based on movements
## Returns true if the direction changed
func set_direction() -> bool:
	var new_dir : Vector2 = cardinal_direction
	
	# No input - direction stays the same
	if direction == Vector2.ZERO:
		return false
	
	if direction.x != 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	# If direction didnt change - do nothing
	if new_dir == cardinal_direction:
		return false
		
	cardinal_direction = new_dir
	return true


## Play animation using current state (walk, idle, etc) and facing direction (left, right, etc)
func update_animation(state : String) -> void:
	animation_player.play(state + "_" + animation_direction())
	pass


## Convert facing direction to a string used in animation naming
func animation_direction() -> String:
	if cardinal_direction == Vector2.LEFT:
		return "left"
	else:
		return "right"
