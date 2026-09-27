extends Control

@onready var death_ui: Control = $DeathUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.show_death_ui.connect(on_death)

func on_death() -> void:
	death_ui.show_ui()
