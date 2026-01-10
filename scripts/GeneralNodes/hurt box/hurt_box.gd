class_name Hurt_Box extends Area2D

## ten kod zadaje obrazenia, gdy w poblizu ma obiekt typu hit box

@export var damage : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(areaEntered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func areaEntered(a : Area2D) -> void:
	if a is Hit_Box:
		a.take_damage(damage)
