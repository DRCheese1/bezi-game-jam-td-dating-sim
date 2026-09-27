extends Control

func show_ui():
	visible = true


func _on_restart_button_pressed() -> void:
	GameManager.reset_gamemanager()
	await get_tree().process_frame
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	Utilities.quit_game(self)
