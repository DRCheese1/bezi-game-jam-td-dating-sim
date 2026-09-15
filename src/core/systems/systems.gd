extends Node
class_name System

@export var system_name: String

func _ready() -> void:
	GameManager.register_system(system_name, self)
