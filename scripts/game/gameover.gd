##Klasa GameOver obsługuje ekran ponownego rozpoczęcia rozgrywki.
class_name GameOver extends Node2D

##Funkcja uruchamiana po naciśnięciu przycisku restart. Włącza rozgrywkę od nowa.
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _input(event):
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
