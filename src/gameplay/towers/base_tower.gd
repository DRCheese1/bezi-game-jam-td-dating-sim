extends Area2D

@export var damage: float = 10.0
@export var fire_rate: float = 1.0

var targets: Array[Area2D] = []

@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
	attack_timer.wait_time = fire_rate
	attack_timer.start()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		targets.append(area)


func _on_area_exited(area: Area2D) -> void:
	targets.erase(area)


func _on_attack_timer_timeout() -> void:
	targets = targets.filter(func(t): return is_instance_valid(t))
	
	if targets.is_empty():
		attack_timer.start()
		return
	
	var target: Area2D = choose_target()
	if target.has_method("take_damage"):
		target.take_damage(damage)


func choose_target() -> Area2D:
	var best = targets[0]
	for t in targets:
		if t.distance > best.distance:
			best = t
	return best
