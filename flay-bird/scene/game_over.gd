extends CanvasLayer

signal restart

func _on_restart_button_pressed() -> void:
	restart.emit()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
