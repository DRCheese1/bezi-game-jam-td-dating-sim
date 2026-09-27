extends Control


func _ready() -> void:
	if not OS.is_debug_build():
		self.queue_free()


func toggle_debug_layer():
	visible = not visible
