extends Node2D

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	if err == OK:
		var value = config.get_value("audio", "master_volume", 100.0)
		$HSlider.value = value

		var db = linear_to_db(value / 100.0)
		AudioServer.set_bus_volume_db(0, db)

func _on_fullscreen_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_window_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/main_menu.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(0, db)

	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", value)
	config.save("user://settings.cfg")

func _input(event):
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
