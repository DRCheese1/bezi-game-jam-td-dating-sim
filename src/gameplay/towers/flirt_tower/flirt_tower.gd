extends BaseTower

var multishot: int = 1

func _attack():
	targets = targets.filter(func(t): return is_instance_valid(t))
	
	if targets.is_empty():
		return
	
	var selected_targets: Array[BaseEnemy] = _choose_targets()
	for target in selected_targets:
		if target.has_method("take_damage"):
			target.take_damage(damage)
	
	can_attack = false
	attack_timer.start()

func _choose_targets() -> Array[BaseEnemy]:
	var sorted_targets: Array[BaseEnemy] = targets.duplicate()
	sorted_targets.sort_custom(func(a, b): return a.distance > b.distance)
	
	var chosen: Array[BaseEnemy] = []
	var count: int = min(multishot, sorted_targets.size())
	
	for i in range(count):
		chosen.append(sorted_targets[i])
	
	return chosen
