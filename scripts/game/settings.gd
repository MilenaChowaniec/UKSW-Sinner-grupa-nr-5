extends Node2D
	
func _on_fullscreen_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_window_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/main_menu.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(0, db) # 0 = Master

func _input(event):
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
