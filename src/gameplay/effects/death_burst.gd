extends GPUParticles2D

## One-shot particle pop that cleans itself up once it has finished.
## Parent it to an effect root at the death position.

func _ready() -> void:
	emitting = true
	await get_tree().create_timer(lifetime + 0.25).timeout
	queue_free()