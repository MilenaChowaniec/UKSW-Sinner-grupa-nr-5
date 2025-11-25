class_name Timer_Game extends Control

@export var start_time := 0.0
var elapsed_time := 0.0

@onready var timer_label: Label = $TimerLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	elapsed_time = start_time
	update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	update_label()


func update_label():
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	timer_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
