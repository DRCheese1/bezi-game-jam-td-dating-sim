extends Path2D

func _ready() -> void:
	var wave_system: System = GameManager.access_system(SystemNames.WAVE_SPAWNER)
	wave_system.path_2d = self
