extends Area2D

var speed: float = 200.0
var direction: Vector2 = Vector2.RIGHT
var damage: int = 10

func _ready():
	# Automatycznie usuń pocisk po 3 sekundach
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		activate_player_hit_state(body)
		queue_free()
	elif not body.is_in_group("enemy"):
		queue_free()

func activate_player_hit_state(player_node):
	var state_machine = player_node.find_child("StateMachine")
	if state_machine:
		if state_machine.has_method("transition_to"):
			state_machine.transition_to("Hit")
		elif state_machine.has_method("change_state"):
			state_machine.change_state("Hit")
		elif state_machine.has_method("set_state"):
			state_machine.set_state("Hit")
		elif state_machine.has_method("hit"):
			state_machine.hit()
