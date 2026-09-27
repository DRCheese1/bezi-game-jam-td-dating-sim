extends Node2D
class_name FloatingText

## Floating combat popup (damage numbers, currency gains).
## Set `message` and `color` before adding to the tree.

var message: String = ""
var color: Color = Color.WHITE

@onready var label: Label = $Label


func _ready() -> void:
	label.text = message
	label.modulate = color

	var rise: Vector2 = position + Vector2(randf_range(-3.0, 3.0), -18.0)
	var pop: Tween = create_tween()
	pop.set_parallel(true)
	pop.tween_property(self, "position", rise, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	pop.tween_property(self, "modulate:a", 0.0, 0.8).set_delay(0.25)
	pop.chain().tween_callback(queue_free)