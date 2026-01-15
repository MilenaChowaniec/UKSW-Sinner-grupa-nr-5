extends Node2D
##Klasa odpowiadająca za odsługe menu głównego w grze.
class_name MainMenu

##Funkcja wywoływana po naciśnięciu przycisku Start. Przenosi gracza do ekranu rozgrywki.
func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn") # Replace with function body.

##Funkcja wywoływana po naciśnięciu przycisku Continue. Przenosi gracza do ekranu rozgrywki wcześniej rozpoczętej i zapisanej rozgrywki.
func _on_continue_pressed() -> void:
	pass # Replace with function body.

##Funkcja wywoływana po naciśnięciu przycisku ustawień. Przenosi gracza do ekranu wyboru ustawień rozgrywki.
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/settings.tscn")

##Funkcja wywoływana po naciśnięciu przycisku Exit. Kończy działanie programu.
func _on_exit_pressed() -> void:
	get_tree().quit() # Replace with function body.


func _input(event):
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
